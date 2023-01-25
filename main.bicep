@description('The storage account location.')
param location string = resourceGroup().location

@description('The name')
param Name string

module sa 'ts/recepies:data-storage:1.0' = {
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
