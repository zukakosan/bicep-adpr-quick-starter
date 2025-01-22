param location string

param spokeVmName string
param onpVmName string
param addsPrivateIpAddress string

param vmAdminUserName string
@secure()
param vmAdminPassword string

resource vnetSpoke 'Microsoft.Network/virtualNetworks@2022-05-01' existing = {
  name: 'vnet-spoke'
  resource vmSubnet 'subnets' existing = {
    name: 'subnet-001'
  }
}

resource vnetOnp 'Microsoft.Network/virtualNetworks@2022-05-01' existing = {
  name: 'vnet-onp'
  resource addsSubnet 'subnets' existing = {
    name: 'subnet-001'
  }
}

resource spokeVmNic 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: '${spokeVmName}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: vnetSpoke::vmSubnet.id
          }
        }
      }
    ]
  }
}

resource spokeWindowsVM 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: spokeVmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2ms'
    }
    osProfile: {
      computerName: spokeVmName
      adminUsername: vmAdminUserName
      adminPassword: vmAdminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-datacenter-azure-edition'
        version: 'latest'
      }
      osDisk: {
        name: '${spokeVmName}-osdisk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: spokeVmNic.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: false
      }
    }
  }
}

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2024-05-01' = {
  name: '${onpVmName}-pip'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource onpVmNic 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: '${onpVmName}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: addsPrivateIpAddress
          subnet: {
            id: vnetOnp::addsSubnet.id
          }
          publicIPAddress: {
            id: publicIPAddress.id
          }
        }
      }
    ]
  }
}

resource onpWindowsVM 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: onpVmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2ms'
    }
    osProfile: {
      computerName: onpVmName
      adminUsername: vmAdminUserName
      adminPassword: vmAdminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-datacenter-azure-edition'
        version: 'latest'
      }
      osDisk: {
        name: '${onpVmName}-osdisk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: onpVmNic.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: false
      }
    }
  }
}
// param adpr_address string = '10.0.17.4'
resource runCommandAdds 'Microsoft.Compute/virtualMachines/runCommands@2024-07-01' = {
  parent: onpWindowsVM
  name: 'runCommand-ADDS'
  location: location
  properties: {
    source: {
      script:'''
        $adpr_address = "10.0.17.4"
        Install-WindowsFeature -Name DNS -IncludeManagementTools
        Add-DnsServerConditionalForwarderZone -Name "blob.core.windows.net" -MasterServers $adpr_address
        Add-DnsServerForwarder -IPAddress "8.8.8.8"
      '''
    }
    treatFailureAsDeploymentFailure: true
  }
}
// output windowsVMId string = windowsVM.id
// output windowsVMName string = windowsVM.name
