# How-To: empezar con ESP32 en C, Rust y Go

Guía de cero a "LED parpadeando" con **crustgo**. Pensada para las placas de
Brian, pero sirve igual para cualquier ESP32 clásico o S3.

---

## 0. Tus placas

| Placa            | Chip         | Arquitectura | C (IDF) | Rust | Go (TinyGo) |
|------------------|--------------|--------------|:-------:|:----:|:-----------:|
| **S3-N16R8** ×2  | ESP32-**S3** | Xtensa LX7   | ✅ `esp32s3` | ✅ | ❌ |
| **ZY-ESP32** ×1  | ESP32 clásico| Xtensa LX6   | ✅ `esp32`   | ✅ | ✅ `esp32` |

- Los **dos S3** tienen 16 MB de flash y 8 MB de PSRAM (el `N16R8`).
- **TinyGo no soporta el S3** → en esas placas usá C o Rust.
- Como los tres son **Xtensa**, un solo `espup install` cubre Rust en todas.

---

## 1. Instalar las toolchains (una vez por máquina)

Desde la raíz del repo, en Arch/CachyOS:

```bash
./install-esp32.sh            # C + Rust + Go
# o selectivo:
./install-esp32.sh c rust     # c | rust | go
```

Eso instala ESP-IDF, espup/espflash y TinyGo, crea los atajos `get_idf` /
`get_esp` y te suma al grupo `uucp` (acceso al puerto serie).

> ⚠️ Después de la primera instalación, **cerrá sesión y volvé a entrar** una
> vez (para que tome el grupo `uucp`). Si no, vas a ver `Permission denied` al
> flashear.

---

## 2. Conectar la placa y encontrar el puerto

Enchufá el ESP32 por USB y mirá qué aparece:

```bash
ls /dev/ttyUSB* /dev/ttyACM* 2>/dev/null
```

- **ZY-ESP32** (chip CP2102/CH340) → suele ser `/dev/ttyUSB0`.
- **S3-N16R8** (USB nativo del chip) → suele ser `/dev/ttyACM0`.

Si tenés varias placas enchufadas, anotá cuál es cuál (después se lo pasás con
`-p`/`--port`). Para ver el log en vivo más tarde, todas las herramientas tienen
su propio "monitor".

> El S3 tiene **dos** conectores USB: uno es USB-UART y el otro el USB nativo
> (JTAG/serial). Si no aparece nada, probá el otro puerto del cable o el otro
> conector de la placa, y revisá que el cable sea de **datos** (no solo carga).

---

## 3. C con ESP-IDF

El camino oficial y más completo. Ejemplo: [`c-idf-blink/`](c-idf-blink/).

```bash
get_idf                       # carga el entorno de ESP-IDF (en cada terminal)
cd examples/esp32/c-idf-blink

idf.py set-target esp32s3     # o: esp32   (para el ZY)
idf.py build
idf.py flash monitor          # compila → flashea → abre el monitor
```

- Salir del monitor: **`Ctrl-]`**.
- Si no autodetecta el puerto: `idf.py -p /dev/ttyACM0 flash monitor`.

**Autocompletado (clangd) en crustgo:** ESP-IDF genera
`build/compile_commands.json`. Linkealo a la raíz para que crustgo lo use:

```bash
ln -s build/compile_commands.json .
```

**LED:** está en `GPIO2` (ZY). En el **S3 DevKitC** el LED on-board es RGB
(WS2812, GPIO48) y no se enciende con un GPIO simple — para la prueba rápida
poné un LED común en otro pin y cambiá `LED_GPIO` en `main/blink.c`.

---

## 4. Rust con esp-hal

Dos ejemplos:

- [`rust-blink/`](rust-blink/) — GPIO simple (esp-hal 0.23), corre en S3 y clásico.
- [`rust-sos-s3/`](rust-sos-s3/) — **LED RGB on-board WS2812** (esp-hal 1.0 +
  `esp-hal-smartled`), SOS en Morse. Solo S3, pero es el que **sí prende** el
  LED integrado del DevKitC.

```bash
get_esp                       # REQUERIDO: mete el linker Xtensa (gcc) en el PATH
cd examples/esp32/rust-blink  # o: rust-sos-s3

cargo run --release           # compila → flashea → monitor (vía espflash)
```

`espflash` está puesto como `runner` en `.cargo/config.toml`, así que
`cargo run` **flashea**. En crustgo, **F5 o F6** hacen lo mismo.

> **¿Usás `fish`?** El `. $HOME/export-esp.sh` (y `get_esp`) es sintaxis de
> bash/zsh; en fish tira `Unknown command: fish_add_path`. Guardá el equivalente
> en `~/export-esp.fish` (`set -x LIBCLANG_PATH …` + `fish_add_path …`) y hacé
> `source ~/export-esp.fish`. Ojo: algunas terminales corren el comando externo
> en **zsh** aunque tu shell sea fish — fijate cuál usás de verdad.

**Cambiar de chip (S3 ↔ clásico)** — solo aplica a `rust-blink`. Por defecto S3:
1. `.cargo/config.toml`: `esp32s3` → `esp32` (dos lugares).
2. `Cargo.toml`: feature `esp32s3` → `esp32` (tres deps).

