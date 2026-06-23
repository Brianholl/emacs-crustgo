// blink.c — parpadeo mínimo con ESP-IDF (FreeRTOS + driver gpio).
//
// LED:
//   - ESP32 clásico (ZY): casi siempre GPIO2.
//   - ESP32-S3 DevKitC-1: el LED on-board es RGB direccionable (WS2812)
//     en GPIO48 → NO se enciende con gpio_set_level; necesitás el
//     componente `led_strip`. Para una prueba rápida en el S3, conectá
//     un LED común a cualquier GPIO y cambiá LED_GPIO.
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "driver/gpio.h"

#define LED_GPIO 2

void app_main(void)
{
    gpio_reset_pin(LED_GPIO);
    gpio_set_direction(LED_GPIO, GPIO_MODE_OUTPUT);

    while (1) {
        gpio_set_level(LED_GPIO, 1);
        vTaskDelay(pdMS_TO_TICKS(500));
        gpio_set_level(LED_GPIO, 0);
        vTaskDelay(pdMS_TO_TICKS(500));
    }
}
