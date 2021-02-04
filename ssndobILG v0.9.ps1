#Enable AD Module
Import-module ActiveDirectory

$loop = 1
do {

cls
$user = Read-Host 'Enter Login'
$group = "GRP-LTL"


$mvw = [regex]::Match($user,'^[A-z]{2,5}[0-9]{3,5}$').Success
if ($mvw){
#old mvw hardpointed script here
    $DisplayName = get-aduser -Server "ad.mvwcorp.com" -identity $user -properties DisplayName | Select -expand DisplayName
    $zSSN = get-aduser -Server "ad.mvwcorp.com" -identity $user -Properties zSSN | Select -expand zSSN
    $zDOB = get-aduser -Server "ad.mvwcorp.com" -identity $user -Properties zDOB | Select -expand zDOB
    $zManagerEID = get-aduser -Server "ad.mvwcorp.com" -identity $user -Properties zManagerEID | Select -expand zManagerEID
    $Manager = get-aduser -Server "ad.mvwcorp.com" -identity $zManagerEID -Properties DisplayName | Select -expand DisplayName
    $lastlogontimestamp = get-aduser -Server "ad.mvwcorp.com" -identity $user -Properties lastlogon | Select -expand lastlogon
    $lastlogonfriendly = [DateTime]::FromFileTime($lastlogontimestamp)
    $otherMobile = Get-ADUser -Server "ad.mvwcorp.com" -identity $user -Properties otherMobile | Select -expand otherMobile
    $zContractorCompany = Get-ADUser -Server "ad.mvwcorp.com" -identity $user -Properties zContractorCompany | Select -expand zContractorCompany
    $zDOBfirstfour = $zDOB.SubString(0,4)
    $zDOBlastfour  =  $zDOB.SubString(4).contains("1920")
    $zDOBlastfour1  =  $zDOB.SubString(4).contains("1900")


    write-host ""
	write-host "Legacy Company      :     MVW" 
	write-host ""
    write-host "          Name      :    " $DisplayName
    write-host "  SSN (last 4)      :    " $zSSN
    write-host ""
    write-host "   DOB (mm/dd)      :    " $zDOBfirstfour
    write-host "    Year 1920       :    " $zDOBlastfour
    write-host "    Year 1900       :    " $zDOBlastfour1
    write-host "       Manager      :    " $Manager
    write-host "    Last Login      :    " $lastlogonfriendly
    write-host "  Other Mobile      :    " $otherMobile
    write-host "       Company      :    " $zContractorCompany
    write-host ""
	}
else{
	#ilg script starts here

    #try all except mvw exception
	Try{
	$DisplayName = get-aduser -Server "ilg.ad" -identity $user -ErrorAction Stop -properties DisplayName | Select -expand DisplayName
	
	$employeeID = get-aduser -Server "ilg.ad" -identity $user -properties employeeID | Select -expand employeeID
	$lastlogontimestamp = get-aduser -Server "ilg.ad" -identity $user -Properties lastlogon | Select -expand lastlogon
	$lastlogonfriendly = [DateTime]::FromFileTime($lastlogontimestamp)
	$otherMobile = Get-ADUser -Server "ilg.ad" -identity $user -Properties otherMobile | Select -expand otherMobile
	$Company = Get-ADUser -Server "ilg.ad" -identity $user -Properties Company | Select -expand Company
	$ManagerFull = Get-ADUser -Server "ilg.ad" -identity $user -Properties Manager| Select -expand Manager
	$Manager = Get-ADUser -Server "ilg.ad" -identity $ManagerFull -properties DisplayName | Select -expand DisplayName


	
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
	}
	
	catch{
	#check if vri
		Try{
		$DisplayName = get-aduser -Server "vri.ilg.ad" -identity $user -ErrorAction Stop -properties DisplayName | Select -expand DisplayName
		
		$employeeID = get-aduser -Server "vri.ilg.ad" -identity $user -properties employeeID | Select -expand employeeID
		$lastlogontimestamp = get-aduser -Server "vri.ilg.ad" -identity $user -Properties lastlogon | Select -expand lastlogon
		$lastlogonfriendly = [DateTime]::FromFileTime($lastlogontimestamp)
		$otherMobile = Get-ADUser -Server "vri.ilg.ad" -identity $user -Properties otherMobile | Select -expand otherMobile
		$Company = Get-ADUser -Server "vri.ilg.ad" -identity $user -Properties Company | Select -expand Company
		$ManagerFull = Get-ADUser -Server "vri.ilg.ad" -identity $user -Properties Manager| Select -expand Manager
		$Manager = Get-ADUser -Server "vri.ilg.ad" -identity $ManagerFull -properties DisplayName | Select -expand DisplayName

	
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
		}
		
		#not ilg or vri
		Catch{
			cls
			write-host "Enter Login:" $user
			#old mvw hardpointed script here
			$DisplayName = get-aduser -Server "ad.mvwcorp.com" -identity $user -properties 	DisplayName | Select -expand DisplayName
			$zSSN = get-aduser -Server "ad.mvwcorp.com" -identity $user -Properties zSSN | Select -expand zSSN
			$zDOB = get-aduser -Server "ad.mvwcorp.com" -identity $user -Properties zDOB | Select -expand zDOB
			$zManagerEID = get-aduser -Server "ad.mvwcorp.com" -identity $user -Properties zManagerEID | Select -expand zManagerEID
			$Manager = get-aduser -Server "ad.mvwcorp.com" -identity $zManagerEID -Properties DisplayName | Select -expand DisplayName
			$lastlogontimestamp = get-aduser -Server "ad.mvwcorp.com" -identity $user -Properties lastlogon | Select -expand lastlogon
			$lastlogonfriendly = [DateTime]::FromFileTime($lastlogontimestamp)
			$otherMobile = Get-ADUser -Server "ad.mvwcorp.com" -identity $user -Properties otherMobile | Select -expand otherMobile
			$zContractorCompany = Get-ADUser -Server "ad.mvwcorp.com" -identity $user -Properties zContractorCompany | Select -expand zContractorCompany
			$zDOBfirstfour = $zDOB.SubString(0,4)
			$zDOBlastfour  =  $zDOB.SubString(4).contains("1920")
			$zDOBlastfour1  =  $zDOB.SubString(4).contains("1900")

		
			write-host ""
			write-host "Legacy Company      :     MVW" 
			write-host ""
			write-host "          Name      :    " $DisplayName
			write-host "  SSN (last 4)      :    " $zSSN
			write-host ""
			write-host "   DOB (mm/dd)      :    " $zDOBfirstfour
			write-host "    Year 1920       :    " $zDOBlastfour
			write-host "    Year 1900       :    " $zDOBlastfour1
			write-host "       Manager      :    " $Manager
			write-host "    Last Login      :    " $lastlogonfriendly
			write-host "  Other Mobile      :    " $otherMobile
			write-host "       Company      :    " $zContractorCompany
			write-host ""
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


}
while ($loop -eq "1")