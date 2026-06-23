//! Blink no_std con esp-hal (ESP32-S3).
//!
//! ⚠️ La API de esp-hal cambia seguido entre versiones. Este main.rs sirve de
//! referencia para esp-hal 0.23; si usás otra versión y no compila, lo más
//! rápido es regenerarlo con la herramienta oficial:
//!
//!     cargo install esp-generate
//!     esp-generate --chip esp32s3 mi-proyecto   # o --chip esp32
//!
//! y después copiá a ese proyecto el .cargo/config.toml, rust-toolchain.toml
//! y .crustgo-flash de esta carpeta (ese es el "glue" de crustgo).

#![no_std]
#![no_main]

use esp_backtrace as _;
use esp_hal::{
    delay::Delay,
    gpio::{Level, Output},
    prelude::*,
};

#[entry]
fn main() -> ! {
    let peripherals = esp_hal::init(esp_hal::Config::default());
    let delay = Delay::new();

    // LED: GPIO2 en el ESP32 clásico. En el S3 DevKitC el LED on-board es RGB
    // (WS2812) y no sirve un GPIO simple — usá otro pin con un LED común.
    let mut led = Output::new(peripherals.GPIO2, Level::Low);

    loop {
        led.toggle();
        delay.delay_millis(500);
    }
}
