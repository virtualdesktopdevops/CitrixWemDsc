@{
    ModuleVersion        = '0.1.0.0'
    GUID                 = '1be452c5-ceeb-4f0a-8dc6-0feba472f69d'
    Author               = 'Virtual Desktop Devops'
    CompanyName          = 'Virtual Desktop Devops'
    Copyright            = '(c) 2018 Virtual Desktop Devops Limited. All rights reserved.'
    Description          = 'Citrix Workspace Environment Manager community module'
    PowerShellVersion    = '5.0';
    DscResourcesToExport = @(
                                'WemDatabase',
                                'WemBrokerConfig'
                            )
    PrivateData = @{
        PSData = @{
            Tags       = @('VirtualDesktopDevops','Citrix','XenDesktop','XenApp','DSC','WEM','Norskale')
            LicenseUri = 'https://github.com/virtualdesktopdevops/CitrixWemDsc/blob/master/LICENSE'
            ProjectUri = 'http://www.virtualdesktopdevops.com/powershell-dsc/citrixwemdsc.html'
            IconUri    = ''
            ReleaseNotes = '- Beta release of the CitrixWemDsc powershell DSC community module
- Compatible with Citrix Workspace Environment Manager 4.5
- WemDatabase & WemBrokerConfig DSC resources'
        } # End of PSData hashtable
    } # End of PrivateData hashtable
}
