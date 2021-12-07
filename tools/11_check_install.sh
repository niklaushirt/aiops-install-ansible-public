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
#  CP4WAIOPS 3.2 - Debug WAIOPS Installation
#
#
#  ©2021 nikh@ch.ibm.com
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
clear

echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo "  "
echo "  🚀 CloudPak for Watson AIOps 3.2 - Check WAIOPS Installation"
echo "  "
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo "  "
echo "  "


export TEMP_PATH=~/aiops-install

# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# Do Not Edit Below
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"

function check_array_crd(){

      echo ""
      echo ""
      echo "--------------------------------------------------------------------------------------------"
      echo "🔎 Check $CHECK_NAME"
      echo "--------------------------------------------------------------------------------------------"

      for ELEMENT in ${CHECK_ARRAY[@]}; do
            ELEMENT_NAME=${ELEMENT##*/}
            ELEMENT_TYPE=${ELEMENT%%/*}
       echo "   Check $ELEMENT_NAME ($ELEMENT_TYPE) ..."

            ELEMENT_OK=$(oc get $ELEMENT -n $WAIOPS_NAMESPACE | grep "AGE" || true) 

            if  ([[ ! $ELEMENT_OK =~ "AGE" ]]); 
            then 
                  echo "      ⭕ $ELEMENT not present"; 
                  echo ""
            else
                  echo "      ✅ OK: $ELEMENT"; 

            fi
      done
      export CHECK_NAME=""
}

function check_array(){

      echo ""
      echo ""
      echo "--------------------------------------------------------------------------------------------"
      echo "🔎 Check $CHECK_NAME"
      echo "--------------------------------------------------------------------------------------------"

      for ELEMENT in ${CHECK_ARRAY[@]}; do
            ELEMENT_NAME=${ELEMENT##*/}
            ELEMENT_TYPE=${ELEMENT%%/*}
       echo "   Check $ELEMENT_NAME ($ELEMENT_TYPE) ..."

            ELEMENT_OK=$(oc get $ELEMENT -n $WAIOPS_NAMESPACE | grep $ELEMENT_NAME || true) 

            if  ([[ ! $ELEMENT_OK =~ "$ELEMENT_NAME" ]]); 
            then 
                  echo "      ⭕ $ELEMENT not present"; 
                  echo ""
            else
                  echo "      ✅ OK: $ELEMENT"; 

            fi
      done
      export CHECK_NAME=""
}


export WAIOPS_NAMESPACE=$(oc get po -A|grep aimanager-operator |awk '{print$1}')
export EVTMGR_NAMESPACE=$(oc get po -A|grep noi-operator |awk '{print$1}')


CLUSTER_ROUTE=$(oc get routes console -n openshift-console | tail -n 1 2>&1 ) 
CLUSTER_FQDN=$( echo $CLUSTER_ROUTE | awk '{print $2}')
CLUSTER_NAME=${CLUSTER_FQDN##*console.}


echo "  Initializing......"
























































#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# DO NOT EDIT BELOW
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



    echo "--------------------------------------------------------------------------------------------------------------------------------"
    echo " 🚀  Examining CP4WAIOPS AI Manager Installation for hints...." 
    echo "--------------------------------------------------------------------------------------------------------------------------------"

      echo ""
      echo ""
      echo "------------------------------------------------------------------------------------------------------------------------------------------------------"
      echo "🔎 Installed Openshift Operator Versions"
      echo "------------------------------------------------------------------------------------------------------------------------------------------------------"
      oc get -n $WAIOPS_NAMESPACE ClusterServiceVersion
      echo "------------------------------------------------------------------------------------------------------------------------------------------------------"


    

      echo ""
      echo ""
      echo "--------------------------------------------------------------------------------------------"
      echo "🔎 Pods not ready in Namespace ibm-common-services"
      echo "--------------------------------------------------------------------------------------------"

      oc get pods -n ibm-common-services | grep -v "Completed" | grep "0/"


      echo ""
      echo ""
      echo "--------------------------------------------------------------------------------------------"
      echo "🔎 Pods not ready in Namespace $WAIOPS_NAMESPACE"
      echo "--------------------------------------------------------------------------------------------"

      oc get pods -n $WAIOPS_NAMESPACE | grep -v "Completed"| grep -v "Error" | grep "0/"


      echo ""
      echo ""
      echo "--------------------------------------------------------------------------------------------"
      echo "🔎 Pods not ready in Namespace $EVTMGR_NAMESPACE"
      echo "--------------------------------------------------------------------------------------------"

      oc get pods -n $EVTMGR_NAMESPACE | grep -v "Completed"| grep -v "Error" | grep "0/"


      echo ""
      echo ""
      echo "--------------------------------------------------------------------------------------------"
      echo "🔎 Pods with Image Pull Errors in Namespace $WAIOPS_NAMESPACE"
      echo "--------------------------------------------------------------------------------------------"

      export IMG_PULL_ERROR=$(oc get pods -n $WAIOPS_NAMESPACE | grep "ImagePull")

      if  ([[ ! $IMG_PULL_ERROR == "" ]]); 
      then 
            echo "      ⭕ There are Image Pull Errors:"; 
            echo "$IMG_PULL_ERROR"
            echo ""
            echo ""

            echo "      🔎 Check your Pull Secrets:"; 
            echo ""
            echo ""
            echo "ibm-entitlement-key Pull Secret"
            oc get secret/ibm-entitlement-key -n $WAIOPS_NAMESPACE --template='{{index .data ".dockerconfigjson" | base64decode}}'

            echo ""
            echo ""
            echo "ibm-aiops-pull-secret Pull Secret"
            oc get secret/ibm-aiops-pull-secret -n $WAIOPS_NAMESPACE --template='{{index .data ".dockerconfigjson" | base64decode}}'

      else
            echo "      ✅ OK: All images can be pulled"; 
      fi




      echo ""
      echo ""
      echo "--------------------------------------------------------------------------------------------"
      echo "🔎 Check ZEN Operator"
      echo "--------------------------------------------------------------------------------------------"

      export ZEN_LOGS=$(oc logs $(oc get po -n ibm-common-services|grep ibm-zen-operator|awk '{print$1}') -n ibm-common-services)
      export ZEN_ERRORS=$(echo $ZEN_LOGS|grep -i error)
      export ZEN_FAILED=$(echo $ZEN_LOGS|grep -i "failed=0")
      export ZEN_READY=$(echo $ZEN_LOGS|grep -i "ok=2")

      if  ([[ $ZEN_FAILED == "" ]]); 
      then 
            echo "      ⭕ Zen has errors"; 
            echo "$ZEN_ERRORS"
            echo ""
      else
            if  ([[ $ZEN_READY == "" ]]); 
            then 
                  echo "      ⭕ Zen Operator is still running"; 
                  echo ""
            else
                  echo "      ✅ OK: ZEN Operator has run successfully"; 
            fi
      fi




      echo ""
      echo ""
      echo "--------------------------------------------------------------------------------------------"
      echo "🔎 Check Topology"
      echo "--------------------------------------------------------------------------------------------"

      CP4AIOPS_CHECK_LIST=(
      "aiops-topology-merge"
      "aiops-topology-status"
      "aiops-topology-topology")
      for ELEMENT in ${CP4AIOPS_CHECK_LIST[@]}; do
        echo "   Check $ELEMENT.."
            ELEMENT_OK=$(oc get pod -n $WAIOPS_NAMESPACE --ignore-not-found | grep $ELEMENT || true) 
            if  ([[ ! $ELEMENT_OK =~ "1/1" ]]); 
            then 
                  echo "      ⭕ Pod $ELEMENT not runing successfully"; 
                  echo ""
            else
                  echo "      ✅ OK: Pod $ELEMENT"; 

            fi

      done




      echo ""
      echo ""
      echo "--------------------------------------------------------------------------------------------"
      echo "🔎 Check Routes"
      echo "--------------------------------------------------------------------------------------------"



      ROUTE_OK=$(oc get route job-manager -n $WAIOPS_NAMESPACE || true) 
      if  ([[ ! $ROUTE_OK =~ "job-manager" ]]); 
      then 
            echo "      ⭕ job-manager Route does not exist"; 
            echo "      ⭕ (You may want to run option: 12  - Recreate custom Routes)";  
            echo ""
      else
            echo "      ✅ OK: job-manager Route exists"; 
      fi

  
      echo ""
      echo ""
      echo "--------------------------------------------------------------------------------------------"
      echo "🔎 Clean-up Pods (if you get 'error: resource(s) were provided' you're good)"
      echo "--------------------------------------------------------------------------------------------"
      echo "      ❎ Clean-up errored Pods in $WAIOPS_NAMESPACE"
      oc delete pod $(oc get po -n $WAIOPS_NAMESPACE|grep "Error"|grep "0/"|awk '{print$1}') -n $WAIOPS_NAMESPACE --ignore-not-found
      echo ""
      echo "      ❎ Clean-up errored Pods in $EVTMGR_NAMESPACE"
      oc delete pod $(oc get po -n $EVTMGR_NAMESPACE|grep "Error"|grep "0/"|awk '{print$1}') -n $EVTMGR_NAMESPACE --ignore-not-found
      echo ""
      echo "      ❎ Clean-up stuck Pods in $WAIOPS_NAMESPACE"
      oc delete pod $(oc get po -n $WAIOPS_NAMESPACE|grep -v "Completed"|grep "0/"|awk '{print$1}') -n $WAIOPS_NAMESPACE --ignore-not-found
      echo ""
      echo "      ❎ Clean-up stuck Pods in $EVTMGR_NAMESPACE"
      oc delete pod $(oc get po -n $EVTMGR_NAMESPACE|grep -v "Completed"|grep "0/"|awk '{print$1}') -n $EVTMGR_NAMESPACE --ignore-not-found



      echo ""
      echo ""
      echo "--------------------------------------------------------------------------------------------"
      echo "🔎 Check Error Events"
      echo "--------------------------------------------------------------------------------------------"
      oc get events -A|grep -v Normal