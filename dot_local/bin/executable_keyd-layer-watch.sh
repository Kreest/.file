#!/usr/bin/env bash

OUT="/tmp/keyd-layer"
IGNORE_LAYERS=(meta control shift)

ignore_layer() {
    local l="$1"
    for i in "${IGNORE_LAYERS[@]}"; do
        [[ "$l" == "$i" ]] && return 0
    done
    return 1
}

while true; do
    declare -a stack=()
    base=""

    # Block until keyd is available
    keyd listen 2>/dev/null | while read -r line; do
        case "$line" in
            /*)
                base="${line#/}"
                stack=("$base")
                ;;
            +*)
                layer="${line#+}"
                ignore_layer "$layer" || stack+=("$layer")
                ;;
            -*)
                layer="${line#-}"
                ignore_layer "$layer" || {
                    for i in "${!stack[@]}"; do
                        [[ "${stack[$i]}" == "$layer" ]] && unset 'stack[$i]' && break
                    done
                }
                ;;
        esac

        current="${stack[-1]:-$base}"
        printf "%s\n" "$current" > "$OUT"
    done

    # keyd listen exited → reset indicator
    : > "$OUT"

    # Avoid tight restart loop
    sleep 0.5
done

