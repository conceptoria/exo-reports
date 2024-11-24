function Get-ExoSendOnBehalfReport {
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
  $mailboxes = (Get-Mailbox -ResultSize Unlimited | Where-Object { $null -ne $_.GrantSendOnBehalfTo })
  $result = @()
  foreach ($mbx in $mailboxes) {
              
      foreach ($s in $mbx.GrantSendOnBehalfTo) {
          $m = Get-Mailbox -Identity $s
          if ($null -ne $m) {
              $result += [PSCustomObject]@{
                  MailboxAddress = $mbx.PrimarySmtpAddress
                  Identity = $mbx.Identity
                  DisplayName = $mbx.DisplayName
                  SendOnBehalfIdentity = $m.Identity
                  SendOnBehalfMailboxAddress = $m.PrimarySmtpAddress
                  SendOnBehalfDisplayName = $m.DisplayName
              }
          }
      }
  }
  $result | Export-Csv -Path $Path -NoTypeInformation -Encoding UTF8 -Confirm:$false 
}