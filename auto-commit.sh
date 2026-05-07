#!/bin/bash

# GitHub Streak Keeper - Auto-Commit Script
# Mantén tu racha verde automáticamente 🟩
#
# Uso: ./auto-commit.sh /ruta/al/repo1 /ruta/al/repo2 ...

set -e

# Configuración
CHECKPOINT_DIR="/tmp/streak-keeper"
LOG_FILE="/tmp/streak-keeper.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
TODAY=$(date '+%Y-%m-%d')

# Mensajes de commit aleatorios
COMMIT_MESSAGES=(
    "docs: actualizar documentación del proyecto"
    "feat: agregar nueva funcionalidad"
    "refactor: mejorar estructura del código"
    "style: ajustar formato y estilos"
    "chore: mantenimiento general del proyecto"
    "perf: optimizar rendimiento"
    "fix: corregir errores menores"
    "test: agregar pruebas unitarias"
    "ci: actualizar configuración de CI/CD"
    "build: actualizar dependencias"
)

# Crear directorio de checkpoints si no existe
mkdir -p "$CHECKPOINT_DIR"

# Función para logging
log() {
    echo "[$TIMESTAMP] $1" | tee -a "$LOG_FILE"
}

# Función para verificar si ya se hizo commit hoy
check_checkpoint() {
    local repo_path="$1"
    local repo_name=$(basename "$repo_path")
    local checkpoint_file="$CHECKPOINT_DIR/.checkpoint-${repo_name}-${TODAY}"
    
    if [ -f "$checkpoint_file" ]; then
        log "⏭️  Skip: $repo_name ya tiene commit hoy"
        return 1
    fi
    
    return 0
}

# Función para crear checkpoint
create_checkpoint() {
    local repo_path="$1"
    local repo_name=$(basename "$repo_path")
    local checkpoint_file="$CHECKPOINT_DIR/.checkpoint-${repo_name}-${TODAY}"
    
    touch "$checkpoint_file"
    log "✅ Checkpoint creado: $checkpoint_file"
}

# Función para hacer commit en un repo
commit_to_repo() {
    local repo_path="$1"
    local repo_name=$(basename "$repo_path")
    
    # Verificar que el directorio existe
    if [ ! -d "$repo_path" ]; then
        log "❌ Error: El directorio no existe: $repo_path"
        return 1
    fi
    
    # Verificar que es un repo git
    if [ ! -d "$repo_path/.git" ]; then
        log "❌ Error: No es un repositorio git: $repo_path"
        return 1
    fi
    
    # Verificar checkpoint
    if ! check_checkpoint "$repo_path"; then
        return 0
    fi
    
    # Cambiar al directorio del repo
    cd "$repo_path"
    
    # Seleccionar mensaje aleatorio
    local message=${COMMIT_MESSAGES[$RANDOM % ${#COMMIT_MESSAGES[@]}]}
    
    # Crear archivo de actividad (si no hay cambios)
    local activity_file="$repo_path/.github-streak"
    echo "Última actividad: $TIMESTAMP" > "$activity_file"
    
    # Agregar cambios
    git add -A 2>/dev/null || true
    
    # Verificar si hay cambios para commitear
    if git diff --cached --quiet; then
        log "⚠️  Warning: Sin cambios en $repo_name, creando archivo de actividad"
        git add "$activity_file"
    fi
    
    # Hacer commit
    git commit -m "$message" --no-verify
    
    # Crear checkpoint
    create_checkpoint "$repo_path"
    
    log "✅ Commit exitoso en $repo_name: '$message'"
    
    return 0
}

# Main
main() {
    log "🚀 Iniciando GitHub Streak Keeper"
    
    if [ $# -eq 0 ]; then
        log "❌ Error: No se proporcionaron repositorios"
        echo "Uso: $0 /ruta/al/repo1 [/ruta/al/repo2 ...]"
        exit 1
    fi
    
    local success_count=0
    local fail_count=0
    
    for repo in "$@"; do
        if commit_to_repo "$repo"; then
            ((success_count++))
        else
            ((fail_count++))
        fi
    done
    
    log "📊 Resumen: $success_count exitosos, $fail_count fallidos"
    log "🏁 GitHub Streak Keeper completado"
}

main "$@"
