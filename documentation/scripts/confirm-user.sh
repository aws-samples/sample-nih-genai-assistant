#!/bin/bash

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "Error: AWS CLI is not installed. Please install it first."
    exit 1
fi

# Check if required parameters are provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <user-pool-id> <username> <region>"
    echo "Example: $0 us-east-1_xxxxxx user@example.com us-east-1"
    exit 1
fi

USER_POOL_ID=$1
USERNAME=$2
REGION=$3

# Check if AWS credentials are configured
if ! aws sts get-caller-identity &> /dev/null; then
    echo "Error: AWS credentials not configured or insufficient permissions."
    echo "Please configure your AWS credentials with appropriate Cognito admin permissions."
    exit 1
fi

# Confirm the user
echo "Attempting to confirm user '$USERNAME' in user pool '$USER_POOL_ID'..."
if aws cognito-idp admin-confirm-sign-up \
    --user-pool-id "$USER_POOL_ID" \
    --username "$USERNAME" \
    --region "$REGION"; then
    echo "Success: User '$USERNAME' has been confirmed!"
else
    echo "Error: Failed to confirm user. Please check the user pool ID and username."
    exit 1
fi
