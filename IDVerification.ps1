#Enable AD Module
Import-module ActiveDirectory

$loop = 1
do {

#clear screen and prompt
cls
$user = Read-Host 'Enter Login'

#initialize variables
$furloughgroup = "GRP-LTL"
$CurrentDateTime = Get-Date

#regex to identify EID format and output as true or false
$mvw = [regex]::Match($user,'^[A-z]{2,5}[0-9]{3,6}$').Success

#function to pull non-mvw info from AD
function Get-Non-MVW-Info {
    param (
    [string]$server
    )

    $DisplayName = Get-ADUser -Server $server -identity $user -ErrorAction Stop -properties DisplayName | Select -expand DisplayName
	
    #pull all info from AD
    $employeeID = Get-ADUser -Server $server -identity $user -properties employeeID | Select -expand employeeID
    $otherMobile = Get-ADUser -Server $server -identity $user -Properties otherMobile | Select -expand otherMobile
    $Company = Get-ADUser -Server $server -identity $user -Properties Company | Select -expand Company
    $enabled = (Get-ADUser -server $server -identity $user -Properties enabled | Select-Object -Property enabled).enabled
	$pwdLastSettimestamp = Get-ADUser -Server $server -identity $user -Properties pwdLastSet | Select -expand pwdLastSet
	$pwdLastSetfriendly = [DateTime]::FromFileTime($pwdLastSettimestamp)
	$TimeSinceLastPwd = $CurrentDateTime - $pwdLastSetfriendly
	
	#try to pull birthDate, if birthDate is blank, set error message. includes 5 placeholder characters to replace year field.
	$birthDate = Get-ADUser -Server $server -identity $user -Properties birthDate | Select -expand birthDate
	if ($birthDate -eq $null) {
	$birthDate = "1234-DOB not in AD"
	}
	$birthDatetowrite = $birthDate.SubString(5)

    #try to pull Manager info. If no manager info, set message.
    try {
        $ManagerFull = Get-ADUser -Server $server -identity $user -Properties Manager| Select -expand Manager
        $Manager = Get-ADUser -Server $server -identity $ManagerFull -properties DisplayName | Select -expand DisplayName
    }
    catch {
        $Manager = "Invalid Manager listed in AD"
    }

    #If user is on ILG domain, check if user is furloughed by checking if they have GRP-LTL. Other domains may or may not have GRP-LTL
    if ($server -eq "ilg.ad"){
        $member = (Get-ADGroup $furloughgroup -server $server -Properties Member |  Select-Object -ExpandProperty Member)
        $memberuser = (Get-ADUser -server $server -Identity $user)
        $furloughed = ($member -contains $memberuser)
    }

    #pull logon time and make the format more user friendly. If never logged on, set message
    Try{
        $lastlogontimestamp = Get-ADUser -Server $server -identity $user -Properties lastlogon | Select -expand lastlogon
        $lastlogonfriendly = [DateTime]::FromFileTime($lastlogontimestamp)
    }
    Catch{
        $lastlogonfriendly = "User has never logged on"
    }

    #display info
    write-host ""
    write-host " Legacy Domain      :    " $server 
    write-host ""
    write-host "          Name      :    " $DisplayName
    write-host "   Employee ID      :    " $employeeID
    write-host ""
	write-host "   DOB (mm/dd)      :    " $birthDatetowrite
    write-host "       Manager      :    " $Manager
	write-host ""
	write-host "  PWD Last Set      :    " $pwdLastSetfriendly
    write-host "    Last Login      :    " $lastlogonfriendly
    write-host "       Company      :    " $Company
    write-host ""
    
    #display results of any checks done above or one line comparisons below
    If($furloughed){write-host "                          User is furloughed `r`n"}
    if(-not $enabled){write-host "                          User is disabled `r`n"}
	if($TimeSinceLastPwd.TotalDays -gt 90) {write-host "                          Password is Expired `r`n"}
    
}



#function to pull mvw info from AD
function Get-MVW-Info 
{
    #pull all info from AD
    $DisplayName = Get-ADUser -Server "ad.mvwcorp.com" -identity $user -properties DisplayName | Select -expand DisplayName
    $zSSN = Get-ADUser -Server "ad.mvwcorp.com" -identity $user -Properties zSSN | Select -expand zSSN
	$employeeID = Get-ADUser -Server "ad.mvwcorp.com" -identity $user -Properties employeeID | Select -expand employeeID
    
    $otherMobile = Get-ADUser -Server "ad.mvwcorp.com" -identity $user -Properties otherMobile | Select -expand otherMobile
    $zContractorCompany = Get-ADUser -Server "ad.mvwcorp.com" -identity $user -Properties zContractorCompany | Select -expand zContractorCompany
    $enabled = (Get-ADUser -server "ad.mvwcorp.com" -identity $user -Properties enabled | Select-Object -Property enabled).enabled
    $checknomanager = Get-ADUser -Server "ad.mvwcorp.com" -identity $user -Properties Manager | Select -expand Manager
	$pwdLastSettimestamp = Get-ADUser -Server "ad.mvwcorp.com" -identity $user -Properties pwdLastSet | Select -expand pwdLastSet
	$pwdLastSetfriendly = [DateTime]::FromFileTime($pwdLastSettimestamp)
	$TimeSinceLastPwd = $CurrentDateTime - $pwdLastSetfriendly
	
	#Try to pull zDOB. If zDOB is blank, set error message. includes 5 placeholder characters to replace year field.
	$zDOB = Get-ADUser -Server "ad.mvwcorp.com" -identity $user -Properties zDOB | Select -expand zDOB
	if ($zDOB -eq $null) {
		$zDOB = "1234-DOB not in AD"
		$zDOBfirstfour = $zDOB.SubString(5)
	}
	else {
		$zDOBfirstfour = $zDOB.SubString(0,4)
	}

    #check if user is furloughed by checking if they have GRP-LTL
    $member = (Get-ADGroup $furloughgroup -server "ad.mvwcorp.com" -Properties Member |  Select-Object -ExpandProperty Member)
    $memberuser = (Get-ADUser -server "ad.mvwcorp.com" -Identity $user)
    $furloughed = ($member -contains $memberuser)


    #pull logon time and make the format more user friendly. If never logged on, set message
    Try{
        $lastlogontimestamp = Get-ADUser -Server "ad.mvwcorp.com" -identity $user -Properties lastlogon | Select -expand lastlogon
        $lastlogonfriendly = [DateTime]::FromFileTime($lastlogontimestamp)
    }
    Catch{
        $lastlogonfriendly = "User has never logged on"
    }


    #try to pull Manager info. If no manager info, set message. This is needed because some MVW accounts have ILG Usernames as managers, which breaks the script
    #possible fix: catch into searching for the manager attribute in ilg.ad
    Try{
        $zManagerEID = Get-ADUser -Server "ad.mvwcorp.com" -identity $user -Properties zManagerEID | Select -expand zManagerEID
        $Manager = Get-ADUser -Server "ad.mvwcorp.com" -identity $zManagerEID -Properties DisplayName | Select -expand DisplayName
    }
    Catch{
        $zManagerEID = "Invalid Manager listed in AD"
        $Manager = "Invalid Manager listed in AD"
    }    


    #display info
    write-host ""
    write-host " Legacy Domain      :     MVW" 
    write-host ""
    write-host "          Name      :    " $DisplayName
	#write-host "  SSN (last 4)      :    " $zSSN
    write-host "   Employee ID      :    " $employeeID
    write-host ""
    write-host "   DOB (mm/dd)      :    " $zDOBfirstfour
    write-host "       Manager      :    " $Manager
	write-host ""
	write-host "  PWD Last Set      :    " $pwdLastSetfriendly
    write-host "    Last Login      :    " $lastlogonfriendly
    write-host "       Company      :    " $zContractorCompany
    write-host ""
	

    #display results of any checks done above or one line comparisons below
    If($furloughed){write-host "                          User is furloughed `r`n"}
    if(-not $enabled){write-host "                          User is disabled `r`n"}
    if($checknomanager -eq $null){write-host "                          Manager Attribute is blank `r`n"}
    if($zManagerEID -eq "Invalid Manager listed in AD"){write-host "                          zManagerEID Attribute is invalid `r`n"}
	if($TimeSinceLastPwd.TotalDays -gt 90) {write-host "                          Password is Expired `r`n"}
}



#main run (old main run. This is no longer used)
<# if ($mvw){
	try{
        Get-MVW-Info
	}

	#this is to catch Mori Accounts with 3 numbers
	catch{
		try{
		Get-Non-MVW-Info -server "partners.ilg.ad"
		}

		#if not found in any domain, write error message
		Catch{
		write-host ""
		write-host "User not found."
		write-host ""
		}
	}
}

