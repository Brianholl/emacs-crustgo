# Blink en Rust — esp-hal (no_std)

Para **ESP32-S3 (S3-N16R8)** y **ESP32 clásico (ZY)** — ambos Xtensa.

## Requisitos (una sola vez)

```bash
cargo install espup espflash
espup install              # instala el toolchain 'esp' (Rust para Xtensa)
. $HOME/export-esp.sh      # cargá el entorno en cada terminal nueva
```

> El `rust-toolchain.toml` de esta carpeta ya selecciona el canal `esp`.

## Compilar y flashear

Con el ESP32 conectado:

```bash
cargo run --release        # ← lo mismo que F5 o F6 en crustgo
```

`espflash` (configurado como `runner` en `.cargo/config.toml`) compila,
flashea y abre el monitor. Autodetecta el puerto; si hay varios:
`cargo run --release -- --port /dev/ttyACM0`.

## Cambiar de chip (S3 ↔ clásico)

Por defecto apunta al **S3**. Para el **ESP32 clásico (ZY)**:

1. En `.cargo/config.toml`: cambiá las dos `esp32s3` por `esp32`.
2. En `Cargo.toml`: cambiá la feature `esp32s3` por `esp32` en las 3 deps.

## ¿No compila por versión de esp-hal?

La API embebida de Rust cambia seguido. Lo más confiable es generar un esqueleto
fresco y pegarle el *glue* de crustgo:

```bash
cargo install esp-generate
esp-generate --chip esp32s3 mi-proyecto
# copiá a mi-proyecto: .cargo/config.toml, rust-toolchain.toml, .crustgo-flash
```

`rust-analyzer` funciona normal una vez cargado `export-esp.sh`.
