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
function checkNewPricesUpdates {
        #BCH
        BCH_LAST_PRICE=`curl -s https://www.mercadobitcoin.net/api/BCH/ticker | jq --raw-output '.ticker.last'`
        #BCH_BUY_PRICE=`curl -s https://www.mercadobitcoin.net/api/BCH/ticker | jq --raw-output '.ticker.buy'`
        #BCH_SELL_PRICE=`curl -s https://www.mercadobitcoin.net/api/BCH/ticker | jq --raw-output '.ticker.sell'`

        #BTC
        BTC_LAST_PRICE=`curl -s https://www.mercadobitcoin.net/api/BTC/ticker | jq --raw-output '.ticker.last'`
        #BTC_BUY_PRICE=`curl -s https://www.mercadobitcoin.net/api/BTC/ticker | jq --raw-output '.ticker.buy'`
        #BTC_SELL_PRICE=`curl -s https://www.mercadobitcoin.net/api/BTC/ticker | jq --raw-output '.ticker.sell'`

        #CHZ
        CHZ_LAST_PRICE=`curl -s https://www.mercadobitcoin.net/api/CHZ/ticker | jq --raw-output '.ticker.last'`
        #CHZ_BUY_PRICE=`curl -s https://www.mercadobitcoin.net/api/CHZ/ticker | jq --raw-output '.ticker.buy'`
        #CHZ_SELL_PRICE=`curl -s https://www.mercadobitcoin.net/api/CHZ/ticker | jq --raw-output '.ticker.sell'`

        #ETH
        ETH_LAST_PRICE=`curl -s https://www.mercadobitcoin.net/api/ETH/ticker | jq --raw-output '.ticker.last'`
        #ETH_BUY_PRICE=`curl -s https://www.mercadobitcoin.net/api/ETH/ticker | jq --raw-output '.ticker.buy'`
        #ETH_SELL_PRICE=`curl -s https://www.mercadobitcoin.net/api/ETH/ticker | jq --raw-output '.ticker.sell'`

        #LTC
        LTC_LAST_PRICE=`curl -s https://www.mercadobitcoin.net/api/LTC/ticker | jq --raw-output '.ticker.last'`
        #LTC_BUY_PRICE=`curl -s https://www.mercadobitcoin.net/api/LTC/ticker | jq --raw-output '.ticker.buy'`
        #LTC_SELL_PRICE=`curl -s https://www.mercadobitcoin.net/api/LTC/ticker | jq --raw-output '.ticker.sell'`
}

