#!/usr/bin/env bash
# Claude Code PreToolUse hook: blocks dangerous actions or ones that break the repo's rules.
# Receives the tool's JSON on stdin. Exiting with 2 blocks the action and shows stderr to the agent.
# Fails closed: if it cannot read the input, it blocks.
# It is one more layer, not the only one: main's real protection is the GitHub ruleset and CI.
set -uo pipefail

input="$(cat)"

extract() {  # extract <field> -> prints tool_input.<field>
  if command -v python3 >/dev/null 2>&1; then
    printf '%s' "$input" | python3 -c 'import json,sys; d=json.load(sys.stdin); print((d.get("tool_input") or {}).get(sys.argv[1]) or "")' "$1"
  elif command -v jq >/dev/null 2>&1; then
    printf '%s' "$input" | jq -r --arg c "$1" '.tool_input[$c] // ""'
  else
    echo "BLOCKED: the security hook needs python3 or jq installed." >&2
    exit 2
  fi
}

block() { echo "BLOCKED by .claude/hooks/guard.sh: $1" >&2; exit 2; }
has() { printf '%s' "$2" | grep -Eiq -- "$1"; }   # has <regex> <text>

cmd_raw="$(extract command)" || block "could not read the hook input."
path="$(extract file_path)$(extract path)" || true
content="$(extract content)$(extract new_string)" || true
search_pattern="$(extract pattern)" || true

# Normalised command: no quotes or backslashes, so 'main' or "main" cannot dodge the rules
cmd="$(printf '%s' "$cmd_raw" | tr -d "\"'\\\\")"

# --- Security configuration: the agent cannot touch its own guardrails ---
# Protected: the agent's own settings, hook, commands, subagents and skills; the git hooks; the CI and
# Dependabot (.github/); and the scripts that enforce or test the rules. Only the owner changes them.
protected_files_re='(^|/)(\.claude/(settings(\.local)?\.json|hooks/|agents/|commands/|skills/)|\.githooks/|\.github/|scripts/(setup-repo|sync-from-template|check-records|test-guard|test-check-records)\.sh)'
if [[ -n "$path" ]] && has "$protected_files_re" "$path"; then
  has '"tool_name" *: *"(Read|Grep|Glob)"' "$input" ||
    block "the security configuration (.claude/, .githooks/, .github/, enforcement scripts) is changed only by the owner."
fi
# Via the shell. Strict by default: a command that mentions a protected path and writes anything is blocked.
# The only relaxation is for simple commands (no cd/pushd, loops, read/set/printf -v, find/xargs, eval/source,
# variables or command substitution): there each subcommand is checked on its own, so read-only commands like
# "git rm app.py && git grep x -- ':!.claude/skills'" or "ls .claude/commands 2>/dev/null" are not taken for
# writes. Harmless redirections (2>/dev/null, >&2, 2>&1) never count as writing.
protected_re='(\.claude/(settings|hooks|agents|commands|skills)|\.githooks|(^|[ /=])\.claude/?( |$)|\.github|scripts/(setup-repo|sync-from-template|check-records|test-guard|test-check-records)\.sh)'
write_re='(>|sed +-i|tee |cp |mv |rm |chmod |ln |truncate|install |dd .*of=|patch |tar |unzip |rsync |perl +-[a-z]*i|python3? +-c|git( +[^ ]+)* +(checkout|restore)( +[^ ]+)* +-- )'
indirect_re='((^|[ ;&|])(cd|pushd|for|while|until|read|set|printf +-v|xargs|find|eval|source|exec)( |$)|=|\$\(|`|\$\{?[A-Za-z_])'
strip_redirs() { printf '%s' "$1" | sed -E 's/[0-9]*>&[0-9-]+//g; s/&?[0-9]*>>? *\/dev\/(null|stderr|stdout)//g'; }

# Each subcommand is analysed separately (split on ; && || | and newlines)
# Compatible with macOS bash 3.2: no mapfile, and awk instead of sed for the newline
# (BSD sed does not understand \n in the replacement).
parts=()
while IFS= read -r line; do parts+=("$line"); done \
  < <(printf '%s\n' "$cmd" | awk '{ gsub(/&&|\|\||;|\|/, "\n"); print }')

