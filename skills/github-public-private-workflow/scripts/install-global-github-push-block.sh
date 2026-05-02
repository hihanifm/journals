#!/usr/bin/env bash
# Optional machine-wide guardrail: block pushes to public github.com (HTTPS + SSH).
# Sets global pushInsteadOf and a global pre-push hook. Run only when you intend this.
set -euo pipefail

HOOKS_DIR="${GIT_GLOBAL_HOOKS_DIR:-$HOME/.git-global-hooks}"

git config --global url."BLOCKED://no-push/".pushInsteadOf "https://github.com/"
git config --global url."BLOCKED://no-push/".pushInsteadOf "git@github.com:"

mkdir -p "$HOOKS_DIR"

cat >"$HOOKS_DIR/pre-push" <<'EOF'
#!/usr/bin/env bash
remote_url=$(git remote get-url "$1" 2>/dev/null)
if echo "$remote_url" | grep -q "github.com"; then
  echo ""
  echo "BLOCKED: Push to github.com is not allowed from this environment."
  echo "Are you trying to push to your internal repo instead?"
  echo ""
  exit 1
fi
EOF
chmod +x "$HOOKS_DIR/pre-push"

git config --global core.hooksPath "$HOOKS_DIR"

echo "Installed global github.com push block."
echo "  hooksPath=$HOOKS_DIR"
echo "Verify: git config --global --list | grep -E 'pushInsteadOf|hooksPath'"
echo "Bypass hooks only if policy allows: git push --no-verify"
