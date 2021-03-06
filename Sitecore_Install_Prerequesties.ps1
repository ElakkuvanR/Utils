function Install-ServerPrerequisites {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [switch]$NoDatabases
    )

    #download URLs
    $webpi = "https://download.microsoft.com/download/C/F/F/CFF3A0B8-99D4-41A2-AE1A-496C08BEB904/WebPlatformInstaller_amd64_en-US.msi"
    $dac64 = "https://download.microsoft.com/download/5/E/4/5E4FCC45-4D26-4CBE-8E2D-79DB86A85F09/EN/x64/DacFramework.msi"
    $dac86 = "https://download.microsoft.com/download/5/E/4/5E4FCC45-4D26-4CBE-8E2D-79DB86A85F09/EN/x86/DacFramework.msi"
    $clr2016 = "https://download.microsoft.com/download/8/7/2/872BCECA-C849-4B40-8EBE-21D48CDF1456/ENU/x64/SQLSysClrTypes.msi"
    $smo = "https://download.microsoft.com/download/8/7/2/872BCECA-C849-4B40-8EBE-21D48CDF1456/ENU/x64/SharedManagementObjects.msi"
    $aspnet462 = "https://download.microsoft.com/download/F/9/4/F942F07D-F26F-4F30-B4E3-EBD54FABA377/NDP462-KB3151800-x86-x64-AllOS-ENU.exe"

    #for WMF
    Write-Verbose "Checking server for Windows Features - IIS..."
    $feature = Get-WindowsOptionalFeature -Online -FeatureName "IIS-WebServerRole" -Verbose:$VerbosePreference
    if ($feature.State -ne "Enabled") {
        Write-Verbose "Windows Feature - IIS is not installed. Installing..."
        Enable-WindowsOptionalFeature -Online -All -FeatureName "IIS-WebServerRole" -Verbose:$VerbosePreference
        Write-Verbose "Windows Feature - IIS has been installed."
    }
    else {
        Write-Verbose "Windows Feature - IIS has been detected. Skipping..."
    }

    Write-Verbose "Checking server for Windows Features - IIS Management Console..."
    $feature = Get-WindowsOptionalFeature -Online -FeatureName "IIS-WebServerManagementTools" -Verbose:$VerbosePreference
    if ($feature.State -ne "Enabled") {
        Write-Verbose "Windows Feature - IIS Management Console is not installed. Installing..."
        Enable-WindowsOptionalFeature -Online -All -FeatureName "IIS-WebServerManagementTools" -Verbose:$VerbosePreference
        Write-Verbose "Windows Feature - IIS Management Console has been installed."
    }
    else {
        Write-Verbose "Windows Feature - IIS Management Console has been detected. Skipping..."
    }

    Write-Verbose "Checking server for Windows Features - ASP.NET 4.5..."
    $feature = Get-WindowsOptionalFeature -Online -FeatureName "IIS-ASPNET45" -Verbose:$VerbosePreference
    if ($feature.State -ne "Enabled") {
        Write-Verbose "Windows Feature - ASP.NET 4.5 has not been installed. Installing..."
        Enable-WindowsOptionalFeature -Online -All -FeatureName "IIS-ASPNET45" -Verbose:$VerbosePreference
        Write-Verbose "ASP.NET 4.5 has been installed."
    }
    else {
        Write-Verbose "Windows Feature - ASP.NET 4.5 has been detected. Skipping..."
    }

    #install webpi
    Write-Verbose "Checking server for Web Platform Installer..."
    if (-not (Test-Path "C:\Program Files\Microsoft\Web Platform Installer\WebpiCmd-x64.exe")) {
        Write-Verbose "Web Platform Installer was not detected. Installing..."
        Write-Verbose "Downloading Web Platform Installer from $webpi..."
        Invoke-WebRequest -Uri $webpi -OutFile WebPlatformInstaller_amd64_en-US.msi -Verbose:$VerbosePreference
        Write-Verbose "Installing Web Platform Installer..."
        Start-Process msiexec.exe -Wait -ArgumentList "/i WebPlatformInstaller_amd64_en-US.msi /quiet /qn /norestart"
        Write-Verbose "Web Platform Installer installed successfully."
    }
    else {
        Write-Verbose "Web Platform Installer has been detected. Skipping..."
    }

    #install web deploy
    Write-Verbose "Checking server for Web Deploy 3.6..."
    #catch exception from Get-ChildItem
    if ((-not (Test-Path "hklm:software\microsoft\iis extensions\msdeploy")) -and ($null -eq (Get-ChildItem "hklm:software\microsoft\iis extensions\msdeploy"))) {
        Write-Verbose "Web Deploy 3.6 was not detected. Installing with Web PI..."
        Start-Process "$env:programfiles\Microsoft\Web Platform Installer\WebpiCmd-x64.exe" -ArgumentList "/install /products:WDeploy36 /AcceptEULA" -NoNewWindow -Wait
        Write-Verbose "Web Deploy 3.6 has been successfully installed."
    }
    else {
        Write-Verbose "Web Deploy 3.6 has been detected. Skipping..."
    }

    #install URL rewrite
    Write-Verbose "Checking server for URL Rewrite..."
    #catch exception from Get-ChildItem
    if ((-not (Test-Path "hklm:software\microsoft\iis extensions\url rewrite")) -and ($null -eq (Get-ChildItem "hklm:software\microsoft\iis extensions\url rewrite"))) {
        Write-Verbose "URL Rewrite was not detected. Installing with Web PI..."
        Start-Process "$env:programfiles\Microsoft\Web Platform Installer\WebpiCmd-x64.exe" -ArgumentList "/install /products:UrlRewrite2 /AcceptEULA" -NoNewWindow -Wait
        Write-Verbose "URL Rewrite has been successfully installed."
    }
    else {
        Write-Verbose "URL Rewrite has been detected. Skipping..."
    }

    if (-not $NoDatabases) {
        #install dacfx
        Write-Verbose "Checking server for SQL Server 2016 Data-Tier Application Framework..."
        if (-not (Test-Path "${env:programfiles(x86)}\Microsoft SQL Server\130\DAC\bin\Microsoft.SqlServer.Dac.dll")) {
            Write-Verbose "SQL Server 2016 Data-Tier Application Framework was not detected. Installing..."
            #2017
            #Invoke-WebRequest -Uri "https://download.microsoft.com/download/F/9/3/F938FCDD-3FAF-40DF-A530-778898E2E5EE/EN/x64/DacFramework.msi" -OutFile DacFramework2017-x64.msi
            #.\DacFramework2017-x64.msi /quiet

            #Invoke-WebRequest -Uri "https://download.microsoft.com/download/5/2/8/528EE32B-A63B-462A-BF86-48EDE3DDF5A6/EN/x86/DacFramework.msi" -OutFile DacFramework2017-x86.msi
            #.\DacFramework2017-x86.msi /quiet

            #2016
            Write-Verbose "Downloading DACFx x64 from $dac64..."
            Invoke-WebRequest -Uri $dac64 -OutFile DacFramework2016-x64.msi -Verbose:$VerbosePreference
            Write-Verbose "Download of DACFx x64 successful."
            Write-Verbose "Installing DACFx x64..."
            Start-Process msiexec.exe -NoNewWindow -Wait -ArgumentList "/i DacFramework2016-x64.msi /quiet /qn /norestart"
            Write-Verbose "Installation of DACFx x64 successful."

            Write-Verbose "Downloading DACFx x86 from $dac86..."
            Invoke-WebRequest -Uri $dac86 -OutFile DacFramework2016-x86.msi -Verbose:$VerbosePreference
            Write-Verbose "Download of DACFx x86 successful."
            Write-Verbose "Installing DACFx x86..."
            Start-Process msiexec.exe -NoNewWindow -Wait -ArgumentList "/i DacFramework2016-x86.msi /quiet /qn /norestart"
            Write-Verbose "Installation of DACFx x86 successful."

            Write-Verbose "SQL Server 2016 Data-Tier Application Framework has been successfully installed."
        }
        else {
            Write-Verbose "SQL Server 2016 Data-Tier Application Framework has been detected. Skipping..."
        }

        #install CLR Types
        Write-Verbose "Checking server for CLR Types for SQL Server 2016..."
        if (-not (Test-Path "${env:programfiles(x86)}\Microsoft SQL Server\130\DAC\bin\Microsoft.SqlServer.Types.dll")) {
            Write-Verbose "CLR Types for SQL Server 2016 was not detected. Installing..."
            #2017
            #Invoke-WebRequest -Uri "https://download.microsoft.com/download/C/1/9/C1917410-8976-4AE0-98BF-1104349EA1E6/x64/SQLSysClrTypes.msi" -OutFile SQLSysClrTypes2017-x64.msi
            #.\SQLSysClrTypes2017-x64.msi /quiet

            #2016
            Write-Verbose "Downloading CLR Types 2016 from $clr2016..."
            Invoke-WebRequest -Uri $clr2016 -OutFile SQLSysClrTypes2016-x64.msi -Verbose:$VerbosePreference
            Write-Verbose "Download of CLR Types 2016 successful."
            Write-Verbose "Installing CLR Types 2016..."
            Start-Process msiexec.exe -ArgumentList "/i SQLSysClrTypes2016-x64.msi /quiet /qn /norestart" -NoNewWindow -Wait
            Write-Verbose "CLR Types for SQL Server 2016 has been successfully installed."
        }
        else {
            Write-Verbose "CLR Types for SQL Server 2016 has been detected. Skipping..."
        }

        #install SQLSMO
        Write-Verbose "Checking server for SQL Server 2016 Management Objects..."
        if (-not (Test-Path "${env:programfiles(x86)}\Microsoft SQL Server\130\SDK\Assemblies\Microsoft.SqlServer.Smo.dll")) {
            Write-Verbose "SQL Server 2016 Management Objects was not detected. Installing..."
            Write-Verbose "Downloading SMO 2016 from $smo..."
            Invoke-WebRequest -Uri $smo -OutFile SharedManagementObjects-x64.msi -Verbose:$VerbosePreference
            Write-Verbose "Download of SMO 2016 successful."
            Write-Verbose "Installing SMO 2016..."
            Start-Process msiexec.exe -NoNewWindow -Wait -ArgumentList "/i SharedManagementObjects-x64.msi /quiet /qn /norestart"
            Write-Verbose "SQL Server 2016 Management Objects has been successfully installed."
        }
        else {
            Write-Verbose "SQL Server 2016 Management Objects has been detected. Skipping..."
        }
    }

    #install .net 4.6.2
    Write-Verbose "Checking server for ASP.NET 4.6.2..."
    if (Get-ChildItem "HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full\" | Get-ItemPropertyValue -Name Release | ForEach-Object { $_ -lt 394802 }) {
        Write-Verbose "ASP.NET 4.6.2 was not detected. Installing..."
        Write-Verbose "Downloading ASP.NET 4.6.2 from $aspnet462..."
        Invoke-WebRequest -Uri  -OutFile NDP462-KB3151800-x86-x64-AllOS-ENU.exe -Verbose:$VerbosePreference
        Write-Verbose "Download of ASP.NET 4.6.2 successful."
        Write-Verbose "Installing ASP.NET 4.6.2..."
        Start-Process NDP462-KB3151800-x86-x64-AllOS-ENU.exe -ArgumentList "/install /quiet" -NoNewWindow -Wait
        Write-Verbose "ASP.NET 4.6.2 has been successfully installed."
    }
    else {
        Write-Verbose "ASP.NET 4.6.2 has been detected. Skipping..."
    }
}
