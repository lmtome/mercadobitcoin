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
#SELL0
BTC_R_LAST_SELL=0
BTC_TOTAL_LAST_SELL=0
BTC_FLAG_ALERT=1

#BUY
CHZ_QTY=0
CHZ_PRICE=0
CHZ_TOTAL_PRICE=0
#SELL
CHZ_R_LAST_SELL=0
CHZ_TOTAL_LAST_SELL=0
CHZ_FLAG_ALERT=1

#BUY
ETH_QTY=0
ETH_PRICE=0
ETH_TOTAL_PRICE=0
#SELL
ETH_R_LAST_SELL=0
ETH_TOTAL_LAST_SELL=0
ETH_FLAG_ALERT=1

#BUY
LTC_QTY=0
LTC_PRICE=0
LTC_TOTAL_PRICE=0
#SELL
LTC_R_LAST_SELL=0
LTC_TOTAL_LAST_SELL=0
LTC_FLAG_ALERT=1


#Consider it's the first time user is running the script
FLAG_FIRST_TIME=1

#Initialization of all LAST prices variables
BCH_LAST_PRICE=0
BTC_LAST_PRICE=0
CHZ_LAST_PRICE=0
ETH_LAST_PRICE=0
LTC_LAST_PRICE=0


###########################################
#
# Functions
#
###########################################

#OK This function is called always the user does not choose an expected option and shows the script usage.
function usageScript {
        echo "Usage: ${0} [ -h | scan | menu | [ buy | sell ] <BCH|BTC|CHZ|ETH|LTC> <qty> <price> ]"
        echo ""
        echo "-h           show the command usage."
        echo ""
        echo "scan - check for good prices to buy one of these crypto currencies below: "
        echo "BCH : Bitcoin Cash"
        echo "BTC : Bitcoin"
        echo "CHZ : Chiliz"
        echo "ETH : Ethereum"
        echo "LTC : Litecoin"
        echo ""
        echo "menu - Interative mode useful to speed up set up process and extract reports."
        echo ""
        echo "buy - Set up the system with new crypto currency user has bought."
        echo ""
        echo "sell - Set up the system with new crypto currency user has sold."
        echo ""
        exit 2
}

