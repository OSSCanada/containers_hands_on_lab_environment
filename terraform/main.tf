#an attempt to keep the aci container group name (and dns label) somewhat unique
resource "random_integer" "random_int" {
  min = 1000
  max = 9999
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_group_name}${random_integer.random_int.result}"
  location = "${var.resource_group_location}"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${azurerm_resource_group.rg.name}-vnet"
  location            = "${azurerm_resource_group.rg.location}"
  address_space       = ["10.0.0.0/16"]
  resource_group_name = "${azurerm_resource_group.rg.name}"
}

resource "azurerm_subnet" "subnet" {
  name                 = "${azurerm_resource_group.rg.name}-subnet"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  address_prefix       = "10.0.0.128/25"
}

# ********************** NETWORK SECURITY GROUP **************************** #
resource "azurerm_network_security_group" "nsg" {
  name                = "${azurerm_resource_group.rg.name}-nsg"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  location            = "${azurerm_resource_group.rg.location}"

  security_rule {
    name                       = "allow-ssh"
    description                = "Allow SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-rdp"
    description                = "Allow RDP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-http"
    description                = "Allow HTTP"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-https"
    description                = "Allow HTTPS"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  tags {
    environment = "jumpbox"
  }
}

# ************************** NETWORK INTERFACES **************************** #
resource "azurerm_network_interface" "nic" {
  name                      = "${var.hostname}${random_integer.random_int.result}-nic"
  location                  = "${azurerm_resource_group.rg.location}"
  resource_group_name       = "${azurerm_resource_group.rg.name}"
  network_security_group_id = "${azurerm_network_security_group.nsg.id}"

  ip_configuration {
    name                          = "${var.hostname}${random_integer.random_int.result}-ipconfig"
    subnet_id                     = "${azurerm_subnet.subnet.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.pip.id}"
  }

  tags {
    environment = "Management"
  }
}

# ************************** PUBLIC IP ADDRESSES **************************** #
resource "azurerm_public_ip" "pip" {
  name                         = "${azurerm_virtual_machine.jumpbox.name}-pip"
  location                     = "${azurerm_resource_group.rg.location}"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  public_ip_address_allocation = "Dynamic"
  domain_name_label            = "${azurerm_virtual_machine.jumpbox.name}"

  tags {
    environment = "Management"
  }
}

# ***************************** STORAGE ACCOUNT **************************** #
resource "azurerm_storage_account" "stor" {
  name                     = "${azurerm_resource_group.rg.name}stor"
  location                 = "${azurerm_resource_group.rg.location}"
  resource_group_name      = "${azurerm_resource_group.rg.name}"
  account_tier             = "${var.storage_account_tier}"
  account_replication_type = "${var.storage_replication_type}"
}

# ***************************** VIRTUAL MACHINE **************************** #
resource "azurerm_virtual_machine" "jumpbox" {
  name                  = "${var.hostname}${random_integer.random_int.result}"
  location              = "${azurerm_resource_group.rg.location}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  vm_size               = "${var.vm_size}"
  network_interface_ids = ["${azurerm_network_interface.nic.id}"]

  storage_image_reference {
    publisher = "${var.image_publisher}"
    offer     = "${var.image_offer}"
    sku       = "${var.image_sku}"
    version   = "${var.image_version}"
  }

  storage_os_disk {
    name              = "${var.hostname}${random_integer.random_int.result}-osdisk"
    managed_disk_type = "Standard_LRS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
  }

  os_profile {
    computer_name  = "${var.hostname}${random_integer.random_int.result}"
    admin_username = "${var.admin_username}"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.admin_username}/.ssh/authorized_keys"
      key_data = "${file("~/.ssh/id_rsa.pub")}"
    }
  }

  boot_diagnostics {
    enabled     = true
    storage_uri = "${azurerm_storage_account.stor.primary_blob_endpoint}"
  }

  tags {
    environment = "Management"
  }
}
