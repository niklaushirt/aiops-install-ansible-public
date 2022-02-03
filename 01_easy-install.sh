#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#       __________  __ ___       _____    ________            
#      / ____/ __ \/ // / |     / /   |  /  _/ __ \____  _____
#     / /   / /_/ / // /| | /| / / /| |  / // / / / __ \/ ___/
#    / /___/ ____/__  __/ |/ |/ / ___ |_/ // /_/ / /_/ (__  ) 
#    \____/_/      /_/  |__/|__/_/  |_/___/\____/ .___/____/  
#                                              /_/            
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------------------------------"
#  CP4WAIOPS 3.2 - CP4WAIOPS Installation
#
#
#  ©2022 nikh@ch.ibm.com
# ---------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------"
clear

echo "*****************************************************************************************************************************"
echo "*****************************************************************************************************************************"
echo "*****************************************************************************************************************************"
echo "*****************************************************************************************************************************"
echo "  "
echo "  🐥 CloudPak for Watson AIOps 3.2 - Easy Install"
echo "  "
echo "*****************************************************************************************************************************"
echo "*****************************************************************************************************************************"
echo "*****************************************************************************************************************************"
echo "  "
echo "  "





while getopts "t:v:r:hc:" opt
do
    case "$opt" in
        t ) INPUT_TOKEN="$OPTARG" ;;
        v ) VERBOSE="$OPTARG" ;;
        r ) REPLACE_INDEX="$OPTARG" ;;
        h ) HELP_USAGE=true ;;

    esac
done


    
if [[ $HELP_USAGE ]];
then
    echo " USAGE: $0 [-t <REGISTRY_TOKEN>] [-v true] [-r true]"
    echo "  "
    echo "     -t  Provide registry pull token              <REGISTRY_TOKEN> "
    echo "     -v  Verbose mode                             true/false"
    echo "     -r  Replace indexes if they already exist    true/false"

    exit 1
fi



if [[ $INPUT_TOKEN == "" ]];
then
    echo " 🔐  Token                               Not Provided (will be asked during installation)"
else
    echo " 🔐  Token                               Provided"
    export ENTITLED_REGISTRY_KEY=$INPUT_TOKEN
fi


if [[ $VERBOSE ]];
then
    echo " ✅  Verbose Mode                        On"
    export ANSIBLE_DISPLAY_SKIPPED_HOSTS=true
    export VERBOSE="-v"
else
    echo " ❎  Verbose Mode                        Off          (enable it by appending '-v true')"
    export ANSIBLE_DISPLAY_SKIPPED_HOSTS=false
    export VERBOSE=""
fi


if [[ $REPLACE_INDEX ]];
then
    echo " ❌  Replace existing Indexes            On ❗         (existing training indexes will be replaced/reloaded)"
    export SILENT_SKIP=false
else
    echo " ✅  Replace existing Indexes            Off          (default - enable it by appending '-r true')"
    export SILENT_SKIP=true

fi
echo ""
echo ""


export TEMP_PATH=~/aiops-install

# ---------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------"
# Do Not Edit Below
# ---------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------"

echo ""
echo ""
echo ""
echo ""
echo "--------------------------------------------------------------------------------------------"
echo " 🐥  Initializing..." 
echo "--------------------------------------------------------------------------------------------"
echo ""

printf "\r  🥚🥚🥚🥚🥚🥚🥚🥚🥚🥚🥚🥚🥚 - Checking Command Line Tools                                  "

if [ ! -x "$(command -v oc)" ]; then
      echo "❌ Openshift Client not installed."
      echo "   🚀 Install prerequisites with ./ansible/scripts/02-prerequisites-mac.sh or ./ansible/scripts/03-prerequisites-ubuntu.sh"
      echo "❌ Aborting...."
      exit 1
fi
if [ ! -x "$(command -v jq)" ]; then
      echo "❌ jq not installed."
      echo "   🚀 Install prerequisites with ./ansible/scripts/02-prerequisites-mac.sh or ./ansible/scripts/03-prerequisites-ubuntu.sh"
      echo "❌ Aborting...."
      exit 1
