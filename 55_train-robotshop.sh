#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#       __________  __ ___       _____    ________            
#      / ____/ __ \/ // / |     / /   |  /  _/ __ \____  _____
#     / /   / /_/ / // /| | /| / / /| |  / // / / / __ \/ ___/
#    / /___/ ____/__  __/ |/ |/ / ___ |_/ // /_/ / /_/ (__  ) 
#    \____/_/      /_/  |__/|__/_/  |_/___/\____/ .___/____/  
#                                              /_/            
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------------------------------------------------------------------"
#  Load Robotshop Data for Training for CP4WAIOPS 3.2
#
#  CloudPak for Watson AIOps
#
#  ©2022 nikh@ch.ibm.com
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
clear

echo "   __________  __ ___       _____    ________            "
echo "  / ____/ __ \/ // / |     / /   |  /  _/ __ \____  _____"
echo " / /   / /_/ / // /| | /| / / /| |  / // / / / __ \/ ___/"
echo "/ /___/ ____/__  __/ |/ |/ / ___ |_/ // /_/ / /_/ (__  ) "
echo "\____/_/      /_/  |__/|__/_/  |_/___/\____/ .___/____/  "
echo "                                          /_/            "
echo ""
echo ""
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo "  "
echo "  🚀 CloudPak for Watson AI OPS 3.2 - Load Robotshop Data for Training "
echo "  "
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo "  "
echo "  "


export ANSIBLE_DISPLAY_SKIPPED_HOSTS=false

echo "  "
echo "  "
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo "  🚀 Initializing"
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"


export existingIndexes=$(curl -s -k -u $username:$password -XGET https://localhost:9200/_cat/indices)


if [[ $SILENT_SKIP == "" ]] ;
then
    export SILENT_SKIP=true
    echo "Setting SILENT_SKIP=true"
fi
echo "  "


if [[ $existingIndexes == "" ]] ;
then
    echo "        ❗ Please start port forward in separate terminal."
    echo "        ❗ Run in a separate terminal window:"
    echo "            ./tools/28_access_elastic.sh"
    echo "        ❗ Or run the following in a separate terminal window:"
    echo "            while true; do oc port-forward statefulset/iaf-system-elasticsearch-es-aiops 9200; done"
    echo "        ❌ Aborting..."
    echo "     "
    echo "     "
    echo "     "
    echo "     "
    exit 1
fi


# Get Namespace from Cluster 
echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "   🔬 Getting Installation Namespace"
echo "   ------------------------------------------------------------------------------------------------------------------------------"
export WAIOPS_NAMESPACE=$(oc get po -A|grep aimanager-operator |awk '{print$1}')
echo "       ✅ AI Manager:         OK - $WAIOPS_NAMESPACE"
echo "     "	

echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "   🛠️  Creating Platform API Route"
echo "   ------------------------------------------------------------------------------------------------------------------------------"
oc create route passthrough ai-platform-api -n $WAIOPS_NAMESPACE  --service=aimanager-aio-ai-platform-api-server --port=4000 --insecure-policy=Redirect --wildcard-policy=None>/dev/null 2>&1
export ROUTE=$(oc get route -n $WAIOPS_NAMESPACE ai-platform-api  -o jsonpath={.spec.host})
echo "       ✅ Platform API Route: OK"
echo ""



echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "   🗄️  Using Parameters"
echo "   ------------------------------------------------------------------------------------------------------------------------------"

echo "       "	
echo "           🌏 Namespace:                 $WAIOPS_NAMESPACE"	
echo "       "	
echo "           🙎‍♂️ Platform API Route:        $ROUTE"	
echo "       "	
echo "           ❎ Skip Data Load if exists:  $SILENT_SKIP"	
echo "       "	



echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo "  🚀 Load and train all models"
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo "  "

cd ansible
ansible-playbook 84_training-all.yaml $VERBOSE
cd -



echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo "  🗺  Log Anomaly Training Mapping"
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo "  "
echo "  "
echo "  "

echo "{"
echo "  \"codec\": \"humio\","
echo "  \"message_field\": \"@rawstring\","
echo "  \"log_entity_types\": \"kubernetes.namespace_name,kubernetes.container_hash,kubernetes.host,kubernetes.container_name,kubernetes.pod_name\","
echo "  \"instance_id_field\": \"kkubernetes.container_name\","
echo "  \"rolling_time\": 10,"
echo "  \"timestamp_field\": \"@timestamp\""
echo "}"
