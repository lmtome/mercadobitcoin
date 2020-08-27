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

#Check access permission toexecute this script
if [ `id -u` -ne 0 ] && [ `id -g` -ne 0 ]; then
        echo "You need root access permission to execute ${0} command."
        exit 99
fi

#Capture line command parameter
if [ "${1}" = "-h" ]; then
        echo "Usage: ${0} [ -h ] | [-f <config file name>]"
        echo ""
	echo "The script reads the config file (.mbconf). This config file should "
        echo "have a reference value defined for each crypto currency:"
	echo "    BCH : Bitcoin Cash"
    	echo "BTC : Bitcoin"
    	echo "CHZ : Chiliz"
    	echo "ETH : Ethereum"
    	echo "LTC : Litecoin"
	echo ""
        echo "-h           show the command usage."
        echo "-f <file>    reads <file> instead .mbconf (default choice)"
        exit 1
elif [ "${1}" = "-f" ] && [ ! -z "${2}" ]; then
        CONFIG_FILE="${2}"
else
        CONFIG_FILE=".mbconf"
fi



if [ ! -f "${$HOME}/${CONFIG_FILE}" ]; then
       	echo "`date "+%m/%d/%Y  %H:%M:%S -  "`ERR#1 CONFIG_FILE does not exist in (${tsmclient_path}/dsm.sys)" 
      	exit 1
else
       	echo "Reading config file ${CONFIG_FILE}"
fi










#Capture cripto currencies values (Last, buy and sell)
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
