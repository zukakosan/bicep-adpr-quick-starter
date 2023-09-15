param location string = 'japaneast'
param vmAdminUserName string = 'AzureAdmin'
@secure()
param vmAdminPassword string
param adprInboundIp string = '10.0.17.4'
param addsPrivateIp string = '10.100.1.4'

module createVnet './modules/vnet.bicep' = {
  name: 'module-vnet'
  params: {
    location: location
    adprInboundIp: adprInboundIp
    addsPrivateIp: addsPrivateIp
  }
}

module createAdpr './modules/adpr.bicep' = {
  name: 'module-adpr'
  params: {
    location: location
    adprInboundIp: adprInboundIp
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
    addsPrivateIpAddress: addsPrivateIp
    vmAdminUserName: vmAdminUserName
    vmAdminPassword: vmAdminPassword

  }
  dependsOn:[
    createVnet
  ]
}

module createPrivateStrgAcct './modules/storage.bicep' = {
  name: 'module-storage'
  params: {
    location: location
  }
}
