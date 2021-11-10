echo "***************************************************************************************************************************************************"
echo " 🚀  Clean for GIT Push" 
echo "***************************************************************************************************************************************************"


echo "--------------------------------------------------------------------------------------------------------------------------------"
echo "    🚀  Restoring vanilla config" 
echo "--------------------------------------------------------------------------------------------------------------------------------"
mkdir -p ./DO_NOT_DELIVER/OLD_CONFIGS/
cp ./00_config_cp4waiops.yaml "./DO_NOT_DELIVER/OLD_CONFIGS/00_config_cp4waiops.yaml-$(date +"%y-%m-%d-%r").sh"
cp ./tools/00_delivery/00_config_cp4waiops_template.yaml ./00_config_cp4waiops.yaml

cp ./tools/01_demo/00_config-secrets.sh "./DO_NOT_DELIVER/OLD_CONFIGS/00_config-secrets.sh-$(date +"%y-%m-%d-%r").sh"
cp ./tools/00_delivery/00_config-secrets_template.sh ./tools/01_demo/00_config-secrets.sh



echo "--------------------------------------------------------------------------------------------------------------------------------"
echo "    🚀  Find File Copies" 
echo "--------------------------------------------------------------------------------------------------------------------------------"
find . -name '*copy*' -type f | grep -v DO_NOT_DELIVER


echo "--------------------------------------------------------------------------------------------------------------------------------"
echo "    🚀  Deleting large and sensitive files" 
echo "--------------------------------------------------------------------------------------------------------------------------------"
echo "      🧻  Deleting DS_Store" 
find . -name '.DS_Store' -type f -delete
echo "      🧻  Deleting Certificate Files" 
find . -name 'cert.*' -type f -delete
echo "      🧻  Deleting Certificate Authority Files" 
find . -name 'ca.*' -type f -delete
echo "      🧻  Deleting TLS Secrets" 
find . -name 'openshift-tls-secret*' -type f -delete
echo "      🧻  Deleting JSON Log Files Kafka" 
find . -name '*.json' -type f -size +1000000k -delete
echo "      🧻  Deleting JSON Log Files Elastic" 
find . -name '*-logtrain.json' -type f -size +10000k -delete
echo "      🧻  Deleting Conflict Files" 
find . -name '*2021_Conflict*' -type f -delete



echo "--------------------------------------------------------------------------------------------------------------------------------"
echo "    🚀  Remove Temp Files" 
echo "--------------------------------------------------------------------------------------------------------------------------------"
rm -f ./reset/tmp_connection.json
rm -f ./reset/test.json
rm -f ./demo/external-tls-secret.yaml
rm -f ./demo/iaf-system-backup.yaml
rm -f ./external-tls-secret.yaml
rm -f ./iaf-system-backup.yaml
rm -f ./events-robotshop-kafka.json


echo "--------------------------------------------------------------------------------------------------------------------------------"
echo "    🚀  Check for Tokens and Keys" 
echo "--------------------------------------------------------------------------------------------------------------------------------"
echo "      🔎  Check for OCP URL" 
grep -rnw '.' -e 'OCP_URL:' | grep -v 'DO_NOT_DELIVER'| grep -v 'delivery'
echo "      🔎  Check for OCP Token" 
grep -rnw '.' -e 'OCP_TOKEN:' | grep -v 'DO_NOT_DELIVER' | grep -v 'delivery'
echo "      🔎  Check for Webhooks" 
grep -rnw '.' -e 'NETCOOL_WEBHOOK_GENERIC=https:' | grep -v 'DO_NOT_DELIVER'
echo "      🔎  Check for Slack User Token" 
grep -rnw '.' -e 'xoxp' | grep -v 'DO_NOT_DELIVER' | grep -v 'xoxp-*'
echo "      🔎  Check for Slack Bot Token" 
grep -rnw '.' -e 'xoxb' | grep -v 'DO_NOT_DELIVER' | grep -v 'xoxb-*'

