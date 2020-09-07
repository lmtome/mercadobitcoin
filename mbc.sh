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


#Function to Alert users about script expecting their action to keep going
#Just to ensure email will works properly follow the instruction to prepare your Linux env:
#Install it with the following commands:
#
#sudo apt-get update
#sudo apt-get install ssmtp
#
#Edit /etc/ssmtp/ssmtp.conf to look like this:
#
#root=rpi3abc@gmail.com
#mailhub=smtp.gmail.com:465
#FromLineOverride=YES
#AuthUser=rpi3abc@gmail.com
#AuthPass=testing123
#UseTLS=YES
#
#
#when you have not allowed access to less secure apps on your gmail. This security setting can be changed through the following link:
#https://myaccount.google.com/lesssecureapps
#
#
# Send an email trough command line
# echo "Testing...1...2...3" | ssmtp myusername@gmail.com
#
#check your Gmail box
#
#It's enough!
function alertUser {
        #Alert user
        #alertUser "dwulbr@gmail.com" "Subject: BCH is at least 3% below of its reference price. Check it ASAP!"
        echo ${2} | ssmtp ${1}
}


#Capture cripto currencies values (Last, buy and sell)
function checkNewPricesUpdates {
        #BCH
        BCH_LAST_PRICE=`curl -s https://www.mercadobitcoin.net/api/BCH/ticker | jq --raw-output '.ticker.last'`

        #BTC
        BTC_LAST_PRICE=`curl -s https://www.mercadobitcoin.net/api/BTC/ticker | jq --raw-output '.ticker.last'`

        #CHZ
        CHZ_LAST_PRICE=`curl -s https://www.mercadobitcoin.net/api/CHZ/ticker | jq --raw-output '.ticker.last'`

        #ETH
        ETH_LAST_PRICE=`curl -s https://www.mercadobitcoin.net/api/ETH/ticker | jq --raw-output '.ticker.last'`

        #LTC
        LTC_LAST_PRICE=`curl -s https://www.mercadobitcoin.net/api/LTC/ticker | jq --raw-output '.ticker.last'`
}


