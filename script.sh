# Usage: script.sh "Domain name" "Path to wordlist"
#!/bin/bash

#Cheks for a target report. If found delete it.
[ -e $1 ] && rm $1 -r

#If not found create a dir with target name
mkdir $1

#Collect subdomains from various web sources
echo "[-] Subdomain Enumeration";
echo "";

#from Crt.sh
echo " [*] Searching crt.sh...";
curl -s -X GET "https://crt.sh/?q=%.$1&output=json" | jq '.[].name_value' | sed 's/\"//g' | sed 's/\*\.//g' | sort -u >> .subdomains

#from Hackertarget
echo " [*] Searching cert.sh...";
curl -s https://api.hackertarget.com/hostsearch/?q=$1 | cut -d',' -f1 | sort -u >> .subdomains

#from ThreatCrowd
echo " [*] Searching cert.sh...";
curl -s https://www.threatcrowd.org/searchApi/v2/domain/report/?domain=$1 | jq -r '.subdomains | .[]' | sort -u >> .subdomains

echo "";

#Transfer subdomain list to target directory with formatting and no duplicates
cat .subdomains | sed 's/\\n/\n/g' | sort -u > $1/subdomains.txt

#Counting number of subdomains
echo "[!] Subdomains Found: $(wc -l $1/subdomains.txt | sed 's/subdomains.txt//')";
rm .subdomains

printf "\n\n\n\n"

#Filtering for live subdomains
echo "[-] Filtering Dead Domains";
echo "";

#Line wise filtering
while read line;
do
[[ "$(dig $line +short)" ]] && printf "$line\n" >> $1/LiveSubDomains.txt
[[ "$(dig $line +short)" ]] || printf " [*] $line : [Dead]\n";
done<$1/subdomains.txt

printf "\n\n\n\n"

#Looking for port scans via nmap
echo "[-] Scanning Ports ";
echo "";

while read line;
do
    echo " [*] Scanning Ports on $line" | tee -a $1/Nmap_Report.txt
    nmap $line -Pn --min-rate 1000 --top-ports 50 | grep -E '^[0-9]' | grep 'open' | cut -d' ' -f1 >> $1/Nmap_Report.txt
    printf "\n\n\n" >> $1/Nmap_Report.txt
done < $1/LiveSubDomains.txt

printf "\n\n\n\n"

#Let's do directory enumeration

echo "[-] Running Dirsearch ";
echo "";

while read line;
do
    echo " [*]Scanning Files $line"
    ffuf -u https://$line/FUZZ -w $2 -o $1/.ffuf.ffuf -of csv -s
    printf "\n\n\n" >> $1/ffuf.txt
    cat $1/.ffuf.ffuf >> $1/ffuf.txt

done < $1/LiveSubDomains.txt

echo "Done [Recon Finished]";