source scripts/.c.env
source scripts/.hlc.env
export CC_LABLNAME="${SAMPLE_CC,,}"
echo -e $PCOLOR"Commiting the chaincode : $org1, $org2 ..."$NONE
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.key
export CORE_PEER_LOCALMSPID=Org1MSP
export CORE_VM_ENDPOINT=unix:///host/var/run/docker.sock
export CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.crt
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ID=
export CORE_PEER_ADDRESS=peer0.org1.example.com:7051
export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer0.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

if [ "$IMAGE_TAG" == "2.2.0" ]; 
then 
#PEER_CONN_PARMS="$PEER_CONN_PARMS --peerAddresses $CORE_PEER_ADDRESS"
## Set path to TLS certificate
#TLSINFO=$(eval echo "--tlsRootCertFiles \$CORE_PEER_TLS_ROOTCERT_FILE")
#export PEER_CONN_PARMS="$PEER_CONN_PARMS $TLSINFO"
#echo $PEER_CONN_PARMS  
export PEER_CONN_PARMS="--peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt"
export PEER_CONN_PARMS1="--peerAddresses peer0.org2.example.com:9051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt"

peer lifecycle chaincode commit -o orderer0.example.com:7050 --tls --cafile $ORDERER_CA --channelID mychannel --name $CC_LABLNAME $PEER_CONN_PARMS $PEER_CONN_PARMS1 --version 1.0 --sequence 1 --signature-policy "OR('Org1MSP.peer', 'Org2MSP.peer')"
else
echo " Nothing for fabric 1.4x"
fi

echo -e $PCOLOR"Querying the Committed chaincode for ORGs "$NONE
peer lifecycle chaincode querycommitted --channelID mychannel --name $CC_LABLNAME --output json
#echo -e $PCOLOR"Querying the Committed chaincode for ORGs for SACC "$NONE
#peer lifecycle chaincode querycommitted --channelID mychannel --name sacc --output json

echo -e $PCOLOR"Invoking the chaincode for ORGs - First transaction "$NONE

if [ $SAMPLE_CC == "ASSETTRANSFER" ]; then 
    peer chaincode invoke -o orderer0.example.com:7050 --tls --cafile $ORDERER_CA -C mychannel -n $CC_LABLNAME $PEER_CONN_PARMS $PEER_CONN_PARMS1 -c '{"function":"InitLedger","Args":[]}'
elif [ $SAMPLE_CC == "SACC" ];then
    peer chaincode invoke -o orderer0.example.com:7050 --tls --cafile $ORDERER_CA -C mychannel -n $CC_LABLNAME $PEER_CONN_PARMS $PEER_CONN_PARMS1 -c '{"Args":["set","name","fabric-v2"]}'
elif [ $SAMPLE_CC == "ABSTORE" ]; then
    peer chaincode invoke -o orderer0.example.com:7050 --tls --cafile $ORDERER_CA -C mychannel -n $CC_LABLNAME $PEER_CONN_PARMS $PEER_CONN_PARMS1 -c '{"Args":["set","a","10","b","20"]}'
elif [ $SAMPLE_CC == "ABAC" ]; then
    peer chaincode invoke -o orderer0.example.com:7050 --tls --cafile $ORDERER_CA -C mychannel -n $CC_LABLNAME $PEER_CONN_PARMS $PEER_CONN_PARMS1 -c '{"Args":["a","500"]}'
elif [ $SAMPLE_CC == "FABCAR" ]; then
    peer chaincode invoke -o orderer0.example.com:7050 --tls --cafile $ORDERER_CA -C mychannel -n $CC_LABLNAME $PEER_CONN_PARMS $PEER_CONN_PARMS1 -c '{"Args":["initLedger"]}'
else
    echo " Unknown invoke commands"
fi
#peer chaincode invoke -o orderer0.example.com:7050 --tls --cafile $ORDERER_CA -C mychannel -n $CC_LABLNAME $PEER_CONN_PARMS $PEER_CONN_PARMS1 -c '{"function":"InitLedger","Args":[]}'
#peer chaincode invoke -o orderer0.example.com:7050 --tls --cafile $ORDERER_CA -C mychannel -n assetbasic $PEER_CONN_PARMS $PEER_CONN_PARMS1 -c '{"Args":["initLedger"]}'
#peer chaincode invoke -o orderer0.example.com:7050 --tls --cafile $ORDERER_CA -C mychannel -n sacc $PEER_CONN_PARMS $PEER_CONN_PARMS1 -c '{"Args":["set","country","india"]}'
sleep 3
echo -e $PCOLOR"Querying the chaincode for ORGs - $org1 "$NONE

if [ $SAMPLE_CC == "ASSETTRANSFER" ]; then 
    echo -e $PCOLOR"Getting all assets for reference "$NONE
    sleep 5
    peer chaincode query -C mychannel -n $CC_LABLNAME -c '{"Args":["GetAllAssets"]}'
    echo -e $PCOLOR"Querying the specific Asset for invoke transaction  from $org1 "$NONE
    sleep 5
    peer chaincode invoke -o orderer0.example.com:7050 --tls --cafile $ORDERER_CA -C mychannel -n $CC_LABLNAME $PEER_CONN_PARMS $PEER_CONN_PARMS1  -c '{"function":"ReadAsset","Args":["asset6"]}'
    
    echo -e $PCOLOR"Invoke transaction to specific Asset from $org1 "$NONE
    sleep 5
    peer chaincode invoke -o orderer0.example.com:7050 --tls --cafile $ORDERER_CA -C mychannel -n $CC_LABLNAME $PEER_CONN_PARMS $PEER_CONN_PARMS1  -c '{"function":"TransferAsset","Args":["asset6","Christopher"]}'

