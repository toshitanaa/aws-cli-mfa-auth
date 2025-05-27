# This script is used to authenticate to AWS using MFA (Multi-Factor Authentication), excluding U2F devices.

# Function to prompt for input
function Read-Input {
    param (
        [string]$prompt,
        [string]$defaultValue
    )
    $userInput = Read-Host -Prompt "$prompt"
    if ([string]::IsNullOrWhiteSpace($userInput)) {
        return $defaultValue
    }
    return $userInput
}

# Check for AWS CLI
if (!(Get-Command aws -ErrorAction SilentlyContinue)) {
    Write-Host "AWS CLI is required. Aborting."
    exit 1
}

# Prompt for AWS profile name
$aws_profile = Read-Input -prompt "Enter your AWS profile name (Default: default)" -defaultValue "default"

# Fetch MFA devices
Write-Host "Fetching MFA devices..."
$mfa_devices = aws iam list-mfa-devices --profile $aws_profile --output json | ConvertFrom-Json

# Filter out U2F devices
$mfa_devices = $mfa_devices.MFADevices | Where-Object { $_.SerialNumber -match "^arn:aws:iam::\d+:mfa/" }
$mfa_count = $mfa_devices.Count

if ($mfa_count -eq 0) {
    Write-Host "No compatible MFA devices found. Please set up a non-U2F MFA device for your IAM user."
    exit 1
}
elseif ($mfa_count -eq 1) {
    $mfa_arn = $mfa_devices[0].SerialNumber
    Write-Host "Using MFA device: $mfa_arn"
}
else {
    Write-Host "Select an MFA device:"
    for ($i = 0; $i -lt $mfa_count; $i++) {
        Write-Host "$($i + 1)) $($mfa_devices[$i].SerialNumber)"
    }
    $device_number = [int](Read-Input -prompt "Enter the number of your MFA device" -defaultValue "1")
    $mfa_arn = $mfa_devices[$device_number - 1].SerialNumber
    Write-Host "Using MFA device: $mfa_arn"
}

# Input MFA code
$token_code = Read-Input -prompt "Enter your MFA code" -defaultValue ""

# Get temporary credentials
Write-Host "Fetching temporary credentials..."
$creds = aws sts get-session-token --serial-number $mfa_arn --token-code $token_code --profile $aws_profile --output json | ConvertFrom-Json

# Create a new profile name
$new_profile = "$aws_profile-mfa"
$new_profile = Read-Input -prompt "Enter a name for the new profile (Default: $new_profile)" -defaultValue $new_profile

# Set up the new profile
aws configure set aws_access_key_id $creds.Credentials.AccessKeyId --profile $new_profile
aws configure set aws_secret_access_key $creds.Credentials.SecretAccessKey --profile $new_profile
aws configure set aws_session_token $creds.Credentials.SessionToken --profile $new_profile

# Get expiration time
$expiration_local = [DateTime]::Parse($creds.Credentials.Expiration).ToLocalTime().ToString("yyyy-MM-dd HH:mm:ss K")

# Final message
Write-Host ""
Write-Host "Success! Temporary credentials have been set up."
Write-Host "---------------------------------------------"
Write-Host "Profile name: $new_profile"
Write-Host "Expiration  : $expiration_local"
Write-Host ""
Write-Host "To use these credentials:"
Write-Host "* For specific commands: aws s3 ls --profile $new_profile"
Write-Host "* For this session: `$env:AWS_PROFILE = '$new_profile'"
Write-Host ""
Write-Host "Remember to renew your credentials before they expire."