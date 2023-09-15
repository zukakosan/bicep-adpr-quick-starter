param location string = resourceGroup().location
param privateDnsZoneName string = 'privatelink.blob.${environment().suffixes.storage}'

resource vnetHub 'Microsoft.Network/virtualNetworks@2020-05-01' existing = {
  name: 'vnet-hub'
}
resource vnetSpoke 'Microsoft.Network/virtualNetworks@2020-05-01' existing = {
  name: 'vnet-spoke'
  resource subnetPe 'subnets' existing = {
    name: 'subnet-002'
  }
}

resource privateStrgAcct 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: 'strgacct${uniqueString(resourceGroup().id)}'
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Premium_LRS'
  }
}

resource strgAcctPrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: '${privateStrgAcct.name}-pe'
  location: location
  properties: {
    subnet: {
      id: vnetSpoke::subnetPe.id
    }
    privateLinkServiceConnections: [
      {
        name: '${privateStrgAcct.name}-pe-conn'
        properties: {
          privateLinkServiceId: privateStrgAcct.id
          groupIds: [
            'blob'
          ]
        }
      }
    ]
  }
}

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsZoneName
  location: 'global'
  properties: {}
}

resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZone
  name: '${privateDnsZoneName}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetHub.id
    }
  }
}

resource pvtEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  name: 'pvtEndpointDnsGroupForStrgAcct'
  parent: strgAcctPrivateEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateDnsZone.id
        }
      }
    ]
  }
}
