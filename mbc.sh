#!/bin/bash

######################
# Log:
# Aug 8th 2020 11:23pm
#    Phase I: It just alert the user which cryptocurrency should be bought/sold.
#
#    BCH : Bitcoin Cash
#    BTC : Bitcoin
#    XRP : Ripple
#    ETH : Ethereum
#    LTC : Litecoin
#
#####################

###########################################
#
# Variables
#
###########################################
#MBC general log file for ERR and INF messages
LOGFILE="mbc.log"
#All buying transations will be logged on this file
BUYLOGFILE=".buy.log"
#All selling transations will be logged on this file
SELLLOGFILE=".sell.log"
#All user alerts will be logged on this file
ALERTLOGFILE=".alert.log"

echo "`date "+%m/%d/%Y  %H:%M:%S -  "`INF: Starting MCB script."  >> ${LOGFILE}

#Configuration file
CONFIG_FILE=".mbc.conf"

#Time in seconds before check prices again
WAITING=10

#Mercado Bitcoin tax % or in R$
GROSS_PROFIT_PERC=3

#These variables will be loaded from confog file
BCH_QTY=0
BCH_PRICE=0
BCH_TOTAL_PRICE=0
BCH_R_LAST_SELL=0
BCH_TOTAL_LAST_SELL=0
BCH_FLAG_ALERT=1

BTC_QTY=0
BTC_PRICE=0
BTC_TOTAL_PRICE=0
BTC_R_LAST_SELL=0
BTC_TOTAL_LAST_SELL=0
BTC_FLAG_ALERT=1

#BUY
XRP_QTY=0
XRP_PRICE=0
XRP_TOTAL_PRICE=0
XRP_R_LAST_SELL=0
XRP_TOTAL_LAST_SELL=0
XRP_FLAG_ALERT=1

#BUY
ETH_QTY=0
ETH_PRICE=0
ETH_TOTAL_PRICE=0
ETH_R_LAST_SELL=0
ETH_TOTAL_LAST_SELL=0
ETH_FLAG_ALERT=1

#BUY
LTC_QTY=0
LTC_PRICE=0
LTC_TOTAL_PRICE=0
LTC_R_LAST_SELL=0
LTC_TOTAL_LAST_SELL=0
LTC_FLAG_ALERT=1


#Consider it's the first time user is running the script
FLAG_FIRST_TIME=1

#Initialization of all LAST prices variables
BCH_LAST_PRICE=0
BTC_LAST_PRICE=0
XRP_LAST_PRICE=0
ETH_LAST_PRICE=0
LTC_LAST_PRICE=0


###########################################
#
# Functions
#
###########################################

#OK This function is called always the user does not choose an expected option and shows the script usage.
function usageScript {
        echo "Usage: ${0} [ -h | scan | scanbuy | menu | ( buy | sell )] <BCH|BTC|XRP|ETH|LTC> <qty> <price> ]"
        echo ""
        echo "-h           show the command usage."
        echo ""
        echo "scan - check for good prices to sell for one of these crypto currencies: "
        echo "BCH : Bitcoin Cash"
        echo "BTC : Bitcoin"
        echo "XRP : Ripple"
        echo "ETH : Ethereum"
        echo "LTC : Litecoin"
        echo ""
        echo "menu - Interative mode useful to speed up set up process and extract reports."
        echo ""
        echo "buy - Set up the system with new crypto currency user has bought."
        echo ""
        echo "sell - Set up the system with new crypto currency user has sold."
        echo ""
	echo "`date "+%m/%d/%Y  %H:%M:%S -  "`ERR2: usage has been printed in user prompt. Script has ended."  >> ${LOGFILE}
        exit 2
}

