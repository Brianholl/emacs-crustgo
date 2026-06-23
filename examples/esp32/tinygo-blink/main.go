// Blink con TinyGo en el ESP32 clásico (target esp32).
//
// OJO: TinyGo soporta el ESP32 clásico (-target=esp32) y el C3
// (-target=esp32-c3), pero NO el ESP32-S3. En tus placas S3-N16R8 usá
// C (ESP-IDF) o Rust; este ejemplo es para el ZY-ESP32.
//
// El compilador `go` estándar NO sirve para microcontroladores: esto se
// compila SOLO con tinygo.
package main

import (
	"machine"
	"time"
)

func main() {
	// machine.LED = GPIO2 en el target esp32.
	led := machine.LED
	led.Configure(machine.PinConfig{Mode: machine.PinOutput})

	for {
		led.High()
		time.Sleep(500 * time.Millisecond)
		led.Low()
		time.Sleep(500 * time.Millisecond)
	}
}
