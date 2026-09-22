# Branch protection for `main`

Keep `main` merge-ready only through **approved PRs with green CI**.

## Status

| Repo | Gate |
|------|------|
| `BikalBhandari/taptotalker-ios` (fork) | Ruleset **`main-pr-gate`** active: required PR + 1 approval; force-push/delete blocked |
| `devcalapps-glitch/taptotalker-ios` (upstream) | Needs an **admin** to apply the same ruleset (read-only contributors cannot) |

After CI has run once on upstream, also require the **Build & Test** status check.

## Required settings (repo admin)

In GitHub → **Settings → Rules → Rulesets** (preferred) or **Branches → Branch protection**:

1. Target branch: `main`
2. **Require a pull request before merging**
   - Required approvals: **1**
   - Dismiss stale reviews when new commits are pushed: on
3. **Require status checks to pass**
   - Require branches to be up to date: on
   - Required check: **Build & Test** (from `.github/workflows/ci.yml`)
4. **Block force pushes** and **Block deletions**
5. Do **not** allow bypass for admins in normal workflow (optional exception only for emergencies)

### CLI (ruleset) sketch

After the CI workflow has run at least once on the default branch (so the check name exists):

```bash
# Requires admin on the repo. Adjust owner/repo as needed.
gh api repos/devcalapps-glitch/taptotalker-ios/rulesets \
  --method POST \
  --input - <<'EOF'
{
  "name": "main-pr-gate",
  "target": "branch",
  "enforcement": "active",
  "conditions": {
    "ref_name": {
      "include": ["refs/heads/main"],
      "exclude": []
    }
  },
  "rules": [
    { "type": "pull_request", "parameters": {
        "required_approving_review_count": 1,
        "dismiss_stale_reviews_on_push": true,
        "require_code_owner_review": false,
        "require_last_push_approval": false,
        "required_review_thread_resolution": false
    }},
    { "type": "required_status_checks", "parameters": {
        "strict_required_status_checks_policy": true,
        "required_status_checks": [
          { "context": "Build & Test" }
        ]
    }},
    { "type": "non_fast_forward" },
    { "type": "deletion" }
  ],
  "bypass_actors": []
}
EOF
```

If the API rejects `required_status_checks` until the check exists, merge one PR that runs CI first, then re-run the ruleset create/update.

## Agent / contributor expectation

See `.cursor/rules/feature-branch-pr.mdc`: never commit on `main`; open a PR and wait for approval + CI.
