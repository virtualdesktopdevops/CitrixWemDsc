Import-LocalizedData -BindingVariable localizedData -FileName VDD_WemBrokerConfig.Resources.psd1;


function Get-TargetResource {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingEmptyCatchBlock', '')]
    [OutputType([System.Collections.Hashtable])]
    param (
        #Citrix WEM database name
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $DatabaseName,

        #MS SQL Server hostname hosting the WEM database
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $DatabaseServer,

        #Use vuemUser SQL user account password
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Enable','Disable')]
        [System.String] $SetSqlUserSpecificPassword,

        #vuemUser SQL user account password
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $SqlUserSpecificPassword,
        
        #Use Windows authentication for infrastructure service database connection
        [Parameter()]
        [ValidateSet('Enable','Disable')]
        [System.String] $EnableInfrastructureServiceAccountCredential = 'Disable',
        
        #PSCredential for running the infrastructure service
        [Parameter()]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $InfrastructureServiceAccountCredential,

        #Enable infrastructure service to always reading site settings from its cache
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Enable','Disable')]
        [System.String] $UseCacheEvenIfOnline = 'Disable',

        #Enable Citrix WEM debug mode
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Enable','Disable')]
        [System.String] $DebugMode = 'Disable',

        #Enable collection of statistics
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Enable','Disable')]
        [System.String] $SendGoogleAnalytics = 'Disable',

        #Administration port for administration console to connect to the infrastructure service
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.UInt32] $AdminServicePort = 8284,

        #Agent service port for agent to connect to the infrastructure server
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.UInt32] $AgentServicePort = 8286,

        #Cache synchronization port for agent cache synchronization process to connect to the infrastructure service
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.UInt32] $AgentSyncPort = 8285,

        #Citrix WEM monitoring port
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.UInt32] $MonitoringPort = 8287,

        #Time (in minutes) before the infrastructure service refreshes its cache
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.UInt32] $CacheRefreshDelay = 15,

        #Time (in seconds) between each infrastructure service attempt to poll the SQL server
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.UInt32] $SQLCheckDelay = 30,

        #Time (in seconds) which the infrastructure service waits when trying to establish a connection with the SQL server
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.UInt32] $InfrastructureServiceSQLConnectionTimeout = 30,
        
        #Enable deletion of old statistics records from the database at periodic intervals
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Enable','Disable')]
        [System.String] $EnableScheduledMaintenance = 'Enable',

        #Retention period for user and agent statistics (in days)
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.UInt32] $StatisticsRetentionPeriod = 365,

        #Retention period for system optimization statistics
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.UInt32] $SystemMonitoringRetentionPeriod = 90,

        #Retention period for agent registration logs
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.UInt32] $AgentRegistrationsRetentionPeriod = 1,

        #The time at which the database maintenance action is performed (HH:MM)
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $DatabaseMaintenanceExecutionTime = '02:00',
        
        #Override any Citrix License Server information already in the WEM database
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Enable','Disable')]
        [System.String] $GlobalLicenseServerOverride = 'Disable',
        
        #Citrix License Server name
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $LicenseServerName,

        #Citrix License Server port
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.UInt32] $LicenseServerPort = 27000

    )
    begin {

        #Test if WEM SDK module is available
        if (-not (Test-Path -Path "${Env:ProgramFiles(x86)}\Norskale\Norskale Infrastructure Services\SDK\WemInfrastructureServiceConfiguration\WemInfrastructureServiceConfiguration.psd1" -PathType leaf)) {
                ThrowInvalidProgramException -ErrorId 'WEMSdkNotFound' -ErrorMessage $localized.WEMSDKNotFoundError;
        }

    } #end begin
    process {

        $scriptBlock = {

            #Import Citrix WEM SDK Powershell module
            Import-Module "${Env:ProgramFiles(x86)}\Norskale\Norskale Infrastructure Services\SDK\WemInfrastructureServiceConfiguration\WemInfrastructureServiceConfiguration.psd1" -Verbose:$false;


            try {
                            
                $brokerConfig = Get-WemInfrastructureServiceConfiguration;

            }
            catch { }

            $targetResource = @{
                DatabaseName = $brokerConfig.DatabaseName
                DatabaseServer = $brokerConfig.DatabaseServerInstance
                SetSqlUserSpecificPassword = $brokerConfig.SetSqlUserSpecificPassword
                #SqlUserSpecificPassword = $brokerConfig.SqlUserSpecificPassword
                EnableInfrastructureServiceAccountCredential = $brokerConfig.EnableInfrastructureServiceAccountCredential
                InfrastructureServiceAccountCredential = $brokerConfig.InfrastructureServiceAccountCredentialLogin
                UseCacheEvenIfOnline = $brokerConfig.UseCacheEvenIfOnline
                DebugMode = $brokerConfig.DebugMode
                SendGoogleAnalytics = $brokerConfig.SendGoogleAnalytics
                AdminServicePort = $brokerConfig.AdminServicePort
                AgentServicePort = $brokerConfig.AgentServicePort
                AgentSyncPort = $brokerConfig.AgentSyncPort
                MonitoringPort = $brokerConfig.MonitoringPort
                CacheRefreshDelay = $brokerConfig.CacheRefreshDelay
                SQLCheckDelay = $brokerConfig.SQLCheckDelay
                InfrastructureServiceSQLConnectionTimeout = $brokerConfig.InfrastructureServiceSQLConnectionTimeout
                EnableScheduledMaintenance = $brokerConfig.EnableScheduledMaintenance
                StatisticsRetentionPeriod = $brokerConfig.StatisticsRetentionPeriod
                SystemMonitoringRetentionPeriod = $brokerConfig.SystemMonitoringRetentionPeriod
                AgentRegistrationsRetentionPeriod = $brokerConfig.AgentRegistrationsRetentionPeriod
                DatabaseMaintenanceExecutionTime = $brokerConfig.DatabaseMaintenanceExecutionTime
                GlobalLicenseServerOverride = $brokerConfig.GlobalLicenseServerOverride
                LicenseServerName = $brokerConfig.LicenseServerName
                LicenseServerPort = $brokerConfig.LicenseServerPort
            };

            return $targetResource;

        } #end scriptBlock

        $invokeCommandParams = @{
            ScriptBlock = $scriptBlock;
            ErrorAction = 'Stop';
        }

        $invokeCommandParams['ScriptBlock'] = [System.Management.Automation.ScriptBlock]::Create($scriptBlock.ToString().Replace('$using:','$'));
        

        Write-Verbose $localizedData.InvokingScriptBlock;
        return Invoke-Command @invokeCommandParams -Verbose:$Verbose;

    } #end process
} #end function Get-TargetResource


