#!/bin/bash
readonly ICON="$HOME/.assets/icons/cpu.svg"

# Получаем температуру процессора из k10temp (Tctl)
TEMP=$(sensors k10temp-pci-00c3 -u | grep "temp1_input" | awk '{print $2}' | cut -d. -f1)

# Выводим результат для Genmon
echo "<img>${ICON}</img><txt> ${TEMP}°C</txt>"