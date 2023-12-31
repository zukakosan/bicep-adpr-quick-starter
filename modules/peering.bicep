// create Peering after creating vpngw for gateway transit setting
resource vnetHub 'Microsoft.Network/virtualNetworks@2022-05-01' existing = {
  name:'vnet-hub'
}

resource vnetSpoke 'Microsoft.Network/virtualNetworks@2022-05-01' existing = {
  name:'vnet-spoke'
}

// create hub vnet peering
resource peeringHubSpoke 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-07-01' = {
  name: 'peering-hub-spoke'
  parent: vnetHub
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: true
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: vnetSpoke.id
    }
  }
}

// create spoke vnet peering
resource peeringSpokeHub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-07-01' = {
  name: 'peering-spoke-hub'
  parent: vnetSpoke
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: true
    useRemoteGateways: true
    remoteVirtualNetwork: {
      id: vnetHub.id
    }
  }
}
