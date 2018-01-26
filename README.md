# CitrixWemDsc

The **CitrixWemDsc** module contains DSC resources for deployment and configuration of Citrix Workspace Environment Management (ex Norskcale VUEM).

## Branches

### master

This is the branch containing the latest release - no contributions should be made directly to this branch.

### dev

This is the development branch to which contributions should be proposed by contributors as pull requests.
This development branch will periodically be merged to the master branch,
and be released to [PowerShell Gallery](https://www.powershellgallery.com/).

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

#### Parameters

* **`[String]` DatabaseName** _(Key)_: Citrix WEM database name.
* **`[String]` DatabaseServer** _(Required)_: MS SQL Server hostname hosting the WEM database.
* **`[String]` DatabaseFilesFolder** _(Required)_: Path to the data and log files location on the SQL Server. You must provide a valid filepath, otherwise the cmdlet will fail.
* **`[String]` VuemUserSqlPassword** _(Required)_: Specific password for the Citrix WEM vuemUser SQL user account.
* **`[String]` DefaultAdministratorsGroup** _(Required)_: Citrix WEM default administrators group.
