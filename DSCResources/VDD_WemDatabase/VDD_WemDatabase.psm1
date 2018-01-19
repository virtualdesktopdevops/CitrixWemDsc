Import-LocalizedData -BindingVariable localizedData -FileName VDD_WemDatabase.Resources.psd1;

function Get-TargetResource {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSDSCUseVerboseMessageInDSCResource', '')]
    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $DatabaseServer,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $DatabaseName,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $DatabaseFilesFolder,

        #Specific password for the WEM vuemUser SQL user account. Leave empty to create a default password.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $VuemUserSqlPassword,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $DefaultAdministratorsGroup,

        [Parameter()]
        [AllowNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Credential
    )
    process {

        $targetResource = @{
            DatabaseServer = $DatabaseServer;
            DatabaseName = '';
            DatabaseFilesFolder = '';
            VuemUserSqlPassword = '';
            DefaultAdministratorsGroup = $DefaultAdministratorsGroup;
        }

        #if ($PSBoundParameters.ContainsKey('Credential')) {

            #Check if database $DatabaseName exist
            if (TestMSSQLDatabase -DatabaseServer $DatabaseServer -DatabaseName $DatabaseName) {
                $targetResource['DatabaseName'] = $DatabaseName;
            }

            #Check WEM Default Administrator Group
            $checkDefaultAdministratorsGroup = Invoke-Sqlcmd -Query "SELECT AAA FROM $DatabaseName WHERE XXX = '$DefaultAdministratorsGroup'" -ServerInstance $DatabaseServer)
            if ($null -ne $checkDefaultAdministratorsGroup.XXXXX[0] ) {

            }

            #Check Database files folder
            $checkDatabaseFilesFolder = Invoke-Sqlcmd -Query "SELECT name, physical_name AS current_file_location FROM sys.master_files WHERE name LIKE '%$DatabaseName%'" -ServerInstance $DatabaseServer;
            if ($null -ne $checkDatabaseFilesFolder.current_file_location[0] ) {
                $targetResource['DatabaseFilesFolder'] = Split-Path -Path $checkDatabaseFilesFolder.current_file_location[0];
            }

            #Check VuemUserSqlPassword
            $checkVuemUserSqlPassword = New-Object System.Data.DataTable
            $checkVuemUserSqlPassword = Invoke-Sqlcmd -Query "SELECT * FROM master.dbo.syslogins WHERE name = 'VuemUser' and PWDCOMPARE('$VuemUserSqlPassword', password) = 1" -ServerInstance $DatabaseServer;
            if ($checkVuemUserSqlPassword.name -eq 'VuemUser'){
                $targetResource['VuemUserSqlPassword'] = $VuemUserSqlPassword;
            }

        #}

        #else {
        #
        #
        #}

        return $targetResource;

    } #end process
} #end function Get-TargetResource


function Test-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $DatabaseServer,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $DatabaseName,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $DatabaseFilesFolder,

        #Specific password for the WEM vuemUser SQL user account. Leave empty to create a default password.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $VuemUserSqlPassword,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $DefaultAdministratorsGroup,

        [Parameter()]
        [AllowNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Credential
    )
    process {
        #Get the data from target node
        $targetResource = Get-TargetResource @PSBoundParameters;

        #Normalize DatabaseFilesFolder to prepare the tes
        $targetDatabaseFilesFolder = Join-Path $targetResource.DatabaseFilesFolder "";
        $desiredDatabaseFilesFolder = Join-Path $DatabaseFilesFolder "";

        if (($targetResource.DatabaseName -eq $DatabaseName) -and ( $targetDatabaseFilesFolder -eq $desiredDatabaseFilesFolder) -and ($targetResource.VuemUserSqlPassword -eq $VuemUserSqlPassword)) {

            Write-Verbose ($localizedData.DatabaseDoesExist -f $DatabaseName, $DatabaseServer);
            Write-Verbose ($localizedData.ResourceInDesiredState -f $DatabaseName);
            $inDesiredState = $true;

        }
        else {
            $inDesiredState = $false;
        }

        if ($inDesiredState) {

            Write-Verbose ($localizedData.ResourceInDesiredState);
            return $true;
        }
        else {

            Write-Verbose ($localizedData.ResourceNotInDesiredState);
            return $false;
        }

    } #end process
} #end function Test-TargetResource


