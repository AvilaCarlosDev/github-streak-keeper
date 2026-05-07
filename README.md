# GitHub Streak Keeper - Mantén tu racha verde 🟩

> **No pierdas más tu racha de contribuciones en GitHub**

[![MIT License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/AvilaCarlosDev/github-streak-keeper?style=flat)](https://github.com/AvilaCarlosDev/github-streak-keeper/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/AvilaCarlosDev/github-streak-keeper?style=flat)](https://github.com/AvilaCarlosDev/github-streak-keeper/network)

## 🎯 El Problema

¿Te ha pasado? Te vas de vacaciones, te enfermas, o simplemente tienes una semana ocupada... y **puf** 🔥 — tu racha de 100+ días en GitHub desaparece.

Mantener una racha verde no es vanidad — es **disciplina visible**. Pero la vida pasa. Este repo te da las herramientas para mantener tu consistencia sin volverte loco.

## 🛠️ La Solución

`auto-commit.sh` es un script bash reutilizable que hace commits automáticos por ti. Configúralo una vez, olvídate, y mira cómo tu gráfico se mantiene verde.

### Características

- ✅ **Multi-repo:** Soporta múltiples repositorios simultáneos
- ✅ **Commits con propósito:** Mensajes descriptivos, no vacíos
- ✅ **Checkpoint inteligente:** Evita commits duplicados en el mismo día
- ✅ **Logs detallados:** Todo queda registrado en `/tmp/streak-keeper.log`
- ✅ **Manejo de errores:** Reporta fallos claramente

## 📦 Instalación

```bash
# Clona este repo
git clone https://github.com/AvilaCarlosDev/github-streak-keeper.git
cd github-streak-keeper

# Haz el script ejecutable
chmod +x auto-commit.sh
```

## 🚀 Uso

### Ejecución Manual

```bash
# Commit en un solo repo
./auto-commit.sh /home/carlosdev/proyectos/mi-proyecto

# Commit en múltiples repos
./auto-commit.sh /home/carlosdev/proyectos/proyecto1 /home/carlosdev/proyectos/proyecto2
```

### Automatización con Cron

Edita tu crontab:

```bash
crontab -e
```

Agrega 6 ejecuciones distribuidas durante el día:

```cron
# GitHub Streak Keeper - 6 veces al día
0 7 * * * /home/carlosdev/proyectos/github-streak-keeper/auto-commit.sh /home/carlosdev/proyectos/mi-proyecto >> /tmp/streak-keeper.log 2>&1
0 10 * * * /home/carlosdev/proyectos/github-streak-keeper/auto-commit.sh /home/carlosdev/proyectos/mi-proyecto >> /tmp/streak-keeper.log 2>&1
0 13 * * * /home/carlosdev/proyectos/github-streak-keeper/auto-commit.sh /home/carlosdev/proyectos/mi-proyecto >> /tmp/streak-keeper.log 2>&1
0 16 * * * /home/carlosdev/proyectos/github-streak-keeper/auto-commit.sh /home/carlosdev/proyectos/mi-proyecto >> /tmp/streak-keeper.log 2>&1
0 19 * * * /home/carlosdev/proyectos/github-streak-keeper/auto-commit.sh /home/carlosdev/proyectos/mi-proyecto >> /tmp/streak-keeper.log 2>&1
0 22 * * * /home/carlosdev/proyectos/github-streak-keeper/auto-commit.sh /home/carlosdev/proyectos/mi-proyecto >> /tmp/streak-keeper.log 2>&1
```

### Automatización con Systemd Timer (Recomendado)

Crea el servicio:

```ini
# ~/.config/systemd/user/github-streak-keeper.service
[Unit]
Description=GitHub Streak Keeper Auto-Commit

[Service]
Type=oneshot
ExecStart=/home/carlosdev/proyectos/github-streak-keeper/auto-commit.sh /home/carlosdev/proyectos/mi-proyecto
```

Crea el timer:

```ini
# ~/.config/systemd/user/github-streak-keeper.timer
[Unit]
Description=Run GitHub Streak Keeper every 2 hours

[Timer]
OnBootSec=10min
OnUnitActiveSec=2h
Persistent=true

[Install]
WantedBy=timers.target
```

Actívalo:

```bash
systemctl --user daemon-reload
systemctl --user enable --now github-streak-keeper.timer
systemctl --user list-timers
```

## 📋 Estrategias para Mantener tu Racha

### 1. **Múltiples Repos**
No dependas de un solo proyecto. Ten 2-3 repos activos para no quedarte sin commits si uno se estanca.

### 2. **Commits con Propósito**
Evita commits vacíos (`fix: typo`). Mejor:
- `docs: actualizar README con ejemplos de uso`
- `feat: agregar función de validación`
- `refactor: limpiar código duplicado`

### 3. **Backup Automático**
El script guarda checkpoints. Si algo falla, puedes recuperar el estado.

### 4. **Monitoreo**
Revisa los logs regularmente:

```bash
tail -f /tmp/streak-keeper.log
```

### 5. **No Confíes en la Memoria**
Automatiza. Los humanos olvidamos, los sistemas no.

## 📁 Estructura del Proyecto

```
github-streak-keeper/
├── auto-commit.sh      # Script principal de auto-commit
├── README.md           # Esta documentación
├── LICENSE             # MIT License
└── .gitignore          # Archivos ignorados por Git
```

## 🔧 Configuración Personalizada

Edita `auto-commit.sh` para ajustar:

- `CHECKPOINT_DIR`: Dónde guardar los checkpoints
- `LOG_FILE`: Dónde escribir los logs
- Los mensajes de commit (agrega los tuyos propios)

## ⚠️ Advertencias

- **GitHub detecta patrones:** No abuses. Commits muy frecuentes y vacíos pueden ser marcados.
- **Calidad > Cantidad:** Mejor un commit con código real que 10 vacíos.
- **Timezone:** GitHub usa UTC. Ajusta tus horarios según tu zona.

## 📊 Mi Racha Actual

[![GitHub Streak](https://streak-stats.demolab.com?user=AvilaCarlosDev&theme=dark&background=000000&border=42ffa1&dates=42ffa1&sideNums=ff8c69&currStreakNum=42ffa1)](https://git.io/streak-stats)

## 🤝 Contribuciones

¿Mejoras al script? ¿Estrategias adicionales? Abre un issue o PR.

## 📄 Licencia

MIT License — úsalo, modifícalo, compártelo. Ver [LICENSE](LICENSE).

---

**Hecho con 💚 en Venezuela** | [AvilaCarlosDev](https://github.com/AvilaCarlosDev)
