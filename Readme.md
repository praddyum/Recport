## RECPORT

![image](https://github.com/Praddy2009/Recport/blob/master/Banner.png)

[![Generic badge](https://img.shields.io/badge/MADE_WITH-Shell_Script-red.svg)](https://shields.io/)
[![Generic badge](https://img.shields.io/badge/Compatibility-Linux_Distribution-red.svg)](https://shields.io/)


Recport is a tool to automate the enumeration process for domain names and process the report for analysis. It makes use of API's to first look for the possible subdomains for the provided domain and then filter out the live subdomains for further enumeration. Once we get live domains we make use of nmap to look for open ports on those vhosts also in end using ffuf it does directory enumeration for hidden paths.

## USP of this tool

- Open Source

- Automation

- Best for target with multiple subdomains

- Bash compatible on linux distros so no extra setup required

## How to setup

- Clone the repository
- Run `sudo ./requirements.sh` 
- Run `./script.sh [domain] [directory_wordlist]` 

## Support
  Support me on [Paypal](https://www.paypal.me/n00bx101)
