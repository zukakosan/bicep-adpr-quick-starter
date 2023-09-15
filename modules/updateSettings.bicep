param inboundEndpointIp string
param location string = resourceGroup().location
resource vnetHub 'Microsoft.Network/virtualNetworks@2019-11-01' existing = {
  name: 'vnet-hub'
}

// r
resource vnetSpoke 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: 'vnet-spoke'
  location: location
  properties: {
    dhcpOptions: {
      dnsServers: [
        inboundEndpointIp
      ]
    }
  }
}
