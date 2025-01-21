$adpr_address = "10.0.17.4"
Install-WindowsFeature -Name DNS -IncludeManagementTools
Add-DnsServerConditionalForwarderZone -Name "blob.core.windows.net" -MasterServers $adpr_address