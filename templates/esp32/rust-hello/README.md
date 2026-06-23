# Plantilla Rust — esp-hal (hello + blink)

Smoke test no_std: imprime por serie con `esp-println` y parpadea el LED.

```bash
get_esp                  # entorno del toolchain 'esp' (si hace falta)
cargo run --release      # compila → flashea → monitor   (F6 en crustgo)
```

**Anda si** en el monitor ves:

```
Hola desde crustgo! Rust + esp-hal funcionando.
tick 0
tick 1
...
```

**Cambiar de chip:** por defecto apunta al **S3**. Para el **clásico (ZY)**:
`esp32s3` → `esp32` en `.cargo/config.toml` (2x) y en `Cargo.toml` (3 deps).

> Empezá tu proyecto copiando esta carpeta y cambiando `name` en `Cargo.toml`.
> Si la versión de esp-hal no compila: `esp-generate --chip esp32s3 ...`.
