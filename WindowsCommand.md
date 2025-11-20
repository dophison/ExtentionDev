


Xuất feature/role của windows server

```
Get-WindowsFeature | Where-Object { $_.Installed -eq $True } | Sort-Object Name | Format-Table Name, DisplayName, Installed -AutoSize
```


Xuất feature/role của windows 10/11
```
Get-WindowsOptionalFeature -Online | Where-Object { $_.State -eq 'Enabled' } | Select-Object FeatureName, State
```



```
Get-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services'
```

```
Get-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services' -Name fSingleSessionPerUser -ErrorAction SilentlyContinue
```

```
# 1. Đặt RDP Session Host chỉ sử dụng TCP
$PathServer = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services'
$NameServer = 'fSingleSessionPerUser'

# Đảm bảo khóa tồn tại
If (-not (Test-Path $PathServer)) {
    New-Item -Path $PathServer -Force | Out-Null
}

# Đặt giá trị 2 (TCP Only)
Write-Host "Cấu hình RDP Server sử dụng TCP Only..."
Set-ItemProperty -Path $PathServer -Name $NameServer -Value 2 -Type DWORD -Force
```

```
# 2. & 3. Tắt UDP trên RDP Client
$PathClient = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\Client'
$NameClient = 'fClientDisableUDP'

# Đảm bảo khóa tồn tại (bao gồm cả thư mục Client)
If (-not (Test-Path $PathClient)) {
    New-Item -Path $PathClient -Force | Out-Null
}

# Đặt giá trị 1 (Enable) để tắt UDP
Write-Host "Cấu hình RDP Client tắt UDP (Disable UDP)..."
Set-ItemProperty -Path $PathClient -Name $NameClient -Value 1 -Type DWORD -Force
```

Set password simple

```
(gc C:\secpol.cfg).replace("PasswordComplexity = 1", "PasswordComplexity = 0") | Out-File C:\secpol.cfg
```


Set timezone

```
tzutil /s  "SE Asia Standard Time"
```





Dọn dẹp image update


```
Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase
```


Cloudbase-init

Cài đặt 

Download link: 
```
https://cloudbase.it/downloads/CloudbaseInitSetup_Stable_x64.msi
```

```
$Installer = $env:TEMP + "\CloudbaseInitSetup.msi";
Invoke-WebRequest -UseBasicParsing https://cloudbase.it/downloads/CloudbaseInitSetup_Stable_x64.msi -OutFile $Installer;

Start-Process msiexec -ArgumentList "/i $Installer /qn /l*v log.txt /passive" -Wait

Remove-Item $Installer;
```


cloudbase-init.cfg

```
[DEFAULT]
username=Administrator
groups=Administrators
inject_user_password=true
first_logon_behaviour=no
raw_hhd=true
cdrom=true
vfat=true
bsdtar_path=C:\Program Files\Cloudbase Solutions\Cloudbase-Init\bin\bsdtar.exe
mtools_path=C:\Program Files\Cloudbase Solutions\Cloudbase-Init\bin\
locations=cdrom
verbose=true
debug=true
logdir=C:\Program Files\Cloudbase Solutions\Cloudbase-Init\log\
logfile=cloudbase-init.log
default_log_levels=comtypes=INFO,suds=INFO,iso8601=WARN,requests=WARN
logging_serial_port_settings=COM1,115200,N,8
mtu_use_dhcp_config=false
ntp_use_dhcp_config=false
local_scripts_path=C:\Program Files\Cloudbase Solutions\Cloudbase-Init\LocalScripts\
metadata_services=cloudbaseinit.metadata.services.configdrive.ConfigDriveService
plugins=cloudbaseinit.plugins.common.networkconfig.NetworkConfigPlugin,cloudbaseinit.plugins.common.mtu.MTUPlugin,cloudbaseinit.plugins.common.sethostname.SetHostNamePlugin,cloudbaseinit.plugins.windows.extendvolumes.ExtendVolumesPlugin,cloudbaseinit.plugins.common.sshpublickeys.SetUserSSHPublicKeysPlugin,cloudbaseinit.plugins.common.setuserpassword.SetUserPasswordPlugin,cloudbaseinit.plugins.common.userdata.UserDataPlugin
check_latest_version=true
```


