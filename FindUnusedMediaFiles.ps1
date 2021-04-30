function HasReference {
    param(
        $Item
    )
    
    $linkDb = [Sitecore.Globals]::LinkDatabase
    $linkDb.GetReferrerCount($Item) -gt 0
}

<# 
    Get-MediaItemWithNoReference gets all the items in the media library
    and checks to see if they have references. Each item that does not
    have a reference is passed down the PowerShell pipeline.
#>
function Get-MediaItemWithNoReference {
    $unusedMediaCount=0;
    $totalSize=0;
    $items = Get-ChildItem -Path "master:\sitecore\media library" -Recurse | 
        Where-Object { $_.TemplateID -ne [Sitecore.TemplateIDs]::MediaFolder }
    Write-Host "Total Number of Media Items:" $items.Count
    foreach($item in $items) {
        if(!(HasReference($item))) {
            $item
            $unusedMediaCount = $unusedMediaCount + 1;
        }
    }
    Write-Host "Total Number of Unused Media:" $unusedMediaCount
    Write-Host "Total Size:" $totalSize
}

# Setup a hashtable to make a more readable script.
$props = @{
    InfoTitle = "Unused media items"
    InfoDescription = "Lists all media items that are not linked to other items."
    PageSize = 25
}

# Passing a hashtable to a command is called splatting. Call Show-ListView to produce
# a table with the results.
Get-MediaItemWithNoReference |
    Show-ListView @props -Property @{Label="Name"; Expression={$_.DisplayName} },
        @{Label="Path"; Expression={$_.ItemPath} },
        @{Label="Size"; Expression={$_.Size/1024/1024 } }
