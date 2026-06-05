#!/usr/bin/env bash
# GitHub API'den stats.svg + top-langs.svg uret (TokyoNight tema).
# cache-svgs.yml workflow'undan cagrilir.

set -euo pipefail

USERNAME="${1:-merbay-erp}"
OUT_DIR="${2:-svg-cache}"
GH_TOKEN="${GH_TOKEN:?GH_TOKEN env var required}"

mkdir -p "$OUT_DIR"

AUTH="Authorization: token $GH_TOKEN"

# Fetch user data
USER_JSON=$(curl -fsS -H "$AUTH" "https://api.github.com/users/$USERNAME")
PUBLIC_REPOS=$(echo "$USER_JSON" | jq -r '.public_repos // 0')
FOLLOWERS=$(echo "$USER_JSON" | jq -r '.followers // 0')

# Fetch all repos (own, not forks)
REPOS_JSON=$(curl -fsS -H "$AUTH" "https://api.github.com/users/$USERNAME/repos?per_page=100&type=owner")
TOTAL_STARS=$(echo "$REPOS_JSON" | jq '[.[] | select(.fork == false) | .stargazers_count] | add // 0')

# Commits via GraphQL (much more accurate than search API)
GQL_QUERY=$(cat <<GQL
{
  user(login: "$USERNAME") {
    contributionsCollection {
      totalCommitContributions
      restrictedContributionsCount
    }
    repositories(first: 100, ownerAffiliations: OWNER, isFork: false) {
      nodes {
        defaultBranchRef {
          target {
            ... on Commit {
              history {
                totalCount
              }
            }
          }
        }
      }
    }
  }
}
GQL
)
GQL_PAYLOAD=$(jq -nc --arg q "$GQL_QUERY" '{query: $q}')
GQL_RESPONSE=$(curl -fsS -H "$AUTH" -H "Content-Type: application/json" -X POST -d "$GQL_PAYLOAD" "https://api.github.com/graphql" || echo '{}')

# Sum commits across all repos (accurate)
REPO_COMMITS=$(echo "$GQL_RESPONSE" | jq '[.data.user.repositories.nodes[]?.defaultBranchRef?.target?.history?.totalCount // 0] | add // 0')
LAST_YEAR_CONTRIB=$(echo "$GQL_RESPONSE" | jq '.data.user.contributionsCollection.totalCommitContributions // 0')
TOTAL_COMMITS=${REPO_COMMITS:-0}
echo "GraphQL: repo_commits=$REPO_COMMITS last_year_contrib=$LAST_YEAR_CONTRIB"

PRS_JSON=$(curl -fsS -H "$AUTH" "https://api.github.com/search/issues?q=author:$USERNAME+is:pr&per_page=1")
TOTAL_PRS=$(echo "$PRS_JSON" | jq -r '.total_count // 0')

ISSUES_JSON=$(curl -fsS -H "$AUTH" "https://api.github.com/search/issues?q=author:$USERNAME+is:issue&per_page=1")
TOTAL_ISSUES=$(echo "$ISSUES_JSON" | jq -r '.total_count // 0')

echo "Stats: stars=$TOTAL_STARS commits=$TOTAL_COMMITS prs=$TOTAL_PRS issues=$TOTAL_ISSUES followers=$FOLLOWERS repos=$PUBLIC_REPOS"

# Compute rank
SCORE=$(awk -v s=$TOTAL_STARS -v c=$TOTAL_COMMITS -v p=$TOTAL_PRS -v i=$TOTAL_ISSUES -v f=$FOLLOWERS \
  'BEGIN { print int(s*4 + c*1 + p*0.5 + i*0.5 + f*1) }')
if   [ "$SCORE" -gt 5000 ]; then RANK="A+"; RANK_PCT=98
elif [ "$SCORE" -gt 2000 ]; then RANK="A";  RANK_PCT=92
elif [ "$SCORE" -gt 500 ];  then RANK="B+"; RANK_PCT=75
elif [ "$SCORE" -gt 100 ];  then RANK="B";  RANK_PCT=60
else RANK="C"; RANK_PCT=40
fi

