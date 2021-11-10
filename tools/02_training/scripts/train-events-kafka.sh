#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# DO NOT MODIFY BELOW
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

echo "   __________  __ ___       _____    ________            "
echo "  / ____/ __ \/ // / |     / /   |  /  _/ __ \____  _____"
echo " / /   / /_/ / // /| | /| / / /| |  / // / / / __ \/ ___/"
echo "/ /___/ ____/__  __/ |/ |/ / ___ |_/ // /_/ / /_/ (__  ) "
echo "\____/_/      /_/  |__/|__/_/  |_/___/\____/ .___/____/  "
echo "                                          /_/            "
echo ""
echo ""
echo "***************************************************************************************************************************************"
echo "***************************************************************************************************************************************"
echo ""
echo " 🚀  CP4WAIOPS Train Events for $APP_NAME"
echo ""
echo "***************************************************************************************************************************************"


#--------------------------------------------------------------------------------------------------------------------------------------------
#  Check Defaults
#--------------------------------------------------------------------------------------------------------------------------------------------

if [ -x "$(command -v kafkacat)" ]; then
      export KAFKACAT_EXE=kafkacat
      echo "  ✅  OK - kafkacat installed"
else
      if [ -x "$(command -v kcat)" ]; then
      export KAFKACAT_EXE=kcat
            echo "  ✅  OK - kcat installed"
      else
            echo "  ❗ ERROR: kafkacat is not installed."
            echo "  ❌ Aborting..."
            exit 1
      fi
fi

if [[ $APP_NAME == "" ]] ;
then
      echo "⚠️ AppName not defined. Launching this script directly?"
      echo "❌ Aborting..."
      exit 1
fi



#--------------------------------------------------------------------------------------------------------------------------------------------
#  Get Credentials
#--------------------------------------------------------------------------------------------------------------------------------------------

echo "***************************************************************************************************************************************"
echo "  🔐  Getting credentials"
echo "***************************************************************************************************************************************"
oc project $WAIOPS_NAMESPACE 

if [[ $EVENTS_TOPIC == "" ]] ;
then
      echo "      🔎 Getting Kafka Log Integration"
      export EVENTS_TOPIC=$(oc get kafkatopics -n $WAIOPS_NAMESPACE | grep alerts-$EVENTS_TYPE| awk '{print $1;}')
      export EVENTS_TOPIC_COUNT=$(echo $EVENTS_TOPIC | wc -w)

      if [[ $EVENTS_TOPIC_COUNT -gt 1 ]] ;
      then
            echo "⚠️  There are several integrations for log type $EVENTS_TYPE:"
            echo "$EVENTS_TOPIC"
            echo "⚠️  Please get the topic name from AI Hub and override EVENTS_TOPIC in the calling script."
            echo "❌ Aborting..."
            exit 1
      else 
       echo "      ✅ OK - Events Topic is: $EVENTS_TOPIC"           
      fi

else
      echo "      ✅ OK - Events Topic defined in calling script: $EVENTS_TOPIC"
fi


export SASL_USER=$(oc get secret ibm-aiops-kafka-secret -n $WAIOPS_NAMESPACE --template={{.data.username}} | base64 --decode)
export SASL_PASSWORD=$(oc get secret ibm-aiops-kafka-secret -n $WAIOPS_NAMESPACE --template={{.data.password}} | base64 --decode)
export KAFKA_BROKER=$(oc get routes iaf-system-kafka-0 -n $WAIOPS_NAMESPACE -o=jsonpath='{.status.ingress[0].host}{"\n"}'):443

export DATE_FORMAT="+%Y-%m-%dT%H:%M:%S"

export WORKING_DIR_EVENTS="./tools/02_training/TRAINING_FILES/KAFKA/$APP_NAME/events"

echo ""
echo ""


#--------------------------------------------------------------------------------------------------------------------------------------------
#  Get the cert for kafkacat
#--------------------------------------------------------------------------------------------------------------------------------------------
echo "***************************************************************************************************************************************"
echo "🥇 Getting Certs"
echo "***************************************************************************************************************************************"
mv ca.crt ca.crt.old
oc extract secret/kafka-secrets -n $WAIOPS_NAMESPACE --keys=ca.crt
echo "      ✅ OK"





#--------------------------------------------------------------------------------------------------------------------------------------------
#  Check Credentials
#--------------------------------------------------------------------------------------------------------------------------------------------

echo "***************************************************************************************************************************************"
echo "  🔗  Checking credentials"
echo "***************************************************************************************************************************************"



if [[ ! $KAFKA_BROKER =~ "iaf-system-kafka-0-$WAIOPS_NAMESPACE" ]] ;
then
      echo "      ❗ Kafka Broker not found..."
      echo "      ❌ Aborting..."
      exit 1
else
      echo "      ✅ OK - Kafka Broker"
fi

export EVENT_FILES=$(ls -1 $WORKING_DIR_EVENTS | grep "json")
if [[ $EVENT_FILES == "" ]] ;
then
      echo "      ❗ No found"
      echo "      ❗    No found to ingest in path $WORKING_DIR_EVENTS"
      echo "      ❗    Please unzip the demo events as described in the documentation of place your own in the directory."
      echo "      ❌ Aborting..."
      exit 1
else
      echo "      ✅ OK - Log Files"
