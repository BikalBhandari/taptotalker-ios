# GitHub labels for triage

## Map

| Role | Label | Notes |
|------|-------|--------|
| bug | `bug` | Built-in |
| enhancement | `enhancement` | Built-in |
| needs-triage | `needs-triage` | Create if missing |
| needs-info | `needs-info` | Create if missing |
| ready-for-agent | `ready-for-agent` | Create if missing |
| ready-for-human | `ready-for-human` | Create if missing |
| wontfix | `wontfix` | Built-in |

## One-time setup (needs write access)

```bash
gh label create "needs-triage" --description "Maintainer needs to evaluate" --color "0E8A16"
gh label create "needs-info" --description "Waiting on reporter for more information" --color "FBCA04"
gh label create "ready-for-agent" --description "Fully specified for an AFK agent" --color "1D76DB"
gh label create "ready-for-human" --description "Needs human implementation" --color "5319E7"
```

Verify: `gh label list`
