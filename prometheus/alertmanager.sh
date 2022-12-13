#!/bin/bash

#Установка Alertmanager
# скачайте последнюю версию приложения с GitHub
# Для 64-битного виртуального сервера выберите amd64 и сразу же извлеките его:
wget https://github.com/prometheus/alertmanager/releases/download/v0.24.0/alertmanager-0.24.0.linux-amd64.tar.gz
sudo tar -xvf alertmanager-*linux-amd64.tar.gz
# Скопируйте содержимое архива в папки:
sudo cp /home/user/alertmanager-*.linux-amd64/alertmanager /usr/local/bin
sudo cp /home/user/alertmanager-*.linux-amd64/amtool /usr/local/bin

#Скопируйте config-файл в папку Prometheus:
sudo cp /home/user/prometheus/alertmanager.yml /etc/prometheus
#Передайте пользователю Prometheus права на файл:
sudo chown -R prometheus:prometheus /etc/prometheus/alertmanager.yml

#Создаем сервис для работы с Alertmanager

sudo cp /home/user/prometheus/prometheus-alertmanager.service /etc/systemd/system/prometheus-alertmanager.service

# порт 9093

#Запуск
sudo systemctl enable prometheus-alertmanager
sudo systemctl start prometheus-alertmanager
# sudo systemctl status prometheus-alertmanager