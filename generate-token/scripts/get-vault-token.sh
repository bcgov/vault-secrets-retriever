#!/usr/bin/env sh

BROKER_JWT=${1}
ROLE_ID=${2}
PROVISION_NAME=${3}
EVENT_URL=${4}
USER=${5}

filename=./output/token.txt

if [ -f $filename ]; then
   rm $filename
   echo "$filename is removed"
fi

echo "===> Intention open"
# Open intention
RESPONSE=$(curl -s -X POST $BROKER_URL/v1/intention/open \
    -H 'Content-Type: application/json' \
    -H "Authorization: Bearer $BROKER_JWT" \
    -d @<(cat ./config/intention.json | \
        jq ".event.url=\"$EVENT_URL\" | \
            .user.id=\"$USER\" \
        " \
    ))
echo "$BROKER_URL/v1/intention/open:"
#echo $RESPONSE | jq '.'
if [ "$(echo $RESPONSE | jq '.error')" != "null" ]; then
    echo "Exit: Error detected"
    exit 0
fi

# Save intention token for later
INTENTION_TOKEN=$(echo $RESPONSE | jq -r '.token')
# echo "Hashed transaction.id: $(echo -n $INTENTION_TOKEN | shasum -a 256)"

echo "===> DB provision"

# Get token for provisioning a db access
DB_INTENTION_TOKEN=$(echo $RESPONSE | jq -r ".actions.$PROVISION_NAME.token")
#echo "DB_INTENTION_TOKEN: $DB_INTENTION_TOKEN"

# Start db action
curl -s -X POST $BROKER_URL/v1/intention/action/start -H 'X-Broker-Token: '"$DB_INTENTION_TOKEN"''

# Get wrapped id for db access
VAULT_TOKEN_WRAP=$(curl -s -X POST $BROKER_URL/v1/provision/approle/secret-id -H 'X-Broker-Token: '"$DB_INTENTION_TOKEN"'' -H 'X-Vault-Role-Id: '"$ROLE_ID"'')
echo "$BROKER_URL/v1/provision/approle/secret-id:"
#echo $VAULT_TOKEN_WRAP | jq '.'
WRAPPED_VAULT_TOKEN=$(echo $VAULT_TOKEN_WRAP | jq -r '.wrap_info.token')
#echo $WRAPPED_VAULT_TOKEN

UNWRAPPED_VAULT_TOKEN=$(curl -s -X POST $VAULT_ADDR/v1/sys/wrapping/unwrap -H 'X-Vault-Token: '"$WRAPPED_VAULT_TOKEN"'')
#echo $UNWRAPPED_VAULT_TOKEN | jq '.'
SECRET_ID=$(echo -n $UNWRAPPED_VAULT_TOKEN | jq -r '.data.secret_id')
#echo $SECRET_ID

WRAPPED_MY_VAULT_TOKEN=$(curl -s -X POST $VAULT_ADDR/v1/auth/vs_apps_approle/login -H "X-Vault-Wrap-TTL: 5m" \
-H 'Content-Type: application/json' \
-d @<(cat <<EOF
{
  "role_id": "$ROLE_ID",
  "secret_id": "$SECRET_ID"
  }
EOF
))

WRAPPED_TOKEN=$(echo -n $WRAPPED_MY_VAULT_TOKEN |  jq -r '.wrap_info.token' )


#echo $WRAPPED_TOKEN
echo "write wrapped token to the shared space"
echo $WRAPPED_TOKEN > $filename

echo "===> Intention close"

# End db action
curl -s -X POST $BROKER_URL/v1/intention/action/end -H 'X-Broker-Token: '"$DB_INTENTION_TOKEN"''

# Use saved intention token to close intention
curl -s -X POST $BROKER_URL/v1/intention/close -H 'X-Broker-Token: '"$INTENTION_TOKEN"''
