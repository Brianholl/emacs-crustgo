//! Plantilla "smoke test" de crustgo para Rust + esp-hal (ESP32-S3, no_std).
//! Imprime por serie con esp-println y parpadea un LED: si ves los "tick N"
//! en el monitor, toda la cadena (compilar/flashear/serie/GPIO) anda.
//!
//! ⚠️ La API de esp-hal cambia entre versiones (esto es para ~0.23). Si no
//! compila, regenerá con `esp-generate --chip esp32s3 ...` y pegale el glue
//! (.cargo/config.toml, rust-toolchain.toml, .crustgo-flash).

#![no_std]
#![no_main]

use esp_backtrace as _;
use esp_hal::{
    delay::Delay,
    gpio::{Level, Output},
    prelude::*,
};
use esp_println::println;

#[entry]
fn main() -> ! {
    let peripherals = esp_hal::init(esp_hal::Config::default());
    let delay = Delay::new();

    // LED: GPIO2 en el ESP32 clásico. En el S3 DevKitC el LED es RGB (WS2812)
    // y un GPIO simple no lo enciende — usá otro pin con un LED común.
    let mut led = Output::new(peripherals.GPIO2, Level::Low);

    println!("Hola desde crustgo! Rust + esp-hal funcionando.");

    let mut n: u32 = 0;
    loop {
        led.toggle();
        println!("tick {}", n);
        n = n.wrapping_add(1);
        delay.delay_millis(1000);
    }
}
