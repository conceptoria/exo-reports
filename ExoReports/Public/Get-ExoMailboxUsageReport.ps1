function Get-ExoMailboxUsageReport {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [string]$Path,
    [Parameter(Mandatory = $true)]
    [ValidateSet('ProhibitSendQuota', 'ProhibitSendReceiveQuota', 'IssueWarningQuota')]
    [string]$QuotaType,
    [Parameter(Mandatory = $false)]
    [int]$PercentageUsed = 90,
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
  $mailboxes = Get-ExoMailbox -ResultSize Unlimited -PropertySets Quota 
  $result = @()
  foreach ($mbx in $mailboxes) {
    $issueWarningQuotaMB = (Convert-ToByteQuantifiedSize -Size $mbx.IssueWarningQuota).ToMB()
    $prohibitSendReceiveQuotaMB = (Convert-ToByteQuantifiedSize -Size $mbx.ProhibitSendReceiveQuota).ToMB()
    $prohibitSendQuotaMB = (Convert-ToByteQuantifiedSize -Size $mbx.ProhibitSendQuota).ToMB()
    switch ($QuotaType) {
      'IssueWarningQuota' { 
        $quotaBytesParsed = Convert-ToByteQuantifiedSize -Size $mbx.IssueWarningQuota
        break      
      }
      'ProhibitSendReceiveQuota' {
        $quotaBytesParsed = Convert-ToByteQuantifiedSize -Size $mbx.ProhibitSendReceiveQuota
        break
      }
      'ProhibitSendQuota' {
        $quotaBytesParsed = Convert-ToByteQuantifiedSize -Size $mbx.ProhibitSendQuota
        break
      }
      Default {
        Write-Error "Unknown quota type: $QuotaType"
        return
      }
    }
  
    if ($null -eq $quotaBytesParsed) {
      Write-Warning "Mailbox $($mbx.PrimarySmtpAddress) does not have $($QuotaType) set"
      continue
    }
    $quotaBytes = $quotaBytesParsed.ToBytes()
    $stats = Get-EXOMailboxStatistics -PrimarySmtpAddress $mbx.PrimarySmtpAddress -PropertySets Minimum
    $mbxBytes = $stats.TotalItemSize.Value.ToBytes()
    if ((($mbxBytes / $quotaBytes) * 100) -gt $PercentageUsed) {
      $result += [PSCustomObject]@{
        Identity                 = $mbx.Identity
        PrimarySmtpAddress       = $mbx.PrimarySmtpAddress
        UserPrincipalName        = $mbx.UserPrincipalName
        IssueWarningQuotaMB      = $issueWarningQuotaMB
        ProhibitSendReceiveQuota = $prohibitSendReceiveQuotaMB
        ProhibitSendQuota        = $prohibitSendQuotaMB
        UsedSpaceMB              = $stats.TotalItemSize.Value.ToMB()
        PercentageUsed           = [math]::Round(($mbxBytes / $quotaBytes) * 100, 2)
      }
    }
  }
  $result | Export-Csv -Path $Path -NoTypeInformation -Encoding UTF8 -Confirm:$false 
}
