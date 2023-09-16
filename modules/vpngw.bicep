param location string = resourceGroup().location

resource vnetHub 'Microsoft.Network/virtualNetworks@2022-05-01' existing = {
  name:'vnet-hub'
  resource GatewaySubnet 'subnets' existing = {
    name: 'GatewaySubnet'
  }
}

resource vnetOnp 'Microsoft.Network/virtualNetworks@2022-05-01' existing = {
  name:'vnet-onp'
  resource GatewaySubnet 'subnets' existing = {
    name: 'GatewaySubnet'
  }
}

// create public ip address for vpngw hub
resource pipVpnGatewayHub 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: 'vpngw-hub-pip'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

// create public ip address for vpngw onp
resource pipVpnGatewayOnp 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: 'vpngw-onp-pip'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

// create vpngw for hub vnet
resource vpnGatewayHub 'Microsoft.Network/virtualNetworkGateways@2020-11-01' = {
  name: 'vpngw-hub'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: vnetHub::GatewaySubnet.id
          }
          publicIPAddress: {
            id: pipVpnGatewayHub.id
          }
        }
      }
    ]
    sku: {
      name: 'VpnGw1'
      tier: 'VpnGw1'
    }
    gatewayType: 'Vpn'
    vpnType: 'RouteBased'
    enableBgp: true
  }
}

// create vpngw for onp vnet
resource vpnGatewayOnp 'Microsoft.Network/virtualNetworkGateways@2020-11-01' = {
  name: 'vpngw-onp'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: vnetOnp::GatewaySubnet.id
          }
          publicIPAddress: {
            id: pipVpnGatewayOnp.id
          }
        }
      }
    ]
    sku: {
      name: 'VpnGw1'
      tier: 'VpnGw1'
    }
    gatewayType: 'Vpn'
    vpnType: 'RouteBased'
    enableBgp: true
  }
}

// create vpngw connection for hub vnet
resource vpnConnectionHubOnp 'Microsoft.Network/connections@2020-11-01' = {
  name: 'vpngw-conncetion-hub-onp'
  location: location
  properties: {
    connectionType: 'VNet2VNet'
    virtualNetworkGateway1: {
      id: vpnGatewayHub.id
      properties:{}
    }
    virtualNetworkGateway2: {
      id: vpnGatewayOnp.id
      properties:{}
    }
    routingWeight: 0
    sharedKey: 'zukakosan'
  }
}

// create vpngw connection for hub vnet
resource vpnConnectionOnpHub 'Microsoft.Network/connections@2023-04-01' = {
  name: 'vpngw-conncetion-onp-hub'
  location: location
  properties: {
    connectionType: 'Vnet2Vnet'
    virtualNetworkGateway1: {
      id: vpnGatewayOnp.id
      properties:{}
    }
    virtualNetworkGateway2: {
      id: vpnGatewayHub.id
      properties:{}
    }
    routingWeight: 0
    sharedKey: 'zukakosan'
  }
}

