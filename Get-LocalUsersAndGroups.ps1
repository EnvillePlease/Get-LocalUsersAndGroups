﻿#
# Get-LocalUsersAndGroups.ps1
#
# Get's local users, groups and group memberships for the
# local or a remote computer(s).
#
# If querying remote computer a list can be supplied for
# multiple systems.  A further parameter can be applied to
# specify where the output is stored.
#
# The output file is in CSV format with headers and is named
# <servername>_LocalUsers.csv & <servername>_LocalGroups.csv
#
# Author: Clark Nelson
# Company: Capita Technology & Software Services
# Copyright: (c)  Copyright 2024 All Rights Reserved
# Version 0.0.1 (alpha)
#

# Get the server to be connected to and the output path for the files
param ([Parameter(Mandatory)]$servername, [Parameter(Mandatory)]$outputpath )

# Class hold an individual user in the correct format and order.
class LocalUser {
	[string]$Computername
	[string]$AccountName
	[string]$AccountType
	[string]$FullName
	[string]$Comment
	[string]$AccountActive
	[string]$PasswordLastSet
	[string]$PasswordExpires
	[string]$PasswordChangeable
	[string]$PasswordRequired
	[string]$UserCanChangePassword
	[string]$LastLogon

	# Default constructor for instancing.
	LocalUser() { $this.Init(@{}) }
	# Shared initializer method
    [void] Init([hashtable]$Properties) {
        foreach ($Property in $Properties.Keys) {
            $this.$Property = $Properties.$Property
        }
    }
}

$localuserstemp = Invoke-Command -ComputerName $servername {Get-LocalUser} -UseSSL
$localuserslist = New-Object -TypeName "System.Collections.ArrayList"
foreach ($localuser in $localuserstemp)
{
    $templocaluser = [LocalUser]::new()
    $templocaluser.Computername = $servername
    $templocaluser.AccountName = $localuser.Name
    $templocaluser.AccountType = ""
    $templocaluser.FullName = $localuser.FullName
    $templocaluser.Comment = $localuser.Description
    $templocaluser.AccountActive = $localuser.Enabled
    $templocaluser.PasswordLastSet = $localuser.PasswordLastSet
    $templocaluser.PasswordExpires = $localuser.PasswordExpires
    $templocaluser.PasswordChangeable = $localuser.PasswordChangeableDate
    $templocaluser.PasswordRequired = $localuser.PasswordRequired
    $templocaluser.UserCanChangePassword = $localuser.UserMayChangePassword
    $templocaluser.LastLogon = $localuser.LastLogon

    $localuserslist.Add($templocaluser)

}
$filename = $outputpath + "\" + $servername + "_LocalUsers.csv"
$localuserslist | Export-Csv -Path $filename -NoTypeInformation