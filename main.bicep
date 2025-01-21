param vmAdminUserName string
@secure()
param vmAdminPassword string
param vnetHubName string
param vnetSpokeName string

param location string = resourceGroup().location
param adprInboundIp string = '10.0.17.4'
param addsPrivateIp string = '10.100.1.4'

module createVnet './modules/vnet.bicep' = {
  name: 'module-vnet'
  params: {
    location: location
    vnetHubName: vnetHubName
    vnetSpokeName: vnetSpokeName
    adprInboundIp: adprInboundIp
    addsPrivateIp: addsPrivateIp
  }
}

module createVpngw './modules/vpngw.bicep' = {
  name: 'module-vpngw'
  params:{
    location: location
  }
  dependsOn:[
    createVnet
  ]
}

module createPeering './modules/peering.bicep' = {
  name: 'module-peering'
  dependsOn:[
    createVpngw 
  ]
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

module createLaw './modules/law.bicep' = {
  name: 'module-law'
  params: {
    location: location
    lawName: 'law-dnslog'
  }
}
module dnslog './modules/dnslog.bicep' = {
  name: 'module-dnslog'
  params: {
    location: location
    dnsRvPlcName: 'dnsRvPlcName'
    vnetHubName: vnetHubName
    vnetSpokeName: vnetSpokeName
    lawId: createLaw.outputs.lawId
  }
  dependsOn:[
    createVnet
  ]
}