fi
if [ ! -x "$(command -v ansible-playbook)" ]; then
      echo "❌ Ansible not installed."
      echo "   🚀 Install prerequisites with ./ansible/scripts/02-prerequisites-mac.sh or ./ansible/scripts/03-prerequisites-ubuntu.sh"
      echo "❌ Aborting...."
      exit 1
fi
if [ ! -x "$(command -v cloudctl)" ]; then
      echo "❌ cloudctl not installed."
      echo "   🚀 Install prerequisites with ./ansible/scripts/02-prerequisites-mac.sh or ./ansible/scripts/03-prerequisites-ubuntu.sh"
      echo "❌ Aborting...."
      exit 1
fi

printf "\r  🐣🥚🥚🥚🥚🥚🥚🥚🥚🥚🥚🥚🥚 - Getting Cluster Status                                       "
export CLUSTER_STATUS=$(oc status | grep "In project")
printf "\r  🐥🐣🥚🥚🥚🥚🥚🥚🥚🥚🥚🥚🥚 - Getting Cluster User                                         "

export CLUSTER_WHOAMI=$(oc whoami)

if [[ ! $CLUSTER_STATUS =~ "In project" ]]; then
      echo "❌ You are not logged into a Openshift Cluster."
      echo "❌ Aborting...."
      exit 1
else
      printf "\r ✅ $CLUSTER_STATUS as user $CLUSTER_WHOAMI\n\n"

fi


printf "  🐥🐥🐣🥚🥚🥚🥚🥚🥚🥚🥚🥚 - Getting AI Manager Namespace                                    "
export WAIOPS_NAMESPACE=$(oc get po -A|grep aimanager-operator |awk '{print$1}')
printf "\r  🐥🐥🐥🐣🥚🥚🥚🥚🥚🥚🥚🥚 -  Getting Event Manager Namespace                              "
export EVTMGR_NAMESPACE=$(oc get po -A|grep noi-operator |awk '{print$1}')
printf "\r  🐥🐥🐥🐥🐣🥚🥚🥚🥚🥚🥚🥚 - Getting RobotShop Status                                      "
export RS_NAMESPACE=$(oc get ns robot-shop  --ignore-not-found|awk '{print$1}')
printf "\r  🐥🐥🐥🐥🐥🐣🥚🥚🥚🥚🥚🥚 - Getting Turbonomic Status                                     "
export TURBO_NAMESPACE=$(oc get ns turbonomic  --ignore-not-found|awk '{print$1}')
printf "\r  🐥🐥🐥🐥🐥🐥🐣🥚🥚🥚🥚🥚 - Getting AWX Status                                            "
export AWX_NAMESPACE=$(oc get ns awx  --ignore-not-found|awk '{print$1}')
printf "\r  🐥🐥🐥🐥🐥🐥🐥🐣🥚🥚🥚🥚 - Getting LDAP Status                                           "
export LDAP_NAMESPACE=$(oc get po -n default --ignore-not-found| grep ldap |awk '{print$1}')
printf "\r  🐥🐥🐥🐥🐥🐥🐥🐥🐣🥚🥚🥚 - Getting Demo UI Status                                       "
export DEMO_NAMESPACE=$(oc get po -A|grep demo-ui- |awk '{print$1}')
printf "\r  🐥🐥🐥🐥🐥🐥🐥🐥🐥🐣🥚🥚 - Getting ELK Status                                            "
export ELK_NAMESPACE=$(oc get ns openshift-logging  --ignore-not-found|awk '{print$1}')
printf "\r  🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐣🥚 - Getting Istio Status                                          "
export ISTIO_NAMESPACE=$(oc get ns istio-logging  --ignore-not-found|awk '{print$1}')
printf "\r  🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐣 - Getting Humio Status                                          "
export HUMIO_NAMESPACE=$(oc get ns humio-logging  --ignore-not-found|awk '{print$1}')
printf "\r  🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥 - Done ✅                                                        "





