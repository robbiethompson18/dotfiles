# Feedback Loop

Run the QA feedback process on a loop every hour at the :15 minute mark.

## Starting

When this skill is invoked, **start immediately** with a check cycle, then continue looping at :15.

## Loop Structure

```
1. Check for feedback NOW (email + DB)
2. Run /incorporate-feedback if issues found
3. Sleep until next :15 (e.g., 1:15, 2:15, 3:15)
4. Repeat
```

## How to Check for Feedback

### Email (AgentMail)
Check the inbox configured in the project's CLAUDE.md. Use the `bin/check-feedback` script if available, or query AgentMail API directly:

```bash
# Run the check-feedback script
source .envrc && python3 bin/check-feedback
```

### Database
Query the `bug_reports` table for open issues:

```sql
SELECT id, description, email, metadata, status, created_at
FROM bug_reports
WHERE status = 'open' OR resolved_at IS NULL
ORDER BY created_at DESC;
```

## Waiting Until :15

Calculate sleep time to the next hour's :15 mark:

```python
import time
from datetime import datetime

def wait_until_quarter_past():
    now = datetime.now()
    # Next :15
    if now.minute >= 15:
        # Wait until next hour's :15
        target = now.replace(hour=now.hour + 1, minute=15, second=0, microsecond=0)
    else:
        target = now.replace(minute=15, second=0, microsecond=0)

    sleep_seconds = (target - now).total_seconds()
    print(f"Sleeping {sleep_seconds/60:.1f} minutes until {target.strftime('%H:%M')}")
    time.sleep(sleep_seconds)
```

## After Each Cycle

Report:
- How many issues were found
- How many were fixed
- What was deployed
- What couldn't be fixed (npm, etc.)
- When the next check will run

## Starting the Loop

When invoked, confirm with user:
1. "Starting feedback loop. Will check at :15 past each hour."
2. "First check at [TIME]. Press Ctrl+C to stop."
3. Begin waiting or check immediately if past :15
