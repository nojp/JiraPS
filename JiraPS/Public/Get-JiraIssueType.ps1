function Get-JiraIssueType {
    # .ExternalHelp ..\JiraPS-help.xml
    [CmdletBinding( DefaultParameterSetName = '_All' )]
    param(
        [Parameter( Position = 0, Mandatory, ValueFromPipeline, ParameterSetName = '_Search' )]
        [String[]]
        $IssueType,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty,

        [Parameter()]
        [String]
        $ProjectID = $null
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"

        $server = Get-JiraConfigServer -ErrorAction Stop

        $resourceURi = "$server/rest/api/latest/issuetype"
    }

    process {
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        switch ($PSCmdlet.ParameterSetName) {
            '_All' {
                $parameter = @{
                    URI        = $resourceURi
                    Method     = "GET"
                    Credential = $Credential
                }
                Write-Debug "[$($MyInvocation.MyCommand.Name)] Invoking JiraMethod with `$parameter"
                $result = Invoke-JiraMethod @parameter

                if ($ProjectID -eq $null){
                    Write-Output (ConvertTo-JiraIssueType -InputObject $($result | ?{$_.scope -eq $null}))
                }
                else {
                    $projectSpecificItemTypes = $result | ?{$_.scope -ne $null} | ?{$_.scope.project.id -eq $ProjectID}
                    $filteredResult = $projectSpecificItemTypes + $($result | ?{($projectSpecificItemTypes.Name -notcontains $_.Name) -and $_.scope -eq $null})
                    Write-Output (ConvertTo-JiraIssueType -InputObject $filteredResult)
                }
            }
            '_Search' {
                foreach ($_issueType in $IssueType) {
                    Write-Verbose "[$($MyInvocation.MyCommand.Name)] Processing [$_issueType]"
                    Write-Debug "[$($MyInvocation.MyCommand.Name)] Processing `$_issueType [$_issueType]"

                    $allIssueTypes = Get-JiraIssueType -Credential $Credential -ProjectID $ProjectID

                    Write-Output ($allIssueTypes | Where-Object -FilterScript {$_.Id -eq $_issueType})
                    Write-Output ($allIssueTypes | Where-Object -FilterScript {$_.Name -like $_issueType})
                }
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
