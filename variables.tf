variable "vnet-address-space" {
    type = string
    description = ""
}

variable "subnet-address-space" {
    type = string
}

variable "vm-name" {
    type = string
}

variable "vm-size" {
    type = string
}

variable "vm_admin_user" {
    type = string
}

variable "os_disk_caching" {
    type = string
}

variable "storage_acc" {
    type = string
}

variable "vm_image" {
    type = string
}

variable "vm_offer" {
  type = string
}

variable "vm_version" {
  type = string
}

variable "vm_os_sku" {
    type = string
}

variable "public_key_location" {
    type = string
}