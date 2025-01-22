using './main.bicep'

param vmAdminUserName = 'AzureAdmin'
@secure()
param vmAdminPassword = 'P@ssw0rd1234' 
param vnetHubName = 'vnet-hub'
param vnetSpokeName = 'vnet-spoke'
