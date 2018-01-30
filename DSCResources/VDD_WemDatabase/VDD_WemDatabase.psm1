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
        $Credential,

        [Parameter()] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )
    process {

        $targetResource = @{
            DatabaseServer = $DatabaseServer;
            DatabaseName = '';
            DatabaseFilesFolder = '';
            VuemUserSqlPassword = '';
            DefaultAdministratorsGroup = '';
            Ensure = '';
        }

        #if ($PSBoundParameters.ContainsKey('Credential')) {

            #Check if database $DatabaseName exist
            if (TestMSSQLDatabase -DatabaseServer $DatabaseServer -DatabaseName $DatabaseName) {
                $targetResource['DatabaseName'] = $DatabaseName;
                $targetResource['Ensure'] = 'Present';

                #Check WEM Default Administrator Group
                #Only the Group SID is stored in dbo.VUEMAdministrators table
                $AdObj = New-Object System.Security.Principal.NTAccount($DefaultAdministratorsGroup)
                $strSID = $AdObj.Translate([System.Security.Principal.SecurityIdentifier])
                $DefaultAdministratorsGroupSID = $strSID.Value
                $checkDefaultAdministratorsGroup = Invoke-Sqlcmd -Query "SELECT * FROM dbo.VUEMAdministrators WHERE Name = '$DefaultAdministratorsGroupSID'" -ServerInstance $DatabaseServer -Database $DatabaseName
                if ($null -ne $checkDefaultAdministratorsGroup ) {
                    $targetResource['DefaultAdministratorsGroup'] = $DefaultAdministratorsGroup;
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
            }
            else {
                $targetResource['Ensure'] = 'Absent';
            }

        #}

        #else {
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
        $Credential,

        [Parameter()] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )
    process {
        #Get the data from target node
        $targetResource = Get-TargetResource @PSBoundParameters;

        #Normalize DatabaseFilesFolder to prepare the test
        $targetDatabaseFilesFolder = ''
        if ($targetResource.DatabaseFilesFolder) {
            $targetDatabaseFilesFolder = Join-Path $targetResource.DatabaseFilesFolder "";
        }

        $desiredDatabaseFilesFolder = Join-Path $DatabaseFilesFolder "";

        if (($targetResource.Ensure -eq $Ensure) -and ($targetResource.DatabaseName -eq $DatabaseName) -and ( $targetDatabaseFilesFolder -eq $desiredDatabaseFilesFolder) -and ($targetResource.VuemUserSqlPassword -eq $VuemUserSqlPassword) -and ($targetResource.DefaultAdministratorsGroup -eq $DefaultAdministratorsGroup)) {

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
        $Credential,

        [Parameter()] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )
    begin {

        #Test if WEM SDK module is available
        if (-not (Test-Path -Path "${Env:ProgramFiles(x86)}\Norskale\Norskale Infrastructure Services\SDK\WemDatabaseConfiguration\WemDatabaseConfiguration.psd1" -PathType leaf)) {
                ThrowInvalidProgramException -ErrorId 'WEMSdkNotFound' -ErrorMessage $localized.WEMSDKNotFoundError;
        }

    } #end begin
    process {

        $scriptBlock = {
            #Import Citrix WEM SDK Powershell module
            Import-Module "${Env:ProgramFiles(x86)}\Norskale\Norskale Infrastructure Services\SDK\WemDatabaseConfiguration\WemDatabaseConfiguration.psd1" -Verbose:$false;

            #GET data
            $targetResource = Get-TargetResource @PSBoundParameters;

            if ($Ensure -eq 'Present') {
                #Normalize DatabaseFilesFolder to prepare the DatabaseFileFolder test
                $targetDatabaseFilesFolder = ''
                if ($targetResource.DatabaseFilesFolder) {
                    $targetDatabaseFilesFolder = Join-Path $targetResource.DatabaseFilesFolder "";
                }
                $desiredDatabaseFilesFolder = Join-Path $DatabaseFilesFolder "";

                #If database does not exist : create database
                if (-not ($targetResource.DatabaseName -eq $DatabaseName)) {
                    $databaseFileName = Join-Path $DatabaseFilesFolder $DatabaseName;
                    New-WemDatabase -DatabaseServerInstance $DatabaseServer -DatabaseName $DatabaseName -DataFilePath($databaseFileName+"_Data.mdf") -LogFilePath($databaseFileName+"_Log.ldf") -DefaultAdministratorsGroup $DefaultAdministratorsGroup;
                    Write-Verbose ($using:localizedData.CreatingWEMDatabase -f $using:DatabaseName, $using:DatabaseServer);
                }
                else {
                    #If default administator group is wrong : Configure Default Administrators Group
                    if (-not ($targetResource.DefaultAdministratorsGroup -eq $DefaultAdministratorsGroup)) {
                        $AdObj = New-Object System.Security.Principal.NTAccount($DefaultAdministratorsGroup)
                        $strSID = $AdObj.Translate([System.Security.Principal.SecurityIdentifier])
                        $DefaultAdministratorsGroupSID = $strSID.Value

                        $null = Invoke-Sqlcmd -Query "INSERT INTO dbo.VUEMAdministrators ([Name], [Description], [State], [Type], [Permissions], [RevisionId]) VALUES ('$DefaultAdministratorsGroupSID', NULL, 1, 2, '<?xml version=`"1.0`" encoding=`"utf-8`"?><ArrayOfVUEMAdminPermission xmlns:xsd=`"http://www.w3.org/2001/XMLSchema`" xmlns:xsi=`"http://www.w3.org/2001/XMLSchema-instance`"><VUEMAdminPermission><idSite>0</idSite><AuthorizationLevel>FullAccess</AuthorizationLevel></VUEMAdminPermission></ArrayOfVUEMAdminPermission>', 1)" -ServerInstance $DatabaseServer -Database $DatabaseName

                    }

                    #If database files folder is wrong, move database files to the correct directory
                    if (-not ( $targetDatabaseFilesFolder -eq $desiredDatabaseFilesFolder)) {
                        #Get the logical name of the data and log files associated with the database by typing the following:
                        #USE master SELECT name, physical_name FROM sys.master_files WHERE database_id = DB_ID("Personnel");
                        $databaseFiles = Invoke-Sqlcmd -Query "SELECT name, physical_name AS current_file_location FROM sys.master_files WHERE name LIKE '%$DatabaseName%'" -ServerInstance $DatabaseServer;

                        #Take the database you want to work with offline
                        $null = Invoke-Sqlcmd -Query "ALTER DATABASE $DatabaseName SET offline WITH ROLLBACK IMMEDIATE" -ServerInstance $DatabaseServer

                        #Move one file at a time to the new location
                        foreach ($databaseFile in $databaseFiles) {
                            $fileName = $databaseFile.name
                            $file = Split-Path -Path $databaseFile.current_file_location  -Leaf
                            $newDatabaseFilePath = Join-Path $DatabaseFilesFolder $file
                            $null = Invoke-Sqlcmd -Query "ALTER DATABASE $DatabaseName MODIFY FILE ( NAME = $fileName, FILENAME = `"$newDatabaseFilePath`")" -ServerInstance $DatabaseServer
                        }

                        #Put the database back online
                        $null = Invoke-Sqlcmd -Query "ALTER DATABASE $DatabaseName SET online" -ServerInstance $DatabaseServer
                    }

                    #If VuemUserSqlPassword is wrong, reset it to the desired value
                    if (-not ($targetResource.VuemUserSqlPassword -eq $VuemUserSqlPassword)) {
                        $null = Invoke-Sqlcmd -Query "ALTER LOGIN vuemUser WITH PASSWORD = '$VuemUserSqlPassword'" -ServerInstance $DatabaseServer
                    }
                }
            }
            #If ensure eq Absent, drop the existing database
            else {
                $null = Invoke-Sqlcmd -Query "DROP DATABASE $DatabaseName" -ServerInstance $DatabaseServer
            }


        } #end scriptBlock

        $invokeCommandParams = @{
            ScriptBlock = $scriptBlock;
            ErrorAction = 'Stop';
        }

        #if ($Credential) {
        #    AddInvokeScriptBlockCredentials -Hashtable $invokeCommandParams -Credential $Credential;
        #}
        #else {
            $invokeCommandParams['ScriptBlock'] = [System.Management.Automation.ScriptBlock]::Create($scriptBlock.ToString().Replace('$using:','$'));
        #}

        #$scriptBlockParams = @($Credential, $SiteName, $DatabaseServer, $DataStore, $DatabaseName);
        #Write-Verbose ($localizedData.InvokingScriptBlockWithParams -f [System.String]::Join("','", $scriptBlockParams));

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

function ThrowInvalidProgramException {
<#
    .SYNOPSIS
        Throws terminating error of category NotInstalled with specified errorId and errorMessage.
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [System.String] $ErrorId,

        [Parameter(Mandatory)]
        [System.String] $ErrorMessage
    )
    process {

        $errorCategory = [System.Management.Automation.ErrorCategory]::NotInstalled;
        $exception = New-Object -TypeName 'System.InvalidProgramException' -ArgumentList $ErrorMessage;
        $errorRecord = New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList $exception, $ErrorId, $errorCategory, $null;
        throw $errorRecord;

    } #end process
} #end function ThrowInvalidProgramException

#endregion Private Functions

$moduleRoot = Split-Path -Path $MyInvocation.MyCommand.Path -Parent;

## Import the XD7Common library functions
$moduleParent = Split-Path -Path $moduleRoot -Parent;
#Import-Module (Join-Path -Path $moduleParent -ChildPath 'VE_XD7Common');

Export-ModuleMember -Function *-TargetResource;