elif [ $SAMPLE_CC == "SACC" ];then
    peer chaincode query -C mychannel -n $CC_LABLNAME -c '{"Args":["query","name"]}'

    echo -e $PCOLOR"Invoke transaction to specific asset from $org1 "$NONE
    #echo "Nil"
    peer chaincode invoke -o orderer0.example.com:7050 --tls --cafile $ORDERER_CA -C mychannel -n $CC_LABLNAME $PEER_CONN_PARMS $PEER_CONN_PARMS1 -c '{"Args":["set","name","HLfab-v2.0"]}'
elif [ $SAMPLE_CC == "ABSTORE" ]; then
    peer chaincode query -C mychannel -n $CC_LABLNAME -c '{"Args":["query","a"]}'
        echo -e $PCOLOR"Invoke transaction to specific Asset from $org1 "$NONE
    echo "Nil"
elif [ $SAMPLE_CC == "ABAC" ]; then
    peer chaincode query -C mychannel -n $CC_LABLNAME -c '{"Args":["query","a"]}'
        echo -e $PCOLOR"Invoke transaction to specific Asset from $org1 "$NONE
    echo "Nil"
elif [ $SAMPLE_CC == "FABCAR" ]; then
    peer chaincode query -C mychannel -n $CC_LABLNAME -c '{"Args":["queryCar","CAR0"]}'
        echo -e $PCOLOR"Invoke transaction to specific Asset from $org1 "$NONE
    echo "Nil"
else
    echo " unknown query commands"
fi





echo -e $PCOLOR"Querying the specific Asset for invoke transaction  from $org2 "$NONE
sleep 5
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.key
export CORE_PEER_LOCALMSPID=Org2MSP
export CORE_VM_ENDPOINT=unix:///host/var/run/docker.sock
export CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.crt
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ID=
export CORE_PEER_ADDRESS=peer0.org2.example.com:9051
export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer0.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

#peer chaincode invoke -o orderer0.example.com:7050 --tls --cafile $ORDERER_CA -C mychannel -n $CC_LABLNAME $PEER_CONN_PARMS $PEER_CONN_PARMS1  -c '{"function":"ReadAsset","Args":["asset6"]}'

if [ $SAMPLE_CC == "ASSETTRANSFER" ]; then 
    
    sleep 5
 
    peer chaincode invoke -o orderer0.example.com:7050 --tls --cafile $ORDERER_CA -C mychannel -n $CC_LABLNAME $PEER_CONN_PARMS $PEER_CONN_PARMS1  -c '{"function":"ReadAsset","Args":["asset6"]}'
    

elif [ $SAMPLE_CC == "SACC" ];then
    peer chaincode query -C mychannel -n $CC_LABLNAME -c '{"Args":["query","name"]}'


elif [ $SAMPLE_CC == "ABSTORE" ]; then
    peer chaincode query -C mychannel -n $CC_LABLNAME -c '{"Args":["query","a"]}'
        echo -e $PCOLOR"Invoke transaction to specific Asset from $org1 "$NONE
    echo "Nil, Under Development"
elif [ $SAMPLE_CC == "ABAC" ]; then
    peer chaincode query -C mychannel -n $CC_LABLNAME -c '{"Args":["query","a"]}'
        echo -e $PCOLOR"Invoke transaction to specific Asset from $org1 "$NONE
    echo "Nil Under Development"
elif [ $SAMPLE_CC == "FABCAR" ]; then
    peer chaincode query -C mychannel -n $CC_LABLNAME -c '{"Args":["queryCar","CAR0"]}'
        echo -e $PCOLOR"Invoke transaction to specific Asset from $org1 "$NONE
    echo "Nil Under Development"
else
    echo " Unknown query commands"
fi


#peer chaincode invoke -o orderer0.example.com:7050 --tls --cafile $ORDERER_CA -C mychannel -n assetbasic $PEER_CONN_PARMS $PEER_CONN_PARMS1 -c '{"function":"CreateAsset","Args":["asset1", "A new asset for Org1MSP"]}' --transient "{\"asset_properties\":\"$ASSET_PROPERTIES\"}"
#peer chaincode query -o orderer0.example.com:7050 --tls --cafile $ORDERER_CA -C mychannel -n assetbasic  $PEER_CONN_PARMS $PEER_CONN_PARMS1 -c '{"function":"GetAssetPrivateProperties","Args":["asset1"]}'
#peer chaincode invoke -o orderer0.example.com:7050 --tls --cafile $ORDERER_CA -C mychannel -n assetbasic $PEER_CONN_PARMS $PEER_CONN_PARMS1 -c '{"function":"InitLedger","Args":[]}'

#peer chaincode invoke -o orderer0.example.com:7050 --tls --cafile $ORDERER_CA -C mychannel -n assetbasic $PEER_CONN_PARMS $PEER_CONN_PARMS1  -c '{"function":"TransferAsset","Args":["asset6","Christopher"]}'

#from org2

#peer chaincode query -C mychannel -n basic -c '{"Args":["ReadAsset","asset6"]}'


#docker exec peer$i.org$i.example.com peer channel getinfo -c mychannel


#abstore
# peer chaincode invoke -o orderer0^Cxample.com:7050 --tls true --cafile $ORDERER_CA -C mychannel -n mycc --peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles $ORG1_CA  --peerAddresses peer0.org2.example.com:9051 --tlsRootCertFiles $ORG2_CA -c '{"Args":["Init","a","1000","b","1000"]}' --waitForEvent
#peer chaincode query -C mychannel -n abstore -c '{"Args":["query","a"]}'