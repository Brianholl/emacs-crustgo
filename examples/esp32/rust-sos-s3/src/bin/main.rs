//! SOS en Morse (azul) sobre el LED RGB on-board del ESP32-S3.
//!
//! Demuestra cómo manejar el WS2812/NeoPixel integrado (GPIO48 en el DevKitC)
//! vía el periférico RMT — eso que un `Output` simple NO puede prender.
//!
//! ⚠️ La API de esp-hal cambia seguido. Esto es esp-hal **1.0** + smartled 0.17.
//! Si algún día no compila, regenerá un esqueleto fresco y pegale el "glue" de
//! crustgo (.cargo/config.toml, rust-toolchain.toml, build.rs, .crustgo-flash):
//!
//!     cargo install esp-generate
//!     esp-generate --chip esp32s3 mi-proyecto
//!
//! Ojo con las versiones: ver el comentario grande en Cargo.toml (smartled fija
//! el "tren" de esp-hal y esp-bootloader-esp-idf tiene que acompañarlo).

#![no_std]
#![no_main]

use esp_backtrace as _;
use esp_hal::{clock::CpuClock, delay::Delay, main, rmt::Rmt, time::Rate};
use esp_hal_smartled::{smart_led_buffer, SmartLedsAdapter};
use log::info;
use smart_leds::{brightness, SmartLedsWrite, RGB8};

esp_bootloader_esp_idf::esp_app_desc!();

#[main]
fn main() -> ! {
    esp_println::logger::init_logger_from_env();

    let config = esp_hal::Config::default().with_cpu_clock(CpuClock::max());
    let peripherals = esp_hal::init(config);
    let delay = Delay::new();

    info!("Iniciando SOS en azul...");

    // RMT a 80 MHz controla el LED WS2812 on-board (GPIO48 en el S3 DevKitC).
    let rmt = Rmt::new(peripherals.RMT, Rate::from_mhz(80)).unwrap();
    let mut rmt_buffer = smart_led_buffer!(1);
    let mut led = SmartLedsAdapter::new(rmt.channel0, peripherals.GPIO48, &mut rmt_buffer);

    let blue = RGB8::new(0, 0, 255);
    let black = RGB8::new(0, 0, 0);

    // Enciende `color` por `duration_ms`, apaga y deja un hueco entre señales.
    let mut show_color = |color: RGB8, duration_ms: u32| {
        led.write(brightness([color; 1].into_iter(), 20)).unwrap(); // brillo 20/255
        delay.delay_millis(duration_ms);
        led.write(brightness([black; 1].into_iter(), 0)).unwrap();
        delay.delay_millis(300); // espacio entre señales
    };

    // === Alternativa: LED común de 2 pines en otro GPIO (p.ej. GPIO2) ===
    // Descomentá esto, comentá el bloque WS2812 de arriba y agregá a los `use`:
    //     esp_hal::gpio::{Level, Output}
    //
    // let mut led = Output::new(peripherals.GPIO2, Level::Low);
    // let mut show_color = |_, duration_ms: u32| {
    //     led.set_high();
    //     delay.delay_millis(duration_ms);
    //     led.set_low();
    //     delay.delay_millis(300);
    // };
    // let blue = RGB8::new(0, 0, 0); // dummy, no se usa con LED simple

    let dot = 300; // punto (S)
    let dash = 900; // raya (O)
    let word_gap = 2000; // pausa antes de repetir

    loop {
        info!("S (. . .)");
        for _ in 0..3 {
            show_color(blue, dot);
        }
        delay.delay_millis(300);

        info!("O (- - -)");
        for _ in 0..3 {
            show_color(blue, dash);
        }
        delay.delay_millis(300);

        info!("S (. . .)");
        for _ in 0..3 {
            show_color(blue, dot);
        }

        info!("Pausa...");
        delay.delay_millis(word_gap);
    }
}
