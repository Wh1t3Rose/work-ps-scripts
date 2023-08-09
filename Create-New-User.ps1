Import-Module ActiveDirectory
Import-Module AzureADPreview

#Get Credentials to connect
$Credential = Get-Credential

Connect-AzureAD -Credential $Credential

#Connect to Exchange Online
Connect-ExchangeOnline -Credential $Credential -ShowBanner:$False

$users = Get-ADUser -SearchBase ‘OU=Test Users, OU=CFGA Users,DC=cfga,DC=titan,DC=1sourcing, DC=net’ -filter *

foreach ($user in $users)
{
    $email = $user.samaccountname + '@cfgreateratlanta.org'
    $UserPrincipalName = $email

    $newemail = "SMTP:"+$email
    $mailattribute = $email
    #$DisplayName = $user.displayName
    #$sam = $_SamAccountName

    Write-Host "UserPrincipalName: $UserPrincipalName"
    $account = Get-AzureADUser | Where-Object {$_.UserPrincipalName -eq $UserPrincipalName}
    Write-Host "Account: $account"
    
    if ($account -ne $null) {
        Get-AzureADUser -ObjectId $account.ObjectId | select Account
    
        # Add the user to the Azure AD group
        Add-AzureADGroupMember -ObjectId (Get-AzureADGroup -SearchString "OfficeUsersTest").ObjectId -RefObjectId $account.ObjectId

        #PowerShell to add a user to office 365 group
        Add-UnifiedGroupLinks -Identity OfficeUsersTest@cfgreateratlanta.onmicrosoft.com -LinkType "Members" -Links $email
    }
}

        #Disconnect Exchange Online
        Disconnect-ExchangeOnline -Confirm:$False