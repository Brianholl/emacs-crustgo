# Blink en Go — TinyGo

Solo para el **ESP32 clásico (ZY-ESP32)**. **TinyGo no soporta el ESP32-S3**;
en los S3-N16R8 usá C o Rust.

## Requisitos

- **TinyGo** (en Arch/CachyOS está en AUR: `tinygo-bin`).
- **esptool** para el flasheo (`pacman -S esptool` o `python-esptool`).

Verificá el soporte del target:

```bash
tinygo info esp32
```

## Compilar y flashear

```bash
tinygo flash -target=esp32 -monitor .   # ← lo mismo que F6 en crustgo
```

Si no autodetecta el puerto: `-port=/dev/ttyUSB0` (el ZY suele ser `ttyUSB0`).

> **F5 vs F6:** NO uses F5 acá (correría `go run .` del host y falla por el
> import `machine`). Usá **F6**, que ya corre `tinygo flash`.

## Límites

TinyGo en ESP32 cubre GPIO, UART, SPI, I2C y poco más; el scheduler de
goroutines es limitado. Para algo serio, C o Rust rinden mucho mejor.
