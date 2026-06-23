# Blink en C — ESP-IDF

Para **ESP32 clásico (ZY)** y **ESP32-S3 (S3-N16R8)**.

## Requisitos

- **ESP-IDF v5.x** instalado (`~/esp/esp-idf`).
- Antes de cada sesión, cargá el entorno:
  ```bash
  . $HOME/esp/esp-idf/export.sh
  ```

## Compilar y flashear

```bash
idf.py set-target esp32s3     # o: esp32   (para el ZY)
idf.py build
idf.py flash monitor          # ← lo mismo que F6 en crustgo
```

`idf.py` autodetecta el puerto; si tenés varios, forzalo:
`idf.py -p /dev/ttyACM0 flash monitor` (el S3 con USB nativo suele ser
`ttyACM0`; el ZY con CP2102/CH340, `ttyUSB0`). Salir del monitor: `Ctrl-]`.

## Autocompletado (clangd)

ESP-IDF genera `build/compile_commands.json`. Para que crustgo/clangd lo use,
linkealo a la raíz del proyecto:

```bash
ln -s build/compile_commands.json .
```

> **Ojo F5 vs F6:** en este proyecto NO uses F5 (intentaría `gcc` del host y
> falla por los headers de IDF). Usá **F6** (`idf.py flash monitor`).

## LED

`LED_GPIO` está en **GPIO2** (ZY). En el **S3 DevKitC** el LED on-board es RGB
WS2812 (GPIO48) y necesita el componente `led_strip`; para la prueba rápida
poné un LED común en otro GPIO. Ver nota en `main/blink.c`.
