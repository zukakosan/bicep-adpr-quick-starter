resource vnetHub 'Microsoft.Network/virtualNetworks@2019-11-01' existing = {
  name: 'vnet-hub'
}
resource vnetSpoke 'Microsoft.Network/virtualNetworks@2019-11-01' existing = {
  name: 'vnet-spoke'
}

// change peering setting for hub-spoke
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

// change peering setting for spoke-hub
resource peeringSpokeHub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-07-01' = {
  name: 'peering-spoke-hub'
  parent: vnetSpoke
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: true
    remoteVirtualNetwork: {
      id: vnetHub.id
    }
  }
}