fi



echo ""
echo ""
echo ""
echo ""


echo "***************************************************************************************************************************************"
echo "***************************************************************************************************************************************"
echo "  "
echo "  🔎  Parameter for Training"
echo "  "
echo "           🌏 Kafka Broker URL            : $KAFKA_BROKER"
echo "           🔐 Kafka Password              : $KAFKA_PASSWORD"
echo "  "
echo "           📅 Date Format                 : $(date $DATE_FORMAT) ($DATE_FORMAT)"
echo "  "
echo "  "
echo "           📂 Directory for Events        : $WORKING_DIR_EVENTS"
echo "  "
echo "***************************************************************************************************************************************"
echo "***************************************************************************************************************************************"
echo ""
echo ""
echo "***************************************************************************************************************************************"
echo "***************************************************************************************************************************************"
echo "  🗄️  Files to be loaded for Log Anomalies"
echo "***************************************************************************************************************************************"
ls -1 $WORKING_DIR_EVENTS | grep "json"
echo "  "
echo "  "
echo "***************************************************************************************************************************************"
echo "***************************************************************************************************************************************"

echo ""
echo ""



echo "***************************************************************************************************************************************"
echo "***************************************************************************************************************************************"
  read -p " ❗❓ Start Training? [y,N] " DO_COMM
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
echo "***************************************************************************************************************************************"
echo "***************************************************************************************************************************************"
echo ""
echo ""
echo ""
echo ""

#--------------------------------------------------------------------------------------------------------------------------------------------
#  Launch Log Injection as a parallel thread
#--------------------------------------------------------------------------------------------------------------------------------------------
echo "***************************************************************************************************************************************"
echo "***************************************************************************************************************************************"
echo " 🚀  Launching Log Anomaly Training" 
echo "***************************************************************************************************************************************"
echo "***************************************************************************************************************************************"
echo ""
echo ""
echo ""
echo ""

for actFile in $(ls -1 $WORKING_DIR_EVENTS | grep "json"); 
do 

#--------------------------------------------------------------------------------------------------------------------------------------------
#  Prepare the Log Data
#--------------------------------------------------------------------------------------------------------------------------------------------

      echo "***************************************************************************************************************************************"
      echo "  🛠️  Preparing Data for file $actFile"
      echo "***************************************************************************************************************************************"


      #--------------------------------------------------------------------------------------------------------------------------------------------
      #  Create file and structure in /tmp
      #--------------------------------------------------------------------------------------------------------------------------------------------
      mkdir /tmp/training-events/  
      rm /tmp/training-events/x* 
      cp $WORKING_DIR_EVENTS/$actFile /tmp/training-events/
      cd /tmp/training-events/

  
      #--------------------------------------------------------------------------------------------------------------------------------------------
      #  Split the files in 1500 line chunks for kafkacat
      #--------------------------------------------------------------------------------------------------------------------------------------------
      echo "    🔨 Splitting"
      split -l 1500 $actFile
      export NUM_FILES=$(ls | wc -l)
      rm $actFile
      cd -  
      echo "      ✅ OK"



      #--------------------------------------------------------------------------------------------------------------------------------------------
      #  Inject the Events
      #--------------------------------------------------------------------------------------------------------------------------------------------
      echo "***************************************************************************************************************************************"
      echo "🌏  Injecting Events from File: ${actFile}" 
      echo "     Quit with Ctrl-Z"
      echo "***************************************************************************************************************************************"
      ACT_COUNT=0
      for FILE in /tmp/training-events/*; do 
          if [[ $FILE =~ "x"  ]]; then
              ACT_COUNT=`expr $ACT_COUNT + 1`
              echo "Injecting file ($ACT_COUNT/$(($NUM_FILES-1))) - $FILE"
              ${KAFKACAT_EXE} -v -X security.protocol=SASL_SSL -X ssl.ca.location=./ca.crt -X sasl.mechanisms=SCRAM-SHA-512  -X sasl.username=$SASL_USER -X sasl.password=$SASL_PASSWORD -b $KAFKA_BROKER -P -t $EVENTS_TOPIC -l $FILE   
              echo "      ✅ OK"
          fi
      done
      rm /tmp/training-events/x*
done

#--------------------------------------------------------------------------------------------------------------------------------------------
#  Clean up
#--------------------------------------------------------------------------------------------------------------------------------------------

rm ./ca.crt

echo "***************************************************************************************************************************************"
echo ""
echo " ✅  Event Injection Done..... "
echo "     Hit ENTER if the command prompt does not appear"
echo ""
echo "***************************************************************************************************************************************"

echo ""
echo ""
echo ""
echo ""
echo "***************************************************************************************************************************************"
echo "***************************************************************************************************************************************"
echo ""
echo " 🚀  CP4WAIOPS Training"
echo " ✅  Done..... "
echo ""
echo "***************************************************************************************************************************************"
echo "***************************************************************************************************************************************"







echo ""
echo ""
echo ""
echo ""
echo "***************************************************************************************************************************************"
echo "***************************************************************************************************************************************"
echo ""
echo " 🚀  CP4WAIOPS Train Events for $APP_NAME"
echo " ✅  Done..... "
echo ""
echo "***************************************************************************************************************************************"
echo "***************************************************************************************************************************************"

