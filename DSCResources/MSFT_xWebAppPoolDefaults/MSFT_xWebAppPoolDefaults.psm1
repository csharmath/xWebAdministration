# Load the Helper Module
Import-Module -Name "$PSScriptRoot\..\Helper.psm1"

# Localized messages
data LocalizedData
{
    # culture="en-US"
    ConvertFrom-StringData -StringData @'
        NoWebAdministrationModule = Please ensure that WebAdministration module is installed.
        SettingValue              = Changing default value '{0}' to '{1}'
        ValueOk                   = Default value '{0}' is already '{1}'
        VerboseGetTargetResource  = Get-TargetResource has been run.
'@
}

function Get-TargetResource
{
    <#
    .SYNOPSIS
        This will return a hashtable of results
    #>

    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Machine')]
        [System.String]
        $ApplyTo
    )

    Assert-Module

    Write-Verbose -Message $LocalizedData.VerboseGetTargetResource

    return @{
        ManagedRuntimeVersion = (Get-Value -Path '' -Name 'managedRuntimeVersion')
        IdentityType          = (Get-Value -Path 'processModel' -Name 'identityType')
        StartMode             = (Get-Value -Path '' -Name 'startMode')
        IdleTimeout           = (Get-Value -Path 'processModel' -Name 'idleTimeout')
        IdleTimeoutAction     = (Get-Value -Path 'processModel' -Name 'idleTimeoutAction')
        RestartTimeLimit      = (Get-Value -Path 'recycling/periodicRestart' -Name 'time')
    }
}

function Set-TargetResource
{
    <#
    .SYNOPSIS
        This will set the desired state

    .PARAMETER ApplyTo
        Only Machine is supported.

    .PARAMETER ManagedRuntimeVersion
        Indicates the CLR version to be used by the application pool.
        The values that are allowed for this property are: v4.0, v2.0, and ''.

    .PARAMETER IdentityType
        Indicates the account identity under which the application pool runs.
        The values that are allowed for this property are:
            ApplicationPoolIdentity, LocalService, LocalSystem, NetworkService, and SpecificUser.

    .PARAMETER StartMode
        Indicates the startup type for the application pool.
        The values that are allowed for this property are: OnDemand, AlwaysRunning.

    .PARAMETER IdleTimeout
        Indicates the amount of time (in minutes) a worker process will remain idle before it shuts down.
        The value must be a string representation of a TimeSpan value and
        must be less than the restartTimeLimit property value.
        The valid range (in minutes) is 0 to 43200.

    .PARAMETER IdleTimeoutAction
        Indicates the action to perform when the idle timeout duration has been reached.
        The values that are allowed for this property are: Terminate, Suspend

        A suspended worker process remains alive but is paged-out to disk, reducing the system resources it consumes.
        When a user accesses the site again, the worker process wakes up from suspension and is quickly available.
        When an idle worker process is terminated, the worker process is shut down,
        and the startup period will be longer when the site is subsequently accessed.
        Terminating the process is the default behavior.

    .PARAMETER RestartTimeLimit
        Indicates the period of time (in minutes) after which the application pool will recycle.
        The value must be a string representation of a TimeSpan value.
        The valid range (in minutes) is 0 to 432000.
        A value of 0 means the application pool does not recycle on a regular interval.
    #>

    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSDSCUseVerboseMessageInDSCResource", "")]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Machine')]
        [System.String]
        $ApplyTo,

        [Parameter()]
        [ValidateSet('','v2.0','v4.0')]
        [System.String]
        $ManagedRuntimeVersion,

        [Parameter()]
        [ValidateSet('ApplicationPoolIdentity','LocalService','LocalSystem','NetworkService')]
        [System.String]
        $IdentityType,

        [ValidateSet('OnDemand', 'AlwaysRunning')]
        [String] $StartMode,

        [ValidateScript({
            ([ValidateRange(0, 43200)]$valueInMinutes = [TimeSpan]::Parse($_).TotalMinutes); $?
        })]
        [String] $IdleTimeout,

        [ValidateSet('Terminate', 'Suspend')]
        [String] $IdleTimeoutAction,

        [ValidateScript({
            ([ValidateRange(0, 432000)]$valueInMinutes = [TimeSpan]::Parse($_).TotalMinutes); $?
        })]
        [String] $RestartTimeLimit
    )

    Assert-Module

    Set-Value -Path '' -Name 'managedRuntimeVersion' -NewValue $ManagedRuntimeVersion
    Set-Value -Path 'processModel' -Name 'identityType' -NewValue $IdentityType
    Set-Value -Path '' -Name 'startMode' -NewValue $StartMode
    Set-Value -Path 'processModel' -Name 'idleTimeout' -NewValue $IdleTimeout
    Set-Value -Path 'processModel' -Name 'idleTimeoutAction' -NewValue $IdleTimeoutAction
    Set-Value -Path 'recycling/periodicRestart' -Name 'time' -NewValue $RestartTimeLimit
}

