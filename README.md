# emacs-crustgo

```text
 ██████╗██████╗ ██╗   ██╗███████╗████████╗ ██████╗  ██████╗
██╔════╝██╔══██╗██║   ██║██╔════╝╚══██╔══╝██╔════╝ ██╔═══██╗
██║     ██████╔╝██║   ██║███████╗   ██║   ██║  ███╗██║   ██║
██║     ██╔══██╗██║   ██║╚════██║   ██║   ██║   ██║██║   ██║
╚██████╗██║  ██║╚██████╔╝███████║   ██║   ╚██████╔╝╚██████╔╝
 ╚═════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝   ╚═╝    ╚═════╝  ╚═════╝
```

**Versión 1.0**

Un Emacs **mínimo para lenguajes de sistemas**: **C, C++, Rust y Go**.
Tema oscuro, `lsp-mode` (clangd / rust-analyzer / gopls) y debug con `gdb`/`dap`.
Sin org-mode, sin IA, sin adornos.

El nombre lo dice todo: **C** + **Rust** + **Go** = `crustgo` (con C++ de yapa).

Es el hermano de [crisol](https://github.com/Brianholl/emacs-crisol)
(que hace sólo C): la misma filosofía de "una cosa, bien hecha", pero ampliada
a los cuatro lenguajes de sistemas que más se usan.

---

## Características

- 🌑 **Tema oscuro** (`doom-one`) con **números de línea** relativos al costado
- 🧠 **LSP por lenguaje** — autocompletado, errores en vivo y navegación:
  - **C / C++** → `clangd`
  - **Rust** → `rust-analyzer`
  - **Go** → `gopls`
- 🐛 **Debug** — `dap-mode` + el `gdb` nativo de Emacs (ideal para ver **registros**);
  para Go, `delve` (`dlv`)
- ⚡ **Compilar/correr con F5** — detecta el proyecto (`Cargo.toml`, `go.mod`,
  `Makefile`) o, si no hay, compila el archivo suelto según su lenguaje
- ✍️ **Autocompletado** con `company`
- 🎨 **Formateo al guardar** — `rustfmt` (Rust) y `gofmt` + organizar imports (Go)
- 🪶 **Liviano y plano** — dos archivos de elisp, sin org-mode ni tangle

---

## Requisitos

- **Emacs 29+** (probado en 30.2)
- **C / C++:** `gcc`, `g++`, `gdb`, `make`, `clangd` (en Arch, `clang`)
- **Rust:** `rustc`, `cargo`, `rust-analyzer`
- **Go:** `go`, `gopls` y, para depurar, `delve` (`dlv`)

El `install.sh` instala todo esto en Arch Linux (y `dlv` con `go install`).

---

## Instalación

```bash
git clone https://github.com/Brianholl/emacs-crustgo.git ~/Dev/emacs-crustgo
cd ~/Dev/emacs-crustgo
./install.sh
```

El script:

1. Instala las dependencias del sistema con `pacman` (pedirá contraseña de sudo).
2. Instala `delve` (debugger de Go) con `go install`.
3. Crea la función/alias de terminal (`fish`, `bash`, `zsh`) `crustgo`.
4. Descarga los paquetes de Emacs en `elpa/` (la primera vez tarda un poco).

> En distros sin `pacman`, instalá las dependencias a mano; el resto del script
> funciona igual.

---

## Uso

Abrí una terminal nueva y ejecutá:

```bash
crustgo            # abre Emacs con la config de crustgo
crustgo main.rs    # abre Emacs directamente en un archivo
```

Equivale a `emacs --init-directory ~/Dev/emacs-crustgo/`.

### Atajos

| Tecla        | Acción                                   |
|--------------|------------------------------------------|
| `F5`         | Guardar y **compilar/correr**            |
| `F12`        | Ir a la **definición** (LSP)             |
| `Shift-F12`  | Buscar **referencias** (LSP)             |
| `C-c l`      | Prefijo de comandos LSP                  |
| `M-x gdb`    | Iniciar el **debugger** (C/C++/Rust)     |
| `M-x dap-debug` | Debug por dap (incl. **Go** con delve) |

### Compilar/correr (F5)

`F5` guarda y elige qué hacer en este orden:

| Si encuentra…                | Corre                                            |
|------------------------------|--------------------------------------------------|
| `Cargo.toml` (archivo `.rs`) | `cargo run`                                       |
| `go.mod` (archivo `.go`)     | `go run .`                                         |
| `Makefile` (archivo C/C++)   | `make`                                            |
| `.c` suelto                  | `gcc -Wall -Wextra -g … && ./bin`                 |
| `.cpp`/`.cc`/`.cxx` suelto   | `g++ -std=c++17 -Wall -Wextra -g … && ./bin`      |
| `.rs` suelto                 | `rustc … && ./bin`                                |
| `.go` suelto                 | `go run archivo.go`                               |

### Debug y registros

Para C/C++/Rust, lo más sólido para **ver los registros** es el gdb nativo:

1. `M-x gdb` e iniciá tu binario (compilá antes con `-g`, que F5 ya hace).
2. Está activado `gdb-many-windows`: tenés código, locals, stack y breakpoints.
3. Para los registros: `M-x gdb-display-registers-buffer`. Se actualizan en cada paso.

También está `dap-mode` (`M-x dap-debug`) para un flujo más moderno.

> **Nota:** Para que `dap-mode` funcione la primera vez en C/C++/Rust, descargá
> el adaptador de VSCode ejecutando en Emacs: `M-x dap-cpptools-setup`.
> Para **Go**, usá `M-x dap-debug` → plantilla "Go Dlv …" (requiere `dlv`).

---

## ESP32 / embebido (F6)

crustgo también sirve para programar **ESP32** en C, Rust y (con límites) Go.
El editor/LSP funciona igual; el build+flash lo hace cada ecosistema:

- **C / C++** → ESP-IDF (`idf.py`)
- **Rust** → `espup` + `espflash` (`cargo run` flashea)
- **Go** → TinyGo (solo ESP32 clásico, no el S3)

`F5` compila/corre en el **host**; para microcontroladores usá **`F6`**
(`crustgo-esp-flash`), que lee un archivo `.crustgo-flash` del proyecto con el
comando de flasheo (o detecta ESP-IDF/cargo/TinyGo).

Para instalar las tres cadenas (ESP-IDF, espup/espflash, TinyGo) de una:

```bash
./install-esp32.sh            # o: ./install-esp32.sh c rust go
```

Hay un "blink" listo por lenguaje en [`examples/esp32/`](examples/esp32/) —
más un [`rust-sos-s3/`](examples/esp32/rust-sos-s3/) que maneja el **LED RGB
on-board (WS2812)** del ESP32-S3 con `esp-hal` 1.0 — plantillas de arranque con
auto-test por serie en [`templates/esp32/`](templates/esp32/), y una guía paso a
paso (con troubleshooting de versiones de esp-hal) en
[`examples/esp32/HOWTO.md`](examples/esp32/HOWTO.md).

---

## Estructura

```
emacs-crustgo/
├── early-init.el   UI temprana (sin barras), GC de arranque
├── init.el         la configuración completa (F5 compila · F6 flashea ESP32)
├── install.sh      instala dependencias + dlv + alias/funciones + paquetes
├── install-esp32.sh  toolchains ESP32: ESP-IDF + espup/espflash + TinyGo
├── examples/esp32/ blink en C (ESP-IDF), Rust (esp-hal) y Go (TinyGo) + SOS RGB del S3
├── templates/esp32/  plantillas de arranque (hello+blink, auto-test por serie)
├── .gitignore      excluye elpa/ y cachés
└── elpa/           paquetes de Emacs (no se versiona)
```

---

## Licencia

MIT.
