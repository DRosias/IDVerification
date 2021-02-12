#Enable AD Module
Import-module ActiveDirectory

$loop = 1
do {

#clear screen and prompt
cls
$user = Read-Host 'Enter Login'
$furloughgroup = "GRP-LTL"

#regex to identify EID format and output as true or false
$mvw = [regex]::Match($user,'^[A-z]{2,5}[0-9]{3,5}$').Success



#multiple functions can be combined into one with passed parameters
#function to pull mvw info from AD
function mvwinfopull 
{
    #pull all info from AD
    $DisplayName = get-aduser -Server "ad.mvwcorp.com" -identity $user -properties DisplayName | Select -expand DisplayName
    $zSSN = get-aduser -Server "ad.mvwcorp.com" -identity $user -Properties zSSN | Select -expand zSSN
    $zDOB = get-aduser -Server "ad.mvwcorp.com" -identity $user -Properties zDOB | Select -expand zDOB
    $otherMobile = Get-ADUser -Server "ad.mvwcorp.com" -identity $user -Properties otherMobile | Select -expand otherMobile
    $zContractorCompany = Get-ADUser -Server "ad.mvwcorp.com" -identity $user -Properties zContractorCompany | Select -expand zContractorCompany
    $zDOBfirstfour = $zDOB.SubString(0,4)
    $zDOBlastfour  =  $zDOB.SubString(4).contains("1920")
    $zDOBlastfour1  =  $zDOB.SubString(4).contains("1900")
    $member = (Get-ADGroup $furloughgroup -server "ad.mvwcorp.com" -Properties Member |  Select-Object -ExpandProperty Member)
    $memberuser = (Get-ADUser -server "ad.mvwcorp.com" -Identity $user)
    $furloughed = ($member -contains $memberuser)
    $enabled = (Get-ADUser -server "ad.mvwcorp.com" -identity $user -Properties enabled | Select-Object -Property enabled).enabled
    $checknomanager = get-aduser -Server "ad.mvwcorp.com" -identity $user -Properties Manager | Select -expand Manager


    #pull logon time and make the format more user friendly. If never logged on, set message
    Try{
        $lastlogontimestamp = get-aduser -Server "ad.mvwcorp.com" -identity $user -Properties lastlogon | Select -expand lastlogon
        $lastlogonfriendly = [DateTime]::FromFileTime($lastlogontimestamp)
    }
    Catch{
        $lastlogonfriendly = "User has never logged on"
    }


    #try to pull Manager info. If no manager info, set message. This is needed because some MVW accounts have ILG Usernames as managers, which breaks the script
    #possible fix: catch into searching for the manager attribute in ilg.ad
    Try{
        $zManagerEID = get-aduser -Server "ad.mvwcorp.com" -identity $user -Properties zManagerEID | Select -expand zManagerEID
        $Manager = get-aduser -Server "ad.mvwcorp.com" -identity $zManagerEID -Properties DisplayName | Select -expand DisplayName
    }
    Catch{
        $zManagerEID = "Invalid Manager listed in AD"
        $Manager = "Invalid Manager listed in AD"
    }    


    #display info
    write-host ""
    write-host "Legacy Company      :     MVW" 
    write-host ""
    write-host "          Name      :    " $DisplayName
    write-host "  SSN (last 4)      :    " $zSSN
    write-host ""
    write-host "   DOB (mm/dd)      :    " $zDOBfirstfour
    write-host "       Manager      :    " $Manager
    write-host "    Last Login      :    " $lastlogonfriendly
    write-host "  Other Mobile      :    " $otherMobile
    write-host "       Company      :    " $zContractorCompany
    write-host ""

    #display results of furlough and/or disable check
    If($furloughed){write-host "                          User is furloughed `r`n"}
    if(-not $enabled){write-host "                          User is disabled `r`n"}
    if($checknomanager -eq $null){write-host "                          Manager Attribute is blank `r`n"}
    if($zManagerEID -eq "Invalid Manager listed in AD"){write-host "                          zManagerEID Attribute is invalid `r`n"}
}




#function to pull ILG info from AD
function ilginfopull
{
    $DisplayName = get-aduser -Server "ilg.ad" -identity $user -ErrorAction Stop -properties DisplayName | Select -expand DisplayName
	
    #pull all info from AD
    $employeeID = get-aduser -Server "ilg.ad" -identity $user -properties employeeID | Select -expand employeeID
    $otherMobile = Get-ADUser -Server "ilg.ad" -identity $user -Properties otherMobile | Select -expand otherMobile
    $Company = Get-ADUser -Server "ilg.ad" -identity $user -Properties Company | Select -expand Company
    $ManagerFull = Get-ADUser -Server "ilg.ad" -identity $user -Properties Manager| Select -expand Manager
    $Manager = Get-ADUser -Server "ilg.ad" -identity $ManagerFull -properties DisplayName | Select -expand DisplayName
    $member = (Get-ADGroup $furloughgroup -server "ilg.ad" -Properties Member |  Select-Object -ExpandProperty Member)
    $memberuser = (Get-ADUser -server "ilg.ad" -Identity $user)
    $furloughed = ($member -contains $memberuser)
    $enabled = (Get-ADUser -server "ilg.ad" -identity $user -Properties enabled | Select-Object -Property enabled).enabled


    #pull logon time and make the format more user friendly. If never logged on, set message
    Try{
        $lastlogontimestamp = get-aduser -Server "ilg.ad" -identity $user -Properties lastlogon | Select -expand lastlogon
        $lastlogonfriendly = [DateTime]::FromFileTime($lastlogontimestamp)
    }
    Catch{
        $lastlogonfriendly = "User has never logged on"
    }

    #display info
    write-host ""
    write-host "Legacy Company      :     ILG" 
    write-host ""
    write-host "          Name      :    " $DisplayName
    write-host "   Employee ID      :    " $employeeID
    write-host ""
    write-host "       Manager      :    " $Manager
    write-host "    Last Login      :    " $lastlogonfriendly
    write-host "       Company      :    " $Company
    write-host ""
    
    #display results of furlough or disable check
    If($furloughed){write-host "                          User is furloughed `r`n"}
    if(-not $enabled){write-host "                          User is disabled `r`n"}
}



#function to pull ILG info from AD
function vriinfopull
{
    $DisplayName = get-aduser -Server "vri.ilg.ad" -identity $user -ErrorAction Stop -properties DisplayName | Select -expand DisplayName
		
    #pull all info from AD
    $employeeID = get-aduser -Server "vri.ilg.ad" -identity $user -properties employeeID | Select -expand employeeID
    $otherMobile = Get-ADUser -Server "vri.ilg.ad" -identity $user -Properties otherMobile | Select -expand otherMobile
    $Company = Get-ADUser -Server "vri.ilg.ad" -identity $user -Properties Company | Select -expand Company
    $ManagerFull = Get-ADUser -Server "vri.ilg.ad" -identity $user -Properties Manager| Select -expand Manager
    $Manager = Get-ADUser -Server "vri.ilg.ad" -identity $ManagerFull -properties DisplayName | Select -expand DisplayName
    $member = (Get-ADGroup $furloughgroup -server "vri.ilg.ad" -Properties Member |  Select-Object -ExpandProperty Member)
    $memberuser = (Get-ADUser -server "vri.ilg.ad" -Identity $user)
    $furloughed = ($member -contains $memberuser)
    $enabled = (Get-ADUser -server "vri.ilg.ad" -identity $user -Properties enabled | Select-Object -Property enabled).enabled
    
    #pull logon time and make the format more user friendly. If never logged on, set message
    Try{
        $lastlogontimestamp = get-aduser -Server "vri.ilg.ad" -identity $user -Properties lastlogon | Select -expand lastlogon
        $lastlogonfriendly = [DateTime]::FromFileTime($lastlogontimestamp)
    }
    Catch{
        $lastlogonfriendly = "User has never logged on"
    }
    

    #display info
    write-host ""
    write-host "Legacy Company      :     ILG" 
    write-host ""
    write-host "          Name      :    " $DisplayName
    write-host "   Employee ID      :    " $employeeID
    write-host ""
    write-host "       Manager      :    " $Manager
    write-host "    Last Login      :    " $lastlogonfriendly
    write-host "       Company      :    " $Company
    write-host ""
        
    #display results of furlough or disable check
    If($furloughed){write-host "                          User is furloughed `r`n"}
    if(-not $enabled){write-host "                          User is disabled `r`n"}
}




#main run
if ($mvw){
        mvwinfopull
    }

else{
	try{
        ilginfopull
	}
	
	catch{
	#try to check if user is vri.ilg.ad. If not, catch to next domain.
		Try{
    		vriinfopull
		}
		
		#if no other domain, assume it's a strangely formatted EID and default back to mvw.
		Catch{
    			#cls and rewrite input request for a consistent display across the other searches
                	cls
    			write-host "Enter Login:" $user
    			mvwinfopull
			}
	}	
}


$pause = Read-Host 'Press enter to lookup another EID'

#Cleanup
    $DisplayName = ""
	$employeeID=""
    $zSSN = ""
    $zDOB = ""
    $zManagerEID = ""
    $zDOBlastfour = ""
    $zDOBlastfour1=""
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
