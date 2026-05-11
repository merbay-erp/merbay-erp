#!/usr/bin/env bash
# SVG fetch + clean utility.
# Usage: fetch-svg.sh URL OUTPUT_PATH
# Capsule-render & github-readme-* bug'larını fixler:
#  1. Leading whitespace strip (XML must start with element)
#  2. Unescaped & → &amp; (XML compliance)
#  3. XML well-formed validation (otherwise abort, keep old file)

set -uo pipefail

URL="$1"
OUT="$2"

if ! curl -fsS --max-time 30 --retry 3 --retry-delay 5 "$URL" -o "$OUT.raw"; then
  echo "✗ $(basename "$OUT") (fetch failed, önceki kalsın)"
  rm -f "$OUT.raw"
  exit 0  # Don't fail workflow, just keep old file
fi

# Pipeline: strip whitespace → cut anything before <svg → escape unescaped &
sed -E 's/^[[:space:]]+//' "$OUT.raw" \
  | awk '/<svg/{found=1} found{print}' \
  | python3 -c '
import sys, re
content = sys.stdin.read()
# Escape & that is NOT already part of an entity reference
content = re.sub(r"&(?!(?:amp|lt|gt|quot|apos|#\d+|#x[0-9a-fA-F]+);)", "&amp;", content)
sys.stdout.write(content)
' > "$OUT.new"

# Validate: starts with <svg AND is well-formed XML
if [ ! -s "$OUT.new" ]; then
  echo "✗ $(basename "$OUT") (empty output)"
  rm -f "$OUT.new" "$OUT.raw"
  exit 0
fi

if ! head -c 4 "$OUT.new" | grep -q '<svg'; then
  echo "✗ $(basename "$OUT") (doesn't start with <svg)"
  rm -f "$OUT.new" "$OUT.raw"
  exit 0
fi

if ! python3 -c "import sys, xml.etree.ElementTree as ET; ET.fromstring(open('$OUT.new').read())" 2>/dev/null; then
  echo "✗ $(basename "$OUT") (invalid XML)"
  rm -f "$OUT.new" "$OUT.raw"
  exit 0
fi

mv "$OUT.new" "$OUT"
rm -f "$OUT.raw"
echo "✓ $(basename "$OUT") ($(wc -c < "$OUT") bytes, valid XML)"
