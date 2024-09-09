function Get-ExoFullAccessReport {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [string]$Path
  )
  try {
    # Connect to Exchange Online
    "connecting to Exchange Online"
    Connect-ExchangeOnline
  } catch {
    Write-Error -Message "Failed to connect to Exchange Online: $_"
    return
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
      $permissions = (Get-MailboxPermission -Identity $mbx.Identity | 
          Where-Object { $_.User -ne 'NT AUTHORITY\SELF' } |
          Select-Object Identity, User, UserSid, IsOwner, Deny, AccessRights, InheritanceType, IsInherited, IsValid)
      $permissions
      foreach ($p in $permissions) {
          $result += [PSCustomObject]@{
              MailboxAddress = $mbx.PrimarySmtpAddress
              Identity = $p.Identity
              User = $p.User
              UserSid = $p.UserSid
              IsOwner = $p.IsOwner
              Deny = $p.Deny
              AccessRights = ($p.AccessRights -join ', ')
              InheritanceType = $p.InheritanceType
              IsInherited = $p.IsInherited
              IsValid = $p.IsValid
          }
      }
  }
  $result | Export-Csv -Path $Path -NoTypeInformation -Encoding UTF8 -Confirm:$false 
}