function loadConfigFile {

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
                CHZ_QTY=`cat ${CONFIG_FILE} | jq --raw-output '.mbc.currency.chz.buy.rqty'`
                CHZ_QTY=$( printf "%.8f" $CHZ_QTY )
                CHZ_PRICE=`cat ${CONFIG_FILE} | jq --raw-output '.mbc.currency.chz.buy.rprice'`
                CHZ_PRICE=$( printf "%.8f" $CHZ_PRICE )
                CHZ_TOTAL_PRICE=`cat ${CONFIG_FILE} | jq --raw-output '.mbc.currency.chz.buy.rtotalprice'`
                CHZ_TOTAL_PRICE=$( printf "%.8f" $CHZ_TOTAL_PRICE )
                #SELL
                CHZ_R_LAST_SELL=`cat ${CONFIG_FILE} | jq --raw-output '.mbc.currency.chz.sell.rlastsell'`
                CHZ_R_LAST_SELL=$( printf "%.8f" $CHZ_R_LAST_SELL )
                CHZ_TOTAL_LAST_SELL=`cat ${CONFIG_FILE} | jq --raw-output '.mbc.currency.chz.sell.rtotallastsell'`
                CHZ_TOTAL_LAST_SELL=$( printf "%.8f" $CHZ_TOTAL_LAST_SELL )
                CHZ_FLAG_ALERT=`cat ${CONFIG_FILE} | jq --raw-output '.mbc.currency.chz.sell.flagalert'`

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

                #CHZ
                echo "About CHZ crypto currency:"
                echo -n "What is the quantity? Please input only numbers. Eg.: 0.12345678  =>"
                read CHZ_QTY
                CHZ_QTY=$( printf "%.8f" $CHZ_QTY )
                echo -n "What is the price? Please input only numbers. Eg.: 0.12345678  =>"
                read CHZ_PRICE
                CHZ_PRICE=$( printf "%.8f" $CHZ_PRICE )
                CHZ_TOTAL_PRICE=`bc <<< "scale=2;(${CHZ_QTY}*${CHZ_PRICE})"`
                CHZ_TOTAL_PRICE=$( printf "%.8f" $CHZ_TOTAL_PRICE )

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

                #Save new data input by user
                echo -e "{\"mbc\":{\"currency\":{\"bch\":{\"buy\":{\"rqty\":\"${BCH_QTY}\",\"rprice\":\"${BCH_PRICE}\",\"rtotalprice\":\"${BCH_TOTAL_PRICE}\"},\"sell\":{\"rlastsell\":\"${BCH_PRICE}\",\"rtotallastsell\":\"${BCH_PRICE}\",\"flagalert\":\"1\"}},\"btc\":{\"buy\":{\"rqty\":\"${BTC_QTY}\",\"rprice\":\"${BTC_PRICE}\",\"rtotalprice\":\"${BTC_TOTAL_PRICE}\"},\"sell\":{\"rlastsell\":\"${BTC_PRICE}\",\"rtotallastsell\":\"${BTC_PRICE}\",\"flagalert\":\"1\"}},\"chz\":{\"buy\":{\"rqty\":\"${CHZ_QTY}\",\"rprice\":\"${CHZ_PRICE}\",\"rtotalprice\":\"${CHZ_TOTAL_PRICE}\"},\"sell\":{\"rlastsell\":\"${CHZ_PRICE}\",\"rtotallastsell\":\"${BCH_PRICE}\",\"flagalert\":\"1\"}},\"eth\":{\"buy\":{\"rqty\":\"${ETH_QTY}\",\"rprice\":\"${ETH_PRICE}\",\"rtotalprice\":\"${ETH_TOTAL_PRICE}\"},\"sell\":{\"rlastsell\":\"${ETH_PRICE}\",\"rtotallastsell\":\"${ETH_PRICE}\",\"flagalert\":\"1\"}},\"ltc\":{\"buy\":{\"rqty\":\"${LTC_QTY}\",\"rprice\":\"${LTC_PRICE}\",\"rtotalprice\":\"${LTC_TOTAL_PRICE}\"},\"sell\":{\"rlastsell\":\"${LTC_PRICE}\",\"rtotallastsell\":\"${LTC_PRICE}\",\"flagalert\":\"1\"}}},\"adminconfig\":{\"flagfirsttime\":\"0\"}}}" > ${CONFIG_FILE}

        else
                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`Reading config file ${CONFIG_FILE}"   >> ${LOGFILE}

                #Read config file and set up each currency reference price
                loadConfigFile
        fi
}


#Alertis user by email about about new prices have reached the thresholds
function alertUser {
        #Alert user
        #alertUser "dwulbr@gmail.com" "Subject: BCH is at least 3% below of its reference price. Check it ASAP!"
        echo ${2} | ssmtp ${1}
}


#OK Capture cripto currencies values (Last, buy and sell)
function checkNewPricesUpdates {
        #BCH
        BCH_LAST_PRICE=`curl -s https://www.mercadobitcoin.net/api/BCH/ticker | jq --raw-output '.ticker.last'`
        BCH_LAST_PRICE=$( printf "%.8f" $BCH_LAST_PRICE )

        #BTC
        BTC_LAST_PRICE=`curl -s https://www.mercadobitcoin.net/api/BTC/ticker | jq --raw-output '.ticker.last'`
        BTC_LAST_PRICE=$( printf "%.8f" $BTC_LAST_PRICE )

        #CHZ
        CHZ_LAST_PRICE=`curl -s https://www.mercadobitcoin.net/api/CHZ/ticker | jq --raw-output '.ticker.last'`
        CHZ_LAST_PRICE=$( printf "%.8f" $CHZ_LAST_PRICE )

        #ETH
        ETH_LAST_PRICE=`curl -s https://www.mercadobitcoin.net/api/ETH/ticker | jq --raw-output '.ticker.last'`
        ETH_LAST_PRICE=$( printf "%.8f" $ETH_LAST_PRICE )

        #LTC
        LTC_LAST_PRICE=`curl -s https://www.mercadobitcoin.net/api/LTC/ticker | jq --raw-output '.ticker.last'`
        LTC_LAST_PRICE=$( printf "%.8f" $LTC_LAST_PRICE )
}


