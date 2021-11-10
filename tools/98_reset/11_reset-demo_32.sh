


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
echo ""
echo " 🚀  CP4WAIOPS 3.2 Reset Demo"
echo ""
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"

WAIOPS_PARAMETER=$(cat ./00_config_cp4waiops.yaml|grep WAIOPS_NAMESPACE:)
WAIOPS_NAMESPACE=${WAIOPS_PARAMETER##*:}
WAIOPS_NAMESPACE=$(echo $WAIOPS_NAMESPACE|tr -d '[:space:]')

oc project $WAIOPS_NAMESPACE


  read -p " ❗❓ Start Reset? [y,N] " DO_COMM
  if [[ $DO_COMM == "y" ||  $DO_COMM == "Y" ]]; then
      echo "   ✅ Ok, continuing..."
      echo ""
      echo ""
      echo ""
      echo ""

  else
    echo "❌ Aborted"
    exit 1
  fi
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"


echo ""
echo ""
echo "***************************************************************************************************************************************************"
echo " 🧻 Deleting Kafka Topics"
echo "***************************************************************************************************************************************************"

# oc delete kt cp4waiops-cartridge.lifecycle.input.alerts 
# oc delete kt cp4waiops-cartridge.lifecycle.input.events 
oc delete kt cp4waiops-cartridge.lifecycle.input.stories 
# oc delete kt cp4waiops-cartridge.lifecycle.internal.completed-executions 
# oc delete kt cp4waiops-cartridge.lifecycle.internal.in-progress-executions
# oc delete kt cp4waiops-cartridge.lifecycle.output.story-notifications 
# oc delete kt cp4waiops-cartridge.lifecycle.output.topology-alert-query 
# oc delete kt cp4waiops-cartridge.lifecycle.output.topology-alert-response

# oc delete kt cp4waiops-cartridge.irdatalayer.changes.alerts
# oc delete kt cp4waiops-cartridge.irdatalayer.changes.stories 
# oc delete kt cp4waiops-cartridge.irdatalayer.requests.alerts   
# oc delete kt cp4waiops-cartridge.irdatalayer.requests.stories  
# oc delete kt cp4waiops-cartridge.irdatalayer.responses.alerts  
# oc delete kt cp4waiops-cartridge.irdatalayer.responses.stories
# oc delete kt cp4waiops-cartridge.lifecycle.output.topology-alert-response

# oc delete kt cp4waiops-cartridge-windowed-logs-1000-1000 

# oc delete kt $(oc get kt | grep "cp4waiops-cartridge-logs-"| awk '{print $1;}')
# oc delete kt $(oc get kt | grep "cp4waiops-cartridge-alerts-"| awk '{print $1;}')

echo ""
echo ""
echo "***************************************************************************************************************************************************"
echo " 🔐 Getting Elasticsearch credentials"
echo "***************************************************************************************************************************************************"
export username=$(oc get secret $(oc get secrets | grep ibm-aiops-elastic-secret | awk '!/-min/' | awk '{print $1;}') -o jsonpath="{.data.username}"| base64 --decode)
export password=$(oc get secret $(oc get secrets | grep ibm-aiops-elastic-secret | awk '!/-min/' | awk '{print $1;}') -o jsonpath="{.data.password}"| base64 --decode)

export existingIndexes=$(curl -s -k -u $username:$password -XGET https://localhost:9200/_cat/indices)


if [[ $existingIndexes == "" ]] ;
then
      echo "❗ Please start port forward in separate terminal."
      echo "❗ Run the following:"
      echo "    while true; do oc port-forward statefulset/$(oc get statefulset | grep es-server-all | awk '{print $1}') 9200; done"
      echo "❌ Aborting..."
      exit 1
fi
echo "      ✅ OK"
echo ""
echo ""


echo ""
echo ""
echo "***************************************************************************************************************************************************"
echo " 🧻 Deleting Elasticsearch Indexes"
echo "***************************************************************************************************************************************************"

# echo "      Deleting Index 1000-1000-reference_oob"
# curl -k -u $username:$password -XDELETE https://$username:$password@localhost:9200/1000-1000-reference_oob  
# echo ""
# echo ""

# echo "      Deleting Index 1000-1000-reference_embedding"
# curl -k -u $username:$password -XDELETE https://$username:$password@localhost:9200/1000-1000-reference_embedding  
# echo ""
# echo ""

# echo "      Deleting Index 1000-1000-v1-pca_anomaly_group_id"
# curl -k -u $username:$password -XDELETE https://$username:$password@localhost:9200/1000-1000-v1-pca_anomaly_group_id  
# echo ""
# echo ""

# echo "      Deleting Index 1000-1000-v1-anomalies"
# curl -k -u $username:$password -XDELETE https://$username:$password@localhost:9200/1000-1000-v1-anomalies  
# echo ""
# echo ""







# echo "      Deleting Index 1000-1000-na-anomalies"
# curl -k -u $username:$password -XDELETE https://$username:$password@localhost:9200/1000-1000-na-anomalies    
# echo ""
# echo ""
# echo "      Deleting Index 1000-1000-na-oob_anomaly_group_id"                                                                    
# curl -k -u $username:$password -XDELETE https://$username:$password@localhost:9200/1000-1000-na-oob_anomaly_group_id  
echo ""
echo ""
# echo "      Deleting Index 1000-1000-reference_embedding  " 
# curl -k -u $username:$password -XDELETE https://$username:$password@localhost:9200/1000-1000-reference_embedding  
echo ""
echo ""
# echo "      Deleting Index 1000-1000-reference_oob"
# curl -k -u $username:$password -XDELETE https://$username:$password@localhost:9200/1000-1000-reference_oob
# echo ""
# echo ""
# echo "      Deleting Index 1000-1000-windowed_logs"
# curl -k -u $username:$password -XDELETE https://$username:$password@localhost:9200/1000-1000-windowed_logs 

            
# for index in $(curl -k -u $username:$password -XGET https://localhost:9200/_cat/indices | grep -E "irdatalayer-aiops-alert*" | awk '{print $3;}'); do
#     echo ""
#     echo ""
#     echo "      Deleting Index $index"
#     curl -k -u $username:$password -XDELETE "https://localhost:9200/$index"
# done



echo ""
echo ""
echo "***************************************************************************************************************************************************"
echo " 🧻 Deleting Alerts in ObjectServer"
echo "***************************************************************************************************************************************************"
export USER_PASS="$(oc get secret aiops-ir-core-ncodl-api-secret -o jsonpath='{.data.username}' | base64 --decode):$(oc get secret aiops-ir-core-ncodl-api-secret -o jsonpath='{.data.password}' | base64 --decode)"

oc apply -n $WAIOPS_NAMESPACE -f ./tools/98_reset/datalayer-api-route.yaml

sleep 2

export DATALAYER_ROUTE=$(oc get route  -n $WAIOPS_NAMESPACE datalayer-api  -o jsonpath='{.status.ingress[0].host}')

curl "https://$DATALAYER_ROUTE/irdatalayer.aiops.io/active/v1/alerts" -X PATCH -u "${USER_PASS}" -d '{"state": "closed"}' -H 'Content-Type: application/json' -H "x-username:admin" -H "x-subscription-id:cfd95b7e-3bc7-4006-a4a8-a73a79c71255"


curl "https://$DATALAYER_ROUTE/irdatalayer.aiops.io/active/v1/alerts" -X GET -u "${USER_PASS}" -H "x-username:admin" -H "x-subscription-id:cfd95b7e-3bc7-4006-a4a8-a73a79c71255" | grep '"state": "open"' | wc -l



echo ""
echo ""
echo "***************************************************************************************************************************************************"
echo " 🧻 Deleting Pods"
echo "***************************************************************************************************************************************************"
# oc delete pod -n cp4waiops $(oc get po -n cp4waiops|grep ep-job |awk '{print$1}') --force --grace-period=0 &
# oc delete pod -n cp4waiops $(oc get po -n cp4waiops|grep ep-task |awk '{print$1}') --force --grace-period=0 &
# oc delete pod -n cp4waiops $(oc get po -n cp4waiops|grep ir-lifecycle-operator-controller-manager |awk '{print$1}') --force --grace-period=0 &
# oc delete pod -n cp4waiops $(oc get po -n cp4waiops|grep chatops |awk '{print$1}') --force --grace-period=0 &



echo ""
echo ""
echo "***************************************************************************************************************************************************"
echo " ⏳ Waiting 20 Seconds"
echo "***************************************************************************************************************************************************"
sleep 20






echo ""
echo ""
echo "***************************************************************************************************************************************************"
echo " ⏳ Waiting for Pods"
echo "***************************************************************************************************************************************************"


echo " 🔎 Check for ir-lifecycle-operator-controller-manager" 
SUCCESFUL_RESTART=$(oc get pods | grep ir-lifecycle-operator-controller-manager | grep 0/1 || true)
while ([[ $SUCCESFUL_RESTART =~ "0" ]] ); do 
 SUCCESFUL_RESTART=$(oc get pods | grep ir-lifecycle-operator-controller-manager | grep 0/1 || true)
 echo "   ⏳ wait for  ir-lifecycle-operator-controller-manager" 
 sleep 10
done
echo " ✅ OK"


echo " 🔎 Check for chatops" 
SUCCESFUL_RESTART=$(oc get pods | grep chatops | grep 0/1 || true)
while ([[ $SUCCESFUL_RESTART =~ "0" ]] ); do 
 SUCCESFUL_RESTART=$(oc get pods | grep chatops | grep 0/1 || true)
 echo "   ⏳ wait for  chatops" 
 sleep 10
done
echo " ✅ OK"


echo " 🔎 Check for ep-jobmanager" 
SUCCESFUL_RESTART=$(oc get pods | grep ep-job || true)
while ([[ $SUCCESFUL_RESTART =~ "0/2" ]] || [[ $SUCCESFUL_RESTART =~ "1/2" ]] ); do 
 SUCCESFUL_RESTART=$(oc get pods | grep ep-job || true)
 echo "   ⏳ wait for  ep-jobmanager" 
 sleep 10
done
echo " ✅ OK"


echo " 🔎 Check for ep-taskmanager" 
SUCCESFUL_RESTART=$(oc get pods | grep ep-task | grep 0/1 || true)
while ([[ $SUCCESFUL_RESTART =~ "0/" ]] ); do 
 SUCCESFUL_RESTART=$(oc get pods | grep ep-task | grep 0/1 || true)
 echo "   ⏳ wait for  ep-taskmanager" 
 sleep 10
done
echo " ✅ OK"


echo ""
echo ""
echo "***************************************************************************************************************************************************"
echo " 🚀 Creating Kafka Topics"
echo "***************************************************************************************************************************************************"


# cat <<EOF | oc apply -f -
# apiVersion: ibmevents.ibm.com/v1beta2
# kind: KafkaTopic
# metadata:
#   name: cp4waiops-cartridge.irdatalayer.requests.alerts
#   namespace: cp4waiops
#   labels:
#     ibmevents.ibm.com/cluster: iaf-system
# spec:
#   config:
#     cleanup.policy: compact
#   partitions: 1
#   replicas: 1
#   topicName: cp4waiops-cartridge.irdatalayer.requests.alerts
# ---
# apiVersion: ibmevents.ibm.com/v1beta2
# kind: KafkaTopic
# metadata:
#   name: cp4waiops-cartridge.irdatalayer.requests.stories
#   namespace: cp4waiops
#   labels:
#     ibmevents.ibm.com/cluster: iaf-system
# spec:
#   config:
#     cleanup.policy: compact
#   partitions: 1
#   replicas: 1
#   topicName: cp4waiops-cartridge.irdatalayer.requests.stories
# ---
# apiVersion: ibmevents.ibm.com/v1beta2
# kind: KafkaTopic
# metadata:
#   name: cp4waiops-cartridge.irdatalayer.responses.stories
#   namespace: cp4waiops
#   labels:
#     ibmevents.ibm.com/cluster: iaf-system
# spec:
#   config:
#     cleanup.policy: compact
#   partitions: 1
#   replicas: 1
#   topicName: cp4waiops-cartridge.irdatalayer.responses.stories
# ---
# apiVersion: ibmevents.ibm.com/v1beta2
# kind: KafkaTopic
# metadata:
#   name: cp4waiops-cartridge.lifecycle.output.topology-alert-response
#   namespace: cp4waiops
#   labels:
#     ibmevents.ibm.com/cluster: iaf-system
# spec:
#   config:
#     cleanup.policy: compact
#   partitions: 1
#   replicas: 1
#   topicName: cp4waiops-cartridge.lifecycle.output.topology-alert-response
# ---
# apiVersion: ibmevents.ibm.com/v1beta2
# kind: KafkaTopic
# metadata:
#   name: cp4waiops-cartridge.lifecycle.internal.in-progress-executions
#   namespace: cp4waiops
#   labels:
#     ibmevents.ibm.com/cluster: iaf-system
# spec:
#   config:
#     cleanup.policy: compact
#   partitions: 1
#   replicas: 1
#   topicName: cp4waiops-cartridge.lifecycle.internal.in-progress-executions
# ---
# apiVersion: ibmevents.ibm.com/v1beta2
# kind: KafkaTopic
# metadata:
#   name: cp4waiops-cartridge.lifecycle.output.topology-alert-response
#   namespace: cp4waiops
#   labels:
#     ibmevents.ibm.com/cluster: iaf-system
# spec:
#   config:
#     cleanup.policy: compact
#   partitions: 1
#   replicas: 1
#   topicName: cp4waiops-cartridge.lifecycle.output.topology-alert-response

# EOF

# echo ""
# echo ""
# echo "***************************************************************************************************************************************************"
# echo " 🚀 Running Pods"
# echo "***************************************************************************************************************************************************"

# oc get po -n cp4waiops|grep ep-job
# oc get po -n cp4waiops|grep ep-task
# oc get po -n cp4waiops|grep ir-lifecycle-operator-controller-manager
# oc get po -n cp4waiops|grep chatops



# echo ""
# echo ""
# echo "***************************************************************************************************************************************************"
# echo " 🩹 Patching Kafka Topics"
# echo "***************************************************************************************************************************************************"
# oc patch kt cp4waiops-cartridge.lifecycle.input.alerts -p '{"spec":{"partitions": 6}}' --type=merge 
# oc patch kt cp4waiops-cartridge.lifecycle.input.events -p '{"spec":{"partitions": 6}}' --type=merge 
oc patch kt cp4waiops-cartridge.lifecycle.input.stories -p '{"spec":{"partitions": 24}}' --type=merge 
oc patch kt cp4waiops-cartridge.lifecycle.input.stories -p '{"spec":{"config":{"retention.ms": "86400000"}}}' --type=merge 
# oc patch kt cp4waiops-cartridge.lifecycle.internal.completed-executions  -p '{"spec":{"partitions": 24}}' --type=merge 
# oc patch kt cp4waiops-cartridge.lifecycle.internal.in-progress-executions -p '{"spec":{"partitions": 24}}' --type=merge 
# oc patch kt cp4waiops-cartridge.lifecycle.output.story-notifications  -p '{"spec":{"partitions": 24}}' --type=merge 
# oc patch kt cp4waiops-cartridge.lifecycle.output.topology-alert-query  -p '{"spec":{"partitions": 24}}' --type=merge 
# oc patch kt cp4waiops-cartridge.lifecycle.output.topology-alert-response -p '{"spec":{"partitions": 24}}' --type=merge 

# oc patch kt cp4waiops-cartridge.irdatalayer.changes.alerts -p '{"spec":{"partitions": 6}}' --type=merge 
# oc patch kt cp4waiops-cartridge.irdatalayer.changes.stories -p '{"spec":{"partitions": 6}}' --type=merge 
# oc patch kt cp4waiops-cartridge.irdatalayer.requests.alerts -p '{"spec":{"partitions": 6}}' --type=merge 
# oc patch kt cp4waiops-cartridge.irdatalayer.requests.stories -p '{"spec":{"partitions": 6}}' --type=merge 
# oc patch kt cp4waiops-cartridge.irdatalayer.responses.alerts -p '{"spec":{"partitions": 6}}' --type=merge 
# oc patch kt cp4waiops-cartridge.irdatalayer.responses.stories -p '{"spec":{"partitions": 6}}' --type=merge 

# oc patch kt cp4waiops-cartridge.lifecycle.output.topology-alert-response -p '{"spec":{"partitions": 24}}' --type=merge 

echo "--------------------------------------------------------------------------------------------------------------------------------"
echo "--------------------------------------------------------------------------------------------------------------------------------"
echo " ✅ DONE... You're good to go...."
echo "--------------------------------------------------------------------------------------------------------------------------------"
echo "--------------------------------------------------------------------------------------------------------------------------------"









exit 1


for index in $(curl -k -u $username:$password -XGET https://localhost:9200/_cat/indices | grep -E "1000-1000-51" | awk '{print $3;}'); do
    curl -k -u $username:$password -XDELETE "https://localhost:9200/$index"
done

for index in $(curl -k -u $username:$password -XGET https://localhost:9200/_cat/indices | grep -E "1000-1000-v1" | awk '{print $3;}'); do
    curl -k -u $username:$password -XDELETE "https://localhost:9200/$index"
done

1000-1000-51827190630-logtrain

export APP_NAME=robot-shop #robot-shop, elk
export LOG_TYPE=humio # humio, elk, splunk, ...

WAIOPS_PARAMETER=$(cat ./00_config_cp4waiops.yaml|grep WAIOPS_NAMESPACE:)
WAIOPS_NAMESPACE=${WAIOPS_PARAMETER##*:}
WAIOPS_NAMESPACE=$(echo $WAIOPS_NAMESPACE|tr -d '[:space:]')

#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# DO NOT EDIT BELOW
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


source ./tools/01_demo/00_config-secrets.sh

banner

echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo " 🚀 CP4WAIOPS RESET DEMO"
echo "***************************************************************************************************************************************************"
echo " This will reset:"
echo " - Stories"
echo " - Netcool Events"
echo "***************************************************************************************************************************************************"

#--------------------------------------------------------------------------------------------------------------------------------------------
# Check Defaults
#--------------------------------------------------------------------------------------------------------------------------------------------
oc project $WAIOPS_NAMESPACE >/tmp/demo.log 2>&1 || true

if [[ $APP_NAME == "" ]] ;
then
 echo "⚠️ AppName not defined. Launching this script directly?"
 echo " Falling back to $DEFAULT_APP_NAME"
 export APP_NAME=$DEFAULT_APP_NAME
fi

if [[ $LOG_TYPE == "" ]] ;
then
 echo "⚠️ Log Type not defined. Launching this script directly?"
 echo " Falling back to $DEFAULT_LOG_TYPE"
 export LOG_TYPE=$DEFAULT_LOG_TYPE
fi



echo " Get Connection Details for $LOG_TYPE"
oc exec -it -n $WAIOPS_NAMESPACE $(oc get po -n $WAIOPS_NAMESPACE |grep aimanager-aio-controller|awk '{print$1}') -- curl -k -X GET https://localhost:9443/v2/connections/application_groups/1000/ > tmp_connection.json
more tmp_connection.json
echo " Get Connection ID"
export CONNECTION_ID=$(jq ".[] | select(.connection_type==\"kafka\") | select(.mapping.codec==\"$LOG_TYPE\") | .connection_id" tmp_connection.json | tr -d '"')
echo $CONNECTION_ID
echo " Get Connection Password"
export CONNECTION_NAME=$(jq ".[] | select(.connection_type==\"kafka\") | select(.mapping.codec==\"$LOG_TYPE\") | .connection_config.display_name" tmp_connection.json | tr -d '"') 
echo " Get Logs Topic for $LOG_TYPE"
export LOGS_TOPIC=$(oc get kafkatopics -n $WAIOPS_NAMESPACE | grep logs-$LOG_TYPE| awk '{print $1;}')

#--------------------------------------------------------------------------------------------------------------------------------------------
# Check Credentials
#--------------------------------------------------------------------------------------------------------------------------------------------

echo "***************************************************************************************************************************************************"
echo " 🔗 Checking credentials"
echo "***************************************************************************************************************************************************"

if [[ $LOGS_TOPIC == "" ]] ;
then
 echo "❌ Please create the $LOG_TYPE Kafka Log Integration. Aborting..."
 exit 1
else
 echo " ✅ OK - Logs Topic"
fi

if [[ $CONNECTION_ID == "" ]] ;
then
 echo "❌ Cannot get DB credentials. Aborting..."
 exit 1
else
 echo " ✅ OK - DB Connection"
fi


echo ""
echo ""
echo ""
echo ""


echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo " "
echo " 🔎 Parameter for resetting demo"
echo " "
echo " 📝 Log Type : $LOG_TYPE"
echo " 🗂 Topic : $LOGS_TOPIC"
echo " "
echo " 🌏 AIOPS DB ID : $CONNECTION_ID"
echo " 🔐 AIOPS DB NAME : $CONNECTION_NAME"
echo " "
echo " "
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo ""

rm -f tmp_connection.json



 read -p "❗ Are you really, really, REALLY sure you want to reset the demo? [y,N] " DO_COMM
 if [[ $DO_COMM == "y" || $DO_COMM == "Y" ]]; then
 echo " 🧞‍♂️ OK, as you wish...."
 else
 echo " ❌ Aborted"
 exit 1
 fi
 



echo ""
echo ""
echo "--------------------------------------------------------------------------------------------------------------------------------"
echo "Turn off Data Flow $CONNECTION_NAME"
echo "--------------------------------------------------------------------------------------------------------------------------------"


oc exec -it $(oc get po |grep aimanager-aio-controller|awk '{print$1}') -- curl -k -X PUT https://localhost:9443/v3/connections/$CONNECTION_ID/disable
echo " ✅ OK"

exit 1

# ----------------------------------------------------------------------------------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------------------------------------------------------------------------
# Reset Demo - Clean Up
# ----------------------------------------------------------------------------------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------------------------------------------------------------------------


echo ""
echo ""
echo "--------------------------------------------------------------------------------------------------------------------------------"
echo "Existing kafka topics"
echo "--------------------------------------------------------------------------------------------------------------------------------"

oc get kafkatopic -n $WAIOPS_NAMESPACE| awk '{print $1}' # > all_topics_$(date +%s).yaml
echo " ✅ OK"



echo ""
echo ""
echo "--------------------------------------------------------------------------------------------------------------------------------"
echo "Delete kafka topics"
echo "--------------------------------------------------------------------------------------------------------------------------------"

oc get kafkatopic -n $WAIOPS_NAMESPACE| grep window | awk '{print $1}' | xargs oc delete kafkatopic -n $WAIOPS_NAMESPACE
echo " ✅ OK"

oc get kafkatopic -n $WAIOPS_NAMESPACE| grep normalized | awk '{print $1}'| xargs oc delete kafkatopic -n $WAIOPS_NAMESPACE
echo " ✅ OK"

oc get kafkatopic -n $WAIOPS_NAMESPACE| grep derived | awk '{print $1}'| xargs oc delete kafkatopic -n $WAIOPS_NAMESPACE
echo " ✅ OK"

oc get kafkatopic -n $WAIOPS_NAMESPACE| grep logs-$LOG_TYPE | awk '{print $1}' | xargs oc delete kafkatopic -n $WAIOPS_NAMESPACE
echo " ✅ OK"




echo ""
echo ""
echo "--------------------------------------------------------------------------------------------------------------------------------"
echo "Recreate Topics"
echo "--------------------------------------------------------------------------------------------------------------------------------"




echo "Creating topics windowed-logs-1000-1000 and normalized-alerts-1000-1000\n\n"
cat <<EOF | oc apply -f -
apiVersion: kafka.strimzi.io/v1beta1
kind: KafkaTopic
metadata:
 name: normalized-alerts-1000-1000 
 namespace: $WAIOPS_NAMESPACE
 labels:
 strimzi.io/cluster: strimzi-cluster
spec:
 config:
 max.message.bytes: '1048588'
 retention.ms: '1800000'
 segment.bytes: '1073741824'
 partitions: 1
 replicas: 1
 topicName: normalized-alerts-1000-1000 
---
apiVersion: kafka.strimzi.io/v1beta1
kind: KafkaTopic
metadata:
 name: windowed-logs-1000-1000 
 namespace: $WAIOPS_NAMESPACE
 labels:
 strimzi.io/cluster: strimzi-cluster
spec:
 config:
 max.message.bytes: '1048588'
 retention.ms: '1800000'
 segment.bytes: '1073741824'
 partitions: 1
 replicas: 1
 topicName: windowed-logs-1000-1000 
EOF
echo " ✅ OK"




cat <<EOF | oc apply -f -
apiVersion: kafka.strimzi.io/v1beta1
kind: KafkaTopic
metadata:
 name: derived-stories
 namespace: $WAIOPS_NAMESPACE
 labels:
 strimzi.io/cluster: strimzi-cluster
spec:
 config:
 max.message.bytes: '1048588'
 retention.ms: '1800000'
 segment.bytes: '1073741824'
 partitions: 1
 replicas: 1
 topicName: derived-stories 
EOF
echo " ✅ OK"




cat <<EOF | oc apply -f -
apiVersion: kafka.strimzi.io/v1beta1
kind: KafkaTopic
metadata:
 name: $LOGS_TOPIC
 namespace: $WAIOPS_NAMESPACE
 labels:
 strimzi.io/cluster: strimzi-cluster
spec:
 config:
 max.message.bytes: '1048588'
 retention.ms: '1800000'
 segment.bytes: '1073741824'
 partitions: 1
 replicas: 1
 topicName: $LOGS_TOPIC
EOF
echo " ✅ OK"





echo ""
echo ""
echo "--------------------------------------------------------------------------------------------------------------------------------"
echo "Kafka topics"
echo "--------------------------------------------------------------------------------------------------------------------------------"

oc get kafkatopic -n $WAIOPS_NAMESPACE
echo " ✅ OK"




echo ""
echo ""
echo "--------------------------------------------------------------------------------------------------------------------------------"
echo "Clear Stories DB"
echo "--------------------------------------------------------------------------------------------------------------------------------"

oc project $WAIOPS_NAMESPACE

echo "1/8"
oc exec -it $(oc get pods | grep persistence | awk '{print $1;}') -- curl -k -X DELETE https://localhost:8443/v2/similar_incident_lists
echo ""
echo "2/8"
oc exec -it $(oc get pods | grep persistence | awk '{print $1;}') -- curl -k -X DELETE https://localhost:8443/v2/alertgroups
echo ""
echo "3/8"
oc exec -it $(oc get pods | grep persistence | awk '{print $1;}') -- curl -k -X DELETE https://localhost:8443/v2/app_states
echo ""
echo "4/8"
oc exec -it $(oc get pods | grep persistence | awk '{print $1;}') -- curl -k -X DELETE https://localhost:8443/v2/stories
echo ""
echo "5/8"
oc exec -it $(oc get pods | grep persistence | awk '{print $1;}') -- curl -k https://localhost:8443/v2/similar_incident_lists
echo ""
echo "6/8"
oc exec -it $(oc get pods | grep persistence | awk '{print $1;}') -- curl -k https://localhost:8443/v2/alertgroups
echo ""
echo "7/8"
oc exec -it $(oc get pods | grep persistence | awk '{print $1;}') -- curl -k https://localhost:8443/v2/application_groups/1000/app_states
echo ""
echo "8/8"
oc exec -it $(oc get pods | grep persistence | awk '{print $1;}') -- curl -k https://localhost:8443/v2/stories
echo ""
echo " ✅ OK"




echo ""
echo ""
echo "--------------------------------------------------------------------------------------------------------------------------------"
echo "Refresh the Flink Jobs"
echo "--------------------------------------------------------------------------------------------------------------------------------"



echo "1/6: Logs"
oc exec -it $(oc get pods | grep aio-controller | awk '{print $1;}') -- curl -k -X PUT https://localhost:9443/v2/connections/application_groups/1000/applications/1000/refresh?datasource_type=logs
echo " ✅ OK"
echo ""
echo "2/6: Events"
oc exec -it $(oc get pods | grep aio-controller | awk '{print $1;}') -- curl -k -X PUT https://localhost:9443/v2/connections/application_groups/1000/applications/1000/refresh?datasource_type=alerts
echo " ✅ OK"



echo ""
echo ""
echo "--------------------------------------------------------------------------------------------------------------------------------"
echo "Delete NOI Events"
echo "--------------------------------------------------------------------------------------------------------------------------------"

password=$(oc get secrets | grep omni-secret | awk '{print $1;}' | xargs oc get secret -o jsonpath --template '{.data.OMNIBUS_ROOT_PASSWORD}' | base64 --decode)
oc get pods | grep ncoprimary-0 | awk '{print $1;}' | xargs -I{} oc exec {} -- bash -c "/opt/IBM/tivoli/netcool/omnibus/bin/nco_sql -server AGG_P -user root -passwd ${password} << EOF
delete from alerts.status where AlertGroup='$APP_NAME';
go
exit
EOF"
echo " ✅ OK"



echo ""
echo ""
echo "--------------------------------------------------------------------------------------------------------------------------------"
echo "Turn on Data Flow $CONNECTION_NAME"
echo "--------------------------------------------------------------------------------------------------------------------------------"


oc exec -it $(oc get po |grep aimanager-aio-controller|awk '{print$1}') -- curl -k -X PUT https://localhost:9443/v3/connections/$CONNECTION_ID/enable
echo " ✅ OK"



echo ""
echo ""
echo ""
echo "--------------------------------------------------------------------------------------------------------------------------------"
echo "Check Pods"
echo "--------------------------------------------------------------------------------------------------------------------------------"



oc delete pod $(oc get pods | grep log-anomaly-detector | awk '{print $1;}') --force --grace-period=0|| true
oc delete pod $(oc get pods | grep aimanager-aio-event-grouping | awk '{print $1;}') --force --grace-period=0|| true
oc delete pod $(oc get pods | grep flink-task-manager-0 | awk '{print $1;}') --force --grace-period=0|| true

#echo " ✅ OK"

echo " 🔎 Check derived-stories KafkaTopic" 

TOPIC_READY=$(oc get kafkatopics -n $WAIOPS_NAMESPACE derived-stories -o jsonpath='{.status.conditions[0].status}' || true)

while ([[ ! $TOPIC_READY =~ "True" ]] ); do 
 TOPIC_READY=$(oc get kafkatopics -n $WAIOPS_NAMESPACE derived-stories -o jsonpath='{.status.conditions[0].status}' || true)
 echo " ⏳ wait for  derived-stories KafkaTopic" 
 sleep 3
done
echo " ✅ OK"



echo " 🔎 Check windowed-logs KafkaTopic" 

TOPIC_READY=$(oc get kafkatopics -n $WAIOPS_NAMESPACE windowed-logs-1000-1000 -o jsonpath='{.status.conditions[0].status}' || true)

while ([[ ! $TOPIC_READY =~ "True" ]] ); do 
 TOPIC_READY=$(oc get kafkatopics -n $WAIOPS_NAMESPACE windowed-logs-1000-1000 -o jsonpath='{.status.conditions[0].status}' || true)
 echo " ⏳ wait for  windowed-logs KafkaTopic" 
 sleep 3
done
echo " ✅ OK"


echo " 🔎 Check normalized-alerts KafkaTopic" 

TOPIC_READY=$(oc get kafkatopics -n $WAIOPS_NAMESPACE normalized-alerts-1000-1000 -o jsonpath='{.status.conditions[0].status}' || true)

while ([[ ! $TOPIC_READY =~ "True" ]] ); do 
 TOPIC_READY=$(oc get kafkatopics -n $WAIOPS_NAMESPACE normalized-alerts-1000-1000 -o jsonpath='{.status.conditions[0].status}' || true)
 echo " ⏳ wait for  normalized-alerts KafkaTopic" 
 sleep 3
done
echo " ✅ OK"

echo " 🔎 Check $LOGS_TOPIC KafkaTopic" 

TOPIC_READY=$(oc get kafkatopics -n $WAIOPS_NAMESPACE $LOGS_TOPIC -o jsonpath='{.status.conditions[0].status}' || true)

while ([[ ! $TOPIC_READY =~ "True" ]] ); do 
 TOPIC_READY=$(oc get kafkatopics -n $WAIOPS_NAMESPACE $LOGS_TOPIC -o jsonpath='{.status.conditions[0].status}' || true)
 echo " ⏳ wait for  $LOGS_TOPIC KafkaTopic" 
 sleep 3
done
echo " ✅ OK"


#oc delete pod $(oc get pods | grep event-gateway-generic-evtmgrgw | awk '{print $1;}')





echo " 🔎 Check for Anomaly Pod" 

SUCCESFUL_RESTART=$(oc get pods | grep log-anomaly-detector | grep 0/1 || true)

while ([[ $SUCCESFUL_RESTART =~ "0" ]] ); do 
 SUCCESFUL_RESTART=$(oc get pods | grep log-anomaly-detector | grep 0/1 || true)
 echo " ⏳ wait for  Anomaly Pod" 
 sleep 10
done
echo " ✅ OK"

echo " 🔎 Check for Event Grouping Pod" 

SUCCESFUL_RESTART=$(oc get pods | grep aimanager-aio-event-grouping | grep 0/1 || true)

while ([[ $SUCCESFUL_RESTART =~ "0" ]] ); do 
 SUCCESFUL_RESTART=$(oc get pods | grep aimanager-aio-event-grouping | grep 0/1 || true)
 echo " ⏳ wait for  Event Grouping Pod" 
 sleep 10
done
echo " ✅ OK"


echo " 🔎 Check for Task Manager Pod" 

SUCCESFUL_RESTART=$(oc get pods | grep flink-task-manager-0 | grep 0/1 || true)

while ([[ $SUCCESFUL_RESTART =~ "0" ]] ); do 
 SUCCESFUL_RESTART=$(oc get pods | grep flink-task-manager-0 | grep 0/1 || true)
 echo " ⏳ wait for  Flink Task Manager Pod" 
 sleep 10
done
echo " ✅ OK"

echo " 🔎 Check for Gateway Pod" 

SUCCESFUL_RESTART=$(oc get pods | grep event-gateway-generic | grep 0/1 || true)

while ([[ $SUCCESFUL_RESTART =~ "0" ]] ); do 
 SUCCESFUL_RESTART=$(oc get pods | grep event-gateway-generic | grep 0/1 || true)
 echo " ⏳ wait for  Gateway Pod" 
 sleep 10
done
echo " ✅ OK"


echo "--------------------------------------------------------------------------------------------------------------------------------"
echo "--------------------------------------------------------------------------------------------------------------------------------"
echo " ✅ DONE... You're good to go...."
echo "--------------------------------------------------------------------------------------------------------------------------------"
echo "--------------------------------------------------------------------------------------------------------------------------------"

