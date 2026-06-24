# SOS en el LED RGB del ESP32-S3 — esp-hal 1.0 (no_std)

Parpadea **SOS en Morse (azul)** usando el **LED RGB on-board (WS2812 / NeoPixel
en GPIO48)** del ESP32-S3 DevKitC, manejado por el periférico **RMT**.

Es el complemento del [`rust-blink/`](../rust-blink/): aquél muestra un GPIO
simple (y avisa que el LED del S3 *no* prende así); **este maneja de verdad el
LED RGB integrado**. Solo para **ESP32-S3** (el ESP32 clásico no trae WS2812).

## Requisitos (una sola vez)

```bash
cargo install espup espflash
espup install              # instala el toolchain 'esp' (Rust para Xtensa)
```

Y cargá el entorno **en cada terminal nueva** antes de compilar:

```bash
. $HOME/export-esp.sh      # bash / zsh
```

> **¿Usás `fish`?** `export-esp.sh` es sintaxis de bash y tira
> `Unknown command: fish_add_path`. Guardá el equivalente en `~/export-esp.fish`
> (`set -x LIBCLANG_PATH …` + `fish_add_path …`) y hacé `source ~/export-esp.fish`.
> Ojo: algunas terminales corren el prefijo de comando externo en **zsh** aunque
> tu shell sea fish — fijate cuál usás de verdad.

## Compilar y flashear

Con el S3 conectado por el **USB nativo** (suele ser `/dev/ttyACM0`):

```bash
cargo run --release        # ← lo mismo que F6 en crustgo
```

`espflash` (puesto como `runner` en `.cargo/config.toml`) compila, flashea y abre
el monitor. Vas a ver el log `Iniciando SOS en azul...` y el LED azul haciendo
`· · ·   — — —   · · ·`.

## El detalle que importa: versiones alineadas

`esp-hal-smartled` (para el WS2812) hoy fija **`esp-hal ~1.0`**, así que todo el
proyecto vive en el *tren 1.0*. La trampa: `esp-bootloader-esp-idf` **0.5.0** es
del tren **1.1** y, combinado con esp-hal 1.0, genera un "app descriptor" que el
bootloader lee como basura → la placa **no arranca**:

```
E (90) boot_comm: Image requires efuse blk rev >= v123.34, but chip is v1.3
E (96) boot: Factory app partition is not bootable
```

**Fix:** mantener `esp-bootloader-esp-idf = 0.4.0` (tren 1.0). Ver el comentario
grande en [`Cargo.toml`](Cargo.toml). Regla general: **smartled manda el tren**.

## ¿No compila por versión de esp-hal?

Regenerá un esqueleto fresco y pegale el *glue* de crustgo (`.cargo/config.toml`,
`rust-toolchain.toml`, `build.rs`, `.crustgo-flash`):

```bash
cargo install esp-generate
esp-generate --chip esp32s3 mi-proyecto
```
