echo "***************************************************************************************************************************************************"
echo " 🚀  Clean for GIT Push"
echo "***************************************************************************************************************************************************"





echo "--------------------------------------------------------------------------------------------------------------------------------"
echo "    🚀  Find File Copies"
echo "--------------------------------------------------------------------------------------------------------------------------------"
find . -name '*copy*' -type f | grep -v DO_NOT_DELIVER
find . -name '*test*' -type f | grep -v DO_NOT_DELIVER


echo "--------------------------------------------------------------------------------------------------------------------------------"
echo "    🚀  Deleting large and sensitive files"
echo "--------------------------------------------------------------------------------------------------------------------------------"
echo "      ❎  Deleting DS_Store"
find . -name '.DS_Store' -type f -delete
echo "      ❎  Deleting Certificate Files"
find . -name 'cert.*' -type f -delete
echo "      ❎  Deleting Certificate Authority Files"
find . -name 'ca.*' -type f -delete
echo "      ❎  Deleting TLS Secrets"
find . -name 'openshift-tls-secret*' -type f -delete
echo "      ❎  Deleting JSON Log Files Kafka"
find . -name '*.json' -type f -size +1000000k -delete
echo "      ❎  Deleting JSON Log Files Elastic"
find . -name '*-logtrain.json' -type f -size +10000k -delete
echo "      ❎  Deleting Conflict Files"
find . -name '*2021_Conflict*' -type f -delete
echo "      ❎  Deleting node_modules directory"
find . -name 'node_modules' -type d -exec rm -rf {} \;


echo "--------------------------------------------------------------------------------------------------------------------------------"
echo "    🚀  Remove Temp Files"
echo "--------------------------------------------------------------------------------------------------------------------------------"
rm -f ./reset/tmp_connection.json
rm -f ./reset/test.json
rm -f ./demo/external-tls-secret.yaml
rm -f ./demo/iaf-system-backup.yaml
rm -f ./external-tls-secret.yaml
rm -f ./iaf-system-backup.yaml



echo "--------------------------------------------------------------------------------------------------------------------------------"
echo "    🚀  Check for Tokens and Keys"
echo "--------------------------------------------------------------------------------------------------------------------------------"
echo "      🔎  Check for OCP URL"
grep -rnw '.' -e 'OCP_URL:' | grep -v 'DO_NOT_DELIVER'| grep -v 'delivery'|grep -v "README"|grep -v "not_configured"
echo "      🔎  Check for OCP Token"
grep -rnw '.' -e 'OCP_TOKEN:' | grep -v 'DO_NOT_DELIVER' | grep -v 'delivery'|grep -v "README"|grep -v "not_configured"
echo "      🔎  Check for Webhooks"
grep -rnw '.' -e 'NETCOOL_WEBHOOK_GENERIC=https:' | grep -v 'DO_NOT_DELIVER'
echo "      🔎  Check for Slack User Token"
grep -rnw '.' -e 'xoxp' | grep -v 'DO_NOT_DELIVER' |grep -v "must start with xoxp"| grep 'xoxp-*'
echo "      🔎  Check for Slack Bot Token"
grep -rnw '.' -e 'xoxb' | grep -v 'DO_NOT_DELIVER' |grep -v "must start with xoxb"| grep 'xoxb-*'

