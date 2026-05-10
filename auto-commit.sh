#!/usr/bin/env bash

# GitHub Streak Keeper - Real Maintenance Script
# Evalúa repositorios y solo crea commits cuando hay mantenimiento real.
#
# Uso:
#   ./auto-commit.sh /ruta/al/repo1 [/ruta/al/repo2 ...]
#
# Variables opcionales:
#   STREAK_KEEPER_PUSH=1        # hace git push después del commit
#   STREAK_KEEPER_DRY_RUN=1     # muestra lo que haría sin commitear
#   STREAK_KEEPER_SKIP_TESTS=1  # omite test/build

set -euo pipefail

CHECKPOINT_DIR="${CHECKPOINT_DIR:-/tmp/streak-keeper}"
LOG_FILE="${LOG_FILE:-/tmp/streak-keeper.log}"
TIMESTAMP="$(date '+%Y-%m-%d %H:%M:%S')"
TODAY="$(date '+%Y-%m-%d')"
DRY_RUN="${STREAK_KEEPER_DRY_RUN:-0}"
PUSH_CHANGES="${STREAK_KEEPER_PUSH:-0}"
SKIP_TESTS="${STREAK_KEEPER_SKIP_TESTS:-0}"

mkdir -p "$CHECKPOINT_DIR"

log() {
    echo "[$TIMESTAMP] $1" | tee -a "$LOG_FILE"
}

repo_checkpoint_file() {
    local repo_path="$1"
    local repo_name
    repo_name="$(basename "$repo_path")"
    echo "$CHECKPOINT_DIR/.checkpoint-${repo_name}-${TODAY}"
}

check_checkpoint() {
    local repo_path="$1"
    local checkpoint_file
    checkpoint_file="$(repo_checkpoint_file "$repo_path")"

    if [ -f "$checkpoint_file" ]; then
        log "⏭️  Skip: $(basename "$repo_path") ya fue procesado hoy"
        return 1
    fi

    return 0
}

create_checkpoint() {
    local repo_path="$1"
    local checkpoint_file
    checkpoint_file="$(repo_checkpoint_file "$repo_path")"
    touch "$checkpoint_file"
    log "✅ Checkpoint creado: $checkpoint_file"
}

has_npm_script() {
    local script_name="$1"
    node -e "const p=require('./package.json'); process.exit(p.scripts && p.scripts['$script_name'] ? 0 : 1)" 2>/dev/null
}

run_validation() {
    if [ "$SKIP_TESTS" = "1" ]; then
        log "⏭️  Validación omitida por STREAK_KEEPER_SKIP_TESTS=1"
        return 0
    fi

    if [ -f package.json ]; then
        if has_npm_script test; then
            log "🧪 Ejecutando npm test"
            npm test
        fi

        if has_npm_script build; then
            log "🏗️  Ejecutando npm run build"
            npm run build
        fi
    fi
}

apply_node_maintenance() {
    local changed=1

    if [ ! -f package.json ]; then
        return 1
    fi

    if [ -f package-lock.json ]; then
        log "📦 Revisando actualizaciones npm seguras (package-lock)"
        npm update --package-lock-only --ignore-scripts
        changed=0
    elif [ -f npm-shrinkwrap.json ]; then
        log "📦 Revisando actualizaciones npm seguras (npm-shrinkwrap)"
        npm update --package-lock-only --ignore-scripts
        changed=0
    else
        log "ℹ️  package.json detectado, pero no hay lockfile npm. No se modifica para evitar cambios inseguros."
    fi

    return "$changed"
}

apply_maintenance() {
    local did_anything=1

    if apply_node_maintenance; then
        did_anything=0
    fi

    # Aquí se pueden añadir más mantenedores seguros en el futuro:
    # - Python requirements con herramientas fijadas
    # - Composer lockfile
    # - GitHub Actions pinning
    # - lint/format explícitos del proyecto

    return "$did_anything"
}

commit_message_for_changes() {
    if git diff --cached --name-only | grep -Eq '(^|/)package-lock\.json$|(^|/)npm-shrinkwrap\.json$'; then
        echo "build: update npm dependency lockfile"
    else
        echo "chore: apply repository maintenance"
    fi
}

process_repo() {
    local repo_path="$1"
    local repo_name
    repo_name="$(basename "$repo_path")"

    if [ ! -d "$repo_path" ]; then
        log "❌ Error: el directorio no existe: $repo_path"
        return 1
    fi

    if [ ! -d "$repo_path/.git" ]; then
        log "❌ Error: no es un repositorio git: $repo_path"
        return 1
    fi

    if ! check_checkpoint "$repo_path"; then
        return 0
    fi

    cd "$repo_path"
    log "🔍 Evaluando repo: $repo_name"

    if ! git diff --quiet || ! git diff --cached --quiet || [ -n "$(git ls-files --others --exclude-standard)" ]; then
        log "⚠️  Skip: $repo_name tiene cambios locales sin revisar. No se commitean automáticamente."
        return 0
    fi

    if ! apply_maintenance; then
        log "ℹ️  Sin mantenedores aplicables para $repo_name"
        return 0
    fi

    if git diff --quiet; then
        log "✅ Sin cambios reales necesarios en $repo_name"
        return 0
    fi

    log "📝 Cambios detectados:"
    git status --short | tee -a "$LOG_FILE"

    if ! run_validation; then
        log "❌ Validación falló. Revirtiendo cambios generados en $repo_name"
        git restore --worktree --staged .
        return 1
    fi

    git add -A

    if git diff --cached --quiet; then
        log "✅ Sin cambios staged después de validar $repo_name"
        return 0
    fi

    local message
    message="$(commit_message_for_changes)"

    if [ "$DRY_RUN" = "1" ]; then
        log "🧪 DRY RUN: se habría creado commit en $repo_name: '$message'"
        git diff --cached --stat | tee -a "$LOG_FILE"
        git restore --staged .
        return 0
    fi

    git commit -m "$message"
    create_checkpoint "$repo_path"
    log "✅ Commit real creado en $repo_name: '$message'"

    if [ "$PUSH_CHANGES" = "1" ]; then
        git push
        log "🚀 Cambios enviados a remoto para $repo_name"
    else
        log "ℹ️  Push omitido. Usa STREAK_KEEPER_PUSH=1 para enviar al remoto."
    fi
}

main() {
    log "🚀 Iniciando GitHub Streak Keeper (modo mantenimiento real)"

    if [ "$#" -eq 0 ]; then
        log "❌ Error: no se proporcionaron repositorios"
        echo "Uso: $0 /ruta/al/repo1 [/ruta/al/repo2 ...]"
        exit 1
    fi

    local success_count=0
    local fail_count=0

    for repo in "$@"; do
        if process_repo "$repo"; then
            success_count=$((success_count + 1))
        else
            fail_count=$((fail_count + 1))
        fi
    done

    log "📊 Resumen: $success_count procesados, $fail_count con error"
    log "🏁 GitHub Streak Keeper completado"
}

main "$@"
