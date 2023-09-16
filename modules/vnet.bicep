// @allowed()
param location string = 'japaneast'
param adprInboundIp string
param addsPrivateIp string
// create nsg for hub
resource nsgHub 'Microsoft.Network/networkSecurityGroups@2019-11-01' = {
  name: 'nsg-hub'
  location: location
  properties: {
    // securityRules: [
    //   {
    //     name: 'nsgRule'
    //     properties: {
    //       description: 'description'
    //       protocol: 'Tcp'
    //       sourcePortRange: '*'
    //       destinationPortRange: '*'
    //       sourceAddressPrefix: '*'
    //       destinationAddressPrefix: '*'
    //       access: 'Allow'
    //       priority: 100
    //       direction: 'Inbound'
    //     }
    //   }
    // ]
  }
}

// create nsg for spoke
resource nsgSpoke 'Microsoft.Network/networkSecurityGroups@2019-11-01' = {
  name: 'nsg-spoke'
  location: location
  properties: {
  //   securityRules: [
  //     {
  //       name: 'nsgRule'
  //       properties: {
  //         description: 'description'
  //         protocol: 'Tcp'
  //         sourcePortRange: '*'
  //         destinationPortRange: '*'
  //         sourceAddressPrefix: '*'
  //         destinationAddressPrefix: '*'
  //         access: 'Allow'
  //         priority: 100
  //         direction: 'Inbound'
  //       }
  //     }
  //   ]
  }
}

// create nsg for onp
resource nsgOnp 'Microsoft.Network/networkSecurityGroups@2019-11-01' = {
  name: 'nsg-onp'
  location: location
  properties: {
    // securityRules: [
    //   {
    //     name: 'nsgRule'
    //     properties: {
    //       description: 'description'
    //       protocol: 'Tcp'
    //       sourcePortRange: '*'
    //       destinationPortRange: '*'
    //       sourceAddressPrefix: '*'
    //       destinationAddressPrefix: '*'
    //       access: 'Allow'
    //       priority: 100
    //       direction: 'Inbound'
    //     }
    //   }
    // ]
  }
}
param vnetHubName string = 'vnet-hub'
// create hub vnet
resource vnetHub 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: vnetHubName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: '10.0.0.0/27'
        }
      }
      {
        name: 'subnet-001'
        properties: {
          addressPrefix: '10.0.1.0/24'
          networkSecurityGroup: {
            id: nsgHub.id
          }
        }
      }
      {
        name: 'subnet-inbound'
        properties: {
          addressPrefix: '10.0.17.0/28'
          networkSecurityGroup: {
            id: nsgHub.id
          }
          delegations: [
            {
              name: 'Microsoft.Network.dnsResolvers'
              properties: {
                serviceName: 'Microsoft.Network/dnsResolvers'
              }
            }
          ]
        }
      }
      {
        name: 'subnet-outbound'
        properties: {
          addressPrefix: '10.0.17.16/28'
          networkSecurityGroup: {
            id: nsgHub.id
          }
          delegations: [
            {
              name: 'Microsoft.Network.dnsResolvers'
              properties: {
                serviceName: 'Microsoft.Network/dnsResolvers'
              }
            }
          ]
        }
      }
    ]
  }
  // refer existing subnet
  resource gatewaySubnetHub 'subnets' existing = {
    name : 'GatewaySubnet'
  }
}

// create spoke vnet
resource vnetSpoke 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: 'vnet-spoke'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.1.0.0/16'
      ]
    }
    dhcpOptions: {
      dnsServers: [
        adprInboundIp
      ]
    }
    subnets: [
      {
        name: 'subnet-001'
        properties: {
          addressPrefix: '10.1.0.0/24'
          networkSecurityGroup: {
            id: nsgSpoke.id
          }
        }
      }
      {
        name: 'subnet-002'
        properties: {
          addressPrefix: '10.1.1.0/24'
          networkSecurityGroup: {
            id: nsgSpoke.id
          }
        }
      }
    ]
  }
}

resource vnetOnp 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: 'vnet-onp'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.100.0.0/16'
      ]
    }
    dhcpOptions: {
      dnsServers: [
        addsPrivateIp
      ]
    }
    subnets: [
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: '10.100.0.0/24'
        }
      }
      {
        name: 'subnet-001'
        properties: {
          addressPrefix: '10.100.1.0/24'
          networkSecurityGroup: {
            id: nsgOnp.id
          }
        }
      }
    ]
  }
  // refer existing subnet
  resource gatewaySubnetOnp 'subnets' existing = {
    name : 'GatewaySubnet'
  }
}

