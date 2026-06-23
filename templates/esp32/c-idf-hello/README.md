# Plantilla C — ESP-IDF (hello + blink)

Smoke test: imprime info del chip + un contador por serie y parpadea el LED.

```bash
get_idf                       # cargar entorno ESP-IDF
idf.py set-target esp32s3     # o: esp32  (para el ZY)
idf.py build
idf.py flash monitor          # F6 en crustgo
```

**Anda si** en el monitor ves:

```
I (xxx) crustgo: Hola desde crustgo! ESP-IDF funcionando.
I (xxx) crustgo: Chip: 2 cores, rev 0, flash 16 MB
I (xxx) crustgo: tick 0
I (xxx) crustgo: tick 1
...
```

Salir del monitor: `Ctrl-]`. Para clangd: `ln -s build/compile_commands.json .`

> Empezá tu proyecto copiando esta carpeta y renombrando `project(...)` en
> `CMakeLists.txt`.
