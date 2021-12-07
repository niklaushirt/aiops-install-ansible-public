

echo "         ***************************************************************************************************************************************"
echo "           ️  Getting exising Indexes"
echo "         ***************************************************************************************************************************************"

export existingIndexes=$(curl -s -k -u $username:$password -XGET https://localhost:9200/_cat/indices)


if [[ $existingIndexes == "" ]] ;
then
    echo "        ❗ Please start port forward in separate terminal."
    echo "        ❗ Run the following:"
    echo "            while true; do oc port-forward statefulset/iaf-system-elasticsearch-es-aiops 9200; done"
    echo "        ❌ Aborting..."
    echo "     "
    echo "     "
    echo "     "
    echo "     "
    exit 1
fi
echo "           ✅ OK"
echo "     "
echo "     "



export NODE_TLS_REJECT_UNAUTHORIZED=0

for actFile in $(ls -1 $WORKING_DIR_ES | grep "json");
do
    
    echo "         ***************************************************************************************************************************************"
    echo "             🛠️  Uploading Index: ${actFile%".json"}"
    echo "         ***************************************************************************************************************************************"
    
    if [[ $existingIndexes =~ "${actFile%".json"}" ]] ;
    then
        curl -k -u $username:$password -XGET https://localhost:9200/_cat/indices | grep ${actFile%".json"} | sort
        echo "     ⚠️  Index already exist in Cluster."
        read -p " ❗❓ Append or Replace? [r,A] " DO_COMM
        if [[ $DO_COMM == "r" ||  $DO_COMM == "R" ]]; then
            read -p " ❗❓ Are you sure that you want to delete and replace the Index? [y,N] " DO_COMM
            if [[ $DO_COMM == "y" ||  $DO_COMM == "Y" ]]; then
                echo "        ✅ Ok, continuing..."
                echo "     "
                echo "     "
                echo "         ***************************************************************************************************************************************"
                echo "             ❌  Deleting Index: ${actFile%".json"}"
                echo "         ***************************************************************************************************************************************"
                curl -k -u $username:$password -XDELETE https://$username:$password@localhost:9200/${actFile%".json"}
                echo "     "
                echo "     "
                
            else
                echo "        ❌ Aborted"
                exit 1
            fi
            
        else
            echo "        ✅ Ok, continuing..."
        fi
        
    fi
    
    
    
    elasticdump --input="$WORKING_DIR_ES/${actFile}" --output=https://$username:$password@localhost:9200/${actFile%".json"} --type=data --limit=1000;
    echo "        ✅  OK"
done

echo "     ***************************************************************************************************************************************"
echo "     ***************************************************************************************************************************************"
echo "           🛠️  Getting all Indexes"
echo "     ***************************************************************************************************************************************"
curl -k -u $username:$password -XGET https://localhost:9200/_cat/indices | sort
echo "     ***************************************************************************************************************************************"
echo "     ***************************************************************************************************************************************"






echo "     "
echo "     "
echo "     "
echo "     "
echo "     ***************************************************************************************************************************************"
echo "     ***************************************************************************************************************************************"
echo "     "
echo "      🚀  CP4WAIOPS Load \"$INDEX_TYPE\" Indexes for $APP_NAME"
echo "      ✅  Done..... "
echo "     "
echo "     ***************************************************************************************************************************************"
echo "     ***************************************************************************************************************************************"


