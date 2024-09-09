$Public = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -Recurse -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -Recurse -ErrorAction SilentlyContinue )

#Dot source the files
Foreach ($import in @($Public + $Private)) {
    Try {
        . $import.fullname
        "$import.fullname"
    } Catch {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

Export-ModuleMember -Function $Public.Basename

function Show-Calendar {
    param(
        [DateTime] $start = [DateTime]::Today,
        [DateTime] $end = $start,
        $firstDayOfWeek,
        [int[]] $highlightDay,
        [string[]] $highlightDate = [DateTime]::Today.ToString('yyyy-MM-dd')
        )
    
    Write-Host ("Start: {0}" -f (Get-Date))
}

Export-ModuleMember -Function Show-Calendar