# ------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------
# Patch IAF Resources for ROKS
# ------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------
menu_INSTALL_AIMGR () {
      echo "--------------------------------------------------------------------------------------------"
      echo " 🚀  Install CP4WAIOPS AI Manager" 
      echo "--------------------------------------------------------------------------------------------"
      echo ""

      # Check if already installed
      if [[  $WAIOPS_NAMESPACE == "" ]]; then
            echo "⚠️  CP4WAIOPS AI Manager seems to be installed already"

            read -p "   Are you sure you want to continue❓ [y,N] " DO_COMM
            if [[ $DO_COMM == "y" ||  $DO_COMM == "Y" ]]; then
                  echo ""
                  echo "   ✅ Ok, continuing..."
                  echo ""
            else
                  echo ""
                  echo "    ❌  Aborting"
                  echo "--------------------------------------------------------------------------------------------"
                  echo  ""    
                  echo  ""
                  return
            fi
      fi

      #Get Pull Token
      if [[ $ENTITLED_REGISTRY_KEY == "" ]];
      then
            echo ""
            echo ""
            echo "  Enter CP4WAIOPS Pull token: "
            read TOKEN
      else
            TOKEN=$ENTITLED_REGISTRY_KEY
      fi

      echo ""
      echo "  🔐 You have provided the following Token:"
      echo "    "$TOKEN
      echo ""

      # Install
      read -p "  Are you sure that this is correct❓ [y,N] " DO_COMM
      if [[ $DO_COMM == "y" ||  $DO_COMM == "Y" ]]; then
            read -p "  Do you want to install demo content (highly recommended - OpenLdap and RobotShop)❓ [Y,n] " DO_COMM
            if [[ $DO_COMM == "n" ||  $DO_COMM == "N" ]]; then
                  echo ""
                  echo "   ✅ Ok, continuing without demo content..."
                  echo ""
                  echo ""
                  echo "--------------------------------------------------------------------------------------------"
                  echo " ❗  Installation can take up to one hour!" 
                  echo "--------------------------------------------------------------------------------------------"

                  echo ""
                  cd ansible
                  ansible-playbook -e ENTITLED_REGISTRY_KEY=$TOKEN 10_install-cp4waiops_ai_manager_only
                  cd -
            else
                  echo ""
                  echo "   ✅ Ok, continuing with demo content..."
                  echo ""
                  echo ""

                  echo ""

                  cd ansible
                  ansible-playbook -e ENTITLED_REGISTRY_KEY=$TOKEN 10_install-cp4waiops_ai_manager_only_with_demo.yaml
                  cd -

            fi
      else
            echo "    ⚠️  Skipping"
            echo "--------------------------------------------------------------------------------------------"
            echo  ""    
            echo  ""
      fi
}




menu_INSTALL_EVTMGR () {
      echo "--------------------------------------------------------------------------------------------"
      echo " 🚀  Install CP4WAIOPS Event Manager" 
      echo "--------------------------------------------------------------------------------------------"
      echo ""

      # Check if already installed
      if [[ ! $EVTMGR_NAMESPACE == "" ]]; then
            echo "⚠️  CP4WAIOPS Event Manager seems to be installed already"

            read -p "   Are you sure you want to continue❓ [y,N] " DO_COMM
            if [[ $DO_COMM == "y" ||  $DO_COMM == "Y" ]]; then
                  echo ""
                  echo "   ✅ Ok, continuing..."
                  echo ""
            else
                  echo ""
                  echo "    ❌  Aborting"
                  echo "--------------------------------------------------------------------------------------------"
                  echo  ""    
                  echo  ""
                  return
            fi

      fi

      #Get Pull Token
      if [[ $ENTITLED_REGISTRY_KEY == "" ]];
      then
            echo ""
            echo ""
            echo "  Enter CP4WAIOPS Pull token: "
            read TOKEN
      else
            TOKEN=$ENTITLED_REGISTRY_KEY
      fi

      # Install
      echo ""
      echo "  🔐 You have provided the following Token:"
      echo "    "$TOKEN
      echo ""
      read -p "  Are you sure that this is correct❓ [y,N] " DO_COMM
      if [[ $DO_COMM == "y" ||  $DO_COMM == "Y" ]]; then
            echo "   ✅ Ok, continuing..."
            echo ""
            echo ""
            echo "--------------------------------------------------------------------------------------------"
            echo " ❗  Installation can take up to 40 mins!" 
            echo "--------------------------------------------------------------------------------------------"
            echo ""
            cd ansible
            ansible-playbook -e ENTITLED_REGISTRY_KEY=$TOKEN 11_install-cp4waiops_event_manager.yaml
            cd -

      else
            echo "    ⚠️  Skipping"
            echo "--------------------------------------------------------------------------------------------"
            echo  ""    
            echo  ""
      fi


}