if [[ -n "$cmd" ]] && has "$protected_re" "$cmd" && has "$write_re" "$(strip_redirs "$cmd")"; then
  has "$indirect_re" "$cmd" &&
    block "the security configuration (.claude/, .githooks/, .github/, enforcement scripts) is changed only by the owner."
  for p in "${parts[@]+"${parts[@]}"}"; do
    if has "$protected_re" "$p" && has "$write_re" "$(strip_redirs "$p")"; then
      block "the security configuration (.claude/, .githooks/, .github/, enforcement scripts) is changed only by the owner."
    fi
  done
fi

# --- Files with secrets (Read/Edit/Write/Grep/Glob) ---
for r in "$path" "$search_pattern"; do
  [[ -z "$r" ]] && continue
  if has '(^|/)\.env($|\.)|\.pem$|\.key$|id_rsa|id_ed25519|/\.ssh/|/\.aws/|/\.config/gh/|/\.npmrc$|/\.netrc$|/\.kube/|/\.docker/config' "$r" &&
     ! has '\.env\.example$' "$r"; then
    block "access to a file with secrets ($r)."
  fi
done

# --- Secrets written to files ---
if [[ -n "$content" ]] && printf '%s' "$content" | grep -Eq \
  '(ghp_[A-Za-z0-9]{36}|github_pat_[A-Za-z0-9_]{40,}|gh[ousr]_[A-Za-z0-9]{36}|sk-ant-[A-Za-z0-9_-]{20,}|sk-[A-Za-z0-9]{40,}|AKIA[0-9A-Z]{16}|AIza[0-9A-Za-z_-]{35}|-----BEGIN [A-Z ]*PRIVATE KEY-----|xox[baprs]-[A-Za-z0-9-]{10,}|eyJhbGciOi[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{20,}\.)'; then
  block "the content seems to include a secret or token. Use GitHub Secrets or environment variables."
fi

[[ -z "$cmd" ]] && exit 0

for p in "${parts[@]+"${parts[@]}"}"; do
  p="$(printf '%s' "$p" | sed -E 's/^[[:space:]]+//')"
  [[ -z "$p" ]] && continue
  isgit=0; has '^(env( +-[a-z]+)* +)?([A-Za-z_][A-Za-z0-9_]*=[^ ]* +)*(env [^ ]+ +)*git( +-[cC] +[^ ]+)*( +--[a-z-]+(=[^ ]+)?)* ' "$p" && isgit=1

  # --- Skipping git hooks ---
  if (( isgit )); then
    has '(-c +core\.|--config-env|--no-verify|commit( +[^ ]+)* +-[a-zA-Z]*n[a-zA-Z]*( |$))' "$p" &&
      block "git hooks and git config cannot be overridden from the command line (--no-verify, -n, -c core.*, --config-env)."
  fi

  # --- Protected branches ---
  # Allow-list: the only pushes allowed are a plain "git push" from a work branch and
  # "git push [-u] origin <development | feat/… fix/… docs/… chore/… refactor/… test/… ci/…>".
  # Anything else (refspecs like +HEAD:x or HEAD:main, variables, --force, --all, other remotes…) is blocked.
  if has '(^|[ ;&|])git( +[^ ]+)* +push( |$)' "$p"; then
    has '[$`]' "$cmd" && block "git push with variables or command substitution is not allowed: write the branch name."
    work_branch_re='(development|(feat|fix|docs|chore|refactor|test|ci)/[A-Za-z0-9._-]+)'
    if has '^git +push *$' "$p"; then
      branch="$(git branch --show-current 2>/dev/null || true)"
      [[ "$branch" =~ ^${work_branch_re}$ ]] ||
        block "you are on '${branch:-a detached HEAD}': plain git push is only allowed from development or a work branch."
    elif ! has "^git +push( +(-u|--set-upstream))? +origin +${work_branch_re} *$" "$p"; then
      block "only 'git push [-u] origin development' (or a feat/, fix/… work branch) is allowed. No refspecs, force, other remotes or main."
    fi
  fi
  if (( isgit )) && has ' commit( |$)' "$p" && [[ "$(git branch --show-current 2>/dev/null)" =~ ^(main|master)$ ]]; then
    block "no commits on main. Use: git switch development"
  fi

  # --- Remotes: where the code goes is not changed ---
  (( isgit )) && has ' remote +(add|set-url|rename)' "$p" &&
    block "git remotes are not changed: the owner decides where the code goes."

  # --- Git identity ---
  # Reading is allowed (AGENTS.md asks to check them before committing): no value after the key, or --get.
  if (( isgit )) && has ' config( +-[-a-z]+)* +(user\.(name|email)|core\.hooksPath)' "$p" &&
     ! has ' config( +--(global|local|system|worktree))*( +--get)? +(user\.(name|email)|core\.hooksPath) *$' "$p"; then
    value="$(printf '%s' "$p" | sed -E 's/.* (user\.(name|email)|core\.hooksPath) +//')"
    [[ "$value" == "serbenda@gmail.com" || "$value" == "Sergio Santiago Bendaña Quesada" || "$value" == ".githooks" ]] ||
      block "the git identity and hooks path are not changed."
  fi
  (( isgit )) && has '--author|GIT_(AUTHOR|COMMITTER)_(NAME|EMAIL)' "$p" &&
    block "the commit author is not changed."
