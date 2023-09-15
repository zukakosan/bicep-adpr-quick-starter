param location string = 'japaneast'
param vmAdminUserName string = 'AzureAdmin'
@secure()
param vmAdminPassword string

module createVnet './modules/vnet.bicep' = {
  name: 'module-vnet'
  params: {
    location: location
  }
}

module createAdpr './modules/adpr.bicep' = {
  name: 'module-adpr'
  params: {
    location: location
  }
  dependsOn:[
    createVnet
  ]
}

module createVm './modules/vm.bicep' = {
  name: 'module-vm'
  params: {
    location: location
    onpVmName: 'vm-onp-adds'
    spokeVmName: 'vm-spoke'
    vmAdminUserName: vmAdminUserName
    vmAdminPassword: vmAdminPassword

  }
  dependsOn:[
    createVnet
  ]
}