menuTRAIN_AIOPSDEMO () {
      echo "--------------------------------------------------------------------------------------------"
      echo " 🚀  Start CP4WAIOPS Demo Training (skip)" 
      echo "--------------------------------------------------------------------------------------------"
      echo ""
     ./55_train-robotshop.sh
}




menuLOAD_TOPOLOGY () {
      echo "--------------------------------------------------------------------------------------------"
      echo " 🚀  Load RobotShop Topology for AI Manager Demo" 
      echo "--------------------------------------------------------------------------------------------"
      echo ""

     ./51_load_robotshop_topology_aimanager.sh
}

menuLOAD_TOPOLOGYNOI () {
      echo "--------------------------------------------------------------------------------------------"
      echo " 🚀  Load RobotShop Topology for Event Manager Demo" 
      echo "--------------------------------------------------------------------------------------------"
      echo ""

     ./52_load_robotshop_topology_eventmanager.sh
}


menu_INSTALL_AIOPSDEMO () {
      echo "--------------------------------------------------------------------------------------------"
      echo " 🚀  Install CP4WAIOPSDemoUI" 
      echo "--------------------------------------------------------------------------------------------"
      echo ""

      cd ansible
      ansible-playbook 18_aiops-demo-ui.yaml
      cd -

}


menu_INSTALL_ROBOTSHOP () {
      echo "--------------------------------------------------------------------------------------------"
      echo " 🚀  Install RobotShop" 
      echo "--------------------------------------------------------------------------------------------"
      echo ""

      cd ansible
      ansible-playbook 18_install-robot-shop.yaml
      cd -
}


menu_INSTALL_LDAP () {
      echo "--------------------------------------------------------------------------------------------"
      echo " 🚀  Install LDAP" 
      echo "--------------------------------------------------------------------------------------------"
      echo ""

      cd ansible
      ansible-playbook 18_install-ldap.yaml
      cd -
}

menu_INSTALL_TURBO () {
      echo "--------------------------------------------------------------------------------------------"
      echo " 🚀  Install Turbonomic" 
      echo "--------------------------------------------------------------------------------------------"
      echo ""

      cd ansible
      ansible-playbook 20_install-turbonomic.yaml
      cd -
}


menu_INSTALL_AWX () {
      echo "--------------------------------------------------------------------------------------------"
      echo " 🚀  Install AWX" 
      echo "--------------------------------------------------------------------------------------------"
      echo ""

      cd ansible
      ansible-playbook 23_install-awx.yaml
      cd -
}




menu_INSTALL_ELK () {
      echo "--------------------------------------------------------------------------------------------"
      echo " 🚀  Install OpenShift Logging" 
      echo "--------------------------------------------------------------------------------------------"
      echo ""

      cd ansible
      ansible-playbook 22_install-elk-ocp.yaml
      cd -
}



menu_INSTALL_ISTIO () {
      echo "--------------------------------------------------------------------------------------------"
      echo " 🚀  Install OpenShift Mesh" 
      echo "--------------------------------------------------------------------------------------------"
      echo ""

      cd ansible
      ansible-playbook 29_install-servicemesh.yaml
      cd -
}



