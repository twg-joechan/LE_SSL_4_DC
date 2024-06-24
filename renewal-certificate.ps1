#requires -Module Posh-ACME
#requires -RunAsAdministrator

#region Information Gathering
    # Set-PAServer LE_STAGE
    Set-PAServer LE_PROD

    $PFXPass = 'Ag^5JKLpqRT#672ak8HGxZmB'
    
    $Path = Get-PACertificate | select -ExpandProperty CertFile
    $Path = $Path.Substring(0, $Path.LastIndexOf('\'))
#region

#region Renewal Lets Encrypt SSL Cert
    $NewCertificate = Submit-Renewal -Force -Verbose
    $NewCertificate
#region

#region Copy to fileserver
    #ProdPath = "$env:LOCALAPPDATA\Posh-ACME\acme-v02.api.letsencrypt.org"
    $DownloadPath = "C:\Users\Administrator\LE\_LetsEncryptCerts$((Get-Date).ToString('yyyyMMdd'))"
    $LatestPath = "C:\Users\Administrator\LE\Latest"
    md -Force $DownloadPath
    Copy-Item "$Path\cert.cer" $DownloadPath -Force
    Copy-Item "$Path\cert.key" $DownloadPath -Force
    Copy-Item "$Path\cert.pfx" $DownloadPath -Force
    # 
    md -Force $LatestPath
    Copy-Item "$Path\cert.cer" $LatestPath -Force
    Copy-Item "$Path\cert.key" $LatestPath -Force
    Copy-Item "$Path\cert.pfx" $LatestPath -Force

#endregion

#region Import PFXPassword, ComputerList and Thumbprint
    $PFXPassword = $PFXPass | ConvertTo-SecureString -AsPlainText -Force
 
    #Enter the array of computers needing the cert
    $ComputerList = "TWG-HQ-DC2"  #, "PAC-WIN1002"
    $Thumbprint = $NewCertificate.Thumbprint
#endregion

#region Deploy to remote machines
    foreach ($Computer in $ComputerList) {
        Copy-Item "$DownloadPath\Cert.pfx" "\\$Computer\c$"
    }
 
    Invoke-Command -ComputerName $ComputerList -ScriptBlock {
        Import-PfxCertificate -FilePath "C:\cert.pfx" -CertStoreLocation Cert:\LocalMachine\My\ -Exportable:$false -Password $Using:PFXPassword
        # $Cert = Get-ChildItem Cert:\LocalMachine\My$($Using:Thumbprint)
    }
 
    foreach ($Computer in $ComputerList) {
        Remove-Item "\\$Computer\c$\cert.pfx"
    }
#endregion
