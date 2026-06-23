// Plantilla "smoke test" de crustgo para TinyGo en el ESP32 clásico (ZY).
// Imprime por serie y parpadea el LED: si ves los "tick N" en el monitor,
// toda la cadena anda.
//
// OJO: TinyGo soporta el ESP32 clásico (-target=esp32), NO el ESP32-S3.
// El compilador `go` estándar no sirve: compilá SOLO con tinygo.
package main

import (
	"machine"
	"time"
)

func main() {
	led := machine.LED
	led.Configure(machine.PinConfig{Mode: machine.PinOutput})

	println("Hola desde crustgo! TinyGo funcionando.")

	n := 0
	for {
		led.Set(n%2 == 0)
		println("tick", n)
		n++
		time.Sleep(time.Second)
	}
}
