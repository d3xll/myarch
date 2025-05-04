#!/bin/bash
readonly ICON="$HOME/.assets/icons/user.svg"

# Получаем имя пользователя
USER=$(whoami)

# Получаем имя хоста
HOST=$(hostnamectl hostname)

# Выводим результат для Genmon
echo "<img>${ICON}</img><txt> ${USER}@${HOST}</txt>"
# echo "<txt> ${USER}@${HOST}</txt>"