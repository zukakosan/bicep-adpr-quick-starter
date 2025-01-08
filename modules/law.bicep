param location string
param lawName string
resource law 'Microsoft.OperationalInsights/workspaces@2020-10-01' = {
  name: lawName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

output lawId string = law.id
