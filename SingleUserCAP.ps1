<#


 Title: Query CAPs for Single User

Description: Find all Conditonal Access Policies for a single user query.

Flow:

    Query all CAPs and pull Included users and groups.

    Query all memebers of groups and compare to single user.

    Return all CAPs that apply to user. 

#>

 

$script:userCAPS = @{}

 

#Get user objectid

$User = Read-Host -Prompt "User SMTP address"

$objUser = Get-AzureADUser -SearchString $User | Select UserPrincipalName,ObjectId

 

 

#Get CAPs

$arrCAPS = @()

$arrCAPS = Get-AzureADMSConditionalAccessPolicy | Select DisplayName, State, Conditions

 

 

Foreach ($CAP in $arrCAPS){

 

 

    #Query User

    # Include User

    #----------------------------------------------------------------

    if($CAP.Conditions.Users.IncludeUsers -eq $objUser){

       

        $CAP.DisplayName

           

        $userCAPS.Add($CAP.DisplayName, "Include - " + $CAP.State)

    }

    # Exclude User

    if($CAP.Conditions.Users.ExcludeUsers -eq $objUser){

       

        $CAP.DisplayName

           

        $userCAPS.Add($CAP.DisplayName, "Exclude - " +  $CAP.State)

    }

 

    #----------------------------------------------------------------

 

    # Include Group

    if(($CAP.Conditions.Users.IncludeGroups).count -eq 1){

       

 

        $Temp = Get-AzureADGroupMember -ObjectId "$($CAP.Conditions.Users.IncludeGroups)" | Where {$_.UserPrincipalName -eq $objUser.UserPrincipalName}   

 

 

        if($Temp.count -ne 0){

       

            $userCAPS.Add($CAP.DisplayName, "Include - " +  $CAP.State)

        }

        $Temp = $null

    }else{

 

        Foreach($Group in $CAP.Conditions.Users.IncludeGroups){

 

            $Temp = (Get-AzureADGroupMember -ObjectId "$($Group)" | Where {$_.UserPrincipalName -eq $objUser.UserPrincipalName})

 

            if( $Temp.Count -ne 0){

 

                    $userCAPS.Add($CAP.DisplayName, "Include - " +  $CAP.State)                                  

            }     

 

            $Temp = $null

        }

 

    }

    #------------------------------------------------------

 

    #Exclude Group

 

    if(($CAP.Conditions.Users.ExcludeGroups).count -eq 1){

       

 

        $Temp = Get-AzureADGroupMember -ObjectId "$($CAP.Conditions.Users.ExcludeGroups)" | Where {$_.UserPrincipalName -eq $objUser.UserPrincipalName}   

 

 

        if($Temp.count -ne 0){

       

            $userCAPS.Add($CAP.DisplayName, "Exclude - " +  $CAP.State)

        }

        $Temp = $null

    }else{

 

        Foreach($Group in $CAP.Conditions.Users.ExcludeGroups){

 

            $Temp = (Get-AzureADGroupMember -ObjectId "$($Group)" | Where {$_.UserPrincipalName -eq $objUser.UserPrincipalName})

 

            if( $Temp.Count -ne 0){

 

                    $userCAPS.Add($CAP.DisplayName, "Exclude - " +   $CAP.State)                                  

            }     

 

            $Temp = $null

        }

 

    }

}


if($userCAPS.count -eq 0){

    Write-Output -Verbose "No CAPs are applied"

}else{

    Write-Output -Verbose "----------"

    Write-Output -Verbose "Following CAPs applied" ; $userCAPS | FT -HideTableHeaders

}
