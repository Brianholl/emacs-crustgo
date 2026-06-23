# Proyecto ESP-IDF mínimo (blink). Requiere ESP-IDF v5.x.
# Antes de compilar:  . $HOME/esp/esp-idf/export.sh
cmake_minimum_required(VERSION 3.16)
include($ENV{IDF_PATH}/tools/cmake/project.cmake)
project(blink)
