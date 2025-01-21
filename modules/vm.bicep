param location string

param spokeVmName string 
param onpVmName string
param addsPrivateIpAddress string

param vmAdminUserName string
@secure()
param vmAdminPassword string

resource vnetSpoke 'Microsoft.Network/virtualNetworks@2022-05-01' existing = {
  name:'vnet-spoke'
  resource vmSubnet 'subnets' existing = {
    name: 'subnet-001'
  }
}

resource vnetOnp 'Microsoft.Network/virtualNetworks@2022-05-01' existing = {
  name:'vnet-onp'
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

// resource runCommandsAdds 'Microsoft.Compute/virtualMachines/runCommands@2024-07-01' = {
//   parent: onpWindowsVM
//   name: 'runCommands'
//   location: location
//   properties: {
//     scriptUri: ''
//   }
// }
// output windowsVMId string = windowsVM.id
// output windowsVMName string = windowsVM.name
