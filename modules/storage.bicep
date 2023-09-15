param location string = resourceGroup().location
resource privateStrgAcct 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: 'strgacct-${uniqueString(resourceGroup().id)}'
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Premium_LRS'
  }
}

