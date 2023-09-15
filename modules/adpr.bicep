param vnetName string = 'vnet-hub'
param location string = 'japaneast'
param onpDomainName string = 'zukakoad.local.'
param adprInboundIp string = '10.0.17.4'

resource vnetHub 'Microsoft.Network/virtualNetworks@2020-05-01' existing = {
  name: vnetName
  resource subnetInbount 'subnets' existing = {
    name: 'subnet-inbound'
  }
  resource subnetOutbound 'subnets' existing = {
    name: 'subnet-outbound'
  }
}

resource dnsResolvers 'Microsoft.Network/dnsResolvers@2022-07-01' = {
  name: 'adpr-hub'
  location: location
  properties: {
     virtualNetwork: {
      id: vnetHub.id
     }
  }

  resource inboundEndpoints 'inboundEndpoints' = {
    name: 'inbound-endpoint'
    location: location
    properties: {
      ipConfigurations: [
        {
          // privateIpAllocationMethod: 'Dynamic'
          privateIpAddress: adprInboundIp
          privateIpAllocationMethod: 'Static'
          subnet: {
            id: vnetHub::subnetInbount.id
          }
        }
      ]
    }
  }

  // you need add delegation settings for outbound-subnet
  resource outboundEndpoints 'outboundEndpoints' = {
    name: 'outbound-endpoint'
    location: location
    properties: {
      subnet: {
        id: vnetHub::subnetOutbound.id
      }
    }
  }
}

resource fwruleSet 'Microsoft.Network/dnsForwardingRulesets@2022-07-01' = {
  name: 'fwruleset'
  location: location
  properties: {
    dnsResolverOutboundEndpoints: [
      {
        id: dnsResolvers::outboundEndpoints.id
      }
    ]
  }
}

resource resolverLink 'Microsoft.Network/dnsForwardingRulesets/virtualNetworkLinks@2022-07-01' = {
  parent: fwruleSet
  name: 'fwruleset-link'
  properties: {
    virtualNetwork: {
      id: vnetHub.id
    }
  }
}

resource fwRules 'Microsoft.Network/dnsForwardingRulesets/forwardingRules@2022-07-01' = {
  parent: fwruleSet
  name: 'onpremise-domain-forwarding'
  properties: {
    domainName: onpDomainName
    targetDnsServers: [{
      ipAddress:'10.100.1.4'
      port:53
    }]
  }
}

output inboundEndpointIp string = dnsResolvers::inboundEndpoints.properties.ipConfigurations[0].privateIpAddress
