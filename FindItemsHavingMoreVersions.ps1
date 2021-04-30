function HasMoreVersions {
    param(
        $Item
    )
    $Item.Versions.GetVersions($true).Count -gt 1
}

$customList = New-Object System.Collections.Generic.List[PSObject]
function Get-ItemVersionReport {
    $maxVerion = Read-Host "Enter the MAX Version.";
    $items = Get-ChildItem -Path "master:/sitecore/content/Royal Canin/Germany" -Language * -Recurse
    $items | ForEach-Object {
	    if ([int]$_.Versions.Count -gt $maxVerion)
		{
		   $newObject = New-Object PSObject @{ ItemPath = $_.FullPath; ItemId = $_.Id; LanguageName = $_.Language; TotalNoVersion = $_.Versions.Count}
		   $customList.Add($newObject)
		}
    }
}

$props = @{
    InfoTitle = "Version Report"
    InfoDescription = "Lists all items having more than 1 version"
    PageSize = 25
}
Get-ItemVersionReport

$customList |
    Show-ListView @props -Property @{Label="ItemPath"; Expression={$_.ItemPath} },
        @{Label="Id"; Expression={$_.ItemId } },
        @{Label="Language Name"; Expression={$_.LanguageName } },
        @{Label="Total Version"; Expression={$_.TotalNoVersion } }
       