# TokyoNight palette
BG="#1a1b27"
TITLE="#70a5fd"
ICON="#bf91f3"
TEXT="#a9b1d6"
RANK_C="#38bdae"

DASH=$(awk -v p=$RANK_PCT 'BEGIN { printf "%.0f", p * 2.83 }')

cat > "$OUT_DIR/stats.svg" <<SVGEOF
<svg xmlns="http://www.w3.org/2000/svg" width="500" height="195" viewBox="0 0 500 195" fill="none" role="img" aria-label="GitHub Stats">
  <style>
    .header { font: 600 18px 'Segoe UI', Ubuntu, Sans-Serif; fill: ${TITLE}; }
    .stat { font: 600 14px 'Segoe UI', Ubuntu, Sans-Serif; fill: ${TEXT}; }
    .label { font: 600 14px 'Segoe UI', Ubuntu, Sans-Serif; fill: ${ICON}; }
    .rank-text { font: 800 24px 'Segoe UI', Ubuntu, Sans-Serif; fill: ${RANK_C}; }
    .rank-pct { font: 400 11px 'Segoe UI', Ubuntu, Sans-Serif; fill: ${TEXT}; }
  </style>
  <rect width="500" height="195" rx="6" fill="${BG}"/>
  <text x="25" y="35" class="header">Mustafa Erbay's GitHub Stats</text>

  <g transform="translate(25, 60)">
    <text x="0" y="0"   class="label">★</text><text x="22" y="0"   class="stat">Total Stars Earned:</text><text x="320" y="0"   class="stat" text-anchor="end">${TOTAL_STARS}</text>
    <text x="0" y="25"  class="label">⬆</text><text x="22" y="25"  class="stat">Total Commits:</text><text x="320" y="25"  class="stat" text-anchor="end">${TOTAL_COMMITS}</text>
    <text x="0" y="50"  class="label">⇄</text><text x="22" y="50"  class="stat">Last Year Contributions:</text><text x="320" y="50"  class="stat" text-anchor="end">${LAST_YEAR_CONTRIB}</text>
    <text x="0" y="75"  class="label">◉</text><text x="22" y="75"  class="stat">Public Repos:</text><text x="320" y="75"  class="stat" text-anchor="end">${PUBLIC_REPOS}</text>
    <text x="0" y="100" class="label">▲</text><text x="22" y="100" class="stat">Followers:</text><text x="320" y="100" class="stat" text-anchor="end">${FOLLOWERS}</text>
  </g>

  <g transform="translate(420, 100)">
    <circle cx="0" cy="0" r="45" fill="none" stroke="#2c2f3e" stroke-width="6"/>
    <circle cx="0" cy="0" r="45" fill="none" stroke="${RANK_C}" stroke-width="6" stroke-dasharray="${DASH} 283" stroke-dashoffset="0" stroke-linecap="round" transform="rotate(-90)"/>
    <text x="0" y="2" text-anchor="middle" class="rank-text">${RANK}</text>
    <text x="0" y="20" text-anchor="middle" class="rank-pct">${RANK_PCT}%</text>
  </g>
</svg>
SVGEOF
echo "✓ stats.svg generated"

# ---------- Top Languages ----------
LANGS_RAW="{}"
for repo in $(echo "$REPOS_JSON" | jq -r '.[] | select(.fork == false) | .name'); do
  R=$(curl -fsS -H "$AUTH" "https://api.github.com/repos/$USERNAME/$repo/languages" 2>/dev/null || echo '{}')
  LANGS_RAW=$(jq -s 'add // {}' <(echo "$LANGS_RAW") <(echo "$R"))
done

# Sort top 8
LANGS_ARR=$(echo "$LANGS_RAW" | jq -c 'to_entries | sort_by(-.value) | .[:8]')
TOTAL=$(echo "$LANGS_ARR" | jq '[.[].value] | add // 1')
COUNT=$(echo "$LANGS_ARR" | jq 'length')
echo "Top langs total bytes: $TOTAL ($COUNT langs)"