function Test-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        #Citrix WEM database name
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $DatabaseName,

        #MS SQL Server hostname hosting the WEM database
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $DatabaseServer,

        #Use vuemUser SQL user account password
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Enable','Disable')]
        [System.String] $SetSqlUserSpecificPassword,

        #vuemUser SQL user account password
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $SqlUserSpecificPassword,
        
        #Use Windows authentication for infrastructure service database connection
        [Parameter()]
        [ValidateSet('Enable','Disable')]
        [System.String] $EnableInfrastructureServiceAccountCredential = 'Disable',
        
        #PSCredential for running the infrastructure service
        [Parameter()]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $InfrastructureServiceAccountCredential,

        #Enable infrastructure service to always reading site settings from its cache
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Enable','Disable')]
        [System.String] $UseCacheEvenIfOnline = 'Disable',

        #Enable Citrix WEM debug mode
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Enable','Disable')]
        [System.String] $DebugMode = 'Disable',

        #Enable collection of statistics
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Enable','Disable')]
        [System.String] $SendGoogleAnalytics = 'Disable',

        #Administration port for administration console to connect to the infrastructure service
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.UInt32] $AdminServicePort = 8284,

        #Agent service port for agent to connect to the infrastructure server
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.UInt32] $AgentServicePort = 8286,

        #Cache synchronization port for agent cache synchronization process to connect to the infrastructure service
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.UInt32] $AgentSyncPort = 8285,

        #Citrix WEM monitoring port
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.UInt32] $MonitoringPort = 8287,

        #Time (in minutes) before the infrastructure service refreshes its cache
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.UInt32] $CacheRefreshDelay = 15,

        #Time (in seconds) between each infrastructure service attempt to poll the SQL server
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.UInt32] $SQLCheckDelay = 30,

        #Time (in seconds) which the infrastructure service waits when trying to establish a connection with the SQL server
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.UInt32] $InfrastructureServiceSQLConnectionTimeout = 30,
        
        #Enable deletion of old statistics records from the database at periodic intervals
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Enable','Disable')]
        [System.String] $EnableScheduledMaintenance = 'Enable',

        #Retention period for user and agent statistics (in days)
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.UInt32] $StatisticsRetentionPeriod = 365,

        #Retention period for system optimization statistics
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.UInt32] $SystemMonitoringRetentionPeriod = 90,

        #Retention period for agent registration logs
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.UInt32] $AgentRegistrationsRetentionPeriod = 1,

        #The time at which the database maintenance action is performed (HH:MM)
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $DatabaseMaintenanceExecutionTime = '02:00',
        
        #Override any Citrix License Server information already in the WEM database
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Enable','Disable')]
        [System.String] $GlobalLicenseServerOverride = 'Disable',
        
        #Citrix License Server name
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $LicenseServerName,

        #Citrix License Server port
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.UInt32] $LicenseServerPort = 27000
        
    )
    process {

        $targetResource = Get-TargetResource @PSBoundParameters;

        $parameters = @(
            'DatabaseName'
            'DatabaseServer'
            'SetSqlUserSpecificPassword'
            #'SqlUserSpecificPassword'
            'EnableInfrastructureServiceAccountCredential'
            'InfrastructureServiceAccountCredential'
            'UseCacheEvenIfOnline'
            'DebugMode'
            'SendGoogleAnalytics'
            'AdminServicePort'
            'AgentServicePort'
            'AgentSyncPort'
            'MonitoringPort'
            'CacheRefreshDelay'
            'SQLCheckDelay'
            'InfrastructureServiceSQLConnectionTimeout'
            'EnableScheduledMaintenance'
            'StatisticsRetentionPeriod'
            'SystemMonitoringRetentionPeriod'
            'AgentRegistrationsRetentionPeriod'
            'DatabaseMaintenanceExecutionTime'
            'GlobalLicenseServerOverride'
            'LicenseServerName'
            'LicenseServerPort'
        )

        $inCompliance = $true;

        foreach ($parameter in $parameters) {

            if ($PSBoundParameters.ContainsKey($parameter)) {

                $expectedValue = $PSBoundParameters[$parameter];
                $actualValue = $targetResource[$parameter];

                if ($expectedValue -ne $actualValue) {
                    Write-Verbose ($localizedData.ResourcePropertyMismatch -f $parameter, $expectedValue, $actualValue);
                    $inCompliance = $false;

                }
            }
        }

        if ($inCompliance) {
            Write-Verbose ($localizedData.ResourceInDesiredState);
        }
        else {
            Write-Verbose ($localizedData.ResourceNotInDesiredState);
        }

        return $inCompliance;

    } #end process
} #end function Test-TargetResource


