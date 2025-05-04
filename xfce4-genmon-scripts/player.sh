#!/bin/bash
readonly ICON="$HOME/.assets/icons/audio.svg"

# Режим выбора плеера: "all" (приоритет Playing, затем Paused) или "first" (первый подходящий плеер)
# Можно задать через переменную окружения или аргумент командной строки
PLAYER_SELECTION_MODE="${1:-$PLAYER_SELECTION_MODE}"
PLAYER_SELECTION_MODE="${PLAYER_SELECTION_MODE:-all}"  # По умолчанию "all"

# Проверка наличия playerctl
if ! command -v playerctl >/dev/null 2>&1; then
    echo "<txt>playerctl not installed</txt>"
    exit 1
fi

# Проверка наличия иконки
if [ ! -f "$ICON" ]; then
    echo "<txt>Icon not found</txt>"
    exit 1
fi

# Функция для выбора первого подходящего плеера (старый метод)
select_first_player() {
    local player
    player=$(playerctl --list-all | while read -r p; do
        status=$(playerctl -p "$p" status 2>/dev/null)
        if [ "$status" = "Playing" ] || [ "$status" = "Paused" ]; then
            echo "$p"
            break
        fi
    done)
    echo "$player"
}

# Функция для выбора плеера с приоритетом Playing, затем Paused (новый метод)
select_priority_player() {
    local player=""
    # Сначала ищем Playing
    while read -r p; do
        status=$(playerctl -p "$p" status 2>/dev/null)
        if [ "$status" = "Playing" ]; then
            player="$p"
            break
        fi
    done < <(playerctl --list-all)

    # Если не нашли Playing, ищем Paused
    if [ -z "$player" ]; then
        while read -r p; do
            status=$(playerctl -p "$p" status 2>/dev/null)
            if [ "$status" = "Paused" ]; then
                player="$p"
                break
            fi
        done < <(playerctl --list-all)
    fi
    echo "$player"
}

# Выбираем плеер в зависимости от режима
case "$PLAYER_SELECTION_MODE" in
    first)
        PLAYER=$(select_first_player)
        ;;
    all|*)
        PLAYER=$(select_priority_player)
        ;;
esac

# Если плеер не найден
# if [ -z "$PLAYER" ]; then
#     echo "<img>$ICON</img><txt> wait.</txt>"
#     exit
# fi

# Проверяем статус и метаданные
STATUS=$(playerctl -p "$PLAYER" status 2>/dev/null)
SONG=$(playerctl -p "$PLAYER" metadata title 2>/dev/null)
ARTIST=$(playerctl -p "$PLAYER" metadata artist 2>/dev/null)

# Если метаданные пустые, показываем "wait."
# if [ -z "$SONG" ]; then
#     echo "<img>$ICON</img><txt> wait.</txt>"
#     exit
# fi

# Выводим информацию в зависимости от статуса
if [ "$STATUS" = "Playing" ]; then
    echo "<img>$ICON</img><txt> $ARTIST - $SONG</txt>"
elif [ "$STATUS" = "Paused" ]; then
    echo "<img>$ICON</img><txt> [Paused] $ARTIST - $SONG</txt>"
else
    echo "<txt></txt>"
fi