else{
	try{
        Get-Non-MVW-Info -server "ilg.ad"
	}
	
	catch{
	#try to check if user is vri.ilg.ad. If not, catch to next domain.
		Try{
    		Get-Non-MVW-Info -server "vri.ilg.ad"
		}
		
		Catch{
		#try to check if user is tpi.ilg.ad. If not, catch to next domain.
			Try{
    		Get-Non-MVW-Info -server "tpi.ilg.ad"
			}
		
			Catch{
			#try to check if user is partners.ilg.ad. If not, catch to next domain.
				Try{
				Get-Non-MVW-Info -server "partners.ilg.ad"
				}
			
				Catch{
				#if no other domain, assume it's a strangely formatted EID and default back to mvw.
					Try{
					#cls and rewrite input request for a consistent display across the other searches
					cls
					write-host "Enter Login:" $user
					Get-MVW-Info
					}
					
					#if not found in any domain, write error message
					Catch{
					write-host ""
					write-host "User not found."
					write-host ""
					}
				}
			}
		}
	}
} #>

#main run
try{
        Get-MVW-Info
	}
	
	Catch{
	write-host ""
	write-host "User not found."
	write-host ""
	}
	

$pause = Read-Host 'Press enter to lookup another EID'

#Cleanup
    $DisplayName = ""
    $employeeID = ""
	$zSSN = ""
    $zDOB = ""
    $zManagerEID = ""
    $ManagerFull=""
    $Manager = ""
    $lastlogon = ""
    $member = ""
    $memberuser = ""
    $furloughed = ""
    $enabled = ""
    $checknomanager = ""


}
while ($loop -eq "1")
