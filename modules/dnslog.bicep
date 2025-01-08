param location string
param vnetHubName string
param lawId string

param dnsRvPlcName string = 'dnsRvPlc'

resource vnetHub 'Microsoft.Network/virtualNetworks@2022-05-01' existing = {
  name:vnetHubName
}

resource dnsRvPlc 'Microsoft.Network/dnsResolverPolicies@2023-07-01-preview' = {
  location: location
  name: dnsRvPlcName
  properties: {}
}

resource dnsRvPlcVNetLink 'Microsoft.Network/dnsResolverPolicies/virtualNetworkLinks@2023-07-01-preview' = {
  parent: dnsRvPlc
  location: location
  name: vnetHub.name
  properties: {
    virtualNetwork: {
      id: vnetHub.id
    }
  }
}

resource diagnosticSetting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-law'
  scope: dnsRvPlc
  properties: {
    workspaceId: lawId
    logs: [
      {
        categoryGroup:'allLogs'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
    ]
  }
}
