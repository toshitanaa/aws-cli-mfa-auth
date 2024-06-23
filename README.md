# AWS MFA Authentication Script

This repository contains scripts for authenticating to AWS using Multi-Factor Authentication (MFA). It provides both Bash (for Unix-like systems) and PowerShell (for Windows) versions of the script.

## Purpose

These scripts simplify the process of obtaining temporary AWS credentials using MFA, allowing users to easily switch between different AWS profiles that require MFA authentication. They automate the steps described in the AWS official documentation: [How do I authenticate using MFA with the AWS CLI?](https://repost.aws/knowledge-center/authenticate-mfa-cli)

## Features

- Supports multiple AWS profiles
- Automatically detects and filters MFA devices (excluding U2F devices)
- Creates a new AWS profile with temporary credentials
- Provides clear instructions for using the new credentials

## Requirements

- AWS CLI (configured with at least one profile)
- jq (for the Bash version)
- Bash (for Unix-like systems) or PowerShell (for Windows)
- A non-U2F MFA device associated with your IAM user

## Usage

### Bash Version (aws-mfa-auth.sh)

1. Make the script executable:
   ```
   chmod +x aws-mfa-auth.sh
   ```

2. Run the script:
   ```
   ./aws-mfa-auth.sh
   ```

### PowerShell Version (aws-mfa-auth.ps1)

1. Ensure PowerShell execution policy allows running scripts. You might need to run:
   ```
   Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

2. Run the script:
   ```
   .\aws-mfa-auth.ps1
   ```

## How it Works

1. The script prompts you for your AWS profile name.
2. It fetches and displays your available MFA devices (excluding U2F devices).
3. You select an MFA device and enter the MFA code.
4. The script obtains temporary credentials from AWS STS.
5. A new AWS profile is created with the temporary credentials.
6. Instructions for using the new profile are displayed.

## Notes

- This script does not support passkey or U2F-based MFA devices.
- Temporary credentials typically expire after a set period (usually 12 hours). You'll need to re-run the script to obtain new credentials after expiration.
- Always keep your MFA device and AWS credentials secure.

## Troubleshooting

- Ensure your AWS CLI is properly configured with your base credentials.
- Check that you have the necessary permissions to call `iam:ListMFADevices` and `sts:GetSessionToken`.
- If using the Bash version, make sure jq is installed and accessible in your PATH.

## Contributing

Contributions to improve the scripts are welcome. Please submit a pull request or open an issue for any bugs or feature requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

This script automates the process described in the AWS Knowledge Center article [How do I use an MFA token to authenticate access to my AWS resources through the AWS CLI?](https://repost.aws/knowledge-center/authenticate-mfa-cli). It aims to simplify the steps outlined in the official documentation for a more streamlined user experience.