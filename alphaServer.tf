# Configure the Microsoft Azure Provider
provider "azurerm" {
    version = "~>2.0"
    features {}
# For this you need to create service pricipal in azure. 
    subscription_id = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    client_id       = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    client_secret   = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    tenant_id       = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
}

# Create a resource group if it doesn't exist
resource "azurerm_resource_group" "sshterraformgroup" {
    name     = "sshResourceGroup"
    location = "eastus"

    tags = {
        environment = "SSH Demo"
    }
}

# Create virtual network
resource "azurerm_virtual_network" "sshterraformnetwork" {
    name                = "sshVnet"
    address_space       = ["10.0.0.0/16"]
    location            = "eastus"
    resource_group_name = azurerm_resource_group.sshterraformgroup.name

    tags = {
        environment = "SSH Demo"
    }
}

# Create subnet
resource "azurerm_subnet" "sshterraformsubnet" {
    name                 = "sshSubnet"
    resource_group_name  = azurerm_resource_group.sshterraformgroup.name
    virtual_network_name = azurerm_virtual_network.sshterraformnetwork.name
    address_prefix       = "10.0.1.0/24"
}

# Create public IPs
resource "azurerm_public_ip" "sshterraformpublicip" {
    name                         = "sshPublicIP"
    location                     = "eastus"
    resource_group_name          = azurerm_resource_group.sshterraformgroup.name
    allocation_method            = "Dynamic"

    tags = {
        environment = "SSH Demo"
    }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "sshterraformnsg" {
    name                = "sshNetworkSecurityGroup"
    location            = "eastus"
    resource_group_name = azurerm_resource_group.sshterraformgroup.name
    
    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = "SSH Demo"
    }
}

# Create network interface
resource "azurerm_network_interface" "sshterraformnic" {
    name                      = "sshNIC"
    location                  = "eastus"
    resource_group_name       = azurerm_resource_group.sshterraformgroup.name

    ip_configuration {
        name                          = "sshNicConfiguration"
        subnet_id                     = azurerm_subnet.sshterraformsubnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.sshterraformpublicip.id
    }

    tags = {
        environment = "SSH Demo"
    }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "sshexample" {
    network_interface_id      = azurerm_network_interface.sshterraformnic.id
    network_security_group_id = azurerm_network_security_group.sshterraformnsg.id
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = azurerm_resource_group.sshterraformgroup.name
    }
    
    byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "sshstorageaccount" {
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = azurerm_resource_group.sshterraformgroup.name
    location                    = "eastus"
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags = {
        environment = "SSH Demo"
    }
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "sshterraformvm" {
    name                  = "sshVM"
    location              = "eastus"
    resource_group_name   = azurerm_resource_group.sshterraformgroup.name
    network_interface_ids = [azurerm_network_interface.sshterraformnic.id]
    size                  = "Standard_DS1_v2"

    os_disk {
        name              = "sshOsDisk"
        caching           = "ReadWrite"
        storage_account_type = "Premium_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04.0-LTS"
        version   = "latest"
    }

    computer_name  = "sshvm"
    admin_username = "sshadmin"
    disable_password_authentication = true
        
    admin_ssh_key {
        username       = "sshadmin"
        public_key     = file("/Users/sajal.golas/.ssh/sshdemo.pub")
    }

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.sshstorageaccount.primary_blob_endpoint
    }

    tags = {
        environment = "SSH Demo"
    }
}