menu_INSTALL_HUMIO () {
      echo "--------------------------------------------------------------------------------------------"
      echo " 🚀  Install Humio" 
      echo "--------------------------------------------------------------------------------------------"
      echo ""
      if [[ ! $HUMIO_NAMESPACE == "" ]]; then
            echo "❗⚠️ Humio seems to be installed already"

            read -p " ❗❓ Are you sure you want to continue? [y,N] " DO_COMM
            if [[ $DO_COMM == "y" ||  $DO_COMM == "Y" ]]; then
                  echo "   ✅ Ok, continuing..."
                  echo ""
                  echo ""

            else
                  echo "    ❌ Aborting"
                  echo "--------------------------------------------------------------------------------------------"
                  echo  ""    
                  echo  ""
                  exit 1
            fi

      fi

      echo ""
      echo ""
      echo "  Enter Humio License: "
      read TOKEN
      echo ""
      echo "You have entered the following license:"
      echo $TOKEN
      echo ""
      read -p " ❗❓ Are you sure that this is correct? [y,N] " DO_COMM
      if [[ $DO_COMM == "y" ||  $DO_COMM == "Y" ]]; then
            echo "   ✅ Ok, continuing..."
            echo ""
            echo ""

cd ansible
ansible-playbook -e HUMIO_LICENSE_KEY=$TOKEN 21_install-humio.yaml
cd -
            

      else
            echo "    ⚠️  Skipping"
            echo "--------------------------------------------------------------------------------------------"
            echo  ""    
            echo  ""
      fi
}



incorrect_selection() {
      echo "--------------------------------------------------------------------------------------------"
      echo " ❗ This option does not exist!" 
      echo "--------------------------------------------------------------------------------------------"
}


clear

echo "*****************************************************************************************************************************"
echo "*****************************************************************************************************************************"
echo "      __________  __ ___       _____    ________            "
echo "     / ____/ __ \/ // / |     / /   |  /  _/ __ \____  _____"
echo "    / /   / /_/ / // /| | /| / / /| |  / // / / / __ \/ ___/"
echo "   / /___/ ____/__  __/ |/ |/ / ___ |_/ // /_/ / /_/ (__  ) "
echo "   \____/_/      /_/  |__/|__/_/  |_/___/\____/ .___/____/  "
echo "                                             /_/            "
echo ""
echo "*****************************************************************************************************************************"
echo " 🐥 CloudPak for Watson AIOPs - EASY INSTALL"
echo "*****************************************************************************************************************************"
echo "  "
echo "  ℹ️  This script provides different options to install CP4WAIOPS demo environments through Ansible"
echo ""
echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "   🗄️  Using Parameters"
echo "   ------------------------------------------------------------------------------------------------------------------------------"


if [[ $ENTITLED_REGISTRY_KEY == "" ]];
then
echo "      🔐 Image Pull Token:          Not Provided (will be asked during installation)"
else
echo "      🔐 Image Pull Token:          Provided"
fi

echo "      🌏 Namespace:                 $WAIOPS_NAMESPACE"	
echo "      💾 Skip Data Load if exists:  $SILENT_SKIP"	
echo "      🔎 Verbose Mode:              $ANSIBLE_DISPLAY_SKIPPED_HOSTS"


echo "  "
echo "*****************************************************************************************************************************"
echo "*****************************************************************************************************************************"
echo "  "




