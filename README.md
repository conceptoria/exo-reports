## Overview

## Usage

### Auditing Mailbox Permissions

[YouTube video with example usage](https://youtu.be/UY1gBOaNK5g)

#### Generate full access permission report

Connect to Exchange Online (you can use whatever method is suitable for you interactive login, device login, or service principal login) and run ```Get-ExoFullAccessReport```

```
Connect-ExchangeOnline
Get-ExoFullAccessReport -Path '.\full-access.csv'
```
Alternatively if you are already connected to Exchange run 

```
Get-ExoFullAccessReport -Path '.\full-access.csv' -AlreadyConnected
```

#### Generate Send As permission report

Connect to Exchange Online (you can use whatever method is suitable for you interactive login, device login, or service principal login) and run ```Get-ExoSendAsReport```

```
Connect-ExchangeOnline
Get-ExoSendAsReport -Path '.\send-as.csv'
```
Alternatively if you are already connected to Exchange run 

```
Get-ExoSendAsReport -Path '.\send-as.csv' -AlreadyConnected
```

#### Generate Send on Behalf permission report

Connect to Exchange Online (you can use whatever method is suitable for you interactive login, device login, or service principal login) and run ```Get-ExoSendOnBehalfReport```

```
Connect-ExchangeOnline
Get-ExoSendOnBehalfReport -Path '.\send-on-behalf.csv'
```

Alternatively if you are already connected to Exchange run 

```
Get-ExoSendOnBehalfReport -Path '.\send-on-behalf.csv' -AlreadyConnected
```



### Reporting Mailbox Usage

Connect to Exchange Online (you can use whatever method is suitable for you interactive login, device login, or service principal login) and run ```Get-ExoMailboxUsageReport```

You need to select, quota type that will be used for mailbox space used comparison. Available types for quotas: 
 - ProhibitSendQuota, 
 - ProhibitSendReceiveQuota, 
 - IssueWarningQuota

```
Connect-ExchangeOnline
Get-ExoSendOnBehalfReport -Path '.\full-access.csv'
```

Alternatively if you are already connected to Exchange run 

```
Get-ExoMailboxUsageReport -Path .\mbx-usage.csv -QuotaType ProhibitSendQuota -AlreadyConnected -PercentageUsed 90
```

## Examples

Configure some sample permissions on mailboxes (remember to change users to the one existing in your environment) and run proper report functions from the module.

Initial setup:

```powershell
Connect-ExchangeOnline
$mailbox = "AllanD@M365x12115223.OnMicrosoft.com"
$fullAccessUser = "diegos@M365x12115223.OnMicrosoft.com"
$fullAccessUser2 = "LeeG@M365x12115223.OnMicrosoft.com"
$sendAsUser = "LeeG@M365x12115223.OnMicrosoft.com"
$sendOnBehalf = "NestorW@M365x12115223.OnMicrosoft.com"
$sendOnBehalf2 = "LeeG@M365x12115223.OnMicrosoft.com"

Add-MailboxPermission -Identity $mailbox -User $fullAccessUser -AccessRights FullAccess -Confirm:$false
Add-MailboxPermission -Identity $mailbox -User $fullAccessUser2 -AccessRights FullAccess -Confirm:$false
Add-RecipientPermission -Identity $mailbox -Trustee $sendAsUser -AccessRights SendAs -Confirm:$false
Set-Mailbox -Identity $mailbox -GrantSendOnBehalfTo $sendOnBehalf, $sendOnBehalf2 -Confirm:$false
```


