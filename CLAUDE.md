# CLAUDE.md — `portofolio` (portofolio.la-zone.io)

## Ce qu'est ce repo
Site **statique standalone** servi par **GitHub Pages** sur **https://portofolio.la-zone.io/**.
La page (`index.html`) est un **export Claude Design** (HTML auto-contenu, CSS/JS inlinés) que
le propriétaire **régénère et remplace en entier** régulièrement.

⚠️ Repo **séparé** de `landing-pages`. Éditer `landing-pages/portofolio/` ne change **PAS** ce site.
Source de vérité du domaine custom = **ce repo** (`LAZONEDEV/portofolio`).

## Faits d'hébergement (ne pas casser)
- GitHub Pages : repo `LAZONEDEV/portofolio`, branche `main`, dossier `/` (root).
- `CNAME` → `portofolio.la-zone.io`. DNS : **Squarespace**, enregistrement `CNAME portofolio → lazonedev.github.io`. **Ne pas supprimer.**
- `.nojekyll` → garder.
- `index.html` (root) = page servie. HTTPS forcé.
- `og.png` (1200×630) = image de partage social, référencée en **URL absolue**.

## 🚀 Rituel de déploiement — À FAIRE À CHAQUE « deploy » / nouvelle version
Un export Claude Design **frais n'a AUCUNE meta SEO/social** et aucun fichier d'infra.
Donc **à chaque déploiement** (ou quand l'utilisateur dit « déploie la nouvelle version ») :

1. Remplacer `index.html` par le nouvel export.
2. **Ré-injecter le bloc meta social** dans `<head>` (Open Graph + Twitter + description).
   → Claude Design l'efface à chaque ré-export. **C'est le point n°1 à ne jamais oublier.**
3. S'assurer que `CNAME`, `.nojekyll`, `og.png` sont présents.
4. Commit `deploy: portofolio` puis push sur `main`.

**Le script fait tout ça (idempotent) :**
```bash
./deploy.sh chemin/vers/nouvel-export.html   # remplace index.html puis déploie
./deploy.sh                                   # re-déploie l'index.html courant
```
Le script lit le `<title>` de la page pour `og:title`, injecte le bloc meta s'il manque
(marqueur `LZ-SOCIAL-META`), garantit les fichiers d'infra, commit et push.

## Image OG
- 1200×630, PNG/JPG, < ~1 Mo. Doit rester une **URL absolue** `https://portofolio.la-zone.io/og.png`
  (les `data:` URIs et chemins relatifs ne marchent pas pour les crawlers sociaux).
- Pour la régénérer depuis une nouvelle source : déposer l'image, la recadrer en 1200×630, écraser `og.png`.

## Règles dures
- Repo **PUBLIC** → jamais de secrets / clés / `.env`.
- Après déploiement, re-scraper le partage via **LinkedIn Post Inspector** / **Facebook Sharing Debugger**
  (les crawlers cachent l'ancienne version).
- Pas de framework, pas de bundler, pas de CI. Reste un bucket statique.
