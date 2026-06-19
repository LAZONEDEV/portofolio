#!/usr/bin/env bash
#
# Deploy portofolio.la-zone.io
# ----------------------------
# Usage:
#   ./deploy.sh path/to/new-claude-design-export.html   # swap in a new export, then deploy
#   ./deploy.sh                                          # re-deploy the current index.html
#
# What it guarantees on every run (idempotent):
#   1. index.html in place (optionally replaced by the given export)
#   2. social <head> meta re-injected  ← Claude Design exports drop these every time
#   3. CNAME / .nojekyll / og.jpg present
#   4. commit + push to LAZONEDEV/portofolio main
#
set -euo pipefail
cd "$(dirname "$0")"

SITE_URL="https://portofolio.la-zone.io"
DESC="Studio produit & agence digitale. Nous concevons et développons des produits digitaux qui livrent — du premier échange à la mise en production."

# --- 1. source HTML --------------------------------------------------------
SRC="${1:-}"
if [ -n "$SRC" ]; then
  [ -f "$SRC" ] || { echo "❌ Source introuvable : $SRC"; exit 1; }
  cp "$SRC" index.html
  echo "→ index.html ← $SRC"
fi
[ -f index.html ] || { echo "❌ Pas d'index.html à déployer."; exit 1; }

# --- 2. infra files --------------------------------------------------------
printf 'portofolio.la-zone.io\n' > CNAME
: > .nojekyll
[ -f og.jpg ] || echo "⚠️  og.jpg manquant — aperçus sociaux vides. Ajoute une image 1200×630 nommée og.jpg."

# --- 3. social meta (idempotent: skip if og:image already there) -----------
if grep -q "og:image" index.html; then
  echo "→ meta social déjà présente, rien à injecter"
else
  TITLE=$(sed -n 's:.*<title>\(.*\)</title>.*:\1:p' index.html | head -1)
  [ -z "$TITLE" ] && TITLE="La Zone — Nos réalisations"
  META_TMP=$(mktemp)
  cat > "$META_TMP" <<EOF
  <!-- LZ-SOCIAL-META:start (auto-injecté par deploy.sh — Claude Design efface ces tags) -->
  <meta name="description" content="$DESC">
  <meta property="og:type" content="website">
  <meta property="og:site_name" content="La Zone">
  <meta property="og:locale" content="fr_FR">
  <meta property="og:url" content="$SITE_URL/">
  <meta property="og:title" content="$TITLE">
  <meta property="og:description" content="$DESC">
  <meta property="og:image" content="$SITE_URL/og.jpg">
  <meta property="og:image:width" content="1200">
  <meta property="og:image:height" content="630">
  <meta property="og:image:alt" content="$TITLE">
  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:title" content="$TITLE">
  <meta name="twitter:description" content="$DESC">
  <meta name="twitter:image" content="$SITE_URL/og.jpg">
  <!-- LZ-SOCIAL-META:end -->
EOF
  # Insert the meta file's contents just before the first </head> (portable awk).
  awk -v mf="$META_TMP" '
    /<\/head>/ && !ins { while ((getline line < mf) > 0) print line; close(mf); ins=1 }
    { print }
  ' index.html > index.html.tmp
  mv index.html.tmp index.html
  rm -f "$META_TMP"
  echo "→ meta social injectée (og:title = \"$TITLE\")"
fi

# --- 4. commit + push ------------------------------------------------------
git add -A
if git diff --cached --quiet; then
  echo "→ aucun changement, déjà à jour"
else
  git commit -q -m "deploy: portofolio"
  git push -q origin main
  echo "✅ Déployé → $SITE_URL/"
  echo "   Pense à re-scraper l'aperçu : https://www.linkedin.com/post-inspector/  &  https://developers.facebook.com/tools/debug/"
fi