function loadConfigFile {
                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`Reading config file ${CONFIG_FILE} and loading variables."   >> ${LOGFILE}

                #Read config file and set up each currency reference price
                #BUY
                BCH_QTY=`cat ${CONFIG_FILE} | jq --raw-output '.mbc.currency.bch.buy.rqty'`
                BCH_QTY=$( printf "%.8f" $BCH_QTY )
                BCH_PRICE=`cat ${CONFIG_FILE} | jq --raw-output '.mbc.currency.bch.buy.rprice'`
                BCH_PRICE=$( printf "%.8f" $BCH_PRICE )
                BCH_TOTAL_PRICE=`cat ${CONFIG_FILE} | jq --raw-output '.mbc.currency.bch.buy.rtotalprice'`
                BCH_TOTAL_PRICE=$( printf "%.8f" $BCH_TOTAL_PRICE )
                #SELL
                BCH_R_LAST_SELL=`cat ${CONFIG_FILE} | jq --raw-output '.mbc.currency.bch.sell.rlastsell'`
                BCH_R_LAST_SELL=$( printf "%.8f" $BCH_R_LAST_SELL )
                BCH_TOTAL_LAST_SELL=`cat ${CONFIG_FILE} | jq --raw-output '.mbc.currency.bch.sell.rtotallastsell'`
                BCH_TOTAL_LAST_SELL=$( printf "%.8f" $BCH_TOTAL_LAST_SELL )
                BCH_FLAG_ALERT=`cat ${CONFIG_FILE} | jq --raw-output '.mbc.currency.bch.sell.flagalert'`

                #BUY
                BTC_QTY=`cat ${CONFIG_FILE} | jq --raw-output '.mbc.currency.btc.buy.rqty'`
                BTC_QTY=$( printf "%.8f" $BTC_QTY )
                BTC_PRICE=`cat ${CONFIG_FILE} | jq --raw-output '.mbc.currency.btc.buy.rprice'`
                BTC_PRICE=$( printf "%.8f" $BTC_PRICE )
                BTC_TOTAL_PRICE=`cat ${CONFIG_FILE} | jq --raw-output '.mbc.currency.btc.buy.rtotalprice'`
                BTC_TOTAL_PRICE=$( printf "%.8f" $BTC_TOTAL_PRICE )
                #SELL
                BTC_R_LAST_SELL=`cat ${CONFIG_FILE} | jq --raw-output '.mbc.currency.btc.sell.rlastsell'`
                BTC_R_LAST_SELL=$( printf "%.8f" $BTC_R_LAST_SELL )
                BTC_TOTAL_LAST_SELL=`cat ${CONFIG_FILE} | jq --raw-output '.mbc.currency.btc.sell.rtotallastsell'`
                BTC_TOTAL_LAST_SELL=$( printf "%.8f" $BTC_TOTAL_LAST_SELL )
                BTC_FLAG_ALERT=`cat ${CONFIG_FILE} | jq --raw-output '.mbc.currency.btc.sell.flagalert'`

                #BUY
                XRP_QTY=`cat ${CONFIG_FILE} | jq --raw-output '.mbc.currency.xrp.buy.rqty'`
                XRP_QTY=$( printf "%.8f" $XRP_QTY )
                XRP_PRICE=`cat ${CONFIG_FILE} | jq --raw-output '.mbc.currency.xrp.buy.rprice'`
                XRP_PRICE=$( printf "%.8f" $XRP_PRICE )
                XRP_TOTAL_PRICE=`cat ${CONFIG_FILE} | jq --raw-output '.mbc.currency.xrp.buy.rtotalprice'`
                XRP_TOTAL_PRICE=$( printf "%.8f" $XRP_TOTAL_PRICE )
                #SELL
                XRP_R_LAST_SELL=`cat ${CONFIG_FILE} | jq --raw-output '.mbc.currency.xrp.sell.rlastsell'`
                XRP_R_LAST_SELL=$( printf "%.8f" $XRP_R_LAST_SELL )
                XRP_TOTAL_LAST_SELL=`cat ${CONFIG_FILE} | jq --raw-output '.mbc.currency.xrp.sell.rtotallastsell'`
                XRP_TOTAL_LAST_SELL=$( printf "%.8f" $XRP_TOTAL_LAST_SELL )
                XRP_FLAG_ALERT=`cat ${CONFIG_FILE} | jq --raw-output '.mbc.currency.xrp.sell.flagalert'`

                #BUY
                ETH_QTY=`cat ${CONFIG_FILE} | jq --raw-output '.mbc.currency.eth.buy.rqty'`
                ETH_QTY=$( printf "%.8f" $ETH_QTY )
                ETH_PRICE=`cat ${CONFIG_FILE} | jq --raw-output '.mbc.currency.eth.buy.rprice'`
                ETH_PRICE=$( printf "%.8f" $ETH_PRICE )
                ETH_TOTAL_PRICE=`cat ${CONFIG_FILE} | jq --raw-output '.mbc.currency.eth.buy.rtotalprice'`
                ETH_TOTAL_PRICE=$( printf "%.8f" $ETH_TOTAL_PRICE )
                #SELL
                ETH_R_LAST_SELL=`cat ${CONFIG_FILE} | jq --raw-output '.mbc.currency.eth.sell.rlastsell'`
                ETH_R_LAST_SELL=$( printf "%.8f" $ETH_R_LAST_SELL )
                ETH_TOTAL_LAST_SELL=`cat ${CONFIG_FILE} | jq --raw-output '.mbc.currency.eth.sell.rtotallastsell'`
                ETH_TOTAL_LAST_SELL=$( printf "%.8f" $ETH_TOTAL_LAST_SELL )
                ETH_FLAG_ALERT=`cat ${CONFIG_FILE} | jq --raw-output '.mbc.currency.eth.sell.flagalert'`

                #BUY
                LTC_QTY=`cat ${CONFIG_FILE} | jq --raw-output '.mbc.currency.ltc.buy.rqty'`
                LTC_QTY=$( printf "%.8f" $LTC_QTY )
                LTC_PRICE=`cat ${CONFIG_FILE} | jq --raw-output '.mbc.currency.ltc.buy.rprice'`
                LTC_PRICE=$( printf "%.8f" $LTC_PRICE )
                LTC_TOTAL_PRICE=`cat ${CONFIG_FILE} | jq --raw-output '.mbc.currency.ltc.buy.rtotalprice'`
                LTC_TOTAL_PRICE=$( printf "%.8f" $LTC_QTY )
                #SELL
                LTC_R_LAST_SELL=`cat ${CONFIG_FILE} | jq --raw-output '.mbc.currency.ltc.sell.rlastsell'`
                LTC_R_LAST_SELL=$( printf "%.8f" $LTC_R_LAST_SELL )
                LTC_TOTAL_LAST_SELL=`cat ${CONFIG_FILE} | jq --raw-output '.mbc.currency.ltc.sell.rtotallastsell'`
                LTC_TOTAL_LAST_SELL=$( printf "%.8f" $LTC_TOTAL_LAST_SELL )
                LTC_FLAG_ALERT=`cat ${CONFIG_FILE} | jq --raw-output '.mbc.currency.ltc.sell.flagalert'`

                #ADMIN
                FLAG_FIRST_TIME=`cat ${CONFIG_FILE} | jq --raw-output '.mbc.adminconfig.flagfirsttime'`

}

#OK Check if config file exists, if so script reads config file and load automation variables. if not, scripts brings a prompt to input manually.
function initialSetup {
	echo "`date "+%m/%d/%Y  %H:%M:%S -  "`INF: initialSetup function."  >> ${LOGFILE}

        if [ ! -f "${CONFIG_FILE}" ]; then
                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`ERR: ${CONFIG_FILE} does not exist. Starting quiz to create one."  >> ${LOGFILE}

                #set up a new conf file in JSON format
                echo "Answer all questions needed for this automation runs properly:"

                #BCH
                echo "About BCH crypto currency:"
                echo -n "What is the quantity? Please input only numbers. Eg.: 0.12345678  =>"
                read BCH_QTY
                BCH_QTY=$( printf "%.8f" $BCH_QTY )

                echo -n "What is the price? Please input only numbers. Eg.: 0.12345678  =>"
                read BCH_PRICE
                BCH_PRICE=$( printf "%.8f" $BCH_PRICE )
                BCH_TOTAL_PRICE=`bc <<< "scale=2;(${BCH_QTY}*${BCH_PRICE})"`
                BCH_TOTAL_PRICE=$( printf "%.8f" $BCH_TOTAL_PRICE )

                #BTC
                echo "About BTC crypto currency:"
                echo -n "What is the quantity? Please input only numbers. Eg.: 0.12345678  =>"
                read BTC_QTY
                BTC_QTY=$( printf "%.8f" $BTC_QTY )
                echo -n "What is the price? Please input only numbers. Eg.: 0.12345678  =>"
                read BTC_PRICE
                BTC_PRICE=$( printf "%.8f" $BTC_PRICE )
                BTC_TOTAL_PRICE=`bc <<< "scale=2;(${BTC_QTY}*${BTC_PRICE})"`
                BTC_TOTAL_PRICE=$( printf "%.8f" $BTC_TOTAL_PRICE )

                #XRP
                echo "About XRP crypto currency:"
                echo -n "What is the quantity? Please input only numbers. Eg.: 0.12345678  =>"
                read XRP_QTY
                XRP_QTY=$( printf "%.8f" $XRP_QTY )
                echo -n "What is the price? Please input only numbers. Eg.: 0.12345678  =>"
                read XRP_PRICE
                XRP_PRICE=$( printf "%.8f" $XRP_PRICE )
                XRP_TOTAL_PRICE=`bc <<< "scale=2;(${XRP_QTY}*${XRP_PRICE})"`
                XRP_TOTAL_PRICE=$( printf "%.8f" $XRP_TOTAL_PRICE )

                #ETH
                echo "About ETH crypto currency:"
                echo -n "What is the quantity? Please input only numbers. Eg.: 0.12345678  =>"
                read ETH_QTY
                ETH_QTY=$( printf "%.8f" $ETH_QTY )
                echo -n "What is the price? Please input only numbers. Eg.: 0.12345678  =>"
                read ETH_PRICE
                ETH_PRICE=$( printf "%.8f" $ETH_PRICE )
                ETH_TOTAL_PRICE=`bc <<< "scale=2;(${ETH_QTY}*${ETH_PRICE})"`
                ETH_TOTAL_PRICE=$( printf "%.8f" $ETH_TOTAL_PRICE )

                #LTC
                echo "About LTC crypto currency:"
                echo -n "What is the quantity? Please input only numbers. Eg.: 0.12345678  =>"
                read LTC_QTY
                LTC_QTY=$( printf "%.8f" $LTC_QTY )
                echo -n "What is the price? Please input only numbers. Eg.: 0.12345678  =>"
                read LTC_PRICE
                LTC_PRICE=$( printf "%.8f" $LTC_PRICE )
                LTC_TOTAL_PRICE=`bc <<< "scale=2;(${LTC_QTY}*${LTC_PRICE})"`
                LTC_TOTAL_PRICE=$( printf "%.8f" $LTC_TOTAL_PRICE )

		echo "`date "+%m/%d/%Y  %H:%M:%S -  "`INF: A config file has been saved with all currencies prices."  >> ${LOGFILE}

                #Save new data input by user
                echo -e "{\"mbc\":{\"currency\":{\"bch\":{\"buy\":{\"rqty\":\"${BCH_QTY}\",\"rprice\":\"${BCH_PRICE}\",\"rtotalprice\":\"${BCH_TOTAL_PRICE}\"},\"sell\":{\"rlastsell\":\"${BCH_PRICE}\",\"rtotallastsell\":\"${BCH_PRICE}\",\"flagalert\":\"1\"}},\"btc\":{\"buy\":{\"rqty\":\"${BTC_QTY}\",\"rprice\":\"${BTC_PRICE}\",\"rtotalprice\":\"${BTC_TOTAL_PRICE}\"},\"sell\":{\"rlastsell\":\"${BTC_PRICE}\",\"rtotallastsell\":\"${BTC_PRICE}\",\"flagalert\":\"1\"}},\"xrp\":{\"buy\":{\"rqty\":\"${XRP_QTY}\",\"rprice\":\"${XRP_PRICE}\",\"rtotalprice\":\"${XRP_TOTAL_PRICE}\"},\"sell\":{\"rlastsell\":\"${XRP_PRICE}\",\"rtotallastsell\":\"${BCH_PRICE}\",\"flagalert\":\"1\"}},\"eth\":{\"buy\":{\"rqty\":\"${ETH_QTY}\",\"rprice\":\"${ETH_PRICE}\",\"rtotalprice\":\"${ETH_TOTAL_PRICE}\"},\"sell\":{\"rlastsell\":\"${ETH_PRICE}\",\"rtotallastsell\":\"${ETH_PRICE}\",\"flagalert\":\"1\"}},\"ltc\":{\"buy\":{\"rqty\":\"${LTC_QTY}\",\"rprice\":\"${LTC_PRICE}\",\"rtotalprice\":\"${LTC_TOTAL_PRICE}\"},\"sell\":{\"rlastsell\":\"${LTC_PRICE}\",\"rtotallastsell\":\"${LTC_PRICE}\",\"flagalert\":\"1\"}}},\"adminconfig\":{\"flagfirsttime\":\"0\"}}}" > ${CONFIG_FILE}

        else

                #Read config file and set up each currency reference price
                loadConfigFile
        fi
}


#OK Alertis user by email about about new prices have reached the thresholds
function alertUser {
        #Alert user
        #alertUser "dwulbr@gmail.com" "Subject: BCH is at least 3% below of its reference price. Check it ASAP!"
        echo ${2} | ssmtp ${1}

	echo "`date "+%m/%d/%Y  %H:%M:%S -  "`INF: An alert is being sent TO: ${2} - ${1}"   >> ${ALERTLOGFILE}
}


#OK Capture cripto currencies values (Last, buy and sell)
function checkNewPricesUpdates {

        echo "`date "+%m/%d/%Y  %H:%M:%S -  "`INF: Capturing the last currencies prices in the market and loading variables."   >> ${LOGFILE}

        #BCH
        BCH_LAST_PRICE=`curl -s https://www.mercadobitcoin.net/api/BCH/ticker | jq --raw-output '.ticker.last'`
        BCH_LAST_PRICE=$( printf "%.8f" $BCH_LAST_PRICE )

        #BTC
        BTC_LAST_PRICE=`curl -s https://www.mercadobitcoin.net/api/BTC/ticker | jq --raw-output '.ticker.last'`
        BTC_LAST_PRICE=$( printf "%.8f" $BTC_LAST_PRICE )

        #XRP
        XRP_LAST_PRICE=`curl -s https://www.mercadobitcoin.net/api/XRP/ticker | jq --raw-output '.ticker.last'`
        XRP_LAST_PRICE=$( printf "%.8f" $XRP_LAST_PRICE )

        #ETH
        ETH_LAST_PRICE=`curl -s https://www.mercadobitcoin.net/api/ETH/ticker | jq --raw-output '.ticker.last'`
        ETH_LAST_PRICE=$( printf "%.8f" $ETH_LAST_PRICE )

        #LTC
        LTC_LAST_PRICE=`curl -s https://www.mercadobitcoin.net/api/LTC/ticker | jq --raw-output '.ticker.last'`
        LTC_LAST_PRICE=$( printf "%.8f" $LTC_LAST_PRICE )
}


