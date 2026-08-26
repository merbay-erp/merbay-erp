#!/usr/bin/env bash

set -euo pipefail

USERNAME="${1:-merbay-erp}"
OUT_DIR="${2:-svg-cache}"
GH_TOKEN="${GH_TOKEN:?GH_TOKEN env var required}"

mkdir -p "$OUT_DIR"

AUTH="Authorization: Bearer $GH_TOKEN"
USER_JSON=$(curl -fsS -H "$AUTH" "https://api.github.com/users/$USERNAME")
REPOS_JSON=$(curl -fsS -H "$AUTH" "https://api.github.com/users/$USERNAME/repos?per_page=100&type=owner")

PUBLIC_REPOS=$(jq -r '.public_repos // 0' <<<"$USER_JSON")
FOLLOWERS=$(jq -r '.followers // 0' <<<"$USER_JSON")
TOTAL_STARS=$(jq '[.[] | select(.fork == false) | .stargazers_count] | add // 0' <<<"$REPOS_JSON")

GQL_QUERY=$(cat <<GQL
{
  user(login: "$USERNAME") {
    contributionsCollection {
      totalCommitContributions
    }
    repositories(first: 100, ownerAffiliations: OWNER, isFork: false) {
      nodes {
        defaultBranchRef {
          target {
            ... on Commit {
              history { totalCount }
            }
          }
        }
      }
    }
  }
}
GQL
)
GQL_PAYLOAD=$(jq -nc --arg query "$GQL_QUERY" '{query: $query}')
GQL_RESPONSE=$(curl -fsS -H "$AUTH" -H "Content-Type: application/json" -X POST -d "$GQL_PAYLOAD" "https://api.github.com/graphql" || printf '{}')

TOTAL_COMMITS=$(jq '[.data.user.repositories.nodes[]?.defaultBranchRef?.target?.history?.totalCount // 0] | add // 0' <<<"$GQL_RESPONSE")
LAST_YEAR_CONTRIB=$(jq '.data.user.contributionsCollection.totalCommitContributions // 0' <<<"$GQL_RESPONSE")
TOTAL_PRS=$(curl -fsS -H "$AUTH" "https://api.github.com/search/issues?q=author:$USERNAME+is:pr&per_page=1" | jq -r '.total_count // 0')
TOTAL_ISSUES=$(curl -fsS -H "$AUTH" "https://api.github.com/search/issues?q=author:$USERNAME+is:issue&per_page=1" | jq -r '.total_count // 0')

LANGS_RAW='{}'
while IFS= read -r repo; do
  repo_langs=$(curl -fsS -H "$AUTH" "https://api.github.com/repos/$USERNAME/$repo/languages" 2>/dev/null || printf '{}')
  LANGS_RAW=$(jq -s 'add // {}' <(printf '%s' "$LANGS_RAW") <(printf '%s' "$repo_langs"))
done < <(jq -r '.[] | select(.fork == false) | .name' <<<"$REPOS_JSON")

LANGS_ARR=$(jq -c 'to_entries | sort_by(-.value) | .[:5]' <<<"$LANGS_RAW")
LANGS_TOTAL=$(jq '[to_entries[].value] | add // 1' <<<"$LANGS_RAW")

language_color() {
  case "$1" in
    Rust) echo '#dea584' ;;
    TypeScript) echo '#3178c6' ;;
    JavaScript) echo '#f1e05a' ;;
    PLpgSQL) echo '#336790' ;;
    C) echo '#a8b9cc' ;;
    HTML) echo '#e34c26' ;;
    CSS) echo '#663399' ;;
    Dockerfile) echo '#2496ed' ;;
    Shell) echo '#89e051' ;;
    *) echo '#8b949e' ;;
  esac
}

LANG_ROWS=''
row=0
while IFS= read -r item; do
  name=$(jq -r '.key' <<<"$item")
  bytes=$(jq -r '.value' <<<"$item")
  pct=$(awk -v bytes="$bytes" -v total="$LANGS_TOTAL" 'BEGIN { printf "%.1f", bytes * 100 / total }')
  width=$(awk -v pct="$pct" 'BEGIN { printf "%.0f", pct * 3.65 }')
  color=$(language_color "$name")
  y=$((300 + row * 38))
  LANG_ROWS+="<text x=\"615\" y=\"$y\" class=\"label\">$name</text>"
  LANG_ROWS+="<rect x=\"760\" y=\"$((y - 13))\" width=\"365\" height=\"10\" rx=\"5\" fill=\"#21283a\"/>"
  LANG_ROWS+="<rect x=\"760\" y=\"$((y - 13))\" width=\"$width\" height=\"10\" rx=\"5\" fill=\"$color\"/>"
  LANG_ROWS+="<text x=\"1140\" y=\"$y\" class=\"value-small\" text-anchor=\"end\">${pct}%</text>"
  row=$((row + 1))
