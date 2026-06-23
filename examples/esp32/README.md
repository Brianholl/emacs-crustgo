# Ejemplos ESP32

Tres "blink" mínimos, uno por lenguaje, pensados para las placas de Brian:

| Carpeta          | Lenguaje | ESP32 clásico (ZY) | ESP32-S3 (N16R8) | Toolchain |
|------------------|----------|:------------------:|:----------------:|-----------|
| `c-idf-blink/`   | C        | ✅ | ✅ | ESP-IDF v5 (`idf.py`) |
| `rust-blink/`    | Rust     | ✅ | ✅ | `espup` + `espflash` |
| `tinygo-blink/`  | Go       | ✅ | ❌ | TinyGo + esptool |

> Los **dos S3-N16R8** son Xtensa (Rust: toolchain `esp`). El **ZY-ESP32** es
> el ESP32 clásico, también Xtensa. **TinyGo no soporta el S3** → en esas
> placas, C o Rust.

## Flashear desde crustgo: F6

`F5` compila/corre en el **host**; para microcontroladores usá **`F6`**
(`crustgo-esp-flash`). Cada ejemplo trae un archivo **`.crustgo-flash`** con el
comando exacto, que es lo que F6 ejecuta (con fallback a detectar
ESP-IDF/cargo/TinyGo si no está).

Editá ese archivo si necesitás fijar el puerto o el target, por ejemplo:

```
idf.py -p /dev/ttyACM0 flash monitor
```

Cada carpeta tiene su propio `README.md` con los requisitos y los pasos.

## Resumen de qué instalar

- **C:** ESP-IDF v5 (`~/esp/esp-idf`, `. export.sh`).
- **Rust:** `cargo install espup espflash` → `espup install` → `. ~/export-esp.sh`.
- **Go:** `tinygo` (AUR `tinygo-bin`) + `esptool`.
