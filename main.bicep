@description('The storage account location.')
param location string = resourceGroup().location

@description('The name')
param Name string = 'bla${uniqueString(resourceGroup().id)}'

module saccount 'ts/recepies:rbby-storage:1.0' = {
  name: Name
  params: {
    location: location
  }
}

output storageAccountName string = saccount.outputs.storageAccountName
output storageAccountId string = saccount.outputs.storageAccountId
