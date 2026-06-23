# Plantilla ESP-IDF (hello + blink). Requiere ESP-IDF v5.x.
#   . $HOME/esp/esp-idf/export.sh   (o el atajo: get_idf)
cmake_minimum_required(VERSION 3.16)
include($ENV{IDF_PATH}/tools/cmake/project.cmake)
project(crustgo_hello)
