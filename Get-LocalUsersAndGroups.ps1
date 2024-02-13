#
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
param ([Parameter(Mandatory)]$serverlist, [Parameter(Mandatory)]$useroutputpath, [parameter(Mandatory)] $groupoutputpath)

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

# Class to hold local group membership information
class LocalGroup {
    [string]$ReportedBy
	[string]$GroupName
	[string]$Member

    # Default constructor for instancing.
	LocalGroup() { $this.Init(@{}) }
	# Shared initializer method
    [void] Init([hashtable]$Properties) {
        foreach ($Property in $Properties.Keys) {
            $this.$Property = $Properties.$Property
        }
    }
}

# Enumerate over the list of servers.
$servers = Get-Content -Path $serverlist
foreach ($servername in $servers)
{

    # Get the local users for the computer specified in the current loop.
    $localuserstemp = Invoke-Command -ComputerName $servername {Get-LocalUser}
    $localuserslist = New-Object -TypeName "System.Collections.ArrayList"
    foreach ($localuser in $localuserstemp)
    {
        # Create an instance of the user object to hold the current user details.
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

        # Add the user to the user collection
        $localuserslist.Add($templocaluser)

    }
    # Create the output file name and output as a csv file.
    $userfilename = $useroutputpath + "\" + $servername + "_LocalUsers.csv"
    $localuserslist | Export-Csv -Path $userfilename -NoTypeInformation

    # Now lets get the local groups, enumerate through and build a list of the group members
    $localgrouptemp = Invoke-Command -ComputerName $servername {Get-LocalGroup}
    $localgrouplist = New-Object -TypeName "System.Collections.ArrayList"
    foreach ($localgroup in $localgrouptemp)
    {
        $groupname = $localgroup.Name
        $groupsid = $localgroup.SID
        # Get the members of the current group in the loop.
        $localgroupmembertemp = Invoke-Command -ComputerName $servername -ScriptBlock {param($sid) Get-LocalGroupMember -SID $sid} -ArgumentList $groupsid
        foreach ($localgroupmember in $localgroupmembertemp)
        {
            # Create an instance of the group object to hold the current groupmember details.
            $templocalgroupmember = [LocalGroup]::new()
            $templocalgroupmember.GroupName = $groupname
            $templocalgroupmember.ReportedBy = $servername
            $templocalgroupmember.Member = $localgroupmember.Name

            # Add the group member to the group collection.
            $localgrouplist.Add($templocalgroupmember)
        }
    }

    # Create the output file name and output to a csv file.
    $groupfilename = $groupoutputpath + "\" + $servername + "_LocalGroups.csv"
    $localgrouplist | Export-Csv -Path $groupfilename -NoTypeInformation
}