$PSVersionTable.PSVersion
Get-Module -ListAvailable -Name Azure -Refresh
Get-Module -ListAvailable -Name Az -Refresh

Get-ExecutionPolicy -List
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force

Connect-AzAccount
Get-AzSubscription
Disconnect-AzAccount
Clear-AzContext -Force

Get-AzResourceGroup |
  Sort-Object Location,ResourceGroupName |
    Format-Table -GroupBy Location ResourceGroupName,ProvisioningState,Tags
    
$resourcegroupName = 'rg-test-template=spec'
Get-AzLocation | Select-Object Location
$location = "westeurope"

New-AzResourceGroup -Name $resourcegroupName -Location $location -Tag @{ "environment"="test" }

# template specs
$params = @{
    Name = 'rbby-storage'
    Version = '1.0'
    Description = 'bla bla bla'
    ResourceGroupName = $resourcegroupName
    Location = $location
    TemplateFile = 'storage.bicep'
}
Write-Output($params)
New-AzTemplateSpec @params -Force -WhatIf




Get-AzTemplateSpec
$pe = Get-AzTemplateSpec -ResourceGroupName $rgIngredientsName -Name Microsoft.Network-PrivateEndpoints
$pe.Id
$pe = Get-AzTemplateSpec -ResourceGroupName $rgIngredientsName -Name Microsoft.Storage-StorageAccounts
$pe.Id
$pe = Get-AzTemplateSpec -ResourceGroupName $rgRecipesName -Name "data-storage"
$pe.Id




# Test Deploy
New-AzSubscriptionDeployment -Location "westeurope" -TemplateFile ".\test-main.bicep"

# Delete
Get-AzResourceGroup -Tag @{'environment'='test'} | Remove-AzResourceGroup -Force

# Test SA lock
$resourceGroup = "rg-bla"
$location = "westeurope"
Get-AzLocation | Select-Object Location
New-AzResourceGroup -Name $resourceGroup -Location $location -Tag @{ "environment"="test" }
New-AzStorageAccount -ResourceGroupName $resourceGroup `
  -Name robbyz `
  -Location $location `
  -SkuName Premium_ZRS `
  -Kind StorageV2

# Deploy bicep/
$id = "/subscriptions/11111111-1111-1111-1111-111111111111/resourceGroups/templateSpecsRG/providers/Microsoft.Resources/templateSpecs/storageSpec/versions/1.0a"

New-AzResourceGroupDeployment `
  -TemplateSpecId $id `
  -ResourceGroupName demoRG


Set-Location E:\repos\Services\PFZW.Web.Services.Particulieren\deploy\azure\arm-templates
$RG = 'rg-mijnpfzw-hosting-o'

New-AzResourceGroupDeployment `
  -DeploymentName 'azdo-defId_1-runId_1' `
  -ResourceGroupName $RG `
  -TemplateFile 'plan-sa.bicep' `
  -TemplateParameterFile 'plan-sa.parameters.o.json' 

# Set role assignment
$servicePrincial = Get-AzADServicePrincipal -SearchString 'azuredevops-rg-mijnpfzw-hosting-o'
$servicePrincial
(Get-AzADServicePrincipal -DisplayName 'azuredevops-rg-mijnpfzw-hosting-o').id
Get-AzRoleDefinition | Format-Table -Property Name, IsCustom, Id
$role = Get-AzRoleDefinition -Name 'Template Spec Reader'
$role

$resource = Get-AzResource -Name 'StorageAccounts-pe-storage' -ResourceGroupName 'rg-it4it-o'
$resource

New-AzRoleAssignment -ObjectId servicePrincial.Id `
-RoleDefinitionName $role.Name `
-Scope $resource.ResourceId