# Snapshots del proyecto (puntos de restauración)

## Snapshot actual: `frecuencia-maldita-3d-SNAPSHOT-2026-03-19.zip`

**Fecha:** 19–21 marzo 2026 (línea base estable acordada en el chat).

**Qué incluye:** copia del proyecto **sin** la carpeta `.godot` (Godot la regenera al abrir el proyecto). Incluye `main.gd`, escena principal, `assets/`, shaders, modelos, etc.

**Estado funcional de referencia (resumen):**

- Música ambiental: `res://assets/ambiente_fondo.mp3`, `MusicaFondo` con volumen base **-15 dB** y **autoplay**.
- Post-procesado PS1: `ColorRect` pantalla completa + `res://assets/ps1_horror.gdshader`, detrás de la UI.
- Mensaje de interacción: centrado abajo, mayúsculas, estilo amarillo + contorno.
- Rayos / radio / diálogo Arthur según la versión guardada en este ZIP.

---

### Cómo volver a este snapshot si algo se rompe

1. **Cierra Godot** (y el editor).
2. **Haz una copia de seguridad** de la carpeta del proyecto actual por si acaso (renómbrala o cópiala a otro sitio).
3. **Descomprime** `frecuencia-maldita-3d-SNAPSHOT-2026-03-19.zip` en una carpeta vacía **o** sobre el proyecto:
   - Opción segura: carpeta nueva → abres `project.godot` en Godot desde ahí.
   - Opción “volver aquí”: borra el contenido del proyecto (menos este ZIP si lo guardas fuera) y descomprime el ZIP dentro.
4. Abre el proyecto en **Godot 4.x**; espera a que termine la reimportación (`.godot` se crea de nuevo).

---

### Crear un snapshot nuevo más adelante

En PowerShell, desde la carpeta del proyecto:

```powershell
$root = "RUTA\A\frecuencia-maldita-3d"
$snapDir = Join-Path $root "snapshots"
$staging = Join-Path $snapDir "_staging_snapshot"
$zipName = "frecuencia-maldita-3d-SNAPSHOT-FECHA.zip"
$zipPath = Join-Path $snapDir $zipName
New-Item -ItemType Directory -Force -Path $snapDir | Out-Null
Remove-Item $staging -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path $staging | Out-Null
robocopy $root $staging /E /XD .godot snapshots .git
Compress-Archive -Path (Join-Path $staging '*') -DestinationPath $zipPath -Force
Remove-Item $staging -Recurse -Force
```

(Cambia `FECHA` por el día que quieras.)

---

### Si más adelante usas Git

```bash
git init
git add .
git commit -m "Snapshot baseline 2026-03-19"
git tag snapshot-2026-03-19
# Para volver:
# git checkout snapshot-2026-03-19
```

El ZIP sigue siendo útil aunque tengas Git (copia portable fuera del historial).
