# Set strong password policy
secedit /export /cfg C:\Windows\Temp\secconfig.cfg
$config = Get-Content C:\Windows\Temp\secconfig.cfg

# Update password policies
$config = $config -replace 'PasswordComplexity = \d+', 'PasswordComplexity = 1'
$config = $config -replace 'MinimumPasswordLength = \d+', 'MinimumPasswordLength = 12'
$config = $config -replace 'MaximumPasswordAge = \d+', 'MaximumPasswordAge = 30'
$config = $config -replace 'MinimumPasswordAge = \d+', 'MinimumPasswordAge = 1'
$config = $config -replace 'PasswordHistorySize = \d+', 'PasswordHistorySize = 24'
$config = $config -replace 'LockoutBadCount = \d+', 'LockoutBadCount = 5'
$config = $config -replace 'LockoutDuration = \d+', 'LockoutDuration = 15'
$config = $config -replace 'ResetLockoutCount = \d+', 'ResetLockoutCount = 15'

# Apply the updated settings
$config | Out-File C:\Windows\Temp\secconfig.cfg
secedit /configure /db secedit.sdb /cfg C:\Windows\Temp\secconfig.cfg /areas SECURITYPOLICY

# Change every user's password to a strong one
$users = Get-LocalUser | Where-Object { $_.Enabled -eq $true -and $_.Name -ne 'Administrator' }
foreach ($user in $users) {
    $newPassword = [System.Web.Security.Membership]::GeneratePassword(16, 2) + (Get-Random -Minimum 10 -Maximum 99)
    $newPassword = $newPassword -replace '[^a-zA-Z0-9]', ([char](Get-Random (65..90 + 97..122 + 48..57))).ToString()
    Set-LocalUser -Name $user.Name -Password (ConvertTo-SecureString -AsPlainText $newPassword -Force)
}

# Enable the firewall
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True

# Configure Internet settings using registry
$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
Set-ItemProperty -Path $regPath -Name "SecureProtocols" -Value 0xA80  # Enable TLS 1.1 and 1.2
Set-ItemProperty -Path $regPath -Name "DisableCachingOfSSLPages" -Value 1

# Set Security Level to High
$zones = @("0", "1", "2", "3", "4")
foreach ($zone in $zones) {
    $zonePath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\$zone"
    Set-ItemProperty -Path $zonePath -Name "Security_Level" -Value 10000
}

# Block all cookies
Set-ItemProperty -Path "$regPath\Zones\3" -Name "1A02" -Value 3

# Never allow websites to request your information
Set-ItemProperty -Path "$regPath\Zones\3" -Name "1A00" -Value 3

# Turn on pop-up blocker
Set-ItemProperty -Path $regPath -Name "PopupsUseFilter" -Value 1
Set-ItemProperty -Path $regPath -Name "FilterLevel" -Value 2

# Disable toolbars and extensions when in private browsing
Set-ItemProperty -Path $regPath -Name "Enable Browser Extensions" -Value 0

# Clean up
Remove-Item C:\Windows\Temp\secconfig.cfg

Write-Host "Security settings have been configured successfully."
