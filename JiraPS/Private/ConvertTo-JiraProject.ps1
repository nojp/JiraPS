function ConvertTo-JiraProject {
    [CmdletBinding()]
    param(
        [Parameter( ValueFromPipeline )]
        [PSObject[]]
        $InputObject
    )

    process {
        foreach ($i in $InputObject) {
            Write-Debug "[$($MyInvocation.MyCommand.Name)] Converting `$InputObject to custom object"

            $props = @{
                'ID'          = $i.id
                'Key'         = $i.key
                'Name'        = $i.name
                'Description' = $i.description
                'Lead'        = ConvertTo-JiraUser $i.lead
                'IssueTypes'  = ConvertTo-JiraIssueType $i.issueTypes
                'Roles'       = $i.roles
                'RestUrl'     = $i.self
                'Components'  = $i.components
                'Style'       = $i.style
            }

            if ($i.projectCategory) {
                $props.Category = $i.projectCategory
            }
            elseif ($i.Category) {
                $props.Category = $i.Category
            }
            else {
                $props.Category = $null
            }

            $result = New-Object -TypeName PSObject -Property $props
            $result.PSObject.TypeNames.Insert(0, 'JiraPS.Project')
            $result | Add-Member -MemberType ScriptMethod -Name "ToString" -Force -Value {
                Write-Output "$($this.Name)"
            }

            Write-Output $result
        }
    }
}
