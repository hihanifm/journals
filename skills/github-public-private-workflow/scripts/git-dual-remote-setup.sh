#!/usr/bin/env bash
set -euo pipefail

echo "== Dual-remote setup (public upstream + private origin) =="

# Non-interactive agents (like Cline) may not show prompts.
# If stdin is not a TTY, require PRIVATE_URL to be provided explicitly.
IS_TTY=0
if [[ -t 0 ]]; then IS_TTY=1; fi

# Auto-detect the public URL from an existing clone when possible:
# - public: github.com
# - private/internal: github.<corp>.com (or anything not github.com)
PUBLIC_URL=""
PRIVATE_URL="${PRIVATE_URL:-}"

if git remote get-url origin >/dev/null 2>&1; then
  ORIGIN_URL="$(git remote get-url origin)"
  if [[ "$ORIGIN_URL" == *"github.com"* ]]; then
    PUBLIC_URL="$ORIGIN_URL"
  else
    PRIVATE_URL="$ORIGIN_URL"
  fi
fi

if [[ -z "$PUBLIC_URL" ]] && git remote get-url upstream >/dev/null 2>&1; then
  UPSTREAM_URL="$(git remote get-url upstream)"
  if [[ "$UPSTREAM_URL" == *"github.com"* ]]; then
    PUBLIC_URL="$UPSTREAM_URL"
  fi
fi

if [[ -z "$PUBLIC_URL" ]]; then
  if [[ "$IS_TTY" -eq 1 ]]; then
    read -r -p "Public GitHub repo URL (github.com, fetch-only): " PUBLIC_URL
  else
    echo "ERROR: Could not auto-detect PUBLIC_URL and prompts are disabled (non-interactive)."
    echo "Set PUBLIC_URL env var or run this script in an interactive terminal."
    exit 2
  fi
else
  echo "Detected public repo: $PUBLIC_URL"
fi

if [[ -z "$PRIVATE_URL" ]]; then
  if [[ "$IS_TTY" -eq 1 ]]; then
    read -r -p "Private/internal GitHub repo URL (github.<corp>.com, push target): " PRIVATE_URL
  else
    echo "ERROR: PRIVATE_URL is required in non-interactive mode."
    echo "Example: PRIVATE_URL=https://github.<corp>.com/org/repo.git $0"
    exit 2
  fi
else
  echo "Detected private repo: $PRIVATE_URL"
fi

# Guardrail: private URL must not be github.com
if [[ "$PRIVATE_URL" == *"github.com"* ]]; then
  echo "ERROR: PRIVATE_URL points to github.com. Refusing to configure a public repo as private."
  echo "PRIVATE_URL=$PRIVATE_URL"
  exit 2
fi

DEFAULT_BASE_BRANCH="main"
read -r -p "Base branch name [${DEFAULT_BASE_BRANCH}]: " BASE_BRANCH
BASE_BRANCH="${BASE_BRANCH:-$DEFAULT_BASE_BRANCH}"

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo "Not in a git repo."; exit 1; }

echo "-> Configuring remotes..."

# origin = private (push target)
if git remote get-url origin >/dev/null 2>&1; then
  git remote set-url origin "$PRIVATE_URL"
else
  git remote add origin "$PRIVATE_URL"
fi

# upstream = public (fetch only)
if git remote get-url upstream >/dev/null 2>&1; then
  git remote set-url upstream "$PUBLIC_URL"
else
  git remote add upstream "$PUBLIC_URL"
fi

# Disable accidental push to upstream
git remote set-url --push upstream DISABLED || true

# Prefer pushing to origin by default
git config remote.pushDefault origin

echo "-> Fetching..."
git fetch origin --prune
git fetch upstream --prune

echo "-> Creating local branches..."

# public-main tracks upstream/main
if git show-ref --verify --quiet refs/heads/public-main; then
  echo "   public-main already exists"
else
  git branch public-main "upstream/${BASE_BRANCH}"
fi
git branch --set-upstream-to="upstream/${BASE_BRANCH}" public-main >/dev/null 2>&1 || true

# private-main tracks origin/main
if git show-ref --verify --quiet refs/heads/private-main; then
  echo "   private-main already exists"
else
  git branch private-main "origin/${BASE_BRANCH}"
fi
git branch --set-upstream-to="origin/${BASE_BRANCH}" private-main >/dev/null 2>&1 || true

echo "-> Adding helpful aliases..."
git config alias.pub-pull  "!git fetch upstream --prune && git switch public-main && git reset --hard upstream/${BASE_BRANCH}"
git config alias.priv-pull "!git fetch origin --prune && git switch private-main && git reset --hard origin/${BASE_BRANCH}"
git config alias.priv-push "!git push origin HEAD"
git config alias.where     "remote -v"

cat <<EOF

Done.

Daily shortcuts:
- git pub-pull   : update public-main from upstream/${BASE_BRANCH} (hard reset)
- git priv-pull  : update private-main from origin/${BASE_BRANCH} (hard reset)
- git priv-push  : push current HEAD to private origin
- git where      : show remotes

Safety:
- 'upstream' push URL is DISABLED.

EOF
