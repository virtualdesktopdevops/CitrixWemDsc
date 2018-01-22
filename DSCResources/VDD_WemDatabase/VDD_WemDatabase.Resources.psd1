<# VDD_WemDatabase\VDD_WemDatabase.Resources.psd1 #>
ConvertFrom-StringData @'
    WEMSDKNotFoundError    = Citrix WEM Powershell SDK/Snap-in was not found.
    CreatingWEMDatabase            = Creating Citrix WEM Database '{0}' on host '{1}'.
    DatabaseDoesNotExist          = Citrix WEM Database '{0}' does not exist on host '{1}'.
    DatabaseDoesExist             = Citrix WEM Database '{0}' does exist on host '{1}'.
    ResourceInDesiredState        = Citrix WEM Database '{0}' is in the desired state.
    ResourceNotInDesiredState     = Citrix WEM Database '{0}' is NOT in the desired state.
    InvokingScriptBlockWithParams = Invoking script block with parameters: '{0}'.
    DefaultAdministratorDoesNotExist = Citrix WEM Default Administrator {0} does not exist in Database '{1}' on host '{2}'.
'@
