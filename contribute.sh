#!/bin/bash
# Fake daily contributions - random delays, natural looking activity
REPO_DIR="/Users/yohanes/daily-contributions"
LOG_FILE="$REPO_DIR/contribute.log"
cd "$REPO_DIR" || exit 1

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Script triggered" >> "$LOG_FILE"

# Randomly skip this run (30% chance) to look more natural
if [ $((RANDOM % 10)) -lt 3 ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Skipped (random skip)" >> "$LOG_FILE"
    exit 0
fi

# Random initial delay: 0~120 minutes
INITIAL_DELAY=$((RANDOM % 7200))
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Sleeping ${INITIAL_DELAY}s before start" >> "$LOG_FILE"
sleep $INITIAL_DELAY

# Random number of commits (1~5)
COMMIT_COUNT=$((RANDOM % 5 + 1))
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Making $COMMIT_COUNT commits" >> "$LOG_FILE"

STATUSES=("active" "idle" "running" "pending" "completed" "success" "queued" "done")
MOODS=("good" "stable" "improving" "optimal" "nominal" "healthy")

for i in $(seq 1 $COMMIT_COUNT); do
    TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
    RANDOM_ID=$(LC_ALL=C cat /dev/urandom | LC_ALL=C tr -dc 'a-z0-9' | head -c 6)
    FILE_NAME="log_${RANDOM_ID}.txt"

    STATUS=${STATUSES[$((RANDOM % ${#STATUSES[@]}))]}
    MOOD=${MOODS[$((RANDOM % ${#MOODS[@]}))]}

    echo "[$TIMESTAMP] Entry #$RANDOM_ID" > "$FILE_NAME"
    echo "Status: $STATUS" >> "$FILE_NAME"
    echo "Health: $MOOD" >> "$FILE_NAME"
    echo "Token: $(LC_ALL=C cat /dev/urandom | LC_ALL=C tr -dc 'a-z0-9' | head -c 20)" >> "$FILE_NAME"
    echo "Score: $((RANDOM % 100))" >> "$FILE_NAME"

    git add "$FILE_NAME"
    git commit -m "chore: update $(date +%Y%m%d)-$RANDOM_ID" --quiet
    git push --quiet

    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Commit $i/$COMMIT_COUNT done" >> "$LOG_FILE"

    # Random delay between commits: 1~8 minutes
    if [ $i -lt $COMMIT_COUNT ]; then
        DELAY=$((RANDOM % 421 + 60))
        sleep $DELAY
    fi
done

# Cleanup old log files, keep recent 50
cd "$REPO_DIR"
ls -t log_*.txt 2>/dev/null | tail -n +51 | xargs -r rm -f
if [ -n "$(git status --porcelain)" ]; then
    git add -A
    git commit -m "chore: cleanup" --quiet
    git push --quiet
fi

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Done" >> "$LOG_FILE"