function Set-TargetResource {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $DatabaseServer,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $DatabaseName,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $DatabaseFilesFolder,

        #Specific password for the WEM vuemUser SQL user account. Leave empty to create a default password.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $VuemUserSqlPassword,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $DefaultAdministratorsGroup,

        [Parameter()]
        [AllowNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Credential
    )
    begin {

        #AssertXDModule -Name 'Citrix.XenDesktop.Admin';

    } #end begin
    process {

        #GET data
        $targetResource = Get-TargetResource @PSBoundParameters;

        #If database does not exist : create database
        if (-not ($targetResource.DatabaseName -eq $DatabaseName)) {
            $fileFolder = (Join-Path $DatabaseFilesFolder '');
            New-WemDatabase -DatabaseServerInstance $DatabaseServer -DatabaseName $DatabaseName -DataFilePath($fileFolder+$DatabaseName+"_Data.mdf") -LogFilePath($fileFolder+$DatabaseName+"_Log.ldf") -DefaultAdministratorsGroup $DefaultAdministratorsGroup;
        }

        #If default administator group is wrong : Configure Default Administrators Group
        if (($targetResource.DatabaseName -eq $DatabaseName) -and (-not ($targetResource.DefaultAdministratorsGroup -eq $DefaultAdministratorsGroup))) {


        }


        $scriptBlock = {
            #Import Citrix WEM SDK Powershell module
            Import-Module "$env:ProgramFiles\Citrix\XenDesktopPoshSdk\Module\Citrix.XenDesktop.Admin.V1\Citrix.XenDesktop.Admin\Citrix.XenDesktop.Admin.psd1" -Verbose:$false;

            $newXDDatabaseParams = @{
                DatabaseServer = $using:DatabaseServer;
                DatabaseName = $using:DatabaseName;
                DataStore = $using:DataStore;
                SiteName = $using:SiteName;
            }

            if ($using:Credential) {
                $newXDDatabaseParams['DatabaseCredentials'] = $using:Credential;
            }

            Write-Verbose ($using:localizedData.CreatingXDDatabase -f $using:DataStore, $using:DatabaseName, $using:DatabaseServer);

            #New-XDDatabase @newXDDatabaseParams;

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

        $scriptBlockParams = @($Credential, $SiteName, $DatabaseServer, $DataStore, $DatabaseName);
        Write-Verbose ($localizedData.InvokingScriptBlockWithParams -f [System.String]::Join("','", $scriptBlockParams));

        [ref] $null = Invoke-Command @invokeCommandParams;

    } #end process
} #end function Set-TargetResource

#region Private Functions

function TestMSSQLDatabase {
    <#
    .SYNOPSIS
        Tests for the presence of a MS SQL Server database.
    .NOTES
        This function requires CredSSP to be enabled on the local machine to communicate with the MS SQL Server.
    #>
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $DatabaseServer,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $DatabaseName,

        [Parameter()]
        [AllowNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Credential
    )
    process {

        $scriptBlock = {

            $sqlConnection = New-Object -TypeName 'System.Data.SqlClient.SqlConnection';
            $sqlConnection.ConnectionString = 'Server="{0}";Integrated Security=SSPI;' -f $using:DatabaseServer;
            $sqlCommand = $sqlConnection.CreateCommand();
            $sqlCommand.CommandText = "SELECT name FROM master.sys.databases WHERE name = N'$using:DatabaseName'";
            $sqlDataAdapter = New-Object -TypeName System.Data.SqlClient.SqlDataAdapter -ArgumentList $sqlCommand;
            $dataSet = New-Object -TypeName System.Data.DataSet;

            try {

                [ref] $null = $sqlDataAdapter.Fill($dataSet);
                if ($dataSet.Tables.Name) { return $true; } else { return $false; }
            }
            catch [System.Data.SqlClient.SqlException] {

                Write-Verbose $_;
                return $false;
            }
            finally {

                $sqlCommand.Dispose();
                $sqlConnection.Close();
            }

        } #end scriptblock

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

        Write-Verbose ($localizedData.InvokingScriptBlockWithParams -f [System.String]::Join("','", @($DatabaseServer, $DatabaseName)));

        return Invoke-Command @invokeCommandParams;

    } #end process
} #end function TestMSSQLDatabase

#endregion Private Functions


$moduleRoot = Split-Path -Path $MyInvocation.MyCommand.Path -Parent;

## Import the XD7Common library functions
$moduleParent = Split-Path -Path $moduleRoot -Parent;
#Import-Module (Join-Path -Path $moduleParent -ChildPath 'VE_XD7Common');

Export-ModuleMember -Function *-TargetResource;
