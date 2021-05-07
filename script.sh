# Usage: script.sh "Domain name" "Path to wordlist"
#!/bin/bash

if [ $# != 2 -a $1 != "-h" ]
then
	echo -e "Inavalid usage: \n Correct usage: ./script example.com wordlist_path"
	exit 0
fi

if [ $# == 1 -a $1 == "-h" ]
then
	echo -e "\e[1;31m
	 ____  _____ ____ ____   ___  ____ _____ 
	|  _ \| ____/ ___|  _ \ / _ \|  _ \_   _|
	| |_) |  _|| |   | |_) | | | | |_) || |
	|  _ <| |__| |___|  __/| |_| |  _ < | | 
	|_| \_\_____\____|_|    \___/|_| \_\|_|
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ \e[0m"
	echo -e "\e[1;32m Developed by : n00bx101 \e[0m"
	echo -e "\e[1;32m Version : 0.1 \n\n \e[0m"

	echo -e "\e[1;32m Recport is a tool to automate the enumerate process for domain names and process the report for analysis. It makes use of API's to first look for the possible subdomains for the provided domain and then filter out the live subdomains for further enumeration. Once we get live domains we make use of nmap to look for open ports on those vhosts also in end using ffuf it does directory enumeration for hidden paths. \e[0m"
	echo -e "\e[1;33m \nExample usage: ./script example.com wordlist_path \e[0m \n\n"

	exit 0
fi

echo -e "\e[1;31m
 ____  _____ ____ ____   ___  ____ _____ 
|  _ \| ____/ ___|  _ \ / _ \|  _ \_   _|
| |_) |  _|| |   | |_) | | | | |_) || |
|  _ <| |__| |___|  __/| |_| |  _ < | | 
|_| \_\_____\____|_|    \___/|_| \_\|_|
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ \e[0m"
echo -e "\e[1;32m Developed by : n00bx101 \e[0m"
echo -e "\e[1;32m Version : 0.1 \n\n \e[0m"

#Cheks for a target report. If found delete it.
[ -e $1 ] && rm $1 -r

#If not found create a dir with target name
mkdir $1

#Collect subdomains from various web sources
echo -e "\e[1;33m [-] Subdomain Enumeration \e[0m";
echo "";

#from Crt.sh
echo -e "\e[1;36m [*] Searching crt.sh... \e[0m";
curl -s -X GET "https://crt.sh/?q=%.$1&output=json" | jq '.[].name_value' | sed 's/\"//g' | sed 's/\*\.//g' | sort -u >> .subdomains

#from Hackertarget
echo -e "\e[1;36m [*] Searching Hackertarget... \e[0m";
curl -s https://api.hackertarget.com/hostsearch/?q=$1 | cut -d',' -f1 | sort -u >> .subdomains

#from ThreatCrowd
echo -e "\e[1;36m [*] Searching Threatcrowd... \e[0m";
curl -s https://www.threatcrowd.org/searchApi/v2/domain/report/?domain=$1 | jq -r '.subdomains | .[]' | sort -u >> .subdomains

echo "";

#Transfer subdomain list to target directory with formatting and no duplicates
cat .subdomains | sed 's/\\n/\n/g' | sort -u > $1/subdomains.txt

#Counting number of subdomains
echo -e "\e[1;33m [-] Subdomains Found: \e[0m \e[1;31m $(wc -l $1/subdomains.txt | sed 's/subdomains.txt//') \e[0m";
rm .subdomains

printf "\n"

#Filtering for live subdomains
echo -e "\e[1;33m [-] Filtering Dead Domains \e[0m";
echo "";

#Line wise filtering
while read line;
do
[[ "$(dig $line +short)" ]] && printf "$line\n" >> $1/LiveSubDomains.txt
[[ "$(dig $line +short)" ]] || printf " [*] $line : [Dead]\n";
done<$1/subdomains.txt

printf "\n\n\n\n"

#Looking for port scans via nmap
echo -e "\e[1;33m [-] Scanning Ports \e[0m";
echo "";

while read line;
do
    echo -e "\e[1;36m [*] Scanning Ports on \e[1;33m $line \e[0m" | tee -a $1/Nmap_Report.txt
    nmap $line -Pn --min-rate 1000 --top-ports 50 | grep -E '^[0-9]' | grep 'open' | cut -d' ' -f1 >> $1/Nmap_Report.txt
    printf "\n\n\n" >> $1/Nmap_Report.txt
done < $1/LiveSubDomains.txt

printf "\n\n\n\n"

#Let's do directory enumeration

echo -e "\e[1;33m [-] Running Dirsearch \e[0m";
echo "";

while read line;
do
    echo -e "\e[1;36m [*]Scanning Files \e[1;33m $line \e[0m"
    ffuf -u https://$line/FUZZ -w $2 -o $1/.ffuf.ffuf -of csv -s
    printf "\n\n\n" >> $1/ffuf.txt
    cat $1/.ffuf.ffuf >> $1/ffuf.txt

done < $1/LiveSubDomains.txt

echo -e "\e[1;33m Done \e[1;31m <3 \e[1;33m find the folder \e[1;31m $1 \e[1;33m for the report \e[0m";