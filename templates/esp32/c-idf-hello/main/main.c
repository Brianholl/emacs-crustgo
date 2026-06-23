// main.c — plantilla "smoke test" de crustgo para ESP-IDF.
// Imprime info del chip por el monitor serie y parpadea un LED:
// si ves los "tick N" en `idf.py monitor`, toda la cadena anda.
//
// LED_GPIO: GPIO2 en el ESP32 clasico (ZY). En el S3 DevKitC el LED on-board
// es RGB (WS2812, GPIO48) y no enciende con un GPIO simple; usa otro pin.
#include <stdio.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "driver/gpio.h"
#include "esp_chip_info.h"
#include "esp_flash.h"
#include "esp_log.h"

static const char *TAG = "crustgo";
#define LED_GPIO 2

void app_main(void)
{
    esp_chip_info_t chip;
    esp_chip_info(&chip);
    uint32_t flash_size = 0;
    esp_flash_get_size(NULL, &flash_size);

    ESP_LOGI(TAG, "Hola desde crustgo! ESP-IDF funcionando.");
    ESP_LOGI(TAG, "Chip: %d cores, rev %d, flash %u MB",
             chip.cores, (int) chip.revision,
             (unsigned) (flash_size / (1024 * 1024)));

    gpio_reset_pin(LED_GPIO);
    gpio_set_direction(LED_GPIO, GPIO_MODE_OUTPUT);

    int n = 0;
    while (1) {
        gpio_set_level(LED_GPIO, n & 1);
        ESP_LOGI(TAG, "tick %d", n++);
        vTaskDelay(pdMS_TO_TICKS(1000));
    }
}
