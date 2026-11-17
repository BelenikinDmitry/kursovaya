#!/usr/bin/env bash
# Автосинхронизация каталога курсовой с GitHub.
# Вызывается хуком Stop Claude Code (и может вызываться из cron).
# Если есть изменения: коммит и push. При отклонённом push — pull --rebase и повтор.

REPO="/home/lordvoldemort/kursovaya"
LOG="$REPO/.claude/git-autosync.log"

cd "$REPO" || exit 0

# Нет изменений — коммитить нечего, но проверим неотправленные коммиты
if [ -n "$(git status --porcelain)" ]; then
    git add -A
    git commit -q -m "Автосинхронизация: $(date '+%Y-%m-%d %H:%M:%S')" || exit 0
fi

# Отправляем, только если есть что отправлять
if [ -n "$(git log origin/main..HEAD --oneline 2>/dev/null)" ] || ! git rev-parse -q --verify origin/main >/dev/null; then
    if ! git push -q origin main >>"$LOG" 2>&1; then
        git pull -q --rebase origin main >>"$LOG" 2>&1 && git push -q origin main >>"$LOG" 2>&1 \
            || echo '{"systemMessage": "Автосинхронизация с GitHub не удалась, см. .claude/git-autosync.log"}'
    fi
fi
exit 0
