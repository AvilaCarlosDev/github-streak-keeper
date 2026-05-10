# GitHub Streak Keeper 🟩

> Mantén tu actividad en GitHub con **mantenimiento real**, no con commits falsos.

[![MIT License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/AvilaCarlosDev/github-streak-keeper?style=flat)](https://github.com/AvilaCarlosDev/github-streak-keeper/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/AvilaCarlosDev/github-streak-keeper?style=flat)](https://github.com/AvilaCarlosDev/github-streak-keeper/network)

## 🎯 El Problema

Automatizar commits vacíos o cambios artificiales puede mantener una racha, pero no aporta valor al proyecto y puede verse como spam.

La mejor forma de mantener consistencia es convertir la automatización en un pequeño asistente de mantenimiento: revisar repos, detectar mejoras reales y crear commits solo cuando hay cambios útiles.

## 🛠️ La Solución

`auto-commit.sh` ahora funciona como un **maintenance bot local**:

- inspecciona cada repositorio,
- evita tocar repos con cambios locales sin revisar,
- aplica mantenimiento seguro cuando corresponde,
- ejecuta validaciones del proyecto,
- crea commits solo si hay cambios reales,
- nunca genera archivos fake de actividad.

## ✅ Qué hace actualmente

- ✅ Soporta múltiples repositorios.
- ✅ Evita commits duplicados con checkpoints diarios.
- ✅ Detecta repos sucios y los omite para no commitear trabajo sin revisar.
- ✅ En proyectos Node con `package-lock.json`, ejecuta:

```bash
npm update --package-lock-only --ignore-scripts
```

- ✅ Ejecuta `npm test` si existe.
- ✅ Ejecuta `npm run build` si existe.
- ✅ Revierte cambios generados si la validación falla.
- ✅ Crea commit solo cuando hay cambios reales.
- ✅ Push opcional con `STREAK_KEEPER_PUSH=1`.
- ✅ Modo simulación con `STREAK_KEEPER_DRY_RUN=1`.

## 🚫 Qué NO hace

- ❌ No crea commits vacíos.
- ❌ No modifica archivos `.github-streak` artificiales.
- ❌ No commitea cambios locales del usuario sin revisión.
- ❌ No hace push automáticamente salvo que lo actives.
- ❌ No fuerza cambios si no hay mantenimiento real.

## 📦 Instalación

```bash
git clone https://github.com/AvilaCarlosDev/github-streak-keeper.git
cd github-streak-keeper
chmod +x auto-commit.sh
```

## 🚀 Uso

### Ejecutar sobre un repo

```bash
./auto-commit.sh /home/carlosdev/proyectos/mi-proyecto
```

### Ejecutar sobre varios repos

```bash
./auto-commit.sh \
  /home/carlosdev/proyectos/proyecto1 \
  /home/carlosdev/proyectos/proyecto2
```

### Modo simulación recomendado

Antes de automatizar, prueba sin crear commits:

```bash
STREAK_KEEPER_DRY_RUN=1 ./auto-commit.sh /home/carlosdev/proyectos/mi-proyecto
```

### Hacer push automáticamente

Por defecto el script crea commits locales, pero no hace push.

```bash
STREAK_KEEPER_PUSH=1 ./auto-commit.sh /home/carlosdev/proyectos/mi-proyecto
```

### Omitir tests/build

Útil si tienes repos lentos o sin entorno instalado:

```bash
STREAK_KEEPER_SKIP_TESTS=1 ./auto-commit.sh /home/carlosdev/proyectos/mi-proyecto
```

## ⏱️ Automatización con Cron

Ejemplo prudente: una revisión diaria.

```cron
# GitHub Streak Keeper - mantenimiento real diario
0 9 * * * STREAK_KEEPER_PUSH=1 /home/carlosdev/proyectos/github-streak-keeper/auto-commit.sh /home/carlosdev/proyectos/mi-proyecto >> /tmp/streak-keeper.log 2>&1
```

> Recomendación: evita correrlo 6 veces al día. Si el objetivo es mantenimiento real, 1 vez al día suele ser suficiente.

## 🧩 Automatización con Systemd Timer

Servicio:

```ini
# ~/.config/systemd/user/github-streak-keeper.service
[Unit]
Description=GitHub Streak Keeper - Real Maintenance
Documentation=https://github.com/AvilaCarlosDev/github-streak-keeper
After=network-online.target

[Service]
Type=oneshot
Environment=STREAK_KEEPER_PUSH=1
ExecStart=/home/carlosdev/proyectos/github-streak-keeper/auto-commit.sh /home/carlosdev/proyectos/mi-proyecto
```

Timer:

```ini
# ~/.config/systemd/user/github-streak-keeper.timer
[Unit]
Description=Run GitHub Streak Keeper daily

[Timer]
OnCalendar=*-*-* 09:00:00
Persistent=true
Unit=github-streak-keeper.service

[Install]
WantedBy=timers.target
```

Activar:

```bash
systemctl --user daemon-reload
systemctl --user enable --now github-streak-keeper.timer
systemctl --user list-timers
```

## 📋 Estrategia Recomendada

1. Usa repos reales, no repos de relleno.
2. Automatiza mantenimiento pequeño y verificable.
3. Revisa logs con frecuencia.
4. No ocultes fallos: si tests/build fallan, arregla el repo.
5. Prefiere pocos commits buenos a muchos commits sin valor.

## 📁 Estructura

```text
github-streak-keeper/
├── auto-commit.sh
├── examples/
│   ├── cron-example
│   ├── systemd-example.service
│   └── systemd-example.timer
├── README.md
├── LICENSE
└── .gitignore
```

## 🔧 Configuración

Variables disponibles:

| Variable | Uso |
|---|---|
| `CHECKPOINT_DIR` | Carpeta para checkpoints diarios. Default: `/tmp/streak-keeper` |
| `LOG_FILE` | Archivo de logs. Default: `/tmp/streak-keeper.log` |
| `STREAK_KEEPER_DRY_RUN=1` | Simula sin commitear |
| `STREAK_KEEPER_PUSH=1` | Hace push después del commit |
| `STREAK_KEEPER_SKIP_TESTS=1` | Omite `npm test` / `npm run build` |

## ⚠️ Nota ética

Este proyecto no busca fabricar actividad falsa. Busca ayudarte a convertir la consistencia en mantenimiento real: dependencias al día, validaciones pasando y repos saludables.

## 🤝 Contribuciones

¿Ideas para nuevos mantenedores seguros? Abre un issue o PR.

Posibles mejoras futuras:

- soporte para `pnpm-lock.yaml`,
- soporte para `yarn.lock`,
- soporte para Python `requirements.txt`,
- reportes Markdown diarios,
- integración opcional con GitHub Actions.

## 📄 Licencia

MIT License — ver [LICENSE](LICENSE).

---

*Workspace mantenido por Carlos Avila - Developer 🇻🇪*
