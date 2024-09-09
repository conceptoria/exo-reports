## Overview

## Examples

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