function Test-TargetResource
{
    <#
    .SYNOPSIS
        This tests the desired state. If the state is not correct it will return $false.
        If the state is correct it will return $true

    .PARAMETER ApplyTo
        Only Machine is supported.

    .PARAMETER ManagedRuntimeVersion
        Indicates the CLR version to be used by the application pool.
        The values that are allowed for this property are: v4.0, v2.0, and ''.

    .PARAMETER IdentityType
        Indicates the account identity under which the application pool runs.
        The values that are allowed for this property are:
            ApplicationPoolIdentity, LocalService, LocalSystem, NetworkService, and SpecificUser.

    .PARAMETER StartMode
        Indicates the startup type for the application pool.
        The values that are allowed for this property are: OnDemand, AlwaysRunning.

    .PARAMETER IdleTimeout
        Indicates the amount of time (in minutes) a worker process will remain idle before it shuts down.
        The value must be a string representation of a TimeSpan value and
        must be less than the restartTimeLimit property value.
        The valid range (in minutes) is 0 to 43200.

    .PARAMETER IdleTimeoutAction
        Indicates the action to perform when the idle timeout duration has been reached.
        The values that are allowed for this property are: Terminate, Suspend

        A suspended worker process remains alive but is paged-out to disk, reducing the system resources it consumes.
        When a user accesses the site again, the worker process wakes up from suspension and is quickly available.
        When an idle worker process is terminated, the worker process is shut down,
        and the startup period will be longer when the site is subsequently accessed.
        Terminating the process is the default behavior.

    .PARAMETER RestartTimeLimit
        Indicates the period of time (in minutes) after which the application pool will recycle.
        The value must be a string representation of a TimeSpan value.
        The valid range (in minutes) is 0 to 432000.
        A value of 0 means the application pool does not recycle on a regular interval.
    #>

    [CmdletBinding()]
    [OutputType([System.Boolean])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSDSCUseVerboseMessageInDSCResource", "")]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Machine')]
        [System.String]
        $ApplyTo,

        [Parameter()]
        [ValidateSet('','v2.0','v4.0')]
        [System.String]
        $ManagedRuntimeVersion,

        [Parameter()]
        [ValidateSet('ApplicationPoolIdentity','LocalService','LocalSystem','NetworkService')]
        [System.String]
        $IdentityType,

        [ValidateSet('OnDemand', 'AlwaysRunning')]
        [String] $StartMode,

        [ValidateScript({
            ([ValidateRange(0, 43200)]$valueInMinutes = [TimeSpan]::Parse($_).TotalMinutes); $?
        })]
        [String] $IdleTimeout,

        [ValidateSet('Terminate', 'Suspend')]
        [String] $IdleTimeoutAction,

        [ValidateScript({
            ([ValidateRange(0, 432000)]$valueInMinutes = [TimeSpan]::Parse($_).TotalMinutes); $?
        })]
        [String] $RestartTimeLimit
    )

    Assert-Module

    if (-not((Confirm-Value -Path '' `
                            -Name 'managedRuntimeVersion' `
                            -NewValue $ManagedRuntimeVersion)))
    {
        return $false
    }

    if (-not((Confirm-Value -Path 'processModel' `
                            -Name 'identityType' `
                            -NewValue $IdentityType)))
    {
        return $false
    }

    if (-not((Confirm-Value -Path '' `
                            -Name 'startMode' `
                            -NewValue $StartMode)))
    {
        return $false
    }

    if (-not((Confirm-Value -Path 'processModel' `
                            -Name 'idleTimeout' `
                            -NewValue $IdleTimeout)))
    {
        return $false
    }

    if (-not((Confirm-Value -Path 'processModel' `
                            -Name 'idleTimeoutAction' `
                            -NewValue $IdleTimeoutAction)))
    {
        return $false
    }

    if (-not((Confirm-Value -Path 'recycling/periodicRestart' `
                            -Name 'time' `
                            -NewValue $RestartTimeLimit)))
    {
        return $false
    }

    return $true
}

#region Helper Functions

function Confirm-Value
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [System.String]
        $Path,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter()]
        [System.String]
        $NewValue
    )

    if (-not($NewValue))
    {
        # if no new value was specified, we assume this value is okay.
        return $true
    }

    $existingValue = Get-Value -Path $Path -Name $Name
    if ($existingValue -ne $NewValue)
    {
        return $false
    }
    else
    {
        $relPath = $Path + '/' + $Name
        Write-Verbose($LocalizedData.ValueOk -f $relPath,$NewValue);
        return $true
    }
}

function Set-Value
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [System.String]
        $Path,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter()]
        [System.String]
        $NewValue
    )

    # if the variable doesn't exist, the user doesn't want to change this value
    if (-not($NewValue))
    {
        return
    }

    $existingValue = Get-Value -Path $Path -Name $Name
    if ($existingValue -ne $NewValue)
    {
        if ($Path -ne '')
        {
            $Path = '/' + $Path
        }

        Set-WebConfigurationProperty `
            -PSPath 'MACHINE/WEBROOT/APPHOST' `
            -Filter "system.applicationHost/applicationPools/applicationPoolDefaults$Path" `
            -Name $Name `
            -Value "$NewValue"

        $relPath = $Path + '/' + $Name
        Write-Verbose($LocalizedData.SettingValue -f $relPath,$NewValue);
    }
}

function Get-Value
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [System.String]
        $Path,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Name
    )

    if ($Path -ne '')
    {
        $Path = '/' + $Path
    }

    $result = Get-WebConfigurationProperty `
                -PSPath 'MACHINE/WEBROOT/APPHOST' `
                -Filter "system.applicationHost/applicationPools/applicationPoolDefaults$Path" `
                -Name $Name

    if ($result -is [Microsoft.IIs.PowerShell.Framework.ConfigurationAttribute])
    {
        return $result.Value
    } else {
        return $result
    }
}

#endregion

Export-ModuleMember -Function *-TargetResource
