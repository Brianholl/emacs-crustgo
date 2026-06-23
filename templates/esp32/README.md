# Plantillas ESP32 (smoke test + arranque)

Plantillas listas para **probar que todo anda** y para **empezar un proyecto**.
A diferencia de los `examples/` (blink mínimo, para leer), estas imprimen por
serie además de parpadear: si en el monitor ves los `tick N`, confirmás de una
toda la cadena — **compilar → flashear → serie → GPIO**.

| Carpeta          | Lenguaje | ESP32 clásico (ZY) | ESP32-S3 (N16R8) |
|------------------|----------|:------------------:|:----------------:|
| `c-idf-hello/`   | C        | ✅ | ✅ |
| `rust-hello/`    | Rust     | ✅ | ✅ |
| `tinygo-hello/`  | Go       | ✅ | ❌ (TinyGo no soporta S3) |

## Cómo usarlas

1. Instalá las toolchains (una vez): `./install-esp32.sh` (en la raíz del repo).
2. Entrá a la plantilla de tu lenguaje y flasheá (o abrí en crustgo y **F6**):

```bash
# C
cd c-idf-hello   && get_idf && idf.py set-target esp32s3 && idf.py flash monitor
# Rust
cd rust-hello    && get_esp && cargo run --release
# Go (solo ESP32 clásico)
cd tinygo-hello  && tinygo flash -target=esp32 -monitor .
```

3. **Para arrancar un proyecto real:** copiá la carpeta y renombrá el proyecto
   (`project(...)` en `CMakeLists.txt`, `name` en `Cargo.toml`, o `module` en
   `go.mod`). El `.crustgo-flash` ya viene listo para el F6 de crustgo.

¿De cero? Mirá la guía [`../HOWTO.md`](../HOWTO.md). Cada carpeta tiene su README
con el detalle y lo que deberías ver en el monitor.
