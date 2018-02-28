# Citrix Workspace Environment Management Powershell DSC module

The **CitrixWemDsc** module contains DSC resources for deployment and configuration of Citrix Workspace Environment Management (ex Norskcale VUEM).

## Branches

### master

This is the branch containing the latest release - no contributions should be made directly to this branch.

### dev

This is the development branch to which contributions should be proposed by contributors as pull requests.
This development branch will periodically be merged to the master branch, and be released to [PowerShell Gallery](https://www.powershellgallery.com/).

## Contributing
Regardless of the way you want to contribute we are tremendously happy to have you here.

There are several ways you can contribute :
- You can submit an issue to report a bug.
- You can submit an issue to request an improvement.
- You can take part in discussions for issues.
- You can review pull requests and comment on other contributors changes.
- You can also improve the resources and tests, or even create new resources, by sending in pull requests yourself.

# Installation
To manually install the module, download the source code and unzip the contents to the
'$env:ProgramFiles\WindowsPowerShell\Modules' folder.

## Requirements

The minimum Windows Management Framework (PowerShell) version required is 5.0 or higher, which ships with Windows 10 or Windows Server 2016, but can also be installed on Windows 7 SP1, Windows 8.1, Windows Server 2008 R2 SP1, Windows Server 2012 and Windows Server 2012 R2.

## Examples

You can review the [Examples](/Examples) directory in the CitrixWemDsc module
for some general use scenarios for all of the resources that are in the module.

## Change log

A full list of changes in each version can be found in the [change log](CHANGELOG.md).

## Resources

* [**WemDatabase**](#wemdatabase)
  resource to ensure Citix WEM database is present and configured with the right permissions.
* [**WemBrokerConfig**](#wembrokerconfig)
  to link the Citrix WEM Broker to the WEM Database.

### WemDatabase

This resource is used to create, manage, and update the Citrix Workspace Management database. It will also manage the Citrix WEM default Administrators group and the vuemUser SQL account password required by WEM broker to access the database.

**Warning :** Database MDF and LDF files have to be moved manually to the new location and the database restarted after a DSC pass if the DatabaseFilesFolder is modified

#### Requirements

* Target machine must be running Windows Server 2008 R2 or later.
* **SqlServer** PowerShell module (has to be installed on the server running this module.

To install the SqlServer module: ```Install-Module -Name SqlServer```

#### Syntax ###

```
WemDatabase [string] #ResourceName
{
    DatabaseName = [string]
    DatabaseServer = [string]
    DatabaseFilesFolder = [string]
    VuemUserSqlPassword = [string]
    WemInfrastructureServiceAccount = [String]
    DefaultAdministratorsGroup = [string]
    [ Ensure = [string] { Absent | Present } ]
}
```


#### Parameters

* **`[String]` DatabaseName** _(Key)_: Citrix WEM database name.
* **`[String]` DatabaseServer** _(Required)_: MS SQL Server hostname hosting the WEM database.
* **`[String]` DatabaseFilesFolder** _(Required)_: Path to the data and log files location on the SQL Server. You must provide a valid filepath, otherwise the cmdlet will fail.
* **`[String]` VuemUserSqlPassword** _(Required)_: Specific password for the Citrix WEM vuemUser SQL user account.
* **`[String]` WemInfrastructureServiceAccount** _(Required)_: Windows service account of WEM infrastructure service.
* **`[String]` DefaultAdministratorsGroup** _(Required)_: Citrix WEM default administrators group.
* **`[String]` Ensure** _(Optional)_: Whether the database should be added or removed. Valid values are Present or Absent. Default value : Present



### WemBrokerConfig

This resource is used to configure a Citrix Workspace Management broker and to link it to a database previously created with the WemDatabase resource.


#### Syntax ###

```
WemBrokerConfig [string] #ResourceName
{
    DatabaseName = [string]
    DatabaseServer = [string]
    SetSqlUserSpecificPassword = [string] { Enable | Disable }
    [ SqlUserSpecificPassword = [string] ]
    [ EnableInfrastructureServiceAccountCredential = [string] { Enable | Disable } ]
    [ [InfrastructureServiceAccountCredential = [MSFT_Credential] ]
    [ UseCacheEvenIfOnline = [string] { Enable | Disable } ]
    [ DebugMode = [string] { Enable | Disable } ]
    [ SendGoogleAnalytics = [string] { Enable | Disable } ]
    [ AdminServicePort = [uint32] ]
    [ AgentServicePort = [uint32] ]
    [ AgentSyncPort = [uint32] ]
    [ MonitoringPort = [uint32] ]
    [ CacheRefreshDelay = [uint32] ]
    [ SQLCheckDelay = [uint32] ]
    [ InfrastructureServiceSQLConnectionTimeout = [uint32] ]
    [ EnableScheduledMaintenance = [string] { Enable | Disable } ]
    [ StatisticsRetentionPeriod = [uint32] ]
    [ SystemMonitoringRetentionPeriod = [uint32] ]
    [ AgentRegistrationsRetentionPeriod = [uint32] ]
    [ DatabaseMaintenanceExecutionTime = [string] ]
    [ GlobalLicenseServerOverride = [string] { Enable | Disable } ]
    [ LicenseServerName = [string] ]
    [ LicenseServerPort = [uint32] ]
}
```


#### Parameters

* **`[String]` DatabaseName** _(Key)_: Citrix WEM database name.
* **`[String]` DatabaseServer** _(Required)_: MS SQL Server hostname hosting the WEM database.
* **`[String]` SetSqlUserSpecificPassword** _(Required ValueMap{"Enable", "Disable"})_: Use vuemUser SQL user account password.
* **`[String]` SqlUserSpecificPassword** _(Optional)_: vuemUser SQL user account password
* **`[String]` EnableInfrastructureServiceAccountCredential** _(Optional ValueMap{"Enable", "Disable"})_: Description("Use Windows authentication for infrastructure service database connection.
* **`[MSFT_Credential]` InfrastructureServiceAccountCredential** _(Optional)_: PSCredential for running the infrastructure service.
* **`[String]` UseCacheEvenIfOnline** _(Optional ValueMap{"Enable", "Disable"})_: Enable infrastructure service to always reading site settings from its cache. Default value : Disable
* **`[String]` DebugMode** _(Optional ValueMap{"Enable", "Disable"})_: Enable Citrix WEM debug mode. Default value : Disable
* **`[String]` SendGoogleAnalytics** _(Optional ValueMap{"Enable", "Disable"})_: Enable collection of statistics. Default value : Disable
* **`[Uint32]` AdminServicePort** _(Optional)_: Administration port for administration console to connect to the infrastructure service.
* **`[Uint32]` AgentServicePort** _(Optional)_: Agent service port for agent to connect to the infrastructure server.
* **`[Uint32]` AgentSyncPort** _(Optional)_: Cache synchronization port for agent cache synchronization process to connect to the infrastructure service.
* **`[Uint32]` MonitoringPort** _(Optional)_: Citrix WEM monitoring port.
* **`[Uint32]` CacheRefreshDelay** _(Optional)_: Time (in minutes) before the infrastructure service refreshes its cache.
* **`[Uint32]` SQLCheckDelay** _(Optional)_: Time (in seconds) between each infrastructure service attempt to poll the SQL server.
* **`[Uint32]` InfrastructureServiceSQLConnectionTimeout** _(Optional)_: Time (in seconds) which the infrastructure service waits when trying to establish a connection with the SQL server.
* **`[String]` EnableScheduledMaintenance** _(Optional ValueMap{"Enable", "Disable"})_: Enable deletion of old statistics records from the database at periodic intervals. Default value : Disable.
* **`[Uint32]` StatisticsRetentionPeriod** _(Optional)_: Retention period for user and agent statistics (in days).
* **`[Uint32]` SystemMonitoringRetentionPeriod** _(Optional)_: Retention period for system optimization statistics (in days).
* **`[Uint32]` AgentRegistrationsRetentionPeriod** _(Optional)_: Retention period for agent registration logs (in days).
* **`[Uint32]` DatabaseMaintenanceExecutionTime** _(Optional)_: The time at which the database maintenance action is performed (HH:MM).
* **`[String]` GlobalLicenseServerOverride** _(Optional ValueMap{"Enable", "Disable"})_: Override any Citrix License Server information already in the WEM database. Default value : Disable.
* **`[String]` LicenseServerName** _(Optional)_: Citrix License Server name.
* **`[Uint32]` LicenseServerPort** _(Optional)_: Citrix License Server port.
