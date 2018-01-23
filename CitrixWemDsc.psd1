@{
    ModuleVersion        = '0.1.0'
    GUID                 = '3bacd95f-494b-4ea2-989b-09cb5e324940'
    Author               = 'Virtual Desktop Devops'
    CompanyName          = 'Virtual Desktop Devops'
    Copyright            = '(c) 2018 Virtual Desktop Devops Limited. All rights reserved.'
    Description          = 'Citrix Workspace Environment Manager module'
    PowerShellVersion    = '5.0';
    DscResourcesToExport = @(
                                'WemDatabase',
                                'WemBrokerConfig'
                            )
    PrivateData = @{
        PSData = @{
            Tags       = @('VirtualDesktopDevops','Citrix','XenDesktop','XenApp','DSC','WEM')
            LicenseUri = ''
            ProjectUri = ''
            IconUri    = ''
        } # End of PSData hashtable
    } # End of PrivateData hashtable
}
