$ReposLocation = "C:\Users\seank\Repositories\"
$NugetOfflineFolder = "C:\Users\SeanK\OneDrive\Nuget_Offline"

######### You probably don't need to edit below this line


## Setup the Powershell Logging to a CSV & the Screen
function Write-Log {
     [CmdletBinding()]
     param(
         [Parameter()]
         [ValidateNotNullOrEmpty()]
         [string]$Message,
 
         [Parameter()]
         [ValidateNotNullOrEmpty()]
         [ValidateSet('Information','Warning','Error')]
         [string]$Severity = 'Information'
     )
 
     $logObject = [pscustomobject]@{
         Time = (Get-Date -f g)
         Message = $Message
         Severity = $Severity
     }
     
     $logObject | Export-Csv -Path "$PSScriptRoot\LogFile.csv" -Append -NoTypeInformation

     switch ($Severity) { 
        'Information' { 
            Write-Information -MessageData $Message -InformationAction Continue
        } 
        'Warning' { 
            Write-Warning -MessageData $Message -WarningAction Continue
        } 
        'Error' { 
            Write-Error -MessageData $Message -ErrorAction Continue
        } 
    }
   
 }

## Begin our Script

Write-Log -Message "***** Sourcing the files" -Severity Information
$repoFolders = Get-ChildItem $ReposLocation -Directory 
$slnFiles = Get-ChildItem -Path $ReposLocation -Recurse -Include *.sln
$gemFiles = Get-ChildItem -Path $ReposLocation -Recurse -Include Gemfile
$packageJsonFiles = Get-ChildItem -Path $ReposLocation -Recurse | Where-Object { $_.Name -eq "package.json" -and $_.FullName -notlike "*node_modules*"}

Write-Log -Message "***** Pulling the latest from git for each repo" -Severity Information
$repoFolders | Foreach-Object { $_.FullName; cd $_.FullName; git pull --all }

Write-Log -Message "***** Installing Nuget Packages" -Severity Information
$slnFiles | Foreach-Object { $_.FullName; cd $_.Directory.FullName; nuget install }

Write-Log -Message "***** Installing the Gems" -Severity Information
$gemFiles | Foreach-Object { $_.FullName; cd $_.Directory.FullName; bundle install }

Write-Log -Message "***** Installing the npm packages" -Severity Information
$packageJsonFiles | Foreach-Object { $_.FullName; cd $_.Directory.FullName; npm install }

Write-Log -Message "***** Copying Nuget packages to the offline nuget folder" -Severity Information
Write-Log -Message "***** NOTE: Error messages about files already existing can be safely ignored" -Severity Warning

# Note: We have to get the folders at this point and not along with the other steps, because the packages may not exist until nuget install is run
$nugetPackageFolders = Get-ChildItem -Path $ReposLocation -Recurse -Directory | where-object { $_.Name -eq "packages" }
$nugetPackageFolders | Foreach-Object { Copy-Item -Recurse ($_.FullName + "\*") -Destination $NugetOfflineFolder }

Write-Log -Message "***** DONE!" -Severity Information