until [ "$selection" = "0" ]; do
  



      echo "  🐥 CP4WAIOPS - Base Install"
      if [[ $WAIOPS_NAMESPACE == "" ]]; then
            echo "      11  - Install AI Manager                                      - Install CP4WAIOPS AI Manager Component"
      else
            echo "      ✅  - Install AI Manager                                      "
      fi

      if [[ $EVTMGR_NAMESPACE == "" ]]; then
            echo "      12  - Install Event Manager                                   - Install CP4WAIOPS Event Manager Component"
      else
            echo "      ✅  - Install Event Manager                                   "
      fi

      echo "  "
      echo "  "
      echo "  🐥 Solutions"
      if [[ $TURBO_NAMESPACE == "" ]]; then
            echo "      21  - Install Turbonomic                                      - Install Turbonomic (needs a separate license)"
      else
            echo "      ✅  - Install Turbonomic                                      "
      fi

      if [[  $HUMIO_NAMESPACE == "" ]]; then
            echo "      22  - Install Humio                                           - Install Humio (needs a separate license)"
      else
            echo "      ✅  - Install Humio                                           "
      fi


      if [[  $AWX_NAMESPACE == "" ]]; then
            echo "      23  - Install AWX                                             - Install AWX (open source Ansible Tower)"
      else
            echo "      ✅  - Install AWX                                             "
      fi

      if [[  $ISTIO_NAMESPACE == "" ]]; then
            echo "      24  - Install OpenShift Mesh                                  - Install OpenShift Mesh (Istio)"
            else
            echo "      ✅  - Install OpenShift Mesh                                  "
            fi



      if [[  $ISTIO_NAMESPACE == "" ]]; then
            echo "      25  - Install OpenShift Logging                               - Install OpenShift Logging (ELK)"
            else
            echo "      ✅  - Install OpenShift Logging                                 "
            fi



      echo "  "
      echo "  "
      echo "  🐥 CP4WAIOPS Addons"
      if [[  $DEMO_NAMESPACE == "" ]]; then
            echo "      31  - Install CP4WAIOPS Demo Application                      - Install CP4WAIOPS Demo Application"
      else
            echo "      ✅  - Install CP4WAIOPS Demo Application                      "
      fi

      if [[  $LDAP_NAMESPACE == "" ]]; then
            echo "      32  - Install OpenLdap                                        - Install OpenLDAP for CP4WAIOPS (should be installed by option 10)"
      else
            echo "      ✅  - Install OpenLdap                                        "
      fi

      if [[  $RS_NAMESPACE == "" ]]; then
            echo "      33  - Install RobotShop                                       - Install RobotShop for CP4WAIOPS (should be installed by option 10)"
      else
            echo "      ✅  - Install RobotShop                                       "
      fi

            #       echo "    	25  - Install OpenShift Logging                               - Install OpenShift Logging (ELK)"
      echo "  "
      echo "  "
      echo "  🐥 Demo Configuration"
      echo "      51  - AI Manager Topology                                      - Create RobotShop Topology for AI Manager"
      echo "      52  - Event Manager Topology                                   - Create RobotShop Topology for AI Manager"
      echo "      55  - Train RobotShop Models                                   - Loads training data, creates definitions and launches training (skip if index exists: $SILENT_SKIP)"
      echo "  "

      echo "  "
      echo "  🐥 Prerequisites Install"
      echo "      81  - Install Prerequisites Mac                                - Install Prerequisites for Mac"
      echo "      82  - Install Prerequisites Ubuntu                             - Install Prerequisites for Ubuntu"
      echo "  "

      echo "  "
      echo "  🐥 Infos"
      echo "      91  - Get logins                                               - Get logins for all installed components"
      echo "      92  - Write logins to file                                     - Write logins for all installed components to file LOGIN.txt"
      echo "  "

  echo "      "
  echo "      "
  echo "      "
  echo "    	0  -  Exit"
  echo ""
  echo ""
  echo "  Enter selection: "
  read selection
  echo ""
  case $selection in
    11 ) clear ; menu_INSTALL_AIMGR  ;;
    12 ) clear ; menu_INSTALL_EVTMGR  ;;

    21 ) clear ; menu_INSTALL_TURBO  ;;
    22 ) clear ; menu_INSTALL_HUMIO  ;;
    23 ) clear ; menu_INSTALL_AWX  ;;
    24 ) clear ; menu_INSTALL_ISTIO  ;;
    25 ) clear ; menu_INSTALL_ELK  ;;

    31 ) clear ; menu_INSTALL_AIOPSDEMO  ;;
    32 ) clear ; menu_INSTALL_LDAP  ;;
    33 ) clear ; menu_INSTALL_ROBOTSHOP  ;;

    51 ) clear ; menuLOAD_TOPOLOGY  ;;
    52 ) clear ; menuLOAD_TOPOLOGYNOI  ;;
    55 ) clear ; menuTRAIN_AIOPSDEMO  ;;


    81 ) clear ; ./ansible/scripts/02-prerequisites-mac.sh  ;;
    82 ) clear ; ./ansible/scripts/03-prerequisites-ubuntu.sh  ;;

    91 ) clear ; ./tools/20_get_logins.sh  ;;
    92 ) clear ; ./tools/20_get_logins.sh > LOGINS.txt  ;;


    0 ) clear ; exit ;;
    * ) clear ; incorrect_selection  ;;
  esac
  read -p "Press Enter to continue..."
  clear 
done


