function Get-ExoSendAsReport {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [string]$Path,
    [Parameter(Mandatory = $false)]
    [switch]$AlreadyConnected = $false
  )
  if (-not $AlreadyConnected) {
    try {
      "Connecting to Exchange Online"
      Connect-ExchangeOnline
    }
    catch {
      Write-Error -Message "Failed to connect to Exchange Online: $_"
      return
    }
  }
  try {
    $Parent = Split-Path -Path $Path -Parent
    if (-not (Test-Path -Path $Parent)) {
      Write-Error -Message "The base path of the specified path does not exist: $Parent"
      return
    }
  } catch {
    Write-Error -Message "Failed to check the specified path: $_"
    return
  }
  $mailboxes = Get-Mailbox -ResultSize Unlimited
  $result = @()
  foreach ($mbx in $mailboxes) {
      $permissions = (Get-RecipientPermission -Identity $mbx.Identity | 
          Where-Object { $_.Trustee -ne 'NT AUTHORITY\SELF' } |
          Select-Object Identity, Trustee, TrusteeSidString, AccessControlType, AccessRights, InheritanceType, IsInherited, IsValid)
          
      foreach ($p in $permissions) {
          if ($null -ne $p) {
              $result += [PSCustomObject]@{
                  MailboxAddress = $mbx.PrimarySmtpAddress
                  Identity = $p.Identity
                  Trustee = $p.Trustee
                  TrusteeSidString = $p.TrusteeSidString
                  AccessControlType = $p.AccessControlType
                  AccessRights = ($p.AccessRights -join ', ')
                  InheritanceType = $p.InheritanceType
                  IsInherited = $p.IsInherited
                  IsValid = $p.IsValid
              }
          }
      }
  }
  $result | Export-Csv -Path $Path -NoTypeInformation -Encoding UTF8 -Confirm:$false 
}