// // To Do: split file not to wait for vpngw creation
// // create public ip address for vpngw hub
// resource pipVpnGatewayHub 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
//   name: 'vpngw-hub-pip'
//   location: location
//   sku: {
//     name: 'Standard'
//   }
//   properties: {
//     publicIPAllocationMethod: 'Static'
//   }
// }

// // create public ip address for vpngw onp
// resource pipVpnGatewayOnp 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
//   name: 'vpngw-onp-pip'
//   location: location
//   sku: {
//     name: 'Standard'
//   }
//   properties: {
//     publicIPAllocationMethod: 'Static'
//   }
// }

// // create vpngw for hub vnet
// resource vpnGatewayHub 'Microsoft.Network/virtualNetworkGateways@2020-11-01' = {
//   name: 'vpngw-hub'
//   location: location
//   properties: {
//     ipConfigurations: [
//       {
//         name: 'ipconfig1'
//         properties: {
//           privateIPAllocationMethod: 'Dynamic'
//           subnet: {
//             id: vnetHub::gatewaySubnetHub.id
//           }
//           publicIPAddress: {
//             id: pipVpnGatewayHub.id
//           }
//         }
//       }
//     ]
//     sku: {
//       name: 'VpnGw1'
//       tier: 'VpnGw1'
//     }
//     gatewayType: 'Vpn'
//     vpnType: 'RouteBased'
//     enableBgp: true
//   }
// }

// // create vpngw for onp vnet
// resource vpnGatewayOnp 'Microsoft.Network/virtualNetworkGateways@2020-11-01' = {
//   name: 'vpngw-onp'
//   location: location
//   properties: {
//     ipConfigurations: [
//       {
//         name: 'ipconfig1'
//         properties: {
//           privateIPAllocationMethod: 'Dynamic'
//           subnet: {
//             id: vnetOnp::gatewaySubnetOnp.id
//           }
//           publicIPAddress: {
//             id: pipVpnGatewayOnp.id
//           }
//         }
//       }
//     ]
//     sku: {
//       name: 'VpnGw1'
//       tier: 'VpnGw1'
//     }
//     gatewayType: 'Vpn'
//     vpnType: 'RouteBased'
//     enableBgp: true
//   }
// }

// // create vpngw connection for hub vnet
// resource vpnConnectionHubOnp 'Microsoft.Network/connections@2020-11-01' = {
//   name: 'vpngw-conncetion-hub-onp'
//   location: location
//   properties: {
//     connectionType: 'VNet2VNet'
//     virtualNetworkGateway1: {
//       id: vpnGatewayHub.id
//       properties:{}
//     }
//     virtualNetworkGateway2: {
//       id: vpnGatewayOnp.id
//       properties:{}
//     }
//     routingWeight: 0
//     sharedKey: 'zukakosan'
//   }
// }

// // create vpngw connection for hub vnet
// resource vpnConnectionOnpHub 'Microsoft.Network/connections@2023-04-01' = {
//   name: 'vpngw-conncetion-onp-hub'
//   location: location
//   properties: {
//     connectionType: 'Vnet2Vnet'
//     virtualNetworkGateway1: {
//       id: vpnGatewayOnp.id
//       properties:{}
//     }
//     virtualNetworkGateway2: {
//       id: vpnGatewayHub.id
//       properties:{}
//     }
//     routingWeight: 0
//     sharedKey: 'zukakosan'
//   }
// }

// // create Peering after creating vpngw for gateway transit setting
// // use explicit dependency

// // create hub vnet peering
// resource peeringHubSpoke 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-07-01' = {
//   name: 'peering-hub-spoke'
//   parent: vnetHub
//   properties: {
//     allowVirtualNetworkAccess: true
//     allowForwardedTraffic: true
//     allowGatewayTransit: true
//     useRemoteGateways: false
//     remoteVirtualNetwork: {
//       id: vnetSpoke.id
//     }
//   }
//   dependsOn:[
//     vpnGatewayHub
//     vpnGatewayOnp
//   ]
// }

// // create spoke vnet peering
// resource peeringSpokeHub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-07-01' = {
//   name: 'peering-spoke-hub'
//   parent: vnetSpoke
//   properties: {
//     allowVirtualNetworkAccess: true
//     allowForwardedTraffic: true
//     allowGatewayTransit: true
//     useRemoteGateways: true
//     remoteVirtualNetwork: {
//       id: vnetHub.id
//     }
//   }
//   dependsOn:[
//     vpnGatewayHub
//     vpnGatewayOnp
//   ]
// }
