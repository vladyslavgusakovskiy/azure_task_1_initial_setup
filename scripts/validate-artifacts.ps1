
# default script values 
$artifactsConfigPath = "$PWD/artifacts.json"
$resourcesTemplateName = "exported-template.json"
$taskName = "task1"
$tempFolderPath = "$PWD/temp"

Write-Output "Reading config" 
$artifactsConfig = Get-Content -Path $artifactsConfigPath | ConvertFrom-Json 

Write-Output "Checking if temp folder exists"
if (-not (Test-Path "$tempFolderPath")) { 
    Write-Output "Temp folder does not exist, creating..."
    New-Item -ItemType Directory -Path $tempFolderPath
}

Write-Output "Downloading artifacts"

Invoke-WebRequest -Uri $artifactsConfig.resourcesTemplate -OutFile "$tempFolderPath/$resourcesTemplateName" -UseBasicParsing

Write-Output "Validating artifacts"
$TemplateFileText = [System.IO.File]::ReadAllText("$tempFolderPath/$resourcesTemplateName")
$TemplateObject = ConvertFrom-Json $TemplateFileText -AsHashtable

$storageAccount = ( $TemplateObject.resources | Where-Object -Property type -EQ "Microsoft.Storage/storageAccounts" )
if ($storageAccount) {
    Write-Output "Checked if storage account exists - OK."
} else {
    Write-Error "Unable to find storage account in the resource template. Please make sure that you created the storage account"
}

if ($storageAccount.sku.name -eq "Standard_LRS") { 
    Write-Output "Checked the storage account SKU - OK."
} else {
    Write-Error "Storage account SKU is not set to Standard LRS. Please try to create storage account again, and make sure that replication type is set to LRS"
}