#check and alert user to sell if the last price has reached an expected price: i
#OK checkTimeToSell ${BCH_R_LAST_SELL} ${BCH_LAST_PRICE} "BCH"
function checkTimeToSell {

	echo "`date "+%m/%d/%Y  %H:%M:%S -  "`INF: Starting checkTimetoSell function."   >> ${LOGFILE}

        #R_LAST_SELL_GP is reference price + 3% of gross profit...
        R_LAST_SELL_GP=`bc <<< "scale=2;(${1}+(${GROSS_PROFIT_PERC}/100)*${1})"`
        R_LAST_SELL_GP=$( printf "%.8f" $R_LAST_SELL_GP )

        #...and last price must be iqual or greater than the reference price + 3% of gross profit to alert the user: Sell time!!!
        FLAG_SELL_TIME=`echo ${2}'>'${R_LAST_SELL_GP} | bc -l`

        #TRUE for LAST PRICE IS GREATER THAN R_LAST_SELL(3% above)
        if [ ${FLAG_SELL_TIME} -ne 0 ];then


                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`${3} last price is currently 3% above of ${3} R LAST SELL"   >> ${SELLLOGFILE}

                if [ "${3}" == "BCH" ];then
                        #Alert user
                        if [ ${BCH_FLAG_ALERT} -eq 1 ];then
                                alertUser "dwulbr@gmail.com" "Subject: ${3} last price is currently 3% above of ${3} R LAST SELL"

                                #Disable alert for BCH coin
                                BCH_FLAG_ALERT=0

                                #update JSON value
                                JSON_UPDATE=`jq --arg flagalert "${BCH_FLAG_ALERT}" '.mbc.currency.bch.sell.flagalert = $flagalert' ${CONFIG_FILE}`
                                echo $JSON_UPDATE > ${CONFIG_FILE}
                                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`An alert has been sent: Last price is currently 3% above. ${3} Flag alert has been disabled."   >> ${LOGFILE}
                        fi

                elif [ "${3}" == "BTC" ];then
                        #Alert user
                        if [ ${BTC_FLAG_ALERT} -eq 1 ];then
                                alertUser "dwulbr@gmail.com" "Subject: ${3} last price is currently 3% above of ${3} R LAST SELL"

                                #Disable alert for BTC coin
                                BTC_FLAG_ALERT=0

                                #update JSON value
                                JSON_UPDATE=`jq --arg flagalert "${BTC_FLAG_ALERT}" '.mbc.currency.btc.sell.flagalert = $flagalert' ${CONFIG_FILE}`
                                echo $JSON_UPDATE > ${CONFIG_FILE}
                                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`An alert has been sent: Last price is currently 3% above. ${3} Flag alert has been disabled."   >> ${LOGFILE}
                        fi

                elif [ "${3}" == "XRP" ];then
                        #Alert user
                        if [ ${XRP_FLAG_ALERT} -eq 1 ];then
                                alertUser "dwulbr@gmail.com" "Subject: ${3} last price is currently 3% above of ${3} R LAST SELL"

                                #Disable alert for XRP coin
                                XRP_FLAG_ALERT=0


                                #update JSON value
                                JSON_UPDATE=`jq --arg flagalert "${XRP_FLAG_ALERT}" '.mbc.currency.xrp.sell.flagalert = $flagalert' ${CONFIG_FILE}`
                                echo $JSON_UPDATE > ${CONFIG_FILE}
                                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`An alert has been sent: Last price is currently 3% above. ${3} Flag alert has been disabled."   >> ${LOGFILE}
                        fi

                elif [ "${3}" == "ETH" ];then
                        #Alert user
                        if [ ${ETH_FLAG_ALERT} -eq 1 ];then
                                alertUser "dwulbr@gmail.com" "Subject: ${3} last price is currently 3% above of ${3} R LAST SELL"

                                #Disable alert for ETH coin
                                ETH_FLAG_ALERT=0


                                #update JSON value
                                JSON_UPDATE=`jq --arg flagalert "${ETH_FLAG_ALERT}" '.mbc.currency.eth.sell.flagalert = $flagalert' ${CONFIG_FILE}`
                                echo $JSON_UPDATE > ${CONFIG_FILE}
                                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`An alert has been sent: Last price is currently 3% above. ${3} Flag alert has been disabled."   >> ${LOGFILE}
                        fi

                elif [ "${3}" == "LTC" ];then
                        #Alert user
                        if [ ${LTC_FLAG_ALERT} -eq 1 ];then
                                alertUser "dwulbr@gmail.com" "Subject: ${3} last price is currently 3% above of ${3} R LAST SELL"

                                #Disable alert for LTC coin
                                LTC_FLAG_ALERT=0


                                #update JSON value
                                JSON_UPDATE=`jq --arg flagalert "${LTC_FLAG_ALERT}" '.mbc.currency.ltc.sell.flagalert = $flagalert' ${CONFIG_FILE}`
                                echo $JSON_UPDATE > ${CONFIG_FILE}
                                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`An alert has been sent: Last price is currently 3% above. ${3} Flag alert has been disabled."   >> ${LOGFILE}
                        fi
                else
                        echo "`date "+%m/%d/%Y  %H:%M:%S -  "ERR3:`${3} is a invalid crypto currency. This scripts accept BCH, BTC, XRP, ETH and LTC ONLY!"   >> ${LOGFILE}
			exit 3
                fi
        else
                #Last value does not reach 3% above of reference price for ${3} crypto currency."
                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`INF: Last price is not 3% above of ${3} R LAST SELL."   >> ${SELLLOGFILE}
        fi

}


#OK Open an interative mode
function interativeMode {

	echo "`date "+%m/%d/%Y  %H:%M:%S -  "`INF: Starting interactive menu."   >> ${LOGFILE}

        #Start CLI menu
        while true ; do
                #flag to ensure all inputed numbers are numbers type
                isNUM=true

                clear
                echo "#################### MBC ADMIN ####################"
                echo "#  1 - Enable SELL's alerts for all currencies    #"
                echo "#  2 - Set up a new value to LAST SELL            #"
                echo "#  3 - Shows 10 last lines from log file          #"
                echo "#  4 - Shows 10 last buy operations               #"
                echo "#  5 - Shows 10 last sell operation               #"
                echo "#  6 - Shows 10 last alerts sent by email         #"
                echo "#  7 - Show crypto currencies variables values    #"
                echo "#  8 - Exit                                       #"
                echo "###################################################"
                echo -n "Choose an option number:"
                read OPTMENU
                echo $OPTMENU | grep -q -v "[^0-9]"

                if [ $? -ne 0 ];then
                        isNUM=false
                fi

                if [ isNUM ];then
                        case $OPTMENU in
                                1)
				clear
                                clear
                                echo "#################### MBC ADMIN ####################"
                                echo "#                                                 #"
                                echo "#                                                 #"
                                echo "#                                                 #"
                                echo "#   Alerts have been enabled for all currencies   #"
                                echo "#       Press ENTER to go back to main menu       #"
                                echo "#                                                 #"
                                echo "#                                                 #"
                                echo "#                                                 #"
                                echo "###################################################"
                                echo -n ""
                                
                                BCH_FLAG_ALERT=1
                                BTC_FLAG_ALERT=1
                                XRP_FLAG_ALERT=1
                                ETH_FLAG_ALERT=1
                                LTC_FLAG_ALERT=1

                                #update JSON value
                                JSON_UPDATE=`jq --arg flagalert "${BCH_FLAG_ALERT}" '.mbc.currency.bch.sell.flagalert = $flagalert' ${CONFIG_FILE}`
                                echo $JSON_UPDATE > ${CONFIG_FILE}
                                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`BCH Flag alert has been enabled by user."   >> ${LOGFILE}
                                
                                JSON_UPDATE=`jq --arg flagalert "${BTC_FLAG_ALERT}" '.mbc.currency.btc.sell.flagalert = $flagalert' ${CONFIG_FILE}`
                                echo $JSON_UPDATE > ${CONFIG_FILE}
                                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`BTC Flag alert has been enabled by user."   >> ${LOGFILE}

                                JSON_UPDATE=`jq --arg flagalert "${XRP_FLAG_ALERT}" '.mbc.currency.xrp.sell.flagalert = $flagalert' ${CONFIG_FILE}`
                                echo $JSON_UPDATE > ${CONFIG_FILE}
                                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`XRP Flag alert has been enabled by user."   >> ${LOGFILE}

                                JSON_UPDATE=`jq --arg flagalert "${ETH_FLAG_ALERT}" '.mbc.currency.eth.sell.flagalert = $flagalert' ${CONFIG_FILE}`
                                echo $JSON_UPDATE > ${CONFIG_FILE}
                                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`ETH Flag alert has been enabled by user."   >> ${LOGFILE}

                                JSON_UPDATE=`jq --arg flagalert "${LTC_FLAG_ALERT}" '.mbc.currency.ltc.sell.flagalert = $flagalert' ${CONFIG_FILE}`
                                echo $JSON_UPDATE > ${CONFIG_FILE}
                                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`LTC Flag alert has been enabled by user."   >> ${LOGFILE}

				echo "`date "+%m/%d/%Y  %H:%M:%S -  "`INF: Alerts have been enabled for all currencies."   >> ${LOGFILE}
                                read OPTMENU;;

                                2)
                                clear
                                clear
                                echo "#################### MBC ADMIN ####################"
                                echo "#                                                 #"
                                echo "#                                                 #"
                                echo "#                                                 #"
                                echo "#    Input last sell prices for each currency     #"
                                echo "#                                                 #"
                                echo "#                                                 #"
                                echo "#                                                 #"
                                echo "#                                                 #"
                                echo "###################################################"
                                echo -n "BCH last sell price (Eg.: 0.12345678)     =>"
                                read BCH_R_LAST_SELL

                                echo -n "BTC last sell price (Eg.: 0.12345678)     =>"
                                read BTC_R_LAST_SELL

                                echo -n "XRP last sell price (Eg.: 0.12345678)     =>"
                                read XRP_R_LAST_SELL

                                echo -n "ETH last sell price (Eg.: 0.12345678)     =>"
                                read ETH_R_LAST_SELL

                                echo -n "LTC last sell price (Eg.: 0.12345678)     =>"
                                read LTC_R_LAST_SELL

                                clear
                                clear
                                echo "#################### MBC ADMIN ####################"
                                echo "#                                                 "
                                echo "#         LAST SELL PRICES HAVE BEEN SETUP        "
                                echo "#   (BCH):$BCH_R_LAST_SELL                        "
                                echo "#   (BTC):$BTC_R_LAST_SELL                        "
                                echo "#   (XRP):$XRP_R_LAST_SELL                        "
                                echo "#   (ETH):$ETH_R_LAST_SELL                        "
                                echo "#   (LTC):$LTC_R_LAST_SELL                        "
                                echo "#       Press ENTER to go back to main menu       "
                                echo "###################################################"

                                JSON_UPDATE=`jq --arg rlastsell "${BCH_R_LAST_SELL}" '.mbc.currency.bch.sell.rlastsell = $rlastsell' ${CONFIG_FILE}`
                                echo $JSON_UPDATE > ${CONFIG_FILE}
                                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`[BCH] The last sell price useded as reference has been changed with success."   >> ${LOGFILE}

                                JSON_UPDATE=`jq --arg rlastsell "${BTC_R_LAST_SELL}" '.mbc.currency.btc.sell.rlastsell = $rlastsell' ${CONFIG_FILE}`
                                echo $JSON_UPDATE > ${CONFIG_FILE}
                                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`[BTC] The last sell price useded as reference has been changed with success."   >> ${LOGFILE}

                                JSON_UPDATE=`jq --arg rlastsell "${XRP_R_LAST_SELL}" '.mbc.currency.xrp.sell.rlastsell = $rlastsell' ${CONFIG_FILE}`
                                echo $JSON_UPDATE > ${CONFIG_FILE}
                                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`[XRP] The last sell price useded as reference has been changed with success."   >> ${LOGFILE}

                                JSON_UPDATE=`jq --arg rlastsell "${ETH_R_LAST_SELL}" '.mbc.currency.eth.sell.rlastsell = $rlastsell' ${CONFIG_FILE}`
                                echo $JSON_UPDATE > ${CONFIG_FILE}
                                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`[ETH] The last sell price useded as reference has been changed with success."   >> ${LOGFILE}

                                JSON_UPDATE=`jq --arg rlastsell "${LTC_R_LAST_SELL}" '.mbc.currency.ltc.sell.rlastsell = $rlastsell' ${CONFIG_FILE}`
                                echo $JSON_UPDATE > ${CONFIG_FILE}
                                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`[LTC] The last sell price useded as reference has been changed with success."   >> ${LOGFILE}

				echo "`date "+%m/%d/%Y  %H:%M:%S -  "`INF: Last sell prices have been setup by user. (BCH):$BCH_R_LAST_SELL;(BTC):$BTC_R_LAST_SELL;(XRP):$XRP_R_LAST_SELL;(ETH):$ETH_R_LAST_SELL; (LTC):$LTC_R_LAST_SELL."   >> ${LOGFILE}

                                echo -n ""
                                read OPTMENU;;

                                3)
				echo "`date "+%m/%d/%Y  %H:%M:%S -  "`INF: Showing 10 last lines from log file."   >> ${LOGFILE}	
				clear
                                clear
                                echo "#################### MBC ADMIN ####################"
                                echo "#                                                 #"
                                echo "#                                                 #"
                                echo "#                                                 #"
                                echo "#       Showing 20 last lines from log file       #"
                                echo "#       Press ENTER to go back to main menu       #"
                                echo "#                                                 #"
                                echo "#                                                 #"
                                echo "#                                                 #"
                                echo "###################################################"
                                tail -20 ${LOGFILE}
                                echo -n ""
                                read OPTMENU;;

                                4)
				echo "`date "+%m/%d/%Y  %H:%M:%S -  "`INF: Showing 10 last lines from buy log file."   >> ${LOGFILE}	
                                clear
                                clear
                                echo "#################### MBC ADMIN ####################"
                                echo "#                                                 #"
                                echo "#                                                 #"
                                echo "#                                                 #"
                                echo "#     Showing 20 last lines from buy log file     #"
                                echo "#       Press ENTER to go back to main menu       #"
                                echo "#                                                 #"
                                echo "#                                                 #"
                                echo "#                                                 #"
                                echo "###################################################"
                                tail -20 ${BUYLOGFILE}
                                echo -n ""
                                read OPTMENU;;

                                5)
				echo "`date "+%m/%d/%Y  %H:%M:%S -  "`INF: Showing 20 last lines from sell log file."   >> ${LOGFILE}	
                                clear
                                clear
                                echo "#################### MBC ADMIN ####################"
                                echo "#                                                 #"
                                echo "#                                                 #"
                                echo "#                                                 #"
                                echo "#      Showing 20 last lines from sell log file   #"
                                echo "#       Press ENTER to go back to main menu       #"
                                echo "#                                                 #"
                                echo "#                                                 #"
                                echo "#                                                 #"
                                echo "###################################################"
                                tail -20 ${SELLLOGFILE}
                                echo -n ""
                                read OPTMENU;;

                                6)
				echo "`date "+%m/%d/%Y  %H:%M:%S -  "`INF: Showing 10 last lines from alerts log file."   >> ${LOGFILE}	
                                clear
                                echo "#################### MBC ADMIN ####################"
                                echo "#                                                 #"
                                echo "#                                                 #"
                                echo "#                                                 #"
                                echo "#    Showing 20 last lines from alerts log file   #"
                                echo "#       Press ENTER to go back to main menu       #"
                                echo "#                                                 #"
                                echo "#                                                 #"
                                echo "#                                                 #"
                                echo "###################################################"
                                tail -20 ${ALERTLOGFILE}
                                echo -n ""
                                read OPTMENU;;

                                7)
				echo "`date "+%m/%d/%Y  %H:%M:%S -  "`INF: Show all variables values per crypto currency"   >> ${LOGFILE}	
                                clear
                                while true ; do
                                        #flag to ensure all inputed numbers are numbers type
                                        isNUMERO=true
                                        loadConfigFile
                                        clear
                                        echo "#################### MBC ADMIN ####################"
                                        echo "#                                                 #"
                                        echo "#      Choose the crypto Currency below:          #"
                                        echo "#   1 - BCH                                       #"
                                        echo "#   2 - BTC                                       #"
                                        echo "#   3 - XRP                                       #"
                                        echo "#   4 - ETH                                       #"
                                        echo "#   5 - LTC                                       #"
                                        echo "#   6 - Back to main menu                         #"
                                        echo "###################################################"
                                        echo -n "Choose an option number:"
                                        read OPTMENU
                                        echo $OPTMENU | grep -q -v "[^0-9]"

                                        if [ $? -ne 0 ];then
                                                isNUMERO=false
                                        fi

                                        if [ isNUMERO ];then
                                                case $OPTMENU in
                                                        1) #Starts loading an initial setup to the script runs properly
                                                           initialSetup
                                                           #BUY
                                                           echo "BCH_QTY=${BCH_QTY}"
                                                           echo "BCH_PRICE=${BCH_PRICE}"
                                                           echo "BCH_TOTAL_PRICE=${BCH_TOTAL_PRICE}"
                                                           #SELL
                                                           echo "BCH_R_LAST_SELL=${BCH_R_LAST_SELL}"
                                                           echo "BCH_TOTAL_LAST_SELL=${BCH_TOTAL_LAST_SELL}"
                                                           echo "BCH_FLAG_ALERT=${BCH_FLAG_ALERT}"
                                                           read OPTMENU;;

                                                        2) #Starts loading an initial setup to the script runs properly
                                                           initialSetup
                                                           #BUY
                                                           echo "BTC_QTY=${BTC_QTY}"
                                                           echo "BTC_PRICE=${BTC_PRICE}"
                                                           echo "BTC_TOTAL_PRICE=${BTC_TOTAL_PRICE}"
                                                           #SELL
                                                           echo "BTC_R_LAST_SELL=${BTC_R_LAST_SELL}"
                                                           echo "BTC_TOTAL_LAST_SELL=${BTC_TOTAL_LAST_SELL}"
                                                           echo "BTC_FLAG_ALERT=${BTC_FLAG_ALERT}"
                                                           read OPTMENU;;

                                                        3) #Starts loading an initial setup to the script runs properly
                                                           initialSetup
                                                           #BUY
                                                           echo "XRP_QTY=${XRP_QTY}"
                                                           echo "XRP_PRICE=${XRP_PRICE}"
                                                           echo "XRP_TOTAL_PRICE=${XRP_TOTAL_PRICE}"
                                                           #SELL
                                                           echo "XRP_R_LAST_SELL=${XRP_R_LAST_SELL}"
                                                           echo "XRP_TOTAL_LAST_SELL=${XRP_TOTAL_LAST_SELL}"
                                                           echo "XRP_FLAG_ALERT=${XRP_FLAG_ALERT}"
                                                           read OPTMENU;;

                                                        4) #Starts loading an initial setup to the script runs properly
                                                           initialSetup
                                                           #BUY
                                                           echo "ETH_QTY=${ETH_QTY}"
                                                           echo "ETH_PRICE=${ETH_PRICE}"
                                                           echo "ETH_TOTAL_PRICE=${ETH_TOTAL_PRICE}"
                                                           #SELL
                                                           echo "ETH_R_LAST_SELL=${ETH_R_LAST_SELL}"
                                                           echo "ETH_TOTAL_LAST_SELL=${ETH_TOTAL_LAST_SELL}"
                                                           echo "ETH_FLAG_ALERT=${ETH_FLAG_ALERT}"
                                                           read OPTMENU;;

                                                        5) #Starts loading an initial setup to the script runs properly
                                                           initialSetup
                                                           #BUY
                                                           echo "LTC_QTY=${LTC_QTY}"
                                                           echo "LTC_PRICE=${LTC_PRICE}"
                                                           echo "LTC_TOTAL_PRICE=${LTC_TOTAL_PRICE}"
                                                           #SELL
                                                           echo "LTC_R_LAST_SELL=${LTC_R_LAST_SELL}"
                                                           echo "LTC_TOTAL_LAST_SELL=${LTC_TOTAL_LAST_SELL}"
                                                           echo "LTC_FLAG_ALERT=${LTC_FLAG_ALERT}"
                                                           read OPTMENU;;
                                                        
                                                        6)clear
                                                          clear
                                                          break;;

                                                        *)
                                                                        echo "`date "+%m/%d/%Y  %H:%M:%S -  "`ERR: User has choosed an invalid option on interative menu."   >> ${LOGFILE}
                                                                        clear
                                                                        echo "#################### MBC ADMIN ####################"
                                                                        echo "#                                                 #"
                                                                        echo "#                                                 #"
                                                                        echo "#                                                 #"
                                                                        echo "#               Invalid option!                   #"
                                                                        echo "#       Press ENTER and try again                 #"
                                                                        echo "#                                                 #"
                                                                        echo "#                                                 #"
                                                                        echo "#                                                 #"
                                                                        echo "###################################################"
                                                                        echo -n ""
                                                                        read OPTMENU;;
                                                esac
                                        fi
                                done;;

                                8)
                                clear
                                clear
                                break;;

                                *)
				echo "`date "+%m/%d/%Y  %H:%M:%S -  "`ERR: User has choosed an invalid option on interative menu."   >> ${LOGFILE}
                                clear
                                echo "#################### MBC ADMIN ####################"
                                echo "#                                                 #"
                                echo "#                                                 #"
                                echo "#                                                 #"
                                echo "#               Invalid option!                   #"
                                echo "#       Press ENTER to go back to main menu       #"
                                echo "#                                                 #"
                                echo "#                                                 #"
                                echo "#                                                 #"
                                echo "###################################################"
                                echo -n ""
                                read OPTMENU;;
                        esac
                fi
        done
}


#Recalc current values with input values through CLI by user
#${1}: Currency type  ${2} quantity sold ${3} price paid
#recalcSelling ${1} ${2} ${3}  
function recalcBuying {
        #BUY:
        #XXX_R_QTY=(XXX__QTY + QTD_FLOAT)......[OK]
        #XXX_PRICE=(TOTAL_PRICE+(QTD_FLOAT * CURRENT_PRICE))/(R_QTY + QTD_FLOAT)......[OK]
        #XXX_TOTAL_PRICE=(XXX_TOTAL_PRICE + (QTD_FLOAT * CURRENT_PRICE))...........[OK]

        #SELL:
        #XXX_TOTAL_LAST_SELL=(R_QTY * R_LAST_SELL) + (QTD_FLOAT * CURRENT_PRICE)..................[OK]
        #XXX_R_LAST_SELL=(R_TOTAL_PRICE + (QTD_FLOAT * CURRENT_PRICE))/(R_QTY + QTD_FLOAT).............[OK]

        #${1}: Currency type  ${2} quantity bought ${3} price paid
        if [ "${1}" == "BCH" ];then
                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`INF.: Currency type choosed ${1}." >> ${BUYLOGFILE}
            #BUY
                BCH_R_QTY=`bc <<< "scale=2;($BCH_QTY+${2})"`
                BCH_R_QTY=$( printf "%.8f" $BCH_R_QTY )
                JSON_UPDATE=`jq --arg rqty "${BCH_R_QTY}" '.mbc.currency.bch.buy.rqty = $rqty' ${CONFIG_FILE}`
                echo $JSON_UPDATE > ${CONFIG_FILE}
                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`The new BCH reference quantitiy is ${BCH_R_QTY}."   >> ${BUYLOGFILE}

                BCH_PRICE=`bc <<< "scale=2;($BCH_TOTAL_PRICE+(${2}*${3}))/($BCH_QTY+${2})"`
                BCH_PRICE=$( printf "%.8f" $BCH_PRICE )
                JSON_UPDATE=`jq --arg rprice "${BCH_PRICE}" '.mbc.currency.bch.buy.rprice = $rprice' ${CONFIG_FILE}`
                echo $JSON_UPDATE > ${CONFIG_FILE}
                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`The new BCH reference price is ${BCH_PRICE}"   >> ${BUYLOGFILE}

                BCH_TOTAL_PRICE=`bc <<< "scale=2;(${BCH_QTY}*${BCH_R_LAST_SELL})"`
                BCH_TOTAL_PRICE=$( printf "%.8f" $BCH_TOTAL_PRICE )       
                JSON_UPDATE=`jq --arg rtotalprice "${BCH_TOTAL_PRICE}" '.mbc.currency.bch.buy.rtotalprice = $rtotalprice' ${CONFIG_FILE}`
                echo $JSON_UPDATE > ${CONFIG_FILE}
                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`The new BCH reference total price is ${BCH_TOTAL_PRICE}"   >> ${BUYLOGFILE}
            #SELL
echo "BCH_TOTAL_LAST_SELL=${BCH_TOTAL_LAST_SELL}"
echo "BCH_QTY=${BCH_QTY}"
                BCH_R_LAST_SELL=`bc <<< "scale=2;(${BCH_TOTAL_LAST_SELL}+(${2}*${3}))/($BCH_QTY+${2})"`
                BCH_R_LAST_SELL=$( printf "%.8f" $BCH_R_LAST_SELL )
                JSON_UPDATE=`jq --arg rlastsell "${BCH_R_LAST_SELL}" '.mbc.currency.bch.sell.rlastsell = $rlastsell' ${CONFIG_FILE}`
                echo $JSON_UPDATE > ${CONFIG_FILE}
                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`The new R_LAST_SELL price from BCH has a new reference price: ${BCH_R_LAST_SELL}"   >> ${BUYLOGFILE}

                BCH_TOTAL_LAST_SELL=`bc <<< "scale=2;(${BCH_R_QTY}*${BCH_R_LAST_SELL})"`
                BCH_TOTAL_LAST_SELL=$( printf "%.8f" $BCH_TOTAL_LAST_SELL )
                JSON_UPDATE=`jq --arg rtotallastsell "${BCH_TOTAL_LAST_SELL}" '.mbc.currency.bch.sell.rtotallastsell = $rtotallastsell' ${CONFIG_FILE}`
                echo $JSON_UPDATE > ${CONFIG_FILE}
                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`The new BCH reference total last sell price is ${BCH_TOTAL_LAST_SELL}"   >> ${BUYLOGFILE}

                BCH_FLAG_ALERT=1
                #update JSON value
                JSON_UPDATE=`jq --arg flagalert "${BCH_FLAG_ALERT}" '.mbc.currency.bch.sell.flagalert = $flagalert' ${CONFIG_FILE}`
                echo $JSON_UPDATE > ${CONFIG_FILE}
                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`BCH Flag alert has been enabled by user."   >> ${BUYLOGFILE}

        elif [ "${1}" == "BTC" ];then
                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`INF.: Currency type choosed ${1}." >> ${BUYLOGFILE}
            #BUY
                BTC_TOTAL_PRICE=`bc <<< "scale=2;($BTC_QTY*$BTC_R_LAST_SELL)"`
                BTC_TOTAL_PRICE=$( printf "%.8f" $BTC_TOTAL_PRICE )
                BTC_QTY=`bc <<< "scale=2;($BTC_QTY+${2})"`
                BTC_QTY=$( printf "%.8f" $BTC_QTY )
                JSON_UPDATE=`jq --arg rqty "${BTC_QTY}" '.mbc.currency.btc.buy.rqty = $rqty' ${CONFIG_FILE}`
                echo $JSON_UPDATE > ${CONFIG_FILE}
                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`The new BTC reference quantitiy is ${BTC_QTY}."   >> ${BUYLOGFILE}
 
                BTC_PRICE=`bc <<< "scale=2;($BTC_TOTAL_PRICE+(${2}*${3}))/(${BTC_QTY})"`
                BTC_PRICE=$( printf "%.8f" $BTC_PRICE )
                JSON_UPDATE=`jq --arg rprice "${BTC_PRICE}" '.mbc.currency.btc.buy.rprice = $rprice' ${CONFIG_FILE}`
                echo $JSON_UPDATE > ${CONFIG_FILE}
                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`The new BTC reference price is ${BTC_PRICE}"   >> ${BUYLOGFILE}

                BTC_R_LAST_SELL=${BTC_PRICE}
                JSON_UPDATE=`jq --arg rlastsell "${BTC_R_LAST_SELL}" '.mbc.currency.btc.sell.rlastsell = $rlastsell' ${CONFIG_FILE}`
                echo $JSON_UPDATE > ${CONFIG_FILE}
                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`The new R_LAST_SELL price from BTC has a new reference price: ${BTC_R_LAST_SELL}"   >> ${BUYLOGFILE}

                BTC_TOTAL_PRICE=`bc <<< "scale=2;(${BTC_TOTAL_PRICE}+(${2}*${3}))"`
                BTC_TOTAL_PRICE=$( printf "%.8f" $BTC_TOTAL_PRICE )       
                JSON_UPDATE=`jq --arg rtotalprice "${BTC_TOTAL_PRICE}" '.mbc.currency.btc.buy.rtotalprice = $rtotalprice' ${CONFIG_FILE}`
                echo $JSON_UPDATE > ${CONFIG_FILE}
                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`The new BTC reference total price is ${BTC_TOTAL_PRICE}"   >> ${BUYLOGFILE}
            #SELL
                BTC_TOTAL_LAST_SELL=`bc <<< "scale=2;(${BTC_QTY}*${BTC_R_LAST_SELL})+(${2}*${3})"`
                BTC_TOTAL_LAST_SELL=$( printf "%.8f" $BTC_TOTAL_LAST_SELL )
                JSON_UPDATE=`jq --arg rtotallastsell "${BTC_TOTAL_LAST_SELL}" '.mbc.currency.btc.sell.rtotallastsell = $rtotallastsell' ${CONFIG_FILE}`
                echo $JSON_UPDATE > ${CONFIG_FILE}
                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`The new BTC reference total last sell price is ${BTC_TOTAL_LAST_SELL}"   >> ${BUYLOGFILE}

                BTC_R_LAST_SELL=`bc <<< "scale=2;(${BTC_TOTAL_PRICE}+(${2}*${3}))/(${BTC_QTY}+${2})"`
                BTC_R_LAST_SELL=$( printf "%.8f" $BTC_R_LAST_SELL )
                JSON_UPDATE=`jq --arg rlastsell "${BTC_R_LAST_SELL}" '.mbc.currency.btc.sell.rlastsell = $rlastsell' ${CONFIG_FILE}`
                echo $JSON_UPDATE > ${CONFIG_FILE}
                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`The new BTC reference last sell price is ${BTC_R_LAST_SELL}"   >> ${BUYLOGFILE}

                BTC_FLAG_ALERT=1
                #update JSON value
                JSON_UPDATE=`jq --arg flagalert "${BTC_FLAG_ALERT}" '.mbc.currency.btc.sell.flagalert = $flagalert' ${CONFIG_FILE}`
                echo $JSON_UPDATE > ${CONFIG_FILE}
                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`BTC Flag alert has been enabled by user."   >> ${BUYLOGFILE}
        elif [ "${1}" == "XRP" ];then
                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`INF.: Currency type choosed ${1}." >> ${BUYLOGFILE}
            #BUY
                XRP_TOTAL_PRICE=`bc <<< "scale=2;($XRP_QTY*$XRP_R_LAST_SELL)"`
                XRP_TOTAL_PRICE=$( printf "%.8f" $XRP_TOTAL_PRICE )

                XRP_QTY=`bc <<< "scale=2;($XRP_QTY+${2})"`
                XRP_QTY=$( printf "%.8f" $XRP_QTY )
                JSON_UPDATE=`jq --arg rqty "${XRP_QTY}" '.mbc.currency.xrp.buy.rqty = $rqty' ${CONFIG_FILE}`
                echo $JSON_UPDATE > ${CONFIG_FILE}
                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`The new XRP reference quantitiy is ${XRP_QTY}."   >> ${BUYLOGFILE}
 
                XRP_PRICE=`bc <<< "scale=2;($XRP_TOTAL_PRICE+(${2}*${3}))/(${XRP_QTY})"`
                XRP_PRICE=$( printf "%.8f" $XRP_PRICE )
                JSON_UPDATE=`jq --arg rprice "${XRP_PRICE}" '.mbc.currency.xrp.buy.rprice = $rprice' ${CONFIG_FILE}`
                echo $JSON_UPDATE > ${CONFIG_FILE}
                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`The new XRP reference price is ${XRP_PRICE}"   >> ${BUYLOGFILE}
                XRP_R_LAST_SELL=${XRP_PRICE}
                JSON_UPDATE=`jq --arg rlastsell "${XRP_R_LAST_SELL}" '.mbc.currency.xrp.sell.rlastsell = $rlastsell' ${CONFIG_FILE}`
                echo $JSON_UPDATE > ${CONFIG_FILE}
                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`The new R_LAST_SELL price from XRP has a new reference price: ${XRP_R_LAST_SELL}"   >> ${BUYLOGFILE}

                XRP_TOTAL_PRICE=`bc <<< "scale=2;(${XRP_TOTAL_PRICE}+(${2}*${3}))"`
                XRP_TOTAL_PRICE=$( printf "%.8f" $XRP_TOTAL_PRICE )       
                JSON_UPDATE=`jq --arg rtotalprice "${XRP_TOTAL_PRICE}" '.mbc.currency.xrp.buy.rtotalprice = $rtotalprice' ${CONFIG_FILE}`
                echo $JSON_UPDATE > ${CONFIG_FILE}
                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`The new XRP reference total price is ${XRP_TOTAL_PRICE}"   >> ${BUYLOGFILE}

            #SELL
                XRP_TOTAL_LAST_SELL=`bc <<< "scale=2;(${XRP_QTY}*${XRP_R_LAST_SELL})+(${2}*${3})"`
                XRP_TOTAL_LAST_SELL=$( printf "%.8f" $XRP_TOTAL_LAST_SELL )
                JSON_UPDATE=`jq --arg rtotallastsell "${XRP_TOTAL_LAST_SELL}" '.mbc.currency.xrp.sell.rtotallastsell = $rtotallastsell' ${CONFIG_FILE}`
                echo $JSON_UPDATE > ${CONFIG_FILE}
                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`The new XRP reference total last sell price is ${XRP_TOTAL_LAST_SELL}"   >> ${BUYLOGFILE}

                XRP_R_LAST_SELL=`bc <<< "scale=2;(${XRP_TOTAL_PRICE}+(${2}*${3}))/(${XRP_QTY}+${2})"`
                XRP_R_LAST_SELL=$( printf "%.8f" $XRP_R_LAST_SELL )
                JSON_UPDATE=`jq --arg rlastsell "${XRP_R_LAST_SELL}" '.mbc.currency.xrp.sell.rlastsell = $rlastsell' ${CONFIG_FILE}`
                echo $JSON_UPDATE > ${CONFIG_FILE}
                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`The new XRP reference last sell price is ${XRP_R_LAST_SELL}"   >> ${BUYLOGFILE}

                XRP_FLAG_ALERT=1
                #update JSON value
                JSON_UPDATE=`jq --arg flagalert "${XRP_FLAG_ALERT}" '.mbc.currency.xrp.sell.flagalert = $flagalert' ${CONFIG_FILE}`
                echo $JSON_UPDATE > ${CONFIG_FILE}
                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`XRP Flag alert has been enabled by user."   >> ${BUYLOGFILE}

        elif [ "${1}" == "ETH" ];then
                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`INF.: Currency type choosed ${1}." >> ${BUYLOGFILE}
            #BUY
                ETH_TOTAL_PRICE=`bc <<< "scale=2;($ETH_QTY*$ETH_R_LAST_SELL)"`
                ETH_TOTAL_PRICE=$( printf "%.8f" $ETH_TOTAL_PRICE )

                ETH_QTY=`bc <<< "scale=2;($ETH_QTY+${2})"`
                ETH_QTY=$( printf "%.8f" $ETH_QTY )
                JSON_UPDATE=`jq --arg rqty "${ETH_QTY}" '.mbc.currency.eth.buy.rqty = $rqty' ${CONFIG_FILE}`
                echo $JSON_UPDATE > ${CONFIG_FILE}
                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`The new ETH reference quantitiy is ${ETH_QTY}."   >> ${BUYLOGFILE}
 
                ETH_PRICE=`bc <<< "scale=2;($ETH_TOTAL_PRICE+(${2}*${3}))/(${ETH_QTY})"`
                ETH_PRICE=$( printf "%.8f" $ETH_PRICE )
                JSON_UPDATE=`jq --arg rprice "${ETH_PRICE}" '.mbc.currency.eth.buy.rprice = $rprice' ${CONFIG_FILE}`
                echo $JSON_UPDATE > ${CONFIG_FILE}
                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`The new ETH reference price is ${ETH_PRICE}"   >> ${BUYLOGFILE}
                ETH_R_LAST_SELL=${ETH_PRICE}
                JSON_UPDATE=`jq --arg rlastsell "${ETH_R_LAST_SELL}" '.mbc.currency.eth.sell.rlastsell = $rlastsell' ${CONFIG_FILE}`
                echo $JSON_UPDATE > ${CONFIG_FILE}
                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`The new R_LAST_SELL price from ETH has a new reference price: ${ETH_R_LAST_SELL}"   >> ${BUYLOGFILE}

                ETH_TOTAL_PRICE=`bc <<< "scale=2;(${ETH_TOTAL_PRICE}+(${2}*${3}))"`
                ETH_TOTAL_PRICE=$( printf "%.8f" $ETH_TOTAL_PRICE )       
                JSON_UPDATE=`jq --arg rtotalprice "${ETH_TOTAL_PRICE}" '.mbc.currency.eth.buy.rtotalprice = $rtotalprice' ${CONFIG_FILE}`
                echo $JSON_UPDATE > ${CONFIG_FILE}
                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`The new ETH reference total price is ${ETH_TOTAL_PRICE}"   >> ${BUYLOGFILE}
            #SELL
                ETH_TOTAL_LAST_SELL=`bc <<< "scale=2;(${ETH_QTY}*${ETH_R_LAST_SELL})+(${2}*${3})"`
                ETH_TOTAL_LAST_SELL=$( printf "%.8f" $ETH_TOTAL_LAST_SELL )
                JSON_UPDATE=`jq --arg rtotallastsell "${ETH_TOTAL_LAST_SELL}" '.mbc.currency.eth.sell.rtotallastsell = $rtotallastsell' ${CONFIG_FILE}`
                echo $JSON_UPDATE > ${CONFIG_FILE}
                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`The new ETH reference total last sell price is ${ETH_TOTAL_LAST_SELL}"   >> ${BUYLOGFILE}

                ETH_R_LAST_SELL=`bc <<< "scale=2;(${ETH_TOTAL_PRICE}+(${2}*${3}))/(${ETH_QTY}+${2})"`
                ETH_R_LAST_SELL=$( printf "%.8f" $ETH_R_LAST_SELL )
                JSON_UPDATE=`jq --arg rlastsell "${ETH_R_LAST_SELL}" '.mbc.currency.eth.sell.rlastsell = $rlastsell' ${CONFIG_FILE}`
                echo $JSON_UPDATE > ${CONFIG_FILE}
                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`The new ETH reference last sell price is ${ETH_R_LAST_SELL}"   >> ${BUYLOGFILE}

                ETH_FLAG_ALERT=1
                #update JSON value
                JSON_UPDATE=`jq --arg flagalert "${ETH_FLAG_ALERT}" '.mbc.currency.eth.sell.flagalert = $flagalert' ${CONFIG_FILE}`
                echo $JSON_UPDATE > ${CONFIG_FILE}
                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`ETH Flag alert has been enabled by user."   >> ${BUYLOGFILE}
        elif [ "${1}" == "LTC" ];then
                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`INF.: Currency type choosed ${1}." >> ${BUYLOGFILE}
            #BUY
                LTC_TOTAL_PRICE=`bc <<< "scale=2;($LTC_QTY*$LTC_R_LAST_SELL)"`
                LTC_TOTAL_PRICE=$( printf "%.8f" $LTC_TOTAL_PRICE )

                LTC_QTY=`bc <<< "scale=2;($LTC_QTY+${2})"`
                LTC_QTY=$( printf "%.8f" $LTC_QTY )
                JSON_UPDATE=`jq --arg rqty "${LTC_QTY}" '.mbc.currency.ltc.buy.rqty = $rqty' ${CONFIG_FILE}`
                echo $JSON_UPDATE > ${CONFIG_FILE}
                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`The new LTC reference quantitiy is ${LTC_QTY}."   >> ${BUYLOGFILE}
 
                LTC_PRICE=`bc <<< "scale=2;($LTC_TOTAL_PRICE+(${2}*${3}))/(${LTC_QTY})"`
                LTC_PRICE=$( printf "%.8f" $LTC_PRICE )
                JSON_UPDATE=`jq --arg rprice "${LTC_PRICE}" '.mbc.currency.ltc.buy.rprice = $rprice' ${CONFIG_FILE}`
                echo $JSON_UPDATE > ${CONFIG_FILE}
                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`The new LTC reference price is ${LTC_PRICE}"   >> ${BUYLOGFILE}
                LTC_R_LAST_SELL=${LTC_PRICE}
                JSON_UPDATE=`jq --arg rlastsell "${LTC_R_LAST_SELL}" '.mbc.currency.ltc.sell.rlastsell = $rlastsell' ${CONFIG_FILE}`
                echo $JSON_UPDATE > ${CONFIG_FILE}
                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`The new R_LAST_SELL price from LTC has a new reference price: ${LTC_R_LAST_SELL}"   >> ${BUYLOGFILE}

                LTC_TOTAL_PRICE=`bc <<< "scale=2;(${LTC_TOTAL_PRICE}+(${2}*${3}))"`
                LTC_TOTAL_PRICE=$( printf "%.8f" $LTC_TOTAL_PRICE )       
                JSON_UPDATE=`jq --arg rtotalprice "${LTC_TOTAL_PRICE}" '.mbc.currency.ltc.buy.rtotalprice = $rtotalprice' ${CONFIG_FILE}`
                echo $JSON_UPDATE > ${CONFIG_FILE}
                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`The new LTC reference total price is ${LTC_TOTAL_PRICE}"   >> ${BUYLOGFILE}

            #SELL
                LTC_TOTAL_LAST_SELL=`bc <<< "scale=2;(${LTC_QTY}*${LTC_R_LAST_SELL})+(${2}*${3})"`
                LTC_TOTAL_LAST_SELL=$( printf "%.8f" $LTC_TOTAL_LAST_SELL )
                JSON_UPDATE=`jq --arg rtotallastsell "${LTC_TOTAL_LAST_SELL}" '.mbc.currency.ltc.sell.rtotallastsell = $rtotallastsell' ${CONFIG_FILE}`
                echo $JSON_UPDATE > ${CONFIG_FILE}
                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`The new LTC reference total last sell price is ${LTC_TOTAL_LAST_SELL}"   >> ${BUYLOGFILE}

                LTC_R_LAST_SELL=`bc <<< "scale=2;(${LTC_TOTAL_PRICE}+(${2}*${3}))/(${LTC_QTY}+${2})"`
                LTC_R_LAST_SELL=$( printf "%.8f" $LTC_R_LAST_SELL )
                JSON_UPDATE=`jq --arg rlastsell "${LTC_R_LAST_SELL}" '.mbc.currency.ltc.sell.rlastsell = $rlastsell' ${CONFIG_FILE}`
                echo $JSON_UPDATE > ${CONFIG_FILE}
                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`The new LTC reference last sell price is ${LTC_R_LAST_SELL}"   >> ${BUYLOGFILE}

                LTC_FLAG_ALERT=1
                #update JSON value
                JSON_UPDATE=`jq --arg flagalert "${LTC_FLAG_ALERT}" '.mbc.currency.ltc.sell.flagalert = $flagalert' ${CONFIG_FILE}`
                echo $JSON_UPDATE > ${CONFIG_FILE}
                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`LTC Flag alert has been enabled by user."   >> ${BUYLOGFILE}

        else
                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`ERR: Wrong currency type ${1}." >> ${BUYLOGFILE}
                exit 1
        fi

}

#Recalc current values with input values through CLI by user
#${1}: Currency type  ${2} quantity sold ${3} price paid
#        recalcSelling ${1} ${2} ${3}      
function recalcSelling {

        #R_QUANTIDADE=(R_QUANTIDADE + QTD_FLOAT)
        #R_PRICE=(R_TOTAL_PRICE+(QTD_FLOAT * CURRENT_PRICE))/(R_QUANTIDADE + QTD_FLOAT)
        #R_TOTAL_PRICE=(R_TOTAL_PRICE + (QTD_FLOAT * CURRENT_PRICE))
        #XXX_QTY=0
        #XXX_PRICE=0
        #XXX_TOTAL_PRICE=0
        #XXX_R_LAST_SELL=0
        #XXX_TOTAL_LAST_SELL=0
        #XXX_FLAG_ALERT=1
        
        #${1}: Currency type  ${2} quantity bought ${3} price paid
        if [ "${1}" == "BCH" ];then
                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`INF.: Currency type choosed ${1} to recalc selling." >> ${SELLLOGFILE}

            #BUY
                BCH_QTY=`bc <<< "scale=2;($BCH_QTY-${2})"`
                BCH_QTY=$( printf "%.8f" $BCH_QTY )
                JSON_UPDATE=`jq --arg rqty "${BCH_QTY}" '.mbc.currency.bch.buy.rqty = $rqty' ${CONFIG_FILE}`
                echo $JSON_UPDATE > ${CONFIG_FILE}
                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`The new BCH reference quantitiy is ${BCH_QTY}."   >> ${SELLLOGFILE}

            #SELL
                BCH_R_LAST_SELL=${3}
                BCH_R_LAST_SELL=$( printf "%.8f" $BCH_R_LAST_SELL )
                JSON_UPDATE=`jq --arg rlastsell "${BCH_R_LAST_SELL}" '.mbc.currency.bch.sell.rlastsell = $rlastsell' ${CONFIG_FILE}`
                echo $JSON_UPDATE > ${CONFIG_FILE}
                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`The new BCH reference last sell price is ${BCH_R_LAST_SELL}"   >> ${SELLLOGFILE}

                BCH_FLAG_ALERT=1
                #update JSON value
                JSON_UPDATE=`jq --arg flagalert "${BCH_FLAG_ALERT}" '.mbc.currency.bch.sell.flagalert = $flagalert' ${CONFIG_FILE}`
                echo $JSON_UPDATE > ${CONFIG_FILE}
                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`BCH Flag alert has been enabled by user."   >> ${SELLLOGFILE}

        elif [ "${1}" == "BTC" ];then
               echo "`date "+%m/%d/%Y  %H:%M:%S -  "`INF.: Currency type choosed ${1} to recalc selling." >> ${SELLLOGFILE}

            #BUY
                BTC_QTY=`bc <<< "scale=2;($BTC_QTY-${2})"`
                BTC_QTY=$( printf "%.8f" $BTC_QTY )
                JSON_UPDATE=`jq --arg rqty "${BTC_QTY}" '.mbc.currency.btc.buy.rqty = $rqty' ${CONFIG_FILE}`
                echo $JSON_UPDATE > ${CONFIG_FILE}
                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`The new BTC reference quantitiy is ${BTC_QTY}."   >> ${SELLLOGFILE}

            #SELL
                BTC_R_LAST_SELL=${3}
                BTC_R_LAST_SELL=$( printf "%.8f" $BTC_R_LAST_SELL )
                JSON_UPDATE=`jq --arg rlastsell "${BTC_R_LAST_SELL}" '.mbc.currency.btc.sell.rlastsell = $rlastsell' ${CONFIG_FILE}`
                echo $JSON_UPDATE > ${CONFIG_FILE}
                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`The new BTC reference last sell price is ${BTC_R_LAST_SELL}"   >> ${SELLLOGFILE}

                BTC_FLAG_ALERT=1
                #update JSON value
                JSON_UPDATE=`jq --arg flagalert "${BTC_FLAG_ALERT}" '.mbc.currency.btc.sell.flagalert = $flagalert' ${CONFIG_FILE}`
                echo $JSON_UPDATE > ${CONFIG_FILE}
                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`BTC Flag alert has been enabled by user."   >> ${SELLLOGFILE}

        elif [ "${1}" == "XRP" ];then
               echo "`date "+%m/%d/%Y  %H:%M:%S -  "`INF.: Currency type choosed ${1} to recalc selling." >> ${SELLLOGFILE}

            #BUY
                XRP_QTY=`bc <<< "scale=2;($XRP_QTY-${2})"`
                XRP_QTY=$( printf "%.8f" $XRP_QTY )
                JSON_UPDATE=`jq --arg rqty "${XRP_QTY}" '.mbc.currency.xrp.buy.rqty = $rqty' ${CONFIG_FILE}`
                echo $JSON_UPDATE > ${CONFIG_FILE}
                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`The new XRP reference quantitiy is ${XRP_QTY}."   >> ${SELLLOGFILE}

            #SELL
                XRP_R_LAST_SELL=${3}
                XRP_R_LAST_SELL=$( printf "%.8f" $XRP_R_LAST_SELL )
                JSON_UPDATE=`jq --arg rlastsell "${XRP_R_LAST_SELL}" '.mbc.currency.xrp.sell.rlastsell = $rlastsell' ${CONFIG_FILE}`
                echo $JSON_UPDATE > ${CONFIG_FILE}
                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`The new XRP reference last sell price is ${XRP_R_LAST_SELL}"   >> ${SELLLOGFILE}

                XRP_FLAG_ALERT=1
                #update JSON value
                JSON_UPDATE=`jq --arg flagalert "${XRP_FLAG_ALERT}" '.mbc.currency.xrp.sell.flagalert = $flagalert' ${CONFIG_FILE}`
                echo $JSON_UPDATE > ${CONFIG_FILE}
                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`XRP Flag alert has been enabled by user."   >> ${SELLLOGFILE}

        elif [ "${1}" == "ETH" ];then
               echo "`date "+%m/%d/%Y  %H:%M:%S -  "`INF.: Currency type choosed ${1} to recalc selling." >> ${SELLLOGFILE}

            #BUY
                ETH_QTY=`bc <<< "scale=2;($ETH_QTY-${2})"`
                ETH_QTY=$( printf "%.8f" $ETH_QTY )
                JSON_UPDATE=`jq --arg rqty "${ETH_QTY}" '.mbc.currency.eth.buy.rqty = $rqty' ${CONFIG_FILE}`
                echo $JSON_UPDATE > ${CONFIG_FILE}
                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`The new ETH reference quantitiy is ${ETH_QTY}."   >> ${SELLLOGFILE}

            #SELL
                ETH_R_LAST_SELL=${3}
                ETH_R_LAST_SELL=$( printf "%.8f" $ETH_R_LAST_SELL )
                JSON_UPDATE=`jq --arg rlastsell "${ETH_R_LAST_SELL}" '.mbc.currency.eth.sell.rlastsell = $rlastsell' ${CONFIG_FILE}`
                echo $JSON_UPDATE > ${CONFIG_FILE}
                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`The new ETH reference last sell price is ${ETH_R_LAST_SELL}"   >> ${SELLLOGFILE}

                ETH_FLAG_ALERT=1
                #update JSON value
                JSON_UPDATE=`jq --arg flagalert "${ETH_FLAG_ALERT}" '.mbc.currency.eth.sell.flagalert = $flagalert' ${CONFIG_FILE}`
                echo $JSON_UPDATE > ${CONFIG_FILE}
                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`ETH Flag alert has been enabled by user."   >> ${SELLLOGFILE}

        elif [ "${1}" == "LTC" ];then
               echo "`date "+%m/%d/%Y  %H:%M:%S -  "`INF.: Currency type choosed ${1} to recalc selling." >> ${SELLLOGFILE}

            #BUY
                LTC_QTY=`bc <<< "scale=2;($LTC_QTY-${2})"`
                LTC_QTY=$( printf "%.8f" $LTC_QTY )
                JSON_UPDATE=`jq --arg rqty "${LTC_QTY}" '.mbc.currency.ltc.buy.rqty = $rqty' ${CONFIG_FILE}`
                echo $JSON_UPDATE > ${CONFIG_FILE}
                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`The new LTC reference quantitiy is ${LTC_QTY}."   >> ${SELLLOGFILE}

            #SELL
                LTC_R_LAST_SELL=${3}
                LTC_R_LAST_SELL=$( printf "%.8f" $LTC_R_LAST_SELL )
                JSON_UPDATE=`jq --arg rlastsell "${LTC_R_LAST_SELL}" '.mbc.currency.ltc.sell.rlastsell = $rlastsell' ${CONFIG_FILE}`
                echo $JSON_UPDATE > ${CONFIG_FILE}
                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`The new LTC reference last sell price is ${LTC_R_LAST_SELL}"   >> ${SELLLOGFILE}

                LTC_FLAG_ALERT=1
                #update JSON value
                JSON_UPDATE=`jq --arg flagalert "${LTC_FLAG_ALERT}" '.mbc.currency.ltc.sell.flagalert = $flagalert' ${CONFIG_FILE}`
                echo $JSON_UPDATE > ${CONFIG_FILE}
                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`LTC Flag alert has been enabled by user."   >> ${SELLLOGFILE}

        else
                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`ERR: Wrong currency type ${1}." >> ${SELLLOGFILE}
                exit 1
        fi

}