#check and alert user to sell if the last price has reached an expected price: i
#checkTimeToSell ${BCH_R_LAST_SELL} ${BCH_LAST_PRICE} "BCH"
function checkTimeToSell {


        #R_LAST_SELL_GP is reference price + 3% of gross profit...
        R_LAST_SELL_GP=`bc <<< "scale=2;(${1}+(${GROSS_PROFIT_PERC}/100)*${1})"`
        R_LAST_SELL_GP=$( printf "%.8f" $R_LAST_SELL_GP )

        #...and last price must be iqual or greater than the reference price + 3% of gross profit to alert the user: Sell time!!!
        FLAG_SELL_TIME=`echo ${2}'>'${R_LAST_SELL_GP} | bc -l`

        #TRUE for LAST PRICE IS GREATER THAN R_LAST_SELL(3% above)
        if [ ${FLAG_SELL_TIME} -ne 0 ];then


                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`${3} last price is currently 3% above of ${3} R LAST SELL"   >> ${LOGFILE}

                if [ "${3}" == "BCH" ];then
                        #Alert user
                        if [ ${BCH_FLAG_ALERT} -eq 1 ];then
                                alertUser "dwulbr@gmail.com" "Subject: ${3} last price is currently 3% above of ${3} R LAST SELL"

                                #Disable alert for BCH coin
                                BCH_FLAG_ALERT=0

                                #update JSON value
                                JSON_UPDATE=`jq --arg flagalert "${BCH_FLAG_ALERT}" '.mbc.currency.bch.sell.flagalert = $flagalert' ${CONFIG_FILE}`
                                echo $JSON_UPDATE > ${CONFIG_FILE}
                                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`${3} Flag alert has been disabled."   >> ${LOGFILE}
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
                                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`${3} Flag alert has been disabled."   >> ${LOGFILE}
                        fi

                elif [ "${3}" == "CHZ" ];then
                        #Alert user
                        if [ ${CHZ_FLAG_ALERT} -eq 1 ];then
                                alertUser "dwulbr@gmail.com" "Subject: ${3} last price is currently 3% above of ${3} R LAST SELL"

                                #Disable alert for CHZ coin
                                CHZ_FLAG_ALERT=0


                                #update JSON value
                                JSON_UPDATE=`jq --arg flagalert "${CHZ_FLAG_ALERT}" '.mbc.currency.chz.sell.flagalert = $flagalert' ${CONFIG_FILE}`
                                echo $JSON_UPDATE > ${CONFIG_FILE}
                                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`${3} Flag alert has been disabled."   >> ${LOGFILE}
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
                                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`${3} Flag alert has been disabled."   >> ${LOGFILE}
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
                                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`${3} Flag alert has been disabled."   >> ${LOGFILE}
                        fi
                else
                        echo "`date "+%m/%d/%Y  %H:%M:%S -  "`${3} is a invalid crypto currency."   >> ${LOGFILE}
                fi
        else
                #Last value does not reach 3% above of reference price for ${3} crypto currency."
                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`Last price is not 3% above of ${3} R LAST SELL."   >> ${LOGFILE}
        fi

}


#Check and alert user to purchase if the last price has reached an expected price.
function checkTimeToBuy {

        while true ; do
                #LESS_PRICE is reference price - 3%...
                LESS_PRICE=`bc <<< "${BCH_REF}-(${BCH_REF}/(${GROSS_PROFIT_PERC}/100))"`

                #...and last price must be 3% less than the reference priceto alert the user it's buy time!!!
                if [ ${BCH_LAST_PRICE} -le ${LESS_PRICE} ];then
                        PERC=`bc <<< "(${BCH_LAST_PRICE}*100)/${BCH_REF}"`
                        echo "Current % below of reference price is: [${PERC}%]"
                        #Alert user
                        alertUser "dwulbr@gmail.com" "Subject: BCH is at least 3% below of its reference price. Check it ASAP!"
                fi
                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`Current % of loss for BCH is: [${PERC}%]"   >> ${LOGFILE}

                #LESS_PRICE is reference price - 3%...
                LESS_PRICE=`bc <<< "${BTC_REF}-(${BTC_REF}/(${GROSS_PROFIT_PERC}/100))"`

                #...and last price must be 3% less than the reference priceto alert the user it's buy time!!!
                if [ ${BTC_LAST_PRICE} -le ${LESS_PRICE} ];then
                        PERC=`bc <<< "(${BTC_LAST_PRICE}*100)/${BTC_REF}"`
                        echo "Current % below of reference price is: [${PERC}%]"
                        #Alert user
                        alertUser "dwulbr@gmail.com" "Subject: BTC is at least 3% below of its reference price. Check it ASAP!"
                fi
                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`Current % of loss for BTC is: [${PERC}%]"   >> ${LOGFILE}

                #LESS_PRICE is reference price - 3%...
                LESS_PRICE=`bc <<< "${CHZ_REF}-(${CHZ_REF}/(${GROSS_PROFIT_PERC}/100))"`

                #...and last price must be 3% less than the reference priceto alert the user it's buy time!!!
                if [ ${CHZ_LAST_PRICE} -le ${LESS_PRICE} ];then
                        PERC=`bc <<< "(${CHZ_LAST_PRICE}*100)/${CHZ_REF}"`
                        echo "Current % below of reference price is: [${PERC}%]"
                        #Alert user
                        alertUser "dwulbr@gmail.com" "Subject: CHZ is at least 3% below of its reference price. Check it ASAP!"
                fi
                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`Current % of loss for CHZ is: [${PERC}%]"   >> ${LOGFILE}

                #LESS_PRICE is reference price - 3%...
                LESS_PRICE=`bc <<< "${ETH_REF}-(${ETH_REF}/(${GROSS_PROFIT_PERC}/100))"`

                #...and last price must be 3% less than the reference priceto alert the user it's buy time!!!
                if [ ${ETH_LAST_PRICE} -le ${LESS_PRICE} ];then
                        PERC=`bc <<< "(${ETH_LAST_PRICE}*100)/${ETH_REF}"`
                        echo "Current % below of reference price is: [${PERC}%]"
                        #Alert user
                        alertUser "dwulbr@gmail.com" "Subject: ETH is at least 3% below of its reference price. Check it ASAP!"

                fi
                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`Current % of loss for ETH is: [${PERC}%]"   >> ${LOGFILE}

                #LESS_PRICE is reference price - 3%...
                LESS_PRICE=`bc <<< "${LTC_REF}-(${LTC_REF}/(${GROSS_PROFIT_PERC}/100))"`

                #...and last price must be 3% less than the reference priceto alert the user it's buy time!!!
                if [ ${LTC_LAST_PRICE} -le ${LESS_PRICE} ];then
                        PERC=`bc <<< "(${LTC_LAST_PRICE}*100)/${LTC_REF}"`
                        echo "Current % below of reference price is: [${PERC}%]"
                        #Alert user
                        alertUser "dwulbr@gmail.com" "Subject: LTC is at least 3% below of its reference price. Check it ASAP!"
                fi


                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`Current % of loss for LTC is: [${PERC}%]"   >> ${LOGFILE}

                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`purchase any currency?"   >> ${LOGFILE}

                isNUM=true

                echo "Would you like to purchase any currency?"
                echo "1 - BCH"
                echo "2 - BTC"
                echo "3 - CHZ"
                echo "4 - ETH"
                echo "5 - LTC"
                echo "6 - None"
                echo -n "Just choose one(number ONLY):"
                read BUY_OPT

                #check if it's number
                echo $BUY_OPT | grep -q -v "[^0-9]"
                if [ $? -ne 0 ];then
                        isNUM=false
                fi

                #Show a menu to the user and afeter he/she choose a valid option the last price 3% less than reference price.
                #A new reference price is set up in JSON config file
                if $isNUM ; then
                        case $BUY_OPT in
                                1) echo "BCH currency purchase approved!"
                                   #update JSON value
                                   JSON_UPDATE=`jq '.refprice.bch = "${BCH_LAST_PRICE}"' `${CONFIG_FILE}``
                                   echo $JSON_UPDATE > ${CONFIG_FILE}
                                   #update reference variable
                                   BCH_REF=${BCH_LAST_PRICE}
                                   echo "`date "+%m/%d/%Y  %H:%M:%S -  "`BCH has been purchased."   >> ${LOGFILE}
                                   break ;;

                                2) echo "BTC currency purchase approved!"
                                   #update JSON value
                                   JSON_UPDATE=`jq '.refprice.btc = "${BTC_LAST_PRICE}"' `${CONFIG_FILE}``
                                   echo $JSON_UPDATE > ${CONFIG_FILE}
                                   #update reference variable
                                   BTC_REF=${BTC_LAST_PRICE}
                                   echo "`date "+%m/%d/%Y  %H:%M:%S -  "`BTC has been purchased."   >> ${LOGFILE}
                                   break ;;

                                3) echo "CHZ currency purchase approved!"
                                   #update JSON value
                                   JSON_UPDATE=`jq '.refprice.chz = "${CHZ_LAST_PRICE}"' `${CONFIG_FILE}``
                                   echo $JSON_UPDATE > ${CONFIG_FILE}
                                   #update reference variable
                                   CHZ_REF=${CHZ_LAST_PRICE}
                                   echo "`date "+%m/%d/%Y  %H:%M:%S -  "`CHZ has been purchased."   >> ${LOGFILE}
                                   break ;;

                                4) echo "ETH currency purchase approved!"
                                   #update JSON value
                                   JSON_UPDATE=`jq '.refprice.eth = "${ETH_LAST_PRICE}"' `${CONFIG_FILE}``
                                   echo $JSON_UPDATE > ${CONFIG_FILE}
                                   #update reference variable
                                   ETH_REF=${ETH_LAST_PRICE}
                                   echo "`date "+%m/%d/%Y  %H:%M:%S -  "`ETH has been purchased."   >> ${LOGFILE}
                                   break ;;

                                5) echo "LTC currency purchase approved!"
                                   #update JSON value
                                   JSON_UPDATE=`jq '.refprice.ltc = "${LTC_LAST_PRICE}"' `${CONFIG_FILE}``
                                   echo $JSON_UPDATE > ${CONFIG_FILE}
                                   #update reference variable
                                   LTC_REF=${LTC_LAST_PRICE}
                                   echo "`date "+%m/%d/%Y  %H:%M:%S -  "`LTC has been purchased."   >> ${LOGFILE}
                                   break ;;

                                6) echo "Currency purchase has been denied!"
                                   echo "`date "+%m/%d/%Y  %H:%M:%S -  "`Currency purchase has been denied!"   >> ${LOGFILE}
                                   break ;;

                                *) echo "Invalid option!"
                                   echo "`date "+%m/%d/%Y  %H:%M:%S -  "`Invalid option!"   >> ${LOGFILE}
                        esac
                else
                        echo "Invalid option!"
                        echo "`date "+%m/%d/%Y  %H:%M:%S -  "`Option is not a number!"   >> ${LOGFILE}
                fi
        done

}

#Open an interative mode
function interativeMode {


        #Start CLI menu
        while true ; do
                #flag to ensure all inputed numbers are numbers type
                isNUM=true

                clear
                echo "#################### MBC ADMIN ####################"
                echo "#                                                 #"
                echo "#  1 - Enable SELL's alerts for all currencies    #"
                echo "#  2 - Set up a new value to LAST SELL            #"
                echo "#  3 - Shows 10 last lines from log file          #"
                echo "#  4 - Shows 10 last buy operations               #"
                echo "#  5 - Shows 10 last sell operation               #"
                echo "#  6 - Shows 10 last alerts sent by email         #"
                echo "#  7 - Exit                                       #"
                echo "###################################################"
                echo -n "Choose an option number:"
                read OPTMENU
                echo $OPTMENU | grep -q -v "[^0-9]"

                if [ $? -ne 0 ];then
                        isNUM=false
                fi

                if [ isNUM ];then
                        case $OPTMENU in
                                1)clear
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
                                read OPTMENU;;

                                2)clear
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

                                echo -n "CHZ last sell price (Eg.: 0.12345678)     =>"
                                read CHZ_R_LAST_SELL

                                echo -n "ETH last sell price (Eg.: 0.12345678)     =>"
                                read ETH_R_LAST_SELL

                                echo -n "LTC last sell price (Eg.: 0.12345678)     =>"
                                read LTC_R_LAST_SELL

                                clear
                                echo "#################### MBC ADMIN ####################"
                                echo "#                                                 "
                                echo "#         LAST SELL PRICES HAVE BEEN SETUP        "
                                echo "#   (BCH):$BCH_R_LAST_SELL                        "
                                echo "#   (BTC):$BTC_R_LAST_SELL                        "
                                echo "#   (CHZ):$CHZ_R_LAST_SELL                        "
                                echo "#   (ETH):$ETH_R_LAST_SELL                        "
                                echo "#   (LTC):$LTC_R_LAST_SELL                        "
                                echo "#       Press ENTER to go back to main menu       "
                                echo "###################################################"
                                echo -n ""
                                read OPTMENU;;

                                3)clear
                                echo "#################### MBC ADMIN ####################"
                                echo "#                                                 #"
                                echo "#                                                 #"
                                echo "#                                                 #"
                                echo "#       Showing 10 last lines from log file       #"
                                echo "#       Press ENTER to go back to main menu       #"
                                echo "#                                                 #"
                                echo "#                                                 #"
                                echo "#                                                 #"
                                echo "###################################################"
                                tail -10 ${LOGFILE}
                                echo -n ""
                                read OPTMENU;;

                                4)clear
                                echo "#################### MBC ADMIN ####################"
                                echo "#                                                 #"
                                echo "#                                                 #"
                                echo "#                                                 #"
                                echo "#     Showing 10 last lines from buy log file     #"
                                echo "#       Press ENTER to go back to main menu       #"
                                echo "#                                                 #"
                                echo "#                                                 #"
                                echo "#                                                 #"
                                echo "###################################################"
                                tail -10 ${BUYLOGFILE}
                                echo -n ""
                                read OPTMENU;;

                                5)clear
                                echo "#################### MBC ADMIN ####################"
                                echo "#                                                 #"
                                echo "#                                                 #"
                                echo "#                                                 #"
                                echo "#      Showing 10 last lines from sell log file   #"
                                echo "#       Press ENTER to go back to main menu       #"
                                echo "#                                                 #"
                                echo "#                                                 #"
                                echo "#                                                 #"
                                echo "###################################################"
                                tail -10 ${SELLLOGFILE}
                                echo -n ""
                                read OPTMENU;;

                                6)clear
                                echo "#################### MBC ADMIN ####################"
                                echo "#                                                 #"
                                echo "#                                                 #"
                                echo "#                                                 #"
                                echo "#    Showing 10 last lines from alerts log file   #"
                                echo "#       Press ENTER to go back to main menu       #"
                                echo "#                                                 #"
                                echo "#                                                 #"
                                echo "#                                                 #"
                                echo "###################################################"
                                tail -10 ${ALERTLOGFILE}
                                echo -n ""
                                read OPTMENU;;

                                7)break;;

                                *)clear
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



##########################################
#
# The main code starts here
#
#########################################

#Check access permission toexecute this script
if [ `id -u` -ne 0 ] && [ `id -g` -ne 0 ]; then
        echo "`date "+%m/%d/%Y  %H:%M:%S -  "`ERR: You need root access permission to execute ${0} command." >> ${LOGFILE}
        exit 1
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
        echo "SCAN"

        #check if config file exists to load all its variables values or create a new one.
        loadConfigFile

        #Load LAST_PRICE from Mecardobitcoin website API
        checkNewPricesUpdates

        #Compare each LAST_PRICE with R_LAST_SELL of each crypto currency. If it's 3% above an alert by email is sent just once.
        checkTimeToSell ${BCH_R_LAST_SELL} ${BCH_LAST_PRICE} "BCH"
        checkTimeToSell ${BTC_R_LAST_SELL} ${BTC_LAST_PRICE} "BTC"
        checkTimeToSell ${CHZ_R_LAST_SELL} ${CHZ_LAST_PRICE} "CHZ"
        checkTimeToSell ${ETH_R_LAST_SELL} ${ETH_LAST_PRICE} "ETH"
        checkTimeToSell ${LTC_R_LAST_SELL} ${LTC_LAST_PRICE} "LTC"

        #Wait 5 seconds by default before start the loop again.
        sleep ${WAITING}
   done

elif [ "${1}" = "menu" ]; then
        echo "MENU"
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

        exit 0

elif [ "${1}" = "sell" ] && [ ! -z "${2}" ] && [ ! -z "${3}" ] && [ ! -z "${4}" ]; then
        echo "SELL"
        #check if config file exists to load all its variables values or create a new one.
        initialSetup

        exit 0
else
        #Show usage function
        usageScript
        exit 0
fi
