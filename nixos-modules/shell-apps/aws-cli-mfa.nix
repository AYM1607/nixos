{ pkgs }:
pkgs.writeShellApplication {
  name = "aws-cli-mfa";
  runtimeInputs = with pkgs; [ 
    awscli2 
    yubikey-manager 
    yq-go 
    jq 
  ];
  text = ''
    set -euo pipefail

    CONFIG_DIR="$HOME/.config/aws-cli-mfa"
    CONFIG_FILE="$CONFIG_DIR/config.yaml"

    usage() {
        echo "Usage: $0 [--unset] [--help]"
        echo ""
        echo "Options:"
        echo "  --unset    Unset AWS environment variables"
        echo "  --help     Show this help message"
        echo ""
        echo "This tool assumes temporary credentials with MFA using a YubiKey."
        echo "Configuration file: $CONFIG_FILE"
    }

    unset_vars() {
        if [[ -t 1 ]]; then
            # Running directly - can't unset in parent shell, show instructions
            echo "To unset AWS environment variables, run:"
            echo "  eval \$(aws-cli-mfa --unset)"
        else
            # Running from eval - output unset commands
            echo "AWS environment variables unset." >&2
            cat << EOF
unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_SECURITY_TOKEN
EOF
        fi
    }

    # Parse command line arguments
    if [[ $# -gt 0 ]]; then
        case "$1" in
            --unset)
                unset_vars
                exit 0
                ;;
            --help)
                usage
                exit 1
                ;;
            *)
                echo "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    fi

    # Check if config file exists
    if [[ ! -f "$CONFIG_FILE" ]]; then
        echo "Error: Configuration file not found: $CONFIG_FILE"
        echo ""
        echo "Please create a configuration file with the following format:"
        echo ""
        echo "mfa_serial: arn:aws:iam::123456789012:mfa/username"
        echo "role_arn: arn:aws:iam::123456789012:role/RoleName"
        echo "session_duration: 43200  # optional, defaults to 43200 seconds (12 hours)"
        echo ""
        exit 1
    fi

    # Read configuration
    MFA_SERIAL=$(yq eval '.mfa_serial' "$CONFIG_FILE")
    ROLE_ARN=$(yq eval '.role_arn' "$CONFIG_FILE")
    SESSION_DURATION=$(yq eval '.session_duration // 43200' "$CONFIG_FILE")

    if [[ "$MFA_SERIAL" == "null" || "$ROLE_ARN" == "null" ]]; then
        echo "Error: mfa_serial and role_arn must be specified in $CONFIG_FILE"
        exit 1
    fi

    echo "Getting TOTP code from YubiKey for device: $MFA_SERIAL" >&2

    # Get TOTP code from YubiKey
    if ! TOTP_CODE=$(ykman oath accounts code "$MFA_SERIAL" -s); then
        echo "Error: Failed to get TOTP code from YubiKey for device '$MFA_SERIAL'"
        echo "Available OATH accounts:"
        ykman oath accounts list || echo "No OATH accounts found on YubiKey"
        exit 1
    fi

    echo "Assuming role with MFA..." >&2

    # Call AWS STS assume-role
    if ! STS_RESPONSE=$(aws sts assume-role \
        --role-arn "$ROLE_ARN" \
        --role-session-name "aws-cli-mfa-$(date +%s)" \
        --serial-number "$MFA_SERIAL" \
        --token-code "$TOTP_CODE" \
        --duration-seconds "$SESSION_DURATION" \
        --output json); then
        echo "Error: Failed to assume role. Check your AWS credentials and configuration."
        exit 1
    fi

    # Extract credentials from response
    AWS_ACCESS_KEY_ID=$(echo "$STS_RESPONSE" | jq -r '.Credentials.AccessKeyId')
    AWS_SECRET_ACCESS_KEY=$(echo "$STS_RESPONSE" | jq -r '.Credentials.SecretAccessKey')
    AWS_SESSION_TOKEN=$(echo "$STS_RESPONSE" | jq -r '.Credentials.SessionToken')
    EXPIRATION=$(echo "$STS_RESPONSE" | jq -r '.Credentials.Expiration')

    if [[ "$AWS_ACCESS_KEY_ID" == "null" || "$AWS_SECRET_ACCESS_KEY" == "null" || "$AWS_SESSION_TOKEN" == "null" ]]; then
        echo "Error: Failed to extract credentials from AWS response"
        exit 1
    fi

    # Check if running from eval (stdout is a pipe) or directly
    if [[ -t 1 ]]; then
        # Running directly - can't export to parent shell, show instructions
        echo "Success! AWS temporary credentials retrieved."
        echo "Credentials expire at: $EXPIRATION"
        echo ""
        echo "To use these credentials in your current shell, run:"
        echo "  eval \$(aws-cli-mfa)"
        echo ""
        echo "To unset the credentials later, run:"
        echo "  eval \$(aws-cli-mfa --unset)"
    else
        # Running from eval - only output export commands
        echo "Success! AWS temporary credentials have been set." >&2
        echo "Credentials expire at: $EXPIRATION" >&2
        echo "" >&2
        echo "To unset the credentials later, run:" >&2
        echo "  eval \$(aws-cli-mfa --unset)" >&2

        # Output export commands for eval
        cat << EOF
export AWS_ACCESS_KEY_ID='$AWS_ACCESS_KEY_ID'
export AWS_SECRET_ACCESS_KEY='$AWS_SECRET_ACCESS_KEY'
export AWS_SESSION_TOKEN='$AWS_SESSION_TOKEN'
export AWS_SECURITY_TOKEN='$AWS_SESSION_TOKEN'
EOF
    fi
  '';
}