color_for() {
  case "$1" in
    "TypeScript") echo "#3178c6" ;;
    "JavaScript") echo "#f1e05a" ;;
    "Astro")      echo "#ff5d01" ;;
    "Python")     echo "#3572A5" ;;
    "Shell")      echo "#89e051" ;;
    "HTML")       echo "#e34c26" ;;
    "CSS")        echo "#563d7c" ;;
    "SCSS")       echo "#c6538c" ;;
    "MDX")        echo "#fcb32c" ;;
    "Vue")        echo "#41b883" ;;
    "Go")         echo "#00ADD8" ;;
    "Rust")       echo "#dea584" ;;
    "Java")       echo "#b07219" ;;
    "C")          echo "#555555" ;;
    "C++")        echo "#f34b7d" ;;
    "Ruby")       echo "#701516" ;;
    "PHP")        echo "#4F5D95" ;;
    "YAML")       echo "#cb171e" ;;
    "Dockerfile") echo "#384d54" ;;
    "Makefile")   echo "#427819" ;;
    "JSON")       echo "#292929" ;;
    *)            echo "#888888" ;;
  esac
}

# Build bars
BARS=""
IDX=0
while read -r LANG_LINE; do
  NAME=$(echo "$LANG_LINE" | jq -r .key)
  BYTES=$(echo "$LANG_LINE" | jq -r .value)
  PCT=$(awk -v b=$BYTES -v t=$TOTAL 'BEGIN { printf "%.1f", b*100/t }')
  COLOR=$(color_for "$NAME")
  COL=$((IDX % 2))
  ROW=$((IDX / 2))
  X=$((25 + COL * 280))
  YPOS=$((70 + ROW * 28))
  BARS+="<g transform=\"translate($X, $YPOS)\"><circle cx=\"5\" cy=\"-5\" r=\"5\" fill=\"$COLOR\"/><text x=\"18\" y=\"0\" class=\"lang\">$NAME</text><text x=\"230\" y=\"0\" text-anchor=\"end\" class=\"pct\">${PCT}%</text></g>"$'\n  '
  IDX=$((IDX + 1))
done < <(echo "$LANGS_ARR" | jq -c '.[]')

ROWS=$(( (IDX + 1) / 2 ))
HEIGHT=$((70 + ROWS * 28 + 20))

cat > "$OUT_DIR/top-langs.svg" <<SVGEOF
<svg xmlns="http://www.w3.org/2000/svg" width="600" height="${HEIGHT}" viewBox="0 0 600 ${HEIGHT}" fill="none" role="img" aria-label="Most Used Languages">
  <style>
    .header { font: 600 18px 'Segoe UI', Ubuntu, Sans-Serif; fill: ${TITLE}; }
    .lang { font: 400 13px 'Segoe UI', Ubuntu, Sans-Serif; fill: ${TEXT}; }
    .pct  { font: 400 13px 'Segoe UI', Ubuntu, Sans-Serif; fill: ${TEXT}; }
  </style>
  <rect width="600" height="${HEIGHT}" rx="6" fill="${BG}"/>
  <text x="25" y="35" class="header">Most Used Languages</text>
  ${BARS}
</svg>
SVGEOF
echo "✓ top-langs.svg generated ($IDX langs, ${HEIGHT}px high)"

# ---------- Trophies (self-hosted) ----------
# github-profile-trophy.vercel.app ÖLDÜ (HTTP 402 DEPLOYMENT_DISABLED — Vercel
# deployment'ı kapattı). Kendi üretiyoruz: GitHub API verisinden, bir daha ASLA
# kırılmaz. 7 rozet (orijinal trophy paramları row=1 column=7), TokyoNight tema.