#check and alert user to sell if the last price has reached an expected price.
# checkTimeToSell ${BCH_REF} ${BCH_LAST_PRICE} "BCH"
function checkTimeToSell {

        #PRICE_PLUS_GP is reference price + 3% of gross profit...
        #PRICE_PLUS_GP is equal LAST_PRICE * (GROSS_PROFIT_PERC / 100)

        PRICE_PLUS_GP=`bc <<< "scale=2;(${GROSS_PROFIT_PERC}/100)*${1}"`
        PRICE_PLUS_GP=$( printf "%.8f" $PRICE_PLUS_GP )
        PARAM2="${2}"
        PARAM2=$( printf "%.8f" $PARAM2 )

        #...and last price must be iqual or greater than the reference price + 3% of gross profit to alert the user: Sell time!!!
        FLAG_SELL_TIME=`echo ${PARAM2}'>'${PRICE_PLUS_GP} | bc -l`

#--->DEBUG<---#
        #echo "PARAM2=${PARAM2}"
        #echo "PRICE_PLUS_GP=${PRICE_PLUS_GP}"
        #echo "FLAG_SELL_TIME=${FLAG_SELL_TIME}"
        #TRUE for CURRENT VALUE > THE LAST VALUE PAID (3% above)
        if [ ${FLAG_SELL_TIME} -ne 0 ];then
                #Alert user
                alertUser "dwulbr@gmail.com" "Subject: ${3} is at least 3% above of its reference price. Check it ASAP!"

                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`${3} last price is currently 3% above of its reference price. Would you like to sell it?"   >> ${LOGFILE}
                echo "${3} last price is currently 3% above of reference price."
                echo -n "Would you like to sell part of ${3} ? [y/n]"
                read YESNO

                if [ "${YESNO}" == "y" ] ; then
                        echo "`date "+%m/%d/%Y  %H:%M:%S -  "`GP's ${3} has been sold."   >> ${LOGFILE}

                        if [ "${3}" == "BCH" ];then

                                #update JSON value
                                JSON_UPDATE=`jq --arg lastprice "${BCH_LAST_PRICE}" '.refprice.bch = $lastprice' ${CONFIG_FILE}`
#--->DEBUG<---#
                                #echo "JSON_UPDATE=${JSON_UPDATE}"
                                echo $JSON_UPDATE > ${CONFIG_FILE}
                                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`${3} reference value has been update."   >> ${LOGFILE}

                                #update reference variable
                                BCH_REF=${BCH_LAST_PRICE}

                        elif [ "${3}" == "BTC" ];then

                                #update JSON value
                                JSON_UPDATE=`jq --arg lastprice "${BTC_LAST_PRICE}" '.refprice.btc = $lastprice' ${CONFIG_FILE}`
                                echo $JSON_UPDATE > ${CONFIG_FILE}

                                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`${3} reference value has been updated."   >> ${LOGFILE}

                                #update reference variable
                                BTC_REF=${BTC_LAST_PRICE}

                        elif [ "${3}" == "CHZ" ];then

                                #update JSON value
                                JSON_UPDATE=`jq --arg lastprice "${CHZ_LAST_PRICE}" '.refprice.chz = $lastprice' ${CONFIG_FILE}`
                                echo $JSON_UPDATE > ${CONFIG_FILE}

                                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`${3} reference value has been updated."   >> ${LOGFILE}

                                #update reference variable
                                CHZ_REF=${CHZ_LAST_PRICE}

                        elif [ "${3}" == "ETH" ];then

                                #update JSON value
                                JSON_UPDATE=`jq --arg lastprice "${ETH_LAST_PRICE}" '.refprice.eth = $lastprice' ${CONFIG_FILE}`
                                echo $JSON_UPDATE > ${CONFIG_FILE}

                                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`${3} reference value has been updated."   >> ${LOGFILE}

                                #update reference variable
                                ETH_REF=${ETH_LAST_PRICE}

                        elif [ "${3}" == "LTC" ];then

                                #update JSON value
                                JSON_UPDATE=`jq --arg lastprice "${LTC_LAST_PRICE}" '.refprice.ltc = $lastprice' ${CONFIG_FILE}`
                                echo $JSON_UPDATE > ${CONFIG_FILE}

                                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`${3} reference value has been updated."   >> ${LOGFILE}

                                #update reference variable
                                LTC_REF=${LTC_LAST_PRICE}
                        else

                                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`${3} is a invalid crypto currency."   >> ${LOGFILE}
                        fi

                else
                        echo "`date "+%m/%d/%Y  %H:%M:%S -  "`${3} sells has been denied by user!"   >> ${LOGFILE}
                fi
        else
                #Last value does not reach 3% above of reference price for ${3} crypto currency."
                echo "`date "+%m/%d/%Y  %H:%M:%S -  "`Last value does not reach 3% above of reference price for ${3} crypto currency."   >> ${LOGFILE}
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


###########################################
#
# Variables
#
###########################################

#Log file name y default
LOGFILE="mbc.log"
#Time in seconds before check prices again
WAITING=10

#Mercado Bitcoin tax % or in R$
#https://www.mercadobitcoin.com.br/comissoes-prazos-limites
#Executada=sell 0.30%
#Executora 0.70%
#MBC_TAX_SELL=0.30
#MBC_TAX_BUY=0.70
#Gross profit in %
GROSS_PROFIT_PERC=3

#Check access permission toexecute this script
if [ `id -u` -ne 0 ] && [ `id -g` -ne 0 ]; then
        echo "`date "+%m/%d/%Y  %H:%M:%S -  "`ERR: You need root access permission to execute ${0} command." >> ${LOGFILE}
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
        echo "`date "+%m/%d/%Y  %H:%M:%S -  "`ERR: ${CONFIG_FILE} does not exist locally."  >> ${LOGFILE}

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

        #Read config file and set up each currency reference price
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

exit 0
        #Check each crypto currency has reached 3% below of reference price.
        #If so, a question user confirmation y or n to buy crypto currency with the best price.
        checkTimeToBuy

        #Wait 5 seconds by default before start the loop again.
        sleep ${WAITIING}
done