cloudbase-init-unattend.cfg
```
[DEFAULT]
username=Administrator
groups=Administrators
inject_user_password=true
first_logon_behaviour=no
raw_hhd=true
cdrom=true
vfat=true
bsdtar_path=C:\Program Files\Cloudbase Solutions\Cloudbase-Init\bin\bsdtar.exe
mtools_path=C:\Program Files\Cloudbase Solutions\Cloudbase-Init\bin\
locations=cdrom
verbose=true
debug=true
logdir=C:\Program Files\Cloudbase Solutions\Cloudbase-Init\log\
logfile=cloudbase-init-unattend.log
default_log_levels=comtypes=INFO,suds=INFO,iso8601=WARN,requests=WARN
logging_serial_port_settings=COM1,115200,N,8
mtu_use_dhcp_config=false
ntp_use_dhcp_config=false
local_scripts_path=C:\Program Files\Cloudbase Solutions\Cloudbase-Init\LocalScripts\
check_latest_version=false
metadata_services=cloudbaseinit.metadata.services.configdrive.ConfigDriveService
plugins=cloudbaseinit.plugins.common.networkconfig.NetworkConfigPlugin,cloudbaseinit.plugins.common.mtu.MTUPlugin,cloudbaseinit.plugins.common.sethostname.SetHostNamePlugin,cloudbaseinit.plugins.windows.extendvolumes.ExtendVolumesPlugin,cloudbaseinit.plugins.common.sshpublickeys.SetUserSSHPublicKeysPlugin,cloudbaseinit.plugins.common.setuserpassword.SetUserPasswordPlugin,cloudbaseinit.plugins.common.userdata.UserDataPlugin
allow_reboot=true
stop_service_on_exit=false
```


Unattend.xml (Chỉ sửa lại file này nếu là Windows 7,8,10, Windows Server không cần thao tác)
```
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
  <settings pass="generalize">
    <component name="Microsoft-Windows-PnpSysprep" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      <PersistAllDeviceInstalls>true</PersistAllDeviceInstalls>
    </component>
  </settings>
  <settings pass="oobeSystem">
    <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State">
      <OOBE>
        <HideEULAPage>true</HideEULAPage>
        <NetworkLocation>Work</NetworkLocation>
        <ProtectYourPC>3</ProtectYourPC>
        <SkipMachineOOBE>true</SkipMachineOOBE>
        <SkipUserOOBE>true</SkipUserOOBE>
      </OOBE>
    </component>
  </settings>
  <settings pass="specialize">
    <component name="Microsoft-Windows-Deployment" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      <RunSynchronous>
        <RunSynchronousCommand wcm:action="add">
          <Path>net user administrator /active:yes</Path>
          <Order>1</Order>
          <Description>Enable Administrator Account</Description>
        </RunSynchronousCommand>
        <RunSynchronousCommand wcm:action="add">
          <Order>2</Order>
          <Path>cmd.exe /c ""C:\Program Files\Cloudbase Solutions\Cloudbase-Init\Python\Scripts\cloudbase-init.exe" --config-file "C:\Program Files\Cloudbase Solutions\Cloudbase-Init\conf\cloudbase-init-unattend.conf" &amp;&amp; exit 1 || exit 2"</Path>
          <Description>Run Cloudbase-Init to set the hostname</Description>
          <WillReboot>OnRequest</WillReboot>
        </RunSynchronousCommand>
      </RunSynchronous>
    </component>
  </settings>
</unattend>
```

- Disable windows Update

 Dọn Windows update cache

```
Remove-Item 'C:\Windows\SoftwareDistribution\Download' -Recurse -Force
New-Item -Path "C:\Windows\SoftwareDistribution\" -Name "Download" -ItemType "directory"
```

Tạo file .bat để thực thi

