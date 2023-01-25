@description('The storage account location.')
param location string = resourceGroup().location

@description('The name')
param Name string

module storage 'ts/' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountType
  }
  kind: 'StorageV2'
  properties: {}
}

output storageAccountName string = storageAccountName
output storageAccountId string = sa.id