function checkTimeToSell {

        #GP_MIN_LIMIT is reference price + 3% of gross profit...
        GP_MIN_LIMIT=( ${1} * (${GROSS_PROFIT_PERC}/100))

        #...and last price must be iqual or greater than the reference price + 3% of gross profit to alert the user: Sell time!!!  
        if [ ${2} -ge ${GP_MIN_LIMIT} ];then
                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`${3} last price is currently 3% above of its reference price. Sell? Yes or No?"   >> ${LOGFILE}
                echo "${3} LAST PRICE IS CURRENTLY 3% ABOVE OF ITS REFERENCE PRICE."
                echo -n "WOULD YOU LIKE TO SELL PART OF YOUR GROSS PROFIT? [y/n]"
                read YESNO

                if [ ${YESNO} -eq "y" ];then
                        echo "`date "+%m/%d/%Y  %H:%M:%S -  "`${3} GROSS PROFIT 1.5% HAS BEEN SOLD!"   >> ${LOGFILE}

                        if [ ${3} -eq "BCH" ];then
                                #update JSON value
                                JSON_UPDATE=`jq '.refprice.bch = "${BCH_LAST_PRICE}"' `${CONFIG_FILE}``
                                echo $JSON_UPDATE > ${CONFIG_FILE}
                                #update reference variable
                                BCH_REF=${BCH_LAST_PRICE}
                        elif [ ${3} -eq "BTC" ];then
                                #update JSON value
                                JSON_UPDATE=`jq '.refprice.btc = "${BTC_LAST_PRICE}"' `${CONFIG_FILE}``
                                echo $JSON_UPDATE > ${CONFIG_FILE}
                                #update reference variable
                                BTC_REF=${BTC_LAST_PRICE}
                        elif [ ${3} -eq "CHZ" ];then
                                #update JSON value
                                JSON_UPDATE=`jq '.refprice.chz = "${CHZ_LAST_PRICE}"' `${CONFIG_FILE}``
                                echo $JSON_UPDATE > ${CONFIG_FILE}
                                #update reference variable
                                CHZ_REF=${CHZ_LAST_PRICE}
                        elif [ ${3} -eq "ETH" ];then
                                #update JSON value
                                JSON_UPDATE=`jq '.refprice.eth = "${ETH_LAST_PRICE}"' `${CONFIG_FILE}``
                                echo $JSON_UPDATE > ${CONFIG_FILE}
                                #update reference variable
                                ETH_REF=${ETH_LAST_PRICE}
                        if [ ${3} -eq "LTC" ];then
                                #update JSON value
                                JSON_UPDATE=`jq '.refprice.ltc = "${LTC_LAST_PRICE}"' `${CONFIG_FILE}``
                                echo $JSON_UPDATE > ${CONFIG_FILE}
                                #update reference variable
                                LTC_REF=${LTC_LAST_PRICE}
                        fi

                        echo "`date "+%m/%d/%Y  %H:%M:%S -  "`REFERENCE PRICE BECOMES ${3} LAST PRICE FROM NOW ON."   >> ${LOGFILE}
                else
                        echo "`date "+%m/%d/%Y  %H:%M:%S -  "`${3} SELLS HAS BEEN DENIED!"   >> ${LOGFILE}
                fi
        fi
}

function checkTimeToBuy {


        while true ; do
                #GP_MIN_LIMIT is reference price - 3%...
                GP_MIN_LIMIT=${BCH_REF} - ( ${BCH_REF} / (${GROSS_PROFIT_PERC}/100))

                #...and last price must be 3% less than the reference priceto alert the user it's buy time!!!  
                if [ ${BCH_LAST_PRICE} -le ${GP_MIN_LIMIT} ];then
                        PERC = ( ${BCH_LAST_PRICE} * 100) / ${BCH_REF} )
                        echo "Current price of BCH is ${PERC}%"
                        echo "`date "+%m/%d/%Y  %H:%M:%S -  "`Current price of BCH is ${PERC}%"   >> ${LOGFILE}
                fi


                #GP_MIN_LIMIT is reference price - 3%...
                GP_MIN_LIMIT=${BCH_REF} - ( ${BCH_REF} / (${GROSS_PROFIT_PERC}/100))

                #...and last price must be 3% less than the reference priceto alert the user it's buy time!!!  
                if [ ${BTC_LAST_PRICE} -le ${GP_MIN_LIMIT} ];then
                        PERC = ( ${BTC_LAST_PRICE} * 100) / ${BTC_REF} )
                        echo "Current price of BTC is ${PERC}%"
                        echo "`date "+%m/%d/%Y  %H:%M:%S -  "`Current price of BTC is ${PERC}%"   >> ${LOGFILE}
                fi

                
                #GP_MIN_LIMIT is reference price - 3%...
                GP_MIN_LIMIT=${CHZ_REF} - ( ${CHZ_REF} / (${GROSS_PROFIT_PERC}/100))

                #...and last price must be 3% less than the reference priceto alert the user it's buy time!!!  
                if [ ${CHZ_LAST_PRICE} -le ${GP_MIN_LIMIT} ];then
                        PERC = ( ${CHZ_LAST_PRICE} * 100) / ${CHZ_REF} )
                        echo "Current price of CHZ is ${PERC}%"
                        echo "`date "+%m/%d/%Y  %H:%M:%S -  "`Current price of CHZ is ${PERC}%"   >> ${LOGFILE}
                fi

                
                #GP_MIN_LIMIT is reference price - 3%...
                GP_MIN_LIMIT=${ETH_REF} - ( ${ETH_REF} / (${GROSS_PROFIT_PERC}/100))

                #...and last price must be 3% less than the reference priceto alert the user it's buy time!!!  
                if [ ${ETH_LAST_PRICE} -le ${GP_MIN_LIMIT} ];then
                        PERC = ( ${ETH_LAST_PRICE} * 100) / ${ETH_REF} )
                        echo "Current price of ETH is ${PERC}%"
                        echo "`date "+%m/%d/%Y  %H:%M:%S -  "`Current price of ETH is ${PERC}%"   >> ${LOGFILE}
                fi

                
                #GP_MIN_LIMIT is reference price - 3%...
                GP_MIN_LIMIT=${LTC_REF} - ( ${LTC_REF} / (${GROSS_PROFIT_PERC}/100))

                #...and last price must be 3% less than the reference priceto alert the user it's buy time!!!  
                if [ ${LTC_LAST_PRICE} -le ${GP_MIN_LIMIT} ];then
                        PERC = ( ${LTC_LAST_PRICE} * 100) / ${LTC_REF} )
                        echo "Current price of LTC is ${PERC}%"
                        echo "`date "+%m/%d/%Y  %H:%M:%S -  "`Current price of LTC is ${PERC}%"   >> ${LOGFILE}
                fi

                echo "Would you like to buy?" 
                echo "1 - BCH"
                echo "2 - BTC"
                echo "3 - CHZ"
                echo "4 - ETH"
                echo "5 - LTC"
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
                                   break ;;

                                2) echo "BTC currency purchase approved!"
                                   #update JSON value
                                   JSON_UPDATE=`jq '.refprice.btc = "${BTC_LAST_PRICE}"' `${CONFIG_FILE}``
                                   echo $JSON_UPDATE > ${CONFIG_FILE} 
                                   #update reference variable
                                   BTC_REF=${BTC_LAST_PRICE} 
                                   break ;;

                                3) echo "CHZ currency purchase approved!"
                                   #update JSON value
                                   JSON_UPDATE=`jq '.refprice.chz = "${CHZ_LAST_PRICE}"' `${CONFIG_FILE}``
                                   echo $JSON_UPDATE > ${CONFIG_FILE}
                                   #update reference variable
                                   CHZ_REF=${CHZ_LAST_PRICE} 
                                   break ;;

                                4) echo "ETH currency purchase approved!"
                                   #update JSON value
                                   JSON_UPDATE=`jq '.refprice.eth = "${ETH_LAST_PRICE}"' `${CONFIG_FILE}``
                                   echo $JSON_UPDATE > ${CONFIG_FILE} 
                                   #update reference variable
                                   ETH_REF=${ETH_LAST_PRICE} 
                                   break ;;

                                5) echo "LTC currency purchase approved!"
                                   #update JSON value
                                   JSON_UPDATE=`jq '.refprice.ltc = "${LTC_LAST_PRICE}"' `${CONFIG_FILE}``
                                   echo $JSON_UPDATE > ${CONFIG_FILE} 
                                   #update reference variable
                                   LTC_REF=${LTC_LAST_PRICE} 
                                   break ;;

                                *) echo "Opcao Invalida!" ;;
                        esac
                fi                
        done

}

###########################################
#
# Variables
#
###########################################

LOGFILE="mbc.log"
#time in seconds before check prices again
WAITING=5

#Mercado Bitcoin tax % or in R$
#https://www.mercadobitcoin.com.br/comissoes-prazos-limites
#Executada=sell 0.30%
#Eexcutora=buy 0.70%
#MBC_TAX_SELL=0.30
#MBC_TAX_BUY=0.70
#gross profit %
GROSS_PROFIT_PERC=3

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
                        echo -e "{\"refprice\": {\"bch\":\"${BCH_REF}\",\"btc\":\"${BTC_REF}\",\"chz\":\"${CHZ_REF}\",\"eth\":\"${ETH_REF}\",\"ltc\":\"${LTC_REF}\"}}" > ${CONFIG_FILE}
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
        checkNewPricesUpdates

        #Check each crypto currency has reached 3% above of reference price.
        #If so, a question user confirmation y or n to sell for that current price.
        checkTimeToSell ${BCH_REF} ${BCH_LAST_PRICE} "BCH"
        checkTimeToSell ${BTC_REF} ${BTC_LAST_PRICE} "BTC"
        checkTimeToSell ${CHZ_REF} ${CHZ_LAST_PRICE} "CHZ"
        checkTimeToSell ${ETH_REF} ${ETH_LAST_PRICE} "ETH"
        checkTimeToSell ${LTC_REF} ${LTC_LAST_PRICE} "LTC"

        #Check each crypto currency has reached 3% below of reference price.
        #If so, a question user confirmation y or n to buy crypto currency with the best price.
        checkTimeToBuy

        #Wait 5 seconds by default before start the loop again.
        sleep ${WAITIING}       
done