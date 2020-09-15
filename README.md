# mercadobitcoin
Phase I: It just alerts the user about which crypto currency should be bought/sold.

There are some pre-reqs to execute the mbc.sh script. 

1) First of all install jq for JSON file handling and ssmtp to make our life easiest:

sudo apt update
sudo apt install jq
sudo apt install ssmtp
mv /etc/ssmtp/ssmtp.conf /etc/ssmtp/ssmtp.conf.bkp
cp ssmtp.conf /etc/ssmtp/ssmtp.conf

2) Run mcb.sh as root

3) Account ID at Mercadobitcoin is not needed for while (Phase I)
