param location string = 'japaneast'
param adprInboundIp string
param addsPrivateIp string

var securityRules = loadJsonContent('./nsgrules/security-rules.json')
// create nsg for hub
resource nsgHub 'Microsoft.Network/networkSecurityGroups@2023-11-01' = {
  name: 'nsg-hub'
  location: location
  properties: {
    securityRules: securityRules
  }
}

// create nsg for spoke
resource nsgSpoke 'Microsoft.Network/networkSecurityGroups@2023-11-01' = {
  name: 'nsg-spoke'
  location: location
  properties: {
    securityRules: securityRules
  }
}

// create nsg for onp
resource nsgOnp 'Microsoft.Network/networkSecurityGroups@2023-11-01' = {
  name: 'nsg-onp'
  location: location
  properties: {
    securityRules: securityRules
  }
}
param vnetHubName string = 'vnet-hub'
// create hub vnet
resource vnetHub 'Microsoft.Network/virtualNetworks@2023-11-01' = {
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
  //// refer existing subnet
  //resource gatewaySubnetHub 'subnets' existing = {
  //  name : 'GatewaySubnet'
  //}
}

// create spoke vnet
resource vnetSpoke 'Microsoft.Network/virtualNetworks@2023-11-01' = {
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

resource vnetOnp 'Microsoft.Network/virtualNetworks@2023-11-01' = {
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
  //// refer existing subnet
  //resource gatewaySubnetOnp 'subnets' existing = {
  //  name : 'GatewaySubnet'
  //}
}
