# Dynamics 365 v9.x requires the use of TLS 1.2 at minimum. The following line will enable TLS 1.2 for the current session
#[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 

# Load modules
$CrmSDKBin = '<PATH>\SDK\Bin';
Import-Module ${CrmSDKBin}\Microsoft.Xrm.Tooling.CrmConnector.Powershell.dll
Import-Module ${CrmSDKBin}\Microsoft.Xrm.Sdk.dll
Import-Module ${CrmSDKBin}\Microsoft.Crm.Sdk.Proxy.dll

# Interactive login to establish Dynamics 365 connection and organization service proxy
$CrmConn = Get-CrmConnection -InteractiveMode
$OrgSvc = $CrmConn.OrganizationServiceProxy 

<#
.Synopsis
   Retrieve CRM contact record
.DESCRIPTION
   Retrieve CRM contact record. Defaults to all columns if no columns are provided.
.EXAMPLE
   Get-Contact '02c6367e-c4f4-e711-a952-000d3a1a9407'
.EXAMPLE
   Get-Contact $myGuid -columns "fullname", "territorycode"
#>
function Get-Contact {
    Param
    (
        # Param1 help description
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        $guid,
        [Parameter(Mandatory = $false, 
            ValueFromPipelineByPropertyName = $true)]
        [string[]]
        $columns = $null
    )

    Process {
        if ($columns -eq $null) {
            $col = New-Object Microsoft.Xrm.Sdk.Query.ColumnSet($true)
        }
        else {
            $col = New-Object Microsoft.Xrm.Sdk.Query.ColumnSet($columns)
        }
        
        $contact = $OrgSvc.Retrieve('contact', $guid, $col)
        return $contact
    }
}

<#
.Synopsis
   Retrieve record change history
.DESCRIPTION
   Retrieve record change history
.EXAMPLE
   Get-RecordChangeHistory $entity
#>
function Get-RecordChangeHistory {
    Param
    (
        # target Dynamics 365 CE entity to bind to RetrieveRecordChangeHistoryRequest as Target
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        $target
    )

    Process {
        $historyRequest = New-Object Microsoft.Crm.Sdk.Messages.RetrieveRecordChangeHistoryRequest          
        $historyRequest.Target = $target.ToEntityReference()

        $response = $OrgSvc.Execute($historyRequest) 
        return $response
    }

}

<#
.Synopsis
   Get-AuditDetail is a CRM RetrieveAuditDetailsRequest
.DESCRIPTION
   Get-AuditDetail is a CRM RetrieveAuditDetailsRequest
.EXAMPLE
   Get-AuditDetail '00000000-0000-0000-0000-000000000000'
#>
function Get-AuditDetail {
    Param
    (
        # Param1 help description
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        $guid
    )

    Process {
        $auditRequest = New-Object Microsoft.Crm.Sdk.Messages.RetrieveAuditDetailsRequest
        $auditRequest.AuditId = $guid
        $response = $OrgSvc.Execute($auditRequest)
        return $response
    }
}


<#
.Synopsis
   Pretty print AuditDetail and AuditRecord properties
.DESCRIPTION
   Pretty print AuditDetail and AuditRecord properties
.EXAMPLE
   NOTE: $myAuditDetail Type: [Microsoft.Crm.Sdk.Messages.AuditDetail]
   
   Write-AuditDetail $myAuditDetail   
#>
function Write-AuditDetail {
    Param
    (
        # Param1 AuditRecord
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        [Microsoft.Crm.Sdk.Messages.AuditDetail]
        $auditDetail
    )

    Process {
        Write-host 
        "Action: $($auditDetail.AuditRecord.FormattedValues['operation'])" + 
        "`r`nAudited On: $($auditDetail.AuditRecord.FormattedValues['createdon'])" +
        "`r`nChanged by: $($auditDetail.AuditRecord.Attributes['userid'].name) ($($auditDetail.AuditRecord.Attributes['userid'].Id))"

        # may not have an old value so check for new
        if ($auditDetail.NewValue) {
            Write-host "Old Value" -foregroundcolor red
            Write-host "$($auditDetail.oldValue.Attributes | Format-List | Out-String)"
    
            Write-host "New Value" -foregroundcolor green
            Write-host "$($auditDetail.NewValue.Attributes | Format-List | Out-String)"
        }
        else {
            Write-host "No attribute history found"
        }
    }
}

#Main
while (1) {
    [Int]$userInput = Read-Host "
    Dynamics 365 CE Audit Log Retriever
    ==============================
    1. Retrieve Contact history by Contact GUID (Retrieves complete change history including old and new attribute values)
    2. Retrieve Audit Log using Audit ID (Only outputs audit log)
    3. Exit
    
    Enter item number" 
    
    switch ($userInput) {
        1 {
            # Get complete audit history of a specific contact
			
            $myGuid = Read-Host -Prompt "    Please enter the GUID of a CRM contact"           
            
            $contact = Get-Contact $myGuid

            $history = Get-RecordChangeHistory $contact

            Write-host "`r`n`tRegarding Record with ID $($myGuid)"
            for ($i = 0; $i -lt $history.AuditDetailCollection.Count; $i++) {
                Write-AuditDetail $history.AuditDetailCollection.AuditDetails[$i]
            }
        }
        2 {            
            $myGuid = Read-Host -Prompt '    Please enter the GUID of an Audit Record'
            $auditDetail = Get-AuditDetail $myGuid

            Write-AuditDetail $auditDetail.AuditDetail
        }
        3 {exit}
    }
}


