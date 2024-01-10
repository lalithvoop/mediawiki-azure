resource "random_password" "linux-vm-password" {
  length           = 15
  min_lower        = 5
  min_upper        = 3
  numeric          = true
  special          = true
  min_special      = 1
  override_special = "!@#$%&"
}


resource "azurerm_linux_virtual_machine" "tw-linux-vm" {
  name                = var.vm-name
  resource_group_name = azurerm_resource_group.tw-rg.name
  location            = azurerm_resource_group.tw-rg.location
  size                = var.vm-size
  admin_username      = var.vm_admin_user

  admin_password = random_password.linux-vm-password.result
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.tw-nic.id,
  ]

  admin_ssh_key {
    username   = var.vm_admin_user
    public_key = file("${var.public_key_location}")
  }

  os_disk {
    caching              = var.os_disk_caching
    storage_account_type = var.storage_acc
  }

    source_image_reference {
        publisher = var.vm_image
        offer = var.vm_offer
        sku= var.vm_os_sku
        version= var.vm_version
                    
   }
    
}

resource "null_resource" "remote_install" {

    connection {
        type = "ssh"
        user = var.vm_admin_user
        password = random_password.linux-vm-password.result
        host = azurerm_public_ip.pip.ip_address
        port = 22
    }
    provisioner "file" {
        source = "automation_script.sh"
        destination = "/tmp/automation_script.sh"
    }

    provisioner "remote-exec" {
        inline = [
            "chmod +x /tmp/automation_script.sh",
            "/bin/bash /tmp/automation_script.sh"
        ]
    }
}