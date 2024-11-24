function Convert-ToByteQuantifiedSize {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Size
  )
  
  begin {
    try {
      Add-Type -AssemblyName "Microsoft.Exchange.Management.RestApiClient"
    }
    catch {
      Write-Error -Message "Failed to load the assembly: $_"
      return
    }
    $result = $null
  }
  
  process {
    try {
      $result = [Microsoft.Exchange.Management.RestApiClient.ByteQuantifiedSize]::Parse($Size)
    }
    catch {
      Write-Error -Message "Failed to parse the size: $_"
    }
  }
  
  end {
    return $result
  }
}

try {
  Add-Type -AssemblyName "Microsoft.Exchange.Management.RestApiClient"
}
catch {
  Write-Error -Message "Failed to load the assembly: $_"
  return
}

