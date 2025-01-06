# Source environment variables
source ../.env
# Cloudflare api key
export TF_VAR_api_key=$CL_TOKEN

# Logout and configure Bitwarden server
bw logout
bw config server $BW_SERVER

# Login and synchronize Bitwarden
export BW_SESSION=$(bw login $BW_LOGIN --method 2 --raw)
bw sync

# Extract and set environment variables for AWS Secrets
eval $(bw get item "Environment Variables" | jq -r '.fields[] | select(.value == null or .value == "") | .name')

# Dynamically pass 'apply' or 'destroy' based on the script argument
if [ "$1" == "apply" ] || [ "$1" == "destroy" ]; then
  tofu $1 --auto-approve
else
  echo "Usage: $0 [apply|destroy]"
  exit 1
fi