done < <(jq -c '.[]' <<<"$LANGS_ARR")

cat > "$OUT_DIR/hero.svg" <<'SVG'
<svg xmlns="http://www.w3.org/2000/svg" width="1200" height="360" viewBox="0 0 1200 360" role="img" aria-label="Mustafa Erbay — systems architect, infrastructure engineer and indie hacker">
  <defs>
    <linearGradient id="bg" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="#07111f"/>
      <stop offset="0.55" stop-color="#0b1730"/>
      <stop offset="1" stop-color="#071c29"/>
    </linearGradient>
    <linearGradient id="accent" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0" stop-color="#22d3ee"/>
      <stop offset="0.5" stop-color="#3b82f6"/>
      <stop offset="1" stop-color="#8b5cf6"/>
    </linearGradient>
    <radialGradient id="glow" cx="50%" cy="50%" r="50%">
      <stop offset="0" stop-color="#2563eb" stop-opacity=".35"/>
      <stop offset="1" stop-color="#2563eb" stop-opacity="0"/>
    </radialGradient>
    <pattern id="grid" width="32" height="32" patternUnits="userSpaceOnUse">
      <path d="M32 0H0V32" fill="none" stroke="#60a5fa" stroke-opacity=".07"/>
    </pattern>
    <filter id="softGlow" x="-50%" y="-50%" width="200%" height="200%">
      <feGaussianBlur stdDeviation="5" result="blur"/>
      <feMerge><feMergeNode in="blur"/><feMergeNode in="SourceGraphic"/></feMerge>
    </filter>
  </defs>
  <style>
    .kicker{font:700 13px ui-monospace,SFMono-Regular,Menlo,monospace;letter-spacing:3px;fill:#67e8f9}
    .name{font:800 62px Inter,Segoe UI,Arial,sans-serif;letter-spacing:-2px;fill:#f8fafc}
    .role{font:600 17px Inter,Segoe UI,Arial,sans-serif;letter-spacing:.6px;fill:#cbd5e1}
    .copy{font:400 15px Inter,Segoe UI,Arial,sans-serif;fill:#94a3b8}
    .terminal{font:600 14px ui-monospace,SFMono-Regular,Menlo,monospace;fill:#dbeafe}
    .prompt{fill:#22d3ee}
    .answer{fill:#a7f3d0}
    .chip{font:700 11px ui-monospace,SFMono-Regular,Menlo,monospace;letter-spacing:.7px;fill:#dbeafe}
    @keyframes pulse{0%,100%{opacity:.35}50%{opacity:1}}
    @keyframes scan{0%{transform:translateY(-30px)}100%{transform:translateY(390px)}}
    .pulse{animation:pulse 2.4s ease-in-out infinite}
    .scan{animation:scan 6s linear infinite}
    @media (prefers-reduced-motion:reduce){.pulse,.scan{animation:none}}
  </style>
  <rect width="1200" height="360" rx="22" fill="url(#bg)"/>
  <rect width="1200" height="360" rx="22" fill="url(#grid)"/>
  <ellipse cx="330" cy="180" rx="430" ry="300" fill="url(#glow)"/>
  <rect class="scan" x="0" y="0" width="1200" height="1" fill="url(#accent)" opacity=".24"/>
  <rect x="1" y="1" width="1198" height="358" rx="21" fill="none" stroke="url(#accent)" stroke-opacity=".5"/>

  <g transform="translate(66 58)">
    <circle cx="7" cy="-4" r="5" fill="#34d399" filter="url(#softGlow)" class="pulse"/>
    <text x="24" y="0" class="kicker">MERBAY // PRODUCTION SYSTEMS</text>
    <text x="0" y="88" class="name">Mustafa Erbay</text>
    <text x="2" y="126" class="role">SYSTEM ARCHITECT  •  NETWORK &amp; INFRASTRUCTURE  •  INDIE HACKER</text>
    <text x="2" y="163" class="copy">I design the systems, ship the products, operate the platform,</text>
    <text x="2" y="187" class="copy">and publish the field notes — from kernel pressure to product architecture.</text>

    <g transform="translate(0 225)">
      <rect width="160" height="34" rx="17" fill="#12213a" stroke="#22d3ee" stroke-opacity=".45"/><text x="80" y="22" text-anchor="middle" class="chip">LINUX + NETWORK</text>
      <g transform="translate(174 0)"><rect width="140" height="34" rx="17" fill="#12213a" stroke="#3b82f6" stroke-opacity=".5"/><text x="70" y="22" text-anchor="middle" class="chip">DEVOPS + SRE</text></g>
      <g transform="translate(328 0)"><rect width="166" height="34" rx="17" fill="#12213a" stroke="#8b5cf6" stroke-opacity=".5"/><text x="83" y="22" text-anchor="middle" class="chip">RUST + TYPESCRIPT</text></g>
    </g>
  </g>

  <g transform="translate(805 56)">
    <rect width="330" height="248" rx="15" fill="#070d19" stroke="#334155"/>
    <path d="M0 42H330" stroke="#1e293b"/>
    <circle cx="22" cy="21" r="5" fill="#fb7185"/><circle cx="40" cy="21" r="5" fill="#fbbf24"/><circle cx="58" cy="21" r="5" fill="#34d399"/>
    <text x="81" y="26" class="terminal" fill="#64748b">operator@merbay</text>
    <text x="22" y="76" class="terminal prompt">$ whoami</text>
    <text x="22" y="101" class="terminal answer">20+ years in production</text>
    <text x="22" y="137" class="terminal prompt">$ platform.status</text>
    <text x="22" y="162" class="terminal answer">self-hosted / sovereign</text>
    <text x="22" y="198" class="terminal prompt">$ currently.shipping</text>
    <text x="22" y="223" class="terminal answer">systems + products + writing</text>
  </g>
</svg>
SVG

cat > "$OUT_DIR/dashboard.svg" <<SVG
<svg xmlns="http://www.w3.org/2000/svg" width="1200" height="520" viewBox="0 0 1200 520" role="img" aria-label="Mustafa Erbay engineering dashboard">
  <defs>
    <linearGradient id="dashBg" x1="0" y1="0" x2="1" y2="1"><stop stop-color="#0b1220"/><stop offset="1" stop-color="#101827"/></linearGradient>
    <linearGradient id="dashAccent" x1="0" y1="0" x2="1" y2="0"><stop stop-color="#22d3ee"/><stop offset=".5" stop-color="#3b82f6"/><stop offset="1" stop-color="#8b5cf6"/></linearGradient>
  </defs>
  <style>
    .title{font:700 17px ui-monospace,SFMono-Regular,Menlo,monospace;letter-spacing:2px;fill:#67e8f9}
    .kpi{font:800 34px Inter,Segoe UI,Arial,sans-serif;fill:#f8fafc}
    .kpi-label{font:700 11px ui-monospace,SFMono-Regular,Menlo,monospace;letter-spacing:1.2px;fill:#94a3b8}
    .section{font:700 15px ui-monospace,SFMono-Regular,Menlo,monospace;letter-spacing:1.4px;fill:#93c5fd}
    .metric{font:800 26px Inter,Segoe UI,Arial,sans-serif;fill:#e2e8f0}
    .label{font:600 13px Inter,Segoe UI,Arial,sans-serif;fill:#cbd5e1}
    .muted{font:500 11px ui-monospace,SFMono-Regular,Menlo,monospace;fill:#64748b}
    .value-small{font:700 12px ui-monospace,SFMono-Regular,Menlo,monospace;fill:#cbd5e1}
  </style>
  <rect width="1200" height="520" rx="20" fill="url(#dashBg)"/>
  <rect x="1" y="1" width="1198" height="518" rx="19" fill="none" stroke="#263449"/>
  <rect x="36" y="32" width="6" height="20" rx="3" fill="#22d3ee"/>
  <text x="56" y="48" class="title">ENGINEERING DASHBOARD</text>
  <text x="1160" y="48" class="muted" text-anchor="end">GENERATED FROM GITHUB API</text>

  <g transform="translate(36 74)">
    <g><rect width="267" height="108" rx="14" fill="#111c2e" stroke="#263449"/><text x="22" y="50" class="kpi">20+</text><text x="22" y="79" class="kpi-label">YEARS IN PRODUCTION</text></g>
    <g transform="translate(285 0)"><rect width="267" height="108" rx="14" fill="#111c2e" stroke="#263449"/><text x="22" y="50" class="kpi">26</text><text x="22" y="79" class="kpi-label">DOCKER CONTAINERS</text></g>
    <g transform="translate(570 0)"><rect width="267" height="108" rx="14" fill="#111c2e" stroke="#263449"/><text x="22" y="50" class="kpi">730+</text><text x="22" y="79" class="kpi-label">TECHNICAL ARTICLES</text></g>
    <g transform="translate(855 0)"><rect width="267" height="108" rx="14" fill="#111c2e" stroke="#263449"/><text x="22" y="50" class="kpi">6</text><text x="22" y="79" class="kpi-label">INDEPENDENT PRODUCTS</text></g>
  </g>

  <g>
    <rect x="36" y="210" width="530" height="270" rx="15" fill="#0d1728" stroke="#263449"/>
    <text x="60" y="246" class="section">GITHUB PULSE</text>
    <text x="60" y="300" class="metric">${TOTAL_COMMITS}</text><text x="60" y="322" class="muted">TOTAL COMMITS</text>
    <text x="238" y="300" class="metric">${LAST_YEAR_CONTRIB}</text><text x="238" y="322" class="muted">LAST YEAR</text>
    <text x="410" y="300" class="metric">${TOTAL_PRS}</text><text x="410" y="322" class="muted">PULL REQUESTS</text>
    <path d="M60 350H542" stroke="#263449"/>
    <text x="60" y="390" class="label">Public repositories</text><text x="520" y="390" class="value-small" text-anchor="end">${PUBLIC_REPOS}</text>
    <text x="60" y="422" class="label">Followers</text><text x="520" y="422" class="value-small" text-anchor="end">${FOLLOWERS}</text>
    <text x="60" y="454" class="label">Stars earned</text><text x="520" y="454" class="value-small" text-anchor="end">${TOTAL_STARS}</text>
  </g>

  <g>
    <rect x="584" y="210" width="580" height="270" rx="15" fill="#0d1728" stroke="#263449"/>
    <text x="608" y="246" class="section">LANGUAGE FINGERPRINT</text>
    ${LANG_ROWS}
  </g>
  <rect x="36" y="500" width="1128" height="3" rx="1.5" fill="url(#dashAccent)"/>
</svg>
SVG

cat > "$OUT_DIR/architecture.svg" <<'SVG'
<svg xmlns="http://www.w3.org/2000/svg" width="1200" height="370" viewBox="0 0 1200 370" role="img" aria-label="Mustafa Erbay capability and architecture map">
  <defs>
    <linearGradient id="archBg" x1="0" y1="0" x2="1" y2="1"><stop stop-color="#0a1323"/><stop offset="1" stop-color="#0f172a"/></linearGradient>
    <linearGradient id="flow" x1="0" y1="0" x2="1" y2="0"><stop stop-color="#22d3ee"/><stop offset=".5" stop-color="#3b82f6"/><stop offset="1" stop-color="#8b5cf6"/></linearGradient>
    <marker id="arrow" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse"><path d="M0 0L10 5L0 10Z" fill="#3b82f6"/></marker>
  </defs>
  <style>
    .title{font:700 17px ui-monospace,SFMono-Regular,Menlo,monospace;letter-spacing:2px;fill:#67e8f9}
    .head{font:800 14px Inter,Segoe UI,Arial,sans-serif;letter-spacing:.8px;fill:#f8fafc}
    .item{font:500 13px Inter,Segoe UI,Arial,sans-serif;fill:#cbd5e1}
    .number{font:800 11px ui-monospace,SFMono-Regular,Menlo,monospace;fill:#60a5fa}
    .caption{font:500 12px ui-monospace,SFMono-Regular,Menlo,monospace;fill:#64748b}
  </style>
  <rect width="1200" height="370" rx="20" fill="url(#archBg)"/>
  <rect x="1" y="1" width="1198" height="368" rx="19" fill="none" stroke="#263449"/>
  <text x="42" y="48" class="title">FULL-STACK INFRASTRUCTURE MAP</text>
  <text x="1158" y="48" class="caption" text-anchor="end">FROM PACKET TO PRODUCT</text>
  <path d="M224 195H273M454 195H503M684 195H733M914 195H963" stroke="#3b82f6" stroke-width="2" stroke-opacity=".65" marker-end="url(#arrow)"/>

  <g transform="translate(34 90)"><rect width="190" height="210" rx="15" fill="#111c2e" stroke="#164e63"/><text x="18" y="30" class="number">01</text><text x="18" y="60" class="head">EDGE &amp; NETWORK</text><path d="M18 76H172" stroke="#164e63"/><text x="18" y="111" class="item">Cloudflare + Nginx</text><text x="18" y="145" class="item">WireGuard + VPN</text><text x="18" y="179" class="item">nftables + routing</text></g>
  <g transform="translate(264 90)"><rect width="190" height="210" rx="15" fill="#111c2e" stroke="#1e40af"/><text x="18" y="30" class="number">02</text><text x="18" y="60" class="head">SYSTEMS</text><path d="M18 76H172" stroke="#1e40af"/><text x="18" y="111" class="item">Linux operations</text><text x="18" y="145" class="item">Docker + Kubernetes</text><text x="18" y="179" class="item">Capacity + performance</text></g>
  <g transform="translate(494 90)"><rect width="190" height="210" rx="15" fill="#111c2e" stroke="#3730a3"/><text x="18" y="30" class="number">03</text><text x="18" y="60" class="head">APPLICATIONS</text><path d="M18 76H172" stroke="#3730a3"/><text x="18" y="111" class="item">Rust + Axum</text><text x="18" y="145" class="item">TypeScript + Node</text><text x="18" y="179" class="item">Astro + React</text></g>
  <g transform="translate(724 90)"><rect width="190" height="210" rx="15" fill="#111c2e" stroke="#5b21b6"/><text x="18" y="30" class="number">04</text><text x="18" y="60" class="head">DATA</text><path d="M18 76H172" stroke="#5b21b6"/><text x="18" y="111" class="item">PostgreSQL</text><text x="18" y="145" class="item">Redis</text><text x="18" y="179" class="item">Meilisearch</text></g>
  <g transform="translate(954 90)"><rect width="212" height="210" rx="15" fill="#111c2e" stroke="#6d28d9"/><text x="18" y="30" class="number">05</text><text x="18" y="60" class="head">RELIABILITY</text><path d="M18 76H194" stroke="#6d28d9"/><text x="18" y="111" class="item">Prometheus + Grafana</text><text x="18" y="145" class="item">GitHub Actions</text><text x="18" y="179" class="item">Incident response</text></g>
  <path d="M34 330H1166" stroke="url(#flow)" stroke-width="3"/>
</svg>
SVG

cat > "$OUT_DIR/footer.svg" <<'SVG'
<svg xmlns="http://www.w3.org/2000/svg" width="1200" height="110" viewBox="0 0 1200 110" role="img" aria-label="Build, operate, learn, share">
  <defs><linearGradient id="footerBg" x1="0" y1="0" x2="1" y2="0"><stop stop-color="#07111f"/><stop offset=".5" stop-color="#102449"/><stop offset="1" stop-color="#071c29"/></linearGradient><linearGradient id="footerLine" x1="0" y1="0" x2="1" y2="0"><stop stop-color="#22d3ee"/><stop offset=".5" stop-color="#3b82f6"/><stop offset="1" stop-color="#8b5cf6"/></linearGradient></defs>
  <rect width="1200" height="110" rx="18" fill="url(#footerBg)"/>
  <rect x="1" y="1" width="1198" height="108" rx="17" fill="none" stroke="#263449"/>
  <rect x="56" y="26" width="1088" height="2" rx="1" fill="url(#footerLine)"/>
  <text x="600" y="67" text-anchor="middle" style="font:700 17px ui-monospace,SFMono-Regular,Menlo,monospace;letter-spacing:4px;fill:#dbeafe">BUILD  •  OPERATE  •  LEARN  •  SHARE</text>
  <text x="600" y="91" text-anchor="middle" style="font:500 11px ui-monospace,SFMono-Regular,Menlo,monospace;letter-spacing:1px;fill:#64748b">MUSTAFAERBAY.COM.TR  //  BURSA, TÜRKİYE</text>
</svg>
SVG

printf 'Generated hero.svg, dashboard.svg, architecture.svg and footer.svg\n'