```
@echo off
cls

echo.
echo =================================================================
echo        BAT DAU CHAN CAP NHAT WINDOWS VA DELIVERY OPTIMIZATION
echo =================================================================

:: 1. CHAN FIREWALL BANG CAC RULE CU THE
echo.
echo === 1. Tao cac quy tac Firewall de chan ket noi ra ngoai ===

echo Tao quy tac chan TCP Port 80, 443 cho svchost.exe...
netsh advfirewall firewall add rule name="Block WU TCP 80_443" dir=out program="C:\Windows\System32\svchost.exe" remoteport=80,443 protocol=TCP action=block

echo Tao quy tac chan UDP Port 443 (QUIC) cho svchost.exe...
netsh advfirewall firewall add rule name="Block WU UDP 443" dir=out program="C:\Windows\System32\svchost.exe" remoteport=443 protocol=UDP action=block

echo Tao quy tac chan TCP Port 7680 (Delivery Optimization) cho svchost.exe...
netsh advfirewall firewall add rule name="Block Delivery Optimization TCP 7680" dir=out program="C:\Windows\System32\svchost.exe" remoteport=7680 protocol=TCP action=block

echo Da tao cac quy tac chan ket noi thanh cong.

:: 2. VO HIEU HOA CUNG CAC DICH VU CAP NHAT
echo.
echo === 2. Vo hieu hoa cung dich vu Windows Update va Delivery Optimization ===

echo Dang dung dich vu wuauserv...
sc stop wuauserv >nul 2>&1

echo Vo hieu hoa kiem tra update tu dong bang Registry (AUOptions=0)...
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /v AUOptions /t REG_DWORD /d 0 /f

echo Dang dung dich vu DoSvc...
sc stop DoSvc >nul 2>&1
echo Vo hieu hoa cung DoSvc bang cach dat Start=4 (Disabled) trong Registry...
REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\DoSvc" /v Start /t REG_DWORD /d 4 /f

echo Dang dung dich vu UsoSvc...
sc stop UsoSvc >nul 2>&1
echo Vo hieu hoa cung UsoSvc bang cach dat Start=4 (Disabled) trong Registry...
REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\UsoSvc" /v Start /t REG_DWORD /d 4 /f

echo Cac dich vu cap nhat da bi vo hieu hoa.

:: 3. CHAN BANG TEP HOSTS
echo.
echo === 3. Chan cac ten mien cap nhat bang cach them vao Hosts File ===

set HOSTSFILE=%SystemRoot%\System32\drivers\etc\hosts
echo Xoa thuoc tinh Read-Only (attrib -r) cua Hosts File...
attrib -r "%HOSTSFILE%"

echo Dang them cac ten mien Microsoft Update vao Hosts File...
powershell -Command ^
  "Add-Content -Path '%HOSTSFILE%' -Value '127.0.0.1 windowsupdate.microsoft.com';" ^
  "Add-Content -Path '%HOSTSFILE%' -Value '127.0.0.1 download.windowsupdate.com';" ^
  "Add-Content -Path '%HOSTSFILE%' -Value '127.0.0.1 *.windowsupdate.microsoft.com';" ^
  "Add-Content -Path '%HOSTSFILE%' -Value '127.0.0.1 *.update.microsoft.com';" ^
  "Add-Content -Path '%HOSTSFILE%' -Value '127.0.0.1 *.windowsupdate.com';" ^
  "Add-Content -Path '%HOSTSFILE%' -Value '127.0.0.1 *.download.windowsupdate.com';" ^
  "Add-Content -Path '%HOSTSFILE%' -Value '127.0.0.1 download.microsoft.com';" ^
  "Add-Content -Path '%HOSTSFILE%' -Value '127.0.0.1 wustat.windows.com';" ^
  "Add-Content -Path '%HOSTSFILE%' -Value '127.0.0.1 ntservicepack.microsoft.com';" ^
  "Add-Content -Path '%HOSTSFILE%' -Value '127.0.0.1 go.microsoft.com';" ^
  "Add-Content -Path '%HOSTSFILE%' -Value '127.0.0.1 dl.delivery.mp.microsoft.com';" ^
  "Add-Content -Path '%HOSTSFILE%' -Value '127.0.0.1 *.delivery.mp.microsoft.com';"

echo Da them cac ten mien vao Hosts File.

echo.
echo =================================================================
echo       QUA TRINH CHAN CAP NHAT HOAN TAT. HAY KHOI DONG LAI MAY
echo =================================================================
pause
 ```

Tắt NLA
```
$rdp = Get-WmiObject -class "Win32_TSGeneralSetting" -Namespace root\cimv2\terminalservices -Filter "TerminalName='RDP-tcp'"
$rdp.SetUserAuthenticationRequired(0)
```

Định nghĩa lại pagefile

```
$sys = Get-WmiObject Win32_Computersystem -EnableAllPrivileges
$sys.AutomaticManagedPagefile = $false
$sys.Put()
$Pagefile = Get-WmiObject -Class Win32_PagefileSetting | Where-Object {$_.Name -eq "C:\pagefile.sys"}
$Pagefile.InitialSize = 512
$Pagefile.MaximumSize = 1024
$Pagefile.Put()
```


- Xoá lịch sử PowerShell (Clear-History)
```
Set-Content "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt" ""
```

Hoặc
```
doskey /listsize=0
```


- Xóa event log 

```
Clear-EventLog -LogName Application, System -Confirm
wevtutil cl "Microsoft-Windows-TerminalServices-LocalSessionManager/Operational"
```


Chạy sysprep.exe
```
c:\windows\system32\sysprep\sysprep.exe /shutdown /generalize /oobe /unattend:"C:\Program Files\Cloudbase Solutions\Cloudbase-Init\conf\Unattend.xml"
```



winget install --id RARLab.WinRAR
winget install --id CoreyButler.NVMforWindows
winget install --id XPDCFJDKLZJLP8

winget install --id Microsoft.VisualStudioCode


# ISO


Lấy tên chuẩn

```
Get-WindowsImage -ImagePath E:\temp\WindowsISO\SOURCES\install.wim
```

Capture lại thành iso
```
dism /Capture-Image /ImageFile:E:\window2012\window2012.wim /CaptureDir:J:\ /Name:"Windows Server 2012 Standard" /Description:"Windows Server 2012 Standard" /Compress:max
```

Win2012 bỏ option udfver102
```
.\oscdimg.exe -bootdata:2#p0,e,bC:\win2025\boot\etfsboot.com#pEF,e,bC:\win2025\efi\microsoft\boot\efisys.bin -m -o -u2 C:\win2025 C:\windows-server-2025-Datacenter-x64-251106.iso
```









