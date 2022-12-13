// Create several similar vm 

// Configure the Yandex Cloud provider

terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  token     = var.OAuthTocken
  cloud_id  = "b1gob4asoo1qa32tbt9b"
  folder_id = "b1gob4asoo1qa32tbt9b"
  zone      = "ru-central1-a"
}


  
//create vm

resource "yandex_compute_instance" "vm" {
  name = "${var.guest_name_prefix}-vm0${count.index + 1}" #variables.tf 
  count = 2


  resources {
    cores     = 2
    memory    = 2
  
  }

  boot_disk {
    initialize_params {
      image_id = "fd8456n7d102l8p6ipgl" #Debian 11
      type     = "network-ssd"
      size     = "16"
    }
  }

  network_interface {
    subnet_id = "e9bf0qhr78eltofkhvbb"
    nat       = true
    ip_address     = lookup(var.vm_ips, count.index) #terraform.tfvars
    }

  
  metadata = {
    user-data = "${file("./meta.txt")}"
  }

  scheduling_policy {
    preemptible = true
  }

  # Copy in the bash script we want to execute.
  # The source is the location of the bash script
  # on the local linux box you are executing terraform
  # from.  The destination is on the new  instance.
  provisioner "file" {
    source      = "/home/user/terraform/checked-versions/prometheus"
    destination = "/home/user/prometheus"
  }  
  
  connection {
    host = lookup(var.vm_ips, count.index) #terraform.tfvars
    type        = "ssh"
    private_key = "${file("~/.ssh/id_rsa")}"
    port        = 22
    user        = "user"
    agent       = false
    timeout     = "1m"
  }

  # Change name and install Node Exporter on bash script and execute from user.

  provisioner "remote-exec" {
    
    inline = [
      "sudo hostnamectl set-hostname ${var.guest_name_prefix}-vm0${count.index + 1}",
      "sudo timedatectl set-timezone Europe/Moscow",
      "sudo sed -i '$a127.0.0.1 ${var.guest_name_prefix}-vm0${count.index + 1}' /etc/hosts",
      "chmod +x /home/user/prometheus/node_exporter.sh",
      "sudo /home/user/prometheus/node_exporter.sh",
    ]  
  }
}

resource "yandex_compute_instance" "makhota-prometheus" {
  name = "makhota-prometheus" 


  resources {
    cores     = 4
    memory    = 4
  
  }

  boot_disk {
    initialize_params {
      image_id = "fd8456n7d102l8p6ipgl" #Debian 11
      type     = "network-ssd"
      size     = "16"
    }
  }

  network_interface {
    subnet_id = "e9bf0qhr78eltofkhvbb"
    nat       = true
    ip_address     = "10.128.0.103"
    }

  
  metadata = {
    user-data = "${file("./meta.txt")}"
  }

  scheduling_policy {
    preemptible = true
  }

  # Copy in the bash script we want to execute.
  # The source is the location of the bash script
  # on the local linux box you are executing terraform
  # from.  The destination is on the new  instance.
  provisioner "file" {
    source      = "/home/user/terraform/checked-versions/prometheus"
    destination = "/home/user/prometheus"
  }  
  
  connection {
    host = "10.128.0.103"
    type        = "ssh"
    private_key = "${file("~/.ssh/id_rsa")}"
    port        = 22
    user        = "user"
    agent       = false
    timeout     = "1m"
  }

  # Change name and permissions on bash script and execute from user.

  provisioner "remote-exec" {
    
    inline = [
      "sudo hostnamectl set-hostname makhota-prometheus",
      "sudo sed -i '$a127.0.0.1 makhota-prometheus' /etc/hosts",
      "sudo timedatectl set-timezone Europe/Moscow",
      "chmod +x /home/user/prometheus/prometheus.sh",
      "sudo /home/user/prometheus/prometheus.sh",
      "chmod +x /home/user/prometheus/node_exporter.sh",
      "sudo /home/user/prometheus/node_exporter.sh",
      "chmod +x /home/user/prometheus/grafana.sh",
      "sudo /home/user/prometheus/grafana.sh",
      "chmod +x /home/user/prometheus/alertmanager.sh",
      "sudo /home/user/prometheus/alertmanager.sh",
      "chmod +x /home/user/prometheus/docker.sh",
      "sudo /home/user/prometheus/docker.sh",
    ]  
  }
}