> **¿No compila / no arranca por versiones de esp-hal?** La API embebida cambia
> seguido y los crates van en "trenes" (1.0, 1.1, …) que **no se mezclan**. En
> `rust-sos-s3`, `esp-hal-smartled` fija el tren 1.0, así que
> `esp-bootloader-esp-idf` va en **0.4.0** (el 0.5.0 es del tren 1.1 y rompe el
> arranque — ver tabla del paso 7). Para empezar de cero, regenerá el esqueleto
> y pegale el *glue* de crustgo (`.cargo/config.toml`, `rust-toolchain.toml`,
> `build.rs`, `.crustgo-flash`):
> ```bash
> cargo install esp-generate
> esp-generate --chip esp32s3 mi-proyecto
> ```

---

## 5. Go con TinyGo

**Solo para el ESP32 clásico (ZY).** Ejemplo: [`tinygo-blink/`](tinygo-blink/).

```bash
cd examples/esp32/tinygo-blink
tinygo flash -target=esp32 -monitor .
```

- Puerto manual: `-port=/dev/ttyUSB0`.
- El `go` estándar **no** compila a ESP32 — usá siempre `tinygo`.
- TinyGo cubre GPIO/UART/SPI/I2C y poco más; para algo serio, C o Rust.

---

## 6. El flujo en crustgo

| Tecla | Acción |
|-------|--------|
| **F5** | Compila/corre en el **host** (PC) — útil para probar lógica pura |
| **F6** | **Flashea al ESP32** (`crustgo-esp-flash`) |
| **F12** / **Shift-F12** | Definición / referencias (LSP) |
| **C-c l** | Prefijo de comandos LSP |

**F6** lee el archivo `.crustgo-flash` de cada proyecto (ya incluido en los
ejemplos) con el comando exacto. Si querés fijar el puerto, editá ese archivo:

```
idf.py -p /dev/ttyACM0 flash monitor
```

> En proyectos embebidos **no uses F5** (intentaría compilar para la PC y
> falla): usá **F6**.

**LSP por lenguaje** (anda apenas abrís el archivo, con el entorno cargado):
`clangd` (C/C++, con `compile_commands.json`), `rust-analyzer` (Rust, tras
`get_esp` si hace falta), `gopls` (Go del host; para TinyGo entiende la mayoría
del código aunque no todos los build tags).

### Debug

- **C / Rust:** `M-x gdb` (gdb nativo, ideal para ver **registros**) o
  `M-x dap-debug`. Recordá `M-x dap-cpptools-setup` la primera vez.
- **On-chip (JTAG):** el S3 trae JTAG por USB; con ESP-IDF: `idf.py openocd` +
  `idf.py gdb` en otra terminal.

---

## 7. Problemas comunes

| Síntoma | Causa / solución |
|---------|------------------|
| `Permission denied` en `/dev/ttyUSB0` | No estás en `uucp` todavía → re-logueá (paso 1). |
| No aparece `/dev/ttyUSB*` ni `ttyACM*` | Cable solo de carga, o probá el otro conector USB (sobre todo en el S3). |
| `idf.py: command not found` | Te faltó `get_idf` en esa terminal. |
| Falla al flashear / no sincroniza | Mantené **BOOT** apretado al conectar, o BOOT + reset. Bajá la velocidad: `idf.py -b 115200 flash`. |
| Rust: `error: toolchain 'esp' is not installed` | Corré `espup install` (o `./install-esp32.sh rust`). |
| Rust: ``error: linker `xtensa-esp32s3-elf-gcc` not found`` | No cargaste el entorno: `get_esp` (= `. ~/export-esp.sh`) antes de compilar. Es el linker Xtensa, hace falta hasta para no_std. |
| Rust no compila (API esp-hal) | Regenerá con `esp-generate` (paso 4). |
| Rust: `Image requires efuse blk rev >= v123.34` / `Factory app partition is not bootable` (loop infinito) | Versiones de distinto "tren": p.ej. `esp-bootloader-esp-idf 0.5.0` (tren 1.1) con `esp-hal 1.0`. El app descriptor sale corrupto. Alineá: con esp-hal 1.0 → `esp-bootloader-esp-idf = 0.4.0` (ver `rust-sos-s3`). |
| Rust: el bootloader lee "basura" / no arranca tras tocar el build | No metas `-Tlinkall.x` en `rustflags`: con esp-hal 1.0 lo inyecta `build.rs`. Dejá `rustflags = []` en `.cargo/config.toml`. |
| `fish`: `Unknown command: fish_add_path` al cargar el entorno | `export-esp.sh` es bash/zsh. En fish usá `~/export-esp.fish`. Y ojo: el comando externo de algunas terminales corre en **zsh**, no en fish. |
| `sudo: a terminal is required to read the password` (al dar permiso al puerto) | Corré el `chmod`/`usermod` en una **terminal real** (Konsole), no a través del prefijo `!`/IDE que no tiene tty. |
| TinyGo: `target not found: esp32s3` | TinyGo no soporta el S3 → usá C o Rust ahí. |
| El LED del S3 no parpadea | Es RGB (WS2812 en GPIO48): un GPIO simple no lo prende. En C usá el componente `led_strip`; en Rust mirá el ejemplo [`rust-sos-s3/`](rust-sos-s3/) (esp-hal-smartled). |

---

## 8. Chuleta de comandos

```bash
# Instalar todo
./install-esp32.sh

# C
get_idf; idf.py set-target esp32s3; idf.py build; idf.py flash monitor

# Rust
get_esp; cargo run --release            # espflash flashea + monitor

# Go (solo ESP32 clásico)
tinygo flash -target=esp32 -monitor .

# Ver puerto
ls /dev/ttyUSB* /dev/ttyACM*
```

Próximo paso: agarrá el ejemplo de tu lenguaje en `examples/esp32/`, flasheá, y
empezá a cambiar el `LED_GPIO` / los `delay` para ver que reacciona. 🚀