done

# --- AI signatures in commits, PRs and issues ---
if has '(git( +-[cC] +[^ ]+)* +(commit|tag)|gh +(pr|issue) +(create|edit|comment)|gh +api)' "$cmd" &&
   has '(co-authored-by|generated (with|by) \[?(claude|cursor|copilot|codex)|claude-session|noreply@anthropic|claude\.ai/code|claude\.com/claude-code|🤖)' "$cmd"; then
  block "commits, PRs and issues go without co-authors or AI tool signatures (see AGENTS.md)."
fi

# --- Owner-only actions ---
has '(gh +pr +merge|gh +repo +(delete|archive|rename|transfer)|gh +repo +edit.*(--visibility|--default-branch)|gh +secret|gh +ssh-key|gh +auth +(token|refresh|logout)|gh +api.*(-X|--method)[ =]*(DELETE|PUT|PATCH)|gh +api.*visibility|gh +api.*/(rulesets|protection|collaborators|keys|hooks))' "$cmd" &&
  block "merging PRs, deleting or publishing a repo, secrets, keys, protections or collaborators: the owner does that."

# --- Destructive ---
has '(^|[ ;&|])rm( +-[a-zA-Z-]+)+ +(-- +)?(/|~|\$HOME|\.\.?/?)( |$)' "$cmd" && has '( -[a-zA-Z]*r| --recursive)' "$cmd" &&
  block "dangerous recursive delete."
has 'git( +-[cC] +[^ ]+)* +(reset +--hard|clean +-[a-z]*f|filter-(branch|repo)|update-ref +-d|reflog +expire)' "$cmd" &&
  block "command that destroys work or rewrites history. Ask the owner for confirmation."

# --- Running downloaded code ---
has '(curl|wget)[^|]*\|[[:space:]]*(sudo +)?(ba|z|da)?sh\b|(ba|z)?sh +<\( *(curl|wget)|(curl|wget).*\| *(python3?|node|perl|ruby)\b' "$cmd" &&
  block "scripts downloaded from the internet are not run."

# --- Secrets and credentials from the shell ---
has '(^|[^a-zA-Z0-9_])\.env($|[^.a-zA-Z]|\.(local|production|development|prod|dev)\b)|\.ssh/|id_rsa|id_ed25519|\.aws/credentials|\.netrc|\.config/gh|/proc/[^ ]*/environ|security +find-' "$cmd" &&
  block "access to credential files from the shell."
has '(^|[ ;&|])(printenv|env|set|export +-p|declare +-x)( *$| *\|| *>)|echo[^;]*\$\{?(GITHUB_TOKEN|GH_TOKEN|[A-Z_]*SECRET|[A-Z_]*API_KEY|[A-Z_]*TOKEN)' "$cmd" &&
  block "dump of environment variables or tokens."
has 'os\.environ($|[^.\[]|\.(copy|items|keys|values))|dict\(os\.environ|process\.env($|[^.\[A-Za-z_])|ENV\.(to_h|each|keys)|getenv\(\)|Environment\.GetEnvironmentVariables' "$cmd" &&
  block "dump of environment variables from an interpreter."

exit 0