function Set-TargetResource {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    param (
        #Citrix WEM database name
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $DatabaseName,

        #MS SQL Server hostname hosting the WEM database
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $DatabaseServer,

        #Use vuemUser SQL user account password
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Enable','Disable')]
        [System.String] $SetSqlUserSpecificPassword,
        
        #vuemUser SQL user account password
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $SqlUserSpecificPassword,
        
        #Use Windows authentication for infrastructure service database connection
        [Parameter()]
        [ValidateSet('Enable','Disable')]
        [System.String] $EnableInfrastructureServiceAccountCredential = 'Disable',
        
        #PSCredential for running the infrastructure service
        [Parameter()]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $InfrastructureServiceAccountCredential,

        #Enable infrastructure service to always reading site settings from its cache
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Enable','Disable')]
        [System.String] $UseCacheEvenIfOnline = 'Disable',

        #Enable Citrix WEM debug mode
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Enable','Disable')]
        [System.String] $DebugMode = 'Disable',

        #Enable collection of statistics
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Enable','Disable')]
        [System.String] $SendGoogleAnalytics = 'Disable',

        #Administration port for administration console to connect to the infrastructure service
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.UInt32] $AdminServicePort = 8284,

        #Agent service port for agent to connect to the infrastructure server
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.UInt32] $AgentServicePort = 8286,

        #Cache synchronization port for agent cache synchronization process to connect to the infrastructure service
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.UInt32] $AgentSyncPort = 8285,

        #Citrix WEM monitoring port
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.UInt32] $MonitoringPort = 8287,

        #Time (in minutes) before the infrastructure service refreshes its cache
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.UInt32] $CacheRefreshDelay = 15,

        #Time (in seconds) between each infrastructure service attempt to poll the SQL server
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.UInt32] $SQLCheckDelay = 30,

        #Time (in seconds) which the infrastructure service waits when trying to establish a connection with the SQL server
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.UInt32] $InfrastructureServiceSQLConnectionTimeout = 30,
        
        #Enable deletion of old statistics records from the database at periodic intervals
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Enable','Disable')]
        [System.String] $EnableScheduledMaintenance = 'Enable',

        #Retention period for user and agent statistics (in days)
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.UInt32] $StatisticsRetentionPeriod = 365,

        #Retention period for system optimization statistics
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.UInt32] $SystemMonitoringRetentionPeriod = 90,

        #Retention period for agent registration logs
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.UInt32] $AgentRegistrationsRetentionPeriod = 1,

        #The time at which the database maintenance action is performed (HH:MM)
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $DatabaseMaintenanceExecutionTime = '02:00',
        
        #Override any Citrix License Server information already in the WEM database
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Enable','Disable')]
        [System.String] $GlobalLicenseServerOverride = 'Disable',
        
        #Citrix License Server name
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $LicenseServerName,

        #Citrix License Server port
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.UInt32] $LicenseServerPort = 27000
    )
    begin {

        #Test if WEM SDK module is available
        if (-not (Test-Path -Path "${Env:ProgramFiles(x86)}\Norskale\Norskale Infrastructure Services\SDK\WemInfrastructureServiceConfiguration\WemInfrastructureServiceConfiguration.psd1" -PathType leaf)) {
                ThrowInvalidProgramException -ErrorId 'WEMSdkNotFound' -ErrorMessage $localized.WEMSDKNotFoundError;
        }

    } #end begin
    process {

        $scriptBlock = {

            #Import Citrix WEM SDK Powershell module
            Import-Module "${Env:ProgramFiles(x86)}\Norskale\Norskale Infrastructure Services\SDK\WemInfrastructureServiceConfiguration\WemInfrastructureServiceConfiguration.psd1" -Verbose:$false;

            #$wemsqlpasswd = ConvertTo-SecureString “Password” –AsPlainText –Force;
            #$cred = New-Object System.Management.Automation.PSCredential(“KINDO\x_citrix_WEM”, $passwd);
            $SecureSqlUserSpecificPassword = ConvertTo-SecureString $SqlUserSpecificPassword –AsPlainText –Force;
            Set-WemInfrastructureServiceConfiguration `                –DatabaseName $DatabaseName `
                –DatabaseServerInstance $DatabaseServer `
                –SetSqlUserSpecificPassword $SetSqlUserSpecificPassword `
                –SqlUserSpecificPassword $SecureSqlUserSpecificPassword `
                –EnableInfrastructureServiceAccountCredential $EnableInfrastructureServiceAccountCredential `
                -InfrastructureServiceAccountCredential $InfrastructureServiceAccountCredential `
                –UseCacheEvenIfOnline $UseCacheEvenIfOnline `
                -DebugMode $DebugMode `
                -SendGoogleAnalytics $SendGoogleAnalytics `
                -AdminServicePort $AdminServicePort `
                -AgentServicePort $AgentServicePort `
                -AgentSyncPort $AgentSyncPort `
                -MonitoringPort $MonitoringPort `
                -CacheRefreshDelay $CacheRefreshDelay `
                -SQLCheckDelay $SQLCheckDelay `
                -InfrastructureServiceSQLConnectionTimeout $InfrastructureServiceSQLConnectionTimeout `
                -EnableScheduledMaintenance $EnableScheduledMaintenance `
                -StatisticsRetentionPeriod $StatisticsRetentionPeriod `
                -SystemMonitoringRetentionPeriod $SystemMonitoringRetentionPeriod `
                -AgentRegistrationsRetentionPeriod $AgentRegistrationsRetentionPeriod `
                -DatabaseMaintenanceExecutionTime $DatabaseMaintenanceExecutionTime `
                -GlobalLicenseServerOverride $GlobalLicenseServerOverride `
                -LicenseServerName $LicenseServerName `
                -LicenseServerPort $LicenseServerPort

                #–InfrastructureServer $WEM_ISServer ` 

        } #end scriptBlock

        $invokeCommandParams = @{
            ScriptBlock = $scriptBlock;
            ErrorAction = 'Stop';
        }

        if ($Credential) {
            AddInvokeScriptBlockCredentials -Hashtable $invokeCommandParams -Credential $Credential;
        }
        else {
            $invokeCommandParams['ScriptBlock'] = [System.Management.Automation.ScriptBlock]::Create($scriptBlock.ToString().Replace('$using:','$'));
        }

        $parameters = @(
            'TrustRequestsSentToTheXmlServicePort',
            'SecureIcaRequired',
            'DnsResolutionEnabled',
            'BaseOU',
            'ConnectionLeasingEnabled'
        )
        foreach ($parameter in $parameters) {
            if ($PSBoundParameters.ContainsKey($parameter)) {
                $scriptBlockParam = "{0}' = '{1}" -f $parameter, $PSBoundParameters[$parameter];
                Write-Verbose ($localizedData.InvokingScriptBlockWithParam -f $scriptBlockParam);
            }
        }

        [ref] $null = Invoke-Command  @invokeCommandParams;

    } #end process
} #end function Set-TargetResource


Export-ModuleMember -Function *-TargetResource;
