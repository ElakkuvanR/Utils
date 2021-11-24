#version 2
Function AddLanguageVersionWithLogging($tgtItem, $srcLang, $tgtLang, $assignWorkflow = $false, $tgtWorkflowStateId = "{2D52775B-5AD4-4A6A-AE2F-FCBAFF490969}")
{
    Write-Host "Adding language version '$($tgtItem.ItemPath)' - '$($tgtLang)'..."
    $addedVer = Add-ItemVersion -Id $tgtItem.Id -TargetLanguage $tgtLang -Language $srcLang -IfExist Append
    if($addedVer -eq $null){
        Write-Host "! New version wasn't added for '$($tgtItem.ItemPath)'. Please confirm that the item has a version in language '($($srcLang))'."
    } else {
        if($assignWorkflow -eq $true){
            Write-Host "Assigning workflow state for item '$($tgtItem.ItemPath)' - '$($tgtLang)'..."
            $addedVer.Editing.BeginEdit();
            $addedVer.Fields["__Workflow state"].Value = $tgtWorkflowStateId
            $addedVer.Editing.EndEdit();
        }
    }
}

$contextItem = Get-Item .
$DataFolderTemplateID = "{A37C4ADC-A626-4807-ACDD-748AD26C4144}"

$settings = @{
    Title = "Select setings"
    Width = "800"
    Height = "400"
    OkButtonName = "Select"
    CancelButtonName = "Cancel"
    Description = "Select item, source and target languages to copy content"
    Parameters = @(
        @{ Name = "tgtItem"; Title="Select the target item";
        Source="DataSource=/sitecore/content&DatabaseName=master";
        Value=$contextItem;
        editor="droptree"; Mandatory=$true;}
        @{ Name = "srcLanguage"; Title="Select the source language";
        Source="DataSource=/sitecore/system/Languages&DatabaseName=master";
        editor="droplist"; Mandatory=$true;}
        @{ Name = "tgtLanguage"; Title="Select the target language";
        Source="DataSource=/sitecore/system/Languages&DatabaseName=master";
        editor="droplist"; Mandatory=$true;}
    )
}

if($contextItem.Fields["__Workflow"].Value -ne "")
{
    $workflowItem = Get-Item -Path "master:" -ID $contextItem.Fields["__Workflow"].Value -Language "en"
    #todo
    $workflowStates = Get-ChildItem -Path "master:" -ID $workflowItem.Id -Language "en"
    $defaultWorkflowState = $workflowStates[0]

    $workflowParams = @(
        @{ Name = "assignWorkflow"; Title="Assign workflow state?";
        Value=$true;
        editor="checkbox"; Mandatory=$true;}
        @{ Name = "tgtWorkflowState"; Title="Select the target workflow state";
        Source="DataSource=$($workflowItem.ItemPath)&DatabaseName=master";
        Value=$defaultWorkflowState;
        editor="droptree"; Mandatory=$true}
    )
    $settings.Parameters += $workflowParams
} else {
    $assignWorkflow = $false
}

$result = Read-Variable @settings

if($result -ne "Cancel")
{
    # copying main item
    if ($assignWorkflow -eq $true){
        AddLanguageVersionWithLogging $tgtItem $srcLanguage.DisplayName $tgtLanguage.DisplayName $assignWorkflow $tgtWorkflowState.Id
    } else {
        AddLanguageVersionWithLogging $tgtItem $srcLanguage.DisplayName $tgtLanguage.DisplayName
    }

    # copying component datasources
    # note: it's not necessary to add version for data folder itself
    $children = Get-ChildItem -Path "master:" -ID $tgtItem.Id #-Language "en"
    $children | ForEach-Object {
        if($_.TemplateID -eq $DataFolderTemplateID){
            Write-Host "Located data folder '$($_.ItemPath)', recursing..."
            $dataFolderChildren = Get-ChildItem  -Path "master:" -ID $_.ID -Language $srcLanguage.DisplayName -Recurse
            $dataFolderChildren | ForEach-Object {
                #assuming datasource items don't have workflow
                AddLanguageVersionWithLogging $_ $srcLanguage.DisplayName $tgtLanguage.DisplayName
            }
        }
    }
}