function checkTimeToBuying {

        #Getting DELTA from each crypto coin
        BCH_DELTA_BUY=`bc <<< "((${BCH_LAST_PRICE}/${BCH_R_LAST_SELL})-1)"`
        BCH_DELTA_BUY=$( printf "%.8f" $BCH_DELTA_BUY )

        BTC_DELTA_BUY=`bc <<< "((${BTC_LAST_PRICE}/${BTC_R_LAST_SELL})-1)"`
        BTC_DELTA_BUY=$( printf "%.8f" $BTC_DELTA_BUY )

        XRP_DELTA_BUY=`bc <<< "((${XRP_LAST_PRICE}/${XRP_R_LAST_SELL})-1)"`
        XRP_DELTA_BUY=$( printf "%.8f" $XRP_DELTA_BUY )

        ETH_DELTA_BUY=`bc <<< "((${ETH_LAST_PRICE}/${ETH_R_LAST_SELL})-1)"`
        ETH_DELTA_BUY=$( printf "%.8f" $ETH_DELTA_BUY )

        LTC_DELTA_BUY=`bc <<< "((${LTC_LAST_PRICE}/${LTC_R_LAST_SELL})-1)"`
        LTC_DELTA_BUY=$( printf "%.8f" $LTC_DELTA_BUY )
        
        #Identifying which one is smaller.
        #Considering BCH=0, BTC=1, XRP=2, ETH=3, LTC=4
        VALUES[0]=${BCH_DELTA_BUY}
        VALUES[1]=${BTC_DELTA_BUY}
        VALUES[2]=${XRP_DELTA_BUY}
        VALUES[3]=${ETH_DELTA_BUY}
        VALUES[4]=${LTC_DELTA_BUY}

        echo "BCH=${BCH_DELTA_BUY}"
        echo "BTC=${BTC_DELTA_BUY}"
        echo "XRP=${XRP_DELTA_BUY}"
        echo "ETH=${ETH_DELTA_BUY}"
        echo "LTC=${LTC_DELTA_BUY}"

        for ((x=0; x < ${#VALUES[*]}; x++)) ; do
                count=0
                for ((y=0; y < ${#VALUES[*]}; y++)) ; do

                        FLAG_SMALLER=`echo ${VALUES[$x]}'<'${VALUES[$y]} | bc -l`
                        
                        if [ ${FLAG_SMALLER} -ne 0 ]; then
                                count=`bc <<< "${count}+1"`
                        fi
                done

                if [ $count -ge 4 ]; then
                        echo "Next Buy is crypto currency with DELTA: ${VALUES[$x]}"
                fi
        done
}



##########################################
#
# The main code starts here
#
#########################################

#Check access permission toexecute this script
if [ `id -u` -ne 0 ] && [ `id -g` -ne 0 ]; then
        echo "`date "+%m/%d/%Y  %H:%M:%S -  "`ERR: You need root access permission to execute ${0} command." >> ${LOGFILE}
        exit 1
else
	echo "`date "+%m/%d/%Y  %H:%M:%S -  "`INF: User has root access to execute the script."  >> ${LOGFILE}
fi

#Capture line command parameter
if [ "${1}" = "-h" ]; then
        #Show usage function
        usageScript
        exit 0
elif [ "${1}" = "scan" ]; then
   #Starts loading an initial setup to the script runs properly
   initialSetup

   #Works in loop checking checking and comparing with new prices
   while true ; do

        #check if config file exists to load all its variables values or create a new one.
        loadConfigFile

        #Load LAST_PRICE from Mecardobitcoin website API
        checkNewPricesUpdates

        #Compare each LAST_PRICE with R_LAST_SELL of each crypto currency. If its 3% above an alert by email is sent just once.
        checkTimeToSell ${BCH_R_LAST_SELL} ${BCH_LAST_PRICE} "BCH"
        checkTimeToSell ${BTC_R_LAST_SELL} ${BTC_LAST_PRICE} "BTC"
        checkTimeToSell ${XRP_R_LAST_SELL} ${XRP_LAST_PRICE} "XRP"
        checkTimeToSell ${ETH_R_LAST_SELL} ${ETH_LAST_PRICE} "ETH"
        checkTimeToSell ${LTC_R_LAST_SELL} ${LTC_LAST_PRICE} "LTC"

        #Wait 5 seconds by default before start the loop again.
        sleep ${WAITING}
   done

elif [ "${1}" = "scanbuy" ]; then

        #Starts loading an initial setup to the script runs properly
        initialSetup

        #Load LAST_PRICE from Mecardobitcoin website API
        checkNewPricesUpdates

        #Compare each LAST_PRICE with R_LAST_SELL of each crypto currency. If its 3% above an alert by email is sent just once.
        checkTimeToBuying

elif [ "${1}" = "menu" ]; then
        #check if config file exists to load all its variables values or create a new one.
        initialSetup

        #1- Enable/Disable SELL's alerts
        #2- Set up a new value to LAST_SELL
        #3- Shows 10 last lines from log file
        #4- Shows 10 last buy operations
        #5- Shows 10 last sell operations
        #6- Shows 10 last alerts sent by email
        interativeMode

        exit 0
elif [ "${1}" = "buy" ] && [ ! -z "${2}" ] && [ ! -z "${3}" ]  && [ ! -z "${4}" ]; then
        echo "BUY"
        #check if config file exists to load all its variables values or create a new one.
        initialSetup

        #Recalc current values with input values through CLI by user
        #${2}: Currency type  ${3} quantity bought ${4} price paid
        recalcBuying ${2} ${3} ${4}      
        exit 0

elif [ "${1}" = "sell" ] && [ ! -z "${2}" ] && [ ! -z "${3}" ] && [ ! -z "${4}" ]; then
        echo "SELL"
        #check if config file exists to load all its variables values or create a new one.
        initialSetup

        #Recalc current values with input values through CLI by user
        #${2}: Currency type  ${3} quantity sold ${4} price paid
        recalcSelling ${2} ${3} ${4}      

        exit 0
else
        #Show usage function
        usageScript
        exit 0
fi
