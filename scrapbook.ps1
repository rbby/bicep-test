$PSVersionTable.PSVersion
Get-Module -ListAvailable -Name Azure -Refresh
Get-Module -ListAvailable -Name Az -Refresh

Get-ExecutionPolicy -List
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force

Connect-AzAccount -UseDeviceAuthentication
Get-AzSubscription
Disconnect-AzAccount
Clear-AzContext -Force

Get-AzResourceGroup |
  Sort-Object Location,ResourceGroupName |
    Format-Table -GroupBy Location ResourceGroupName,ProvisioningState,Tags
    
$resourcegroupName = 'rg-test-template-spec'
Get-AzLocation | Select-Object Location
$location = "westeurope"
$name = 'rbby-storage'
New-AzResourceGroup -Name $resourcegroupName -Location $location -Tag @{ "environment"="test" }

# template specs
$params = @{
    Name = $name
    Version = '1.0'
    Description = 'bla bla bla'
    ResourceGroupName = $resourcegroupName
    Location = $location
    TemplateFile = 'storage.bicep'
}
Write-Output($params)
New-AzTemplateSpec @params -Force

Remove-AzTemplateSpec -ResourceGroupName $resourcegroupName -Name $name -Force

# Test Deploy
New-AzResourceGroupDeployment `
  -DeploymentName 'azdo-defId_1-runId_1' `
  -ResourceGroupName $resourcegroupName `
  -TemplateFile 'main.bicep' 

$id = (Get-AzTemplateSpec -ResourceGroupName $resourcegroupName -Name $name -Version "1.0").Versions.Id
New-AzResourceGroupDeployment `
  -DeploymentName 'azdo-defId_1-runId_29' `
  -ResourceGroupName $resourcegroupName `
  -TemplateSpecId $id


# Delete
Get-AzResourceGroup -Tag @{'environment'='test'} | Remove-AzResourceGroup -Force