# value + S/A/B/C eşikleri → "RANK|COLOR"
trophy_rank() {
  local v="$1" s="$2" a="$3" b="$4" c="$5"
  if   [ "$v" -ge "$s" ]; then printf 'S|#fbbf24'
  elif [ "$v" -ge "$a" ]; then printf 'A|#bf91f3'
  elif [ "$v" -ge "$b" ]; then printf 'B|#70a5fd'
  elif [ "$v" -ge "$c" ]; then printf 'C|#38bdae'
  else printf '?|#565f89'
  fi
}

# Experience rozeti için genel rank rengi
case "$RANK" in
  "A+"|"A") EXP_COLOR="#fbbf24" ;;
  "B+"|"B") EXP_COLOR="#70a5fd" ;;
  *)        EXP_COLOR="#38bdae" ;;
esac

# Satır formatı: SEMBOL|BAŞLIK|DEĞER|RANK|RENK  (ilk 6 rozetin RANK|RENK'i trophy_rank'ten)
TROPHY_DATA=$(cat <<DATA
★|Stars|${TOTAL_STARS}|$(trophy_rank "$TOTAL_STARS" 100 30 10 1)
⬆|Commits|${TOTAL_COMMITS}|$(trophy_rank "$TOTAL_COMMITS" 1000 300 100 1)
▲|Followers|${FOLLOWERS}|$(trophy_rank "$FOLLOWERS" 100 30 10 1)
◉|Repos|${PUBLIC_REPOS}|$(trophy_rank "$PUBLIC_REPOS" 50 20 10 1)
⇄|Pull Reqs|${TOTAL_PRS}|$(trophy_rank "$TOTAL_PRS" 100 30 10 1)
◎|Issues|${TOTAL_ISSUES}|$(trophy_rank "$TOTAL_ISSUES" 100 30 10 1)
♦|Experience|${RANK_PCT}%|${RANK}|${EXP_COLOR}
DATA
)

TROPHY_CARDS=""
i=0
while IFS='|' read -r SYM NAME VAL RK COL; do
  if [ -z "$SYM" ]; then continue; fi
  X=$((i * 120))
  TROPHY_CARDS+="<g transform=\"translate($X,0)\">"
  TROPHY_CARDS+="<rect x=\"2\" y=\"2\" width=\"110\" height=\"106\" rx=\"10\" fill=\"#1a1b27\" stroke=\"#2c2f3e\" stroke-width=\"1\"/>"
  TROPHY_CARDS+="<text x=\"57\" y=\"33\" text-anchor=\"middle\" class=\"t-sym\" fill=\"${COL}\">${SYM}</text>"
  TROPHY_CARDS+="<text x=\"57\" y=\"65\" text-anchor=\"middle\" class=\"t-rank\" fill=\"${COL}\">${RK}</text>"
  TROPHY_CARDS+="<text x=\"57\" y=\"84\" text-anchor=\"middle\" class=\"t-name\">${NAME}</text>"
  TROPHY_CARDS+="<text x=\"57\" y=\"100\" text-anchor=\"middle\" class=\"t-val\">${VAL}</text>"
  TROPHY_CARDS+="</g>"
  i=$((i + 1))
done <<< "$TROPHY_DATA"

cat > "$OUT_DIR/trophies.svg" <<SVGEOF
<svg xmlns="http://www.w3.org/2000/svg" width="834" height="112" viewBox="0 0 834 112" fill="none" role="img" aria-label="GitHub Trophies">
  <style>
    .t-sym  { font: 400 20px 'Segoe UI Symbol','Segoe UI', Ubuntu, Sans-Serif; }
    .t-rank { font: 800 26px 'Segoe UI', Ubuntu, Sans-Serif; }
    .t-name { font: 600 12px 'Segoe UI', Ubuntu, Sans-Serif; fill: ${TITLE}; }
    .t-val  { font: 400 11px 'Segoe UI', Ubuntu, Sans-Serif; fill: ${TEXT}; }
  </style>
  ${TROPHY_CARDS}
</svg>
SVGEOF
echo "✓ trophies.svg generated"
