#!/bin/bash

######################
# Log:
# Aug 8th 2020 11:23pm
#    Phase I: It just alert the user which cryptocurrency should be bought/sold.
#
#    BCH : Bitcoin Cash 
#    BTC : Bitcoin 
#    CHZ : Chiliz 
#    ETH : Ethereum 
#    LTC : Litecoin
#
#####################


###########################################
#
# Functions
#
###########################################


#Capture cripto currencies values (Last, buy and sell)
function checkForUpdate {
        #BCH
        BCH_LAST_PRICE=`curl -s https://www.mercadobitcoin.net/api/BCH/ticker | jq --raw-output '.ticker.last'`
        BCH_BUY_PRICE=`curl -s https://www.mercadobitcoin.net/api/BCH/ticker | jq --raw-output '.ticker.buy'`
        BCH_SELL_PRICE=`curl -s https://www.mercadobitcoin.net/api/BCH/ticker | jq --raw-output '.ticker.sell'`

        #BTC
        BTC_LAST_PRICE=`curl -s https://www.mercadobitcoin.net/api/BTC/ticker | jq --raw-output '.ticker.last'`
        BTC_BUY_PRICE=`curl -s https://www.mercadobitcoin.net/api/BTC/ticker | jq --raw-output '.ticker.buy'`
        BTC_SELL_PRICE=`curl -s https://www.mercadobitcoin.net/api/BTC/ticker | jq --raw-output '.ticker.sell'`

        #CHZ
        CHZ_LAST_PRICE=`curl -s https://www.mercadobitcoin.net/api/CHZ/ticker | jq --raw-output '.ticker.last'`
        CHZ_BUY_PRICE=`curl -s https://www.mercadobitcoin.net/api/CHZ/ticker | jq --raw-output '.ticker.buy'`
        CHZ_SELL_PRICE=`curl -s https://www.mercadobitcoin.net/api/CHZ/ticker | jq --raw-output '.ticker.sell'`

        #ETH
        ETH_LAST_PRICE=`curl -s https://www.mercadobitcoin.net/api/ETH/ticker | jq --raw-output '.ticker.last'`
        ETH_BUY_PRICE=`curl -s https://www.mercadobitcoin.net/api/ETH/ticker | jq --raw-output '.ticker.buy'`
        ETH_SELL_PRICE=`curl -s https://www.mercadobitcoin.net/api/ETH/ticker | jq --raw-output '.ticker.sell'`

        #LTC
        LTC_LAST_PRICE=`curl -s https://www.mercadobitcoin.net/api/LTC/ticker | jq --raw-output '.ticker.last'`
        LTC_BUY_PRICE=`curl -s https://www.mercadobitcoin.net/api/LTC/ticker | jq --raw-output '.ticker.buy'`
        LTC_SELL_PRICE=`curl -s https://www.mercadobitcoin.net/api/LTC/ticker | jq --raw-output '.ticker.sell'`
}


###########################################
#
# Variables
#
###########################################

LOGFILE="mbc.log"
#time in seconds before check prices again
WAITIING=5


#Check access permission toexecute this script
if [ `id -u` -ne 0 ] && [ `id -g` -ne 0 ]; then
        echo "`date "+%m/%d/%Y  %H:%M:%S -  "`You need root access permission to execute ${0} command." >> ${LOGFILE}
        exit 1
fi

#Capture line command parameter
if [ "${1}" = "-h" ]; then
        echo "Usage: ${0} [ -h ] | [-f <config file name>]"
        echo ""
	echo "The script reads the config file (.mbconf). This config file should "
        echo "have a reference value defined for each crypto currency:"
	echo "BCH : Bitcoin Cash"
    	echo "BTC : Bitcoin"
    	echo "CHZ : Chiliz"
    	echo "ETH : Ethereum"
    	echo "LTC : Litecoin"
	echo ""
        echo "-h           show the command usage."
        echo "-f <file>    reads <file> instead .mbconf (default choice)"
        exit 2
elif [ "${1}" = "-f" ] && [ ! -z "${2}" ]; then
        CONFIG_FILE="${2}"
else
        CONFIG_FILE=".mbconf"
fi

echo "`date "+%m/%d/%Y  %H:%M:%S -  "`The config file ${CONFIG_FILE} is being used by ${0}."  >> ${LOGFILE}

if [ ! -f "${CONFIG_FILE}" ]; then
       	echo "`date "+%m/%d/%Y  %H:%M:%S -  "`ERR#3 ${CONFIG_FILE} does not exist locally."  >> ${LOGFILE}

        #set up a new conf file in JSON format
        while true ; do
                #flag to ensure all inputed numbers are numbers type
                isNUM=true

                echo "Enter the references prices for each crypto currency(Numbers ONLY):"
                echo -n "BCH:"
                read BCH_REF
                echo $BCH_REF | grep -q -v "[^0-9]"

                if [ $? -ne 0 ];then
                        isNUM=false
                fi

                echo -n "BTC:"
                read BTC_REF
                echo $BTC_REF | grep -q -v "[^0-9]"

                if [ $? -ne 0 ];then
                        isNUM=false
                fi

                echo -n "CHZ:"
                read CHZ_REF
                echo $CHZ_REF | grep -q -v "[^0-9]"

                if [ $? -ne 0 ];then
                        isNUM=false
                fi

                echo -n "ETH:"
                read ETH_REF
                echo $ETH_REF | grep -q -v "[^0-9]"

                if [ $? -ne 0 ];then
                        isNUM=false
                fi

                echo -n "LTC:"
                read LTC_REF
                echo $LTC_REF | grep -q -v "[^0-9]"

                if [ $? -ne 0 ];then
                        isNUM=false
                fi

                if $isNUM ; then
                        echo "{\"refprice\": {\"bch\":\"${BCH_REF}\",\"btc\":\"${BTC_REF}\",\"chz\":\"${CHZ_REF}\",\"eth\":\"${ETH_REF}\",\"ltc\":\"${LTC_REF}\"}}" > ${CONFIG_FILE}
                        break
                fi
	done
        
else
       	echo "`date "+%m/%d/%Y  %H:%M:%S -  "`Reading config file ${CONFIG_FILE}"   >> ${LOGFILE}
        
        BCH_REF=`cat ${CONFIG_FILE} | jq --raw-output '.refprice.bch'`
        BTC_REF=`cat ${CONFIG_FILE} | jq --raw-output '.refprice.btc'`
        CHZ_REF=`cat ${CONFIG_FILE} | jq --raw-output '.refprice.chz'`
        ETH_REF=`cat ${CONFIG_FILE} | jq --raw-output '.refprice.eth'`
        LTC_REF=`cat ${CONFIG_FILE} | jq --raw-output '.refprice.ltc'`
fi

# Check for updates each second running 
while true ; do
        #Capture all current crypto currencies prices
        checkForUpdate

        #Compare crypto currencies last value with their predefined references prices


        #Alert sent to terminal and logfile
        echo "NOTHING"

        sleep ${WAITIING}       
done

