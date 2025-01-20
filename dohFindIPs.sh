#!/bin/bash
filename='dohDomainList.txt'
listOfIPs=()
ipV4Regex="^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}"
ipV6Regex="(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))"
echo $ipV6Regex
while read domainName; do
    for ipAddress in `dig +short -t A $domainName`; do
        if [[ $ipAddress =~ $ipV4Regex ]]; then
            echo "[+] DOH IPv4 $ipAddress"
            listOfIPs+=("${ipAddress}")
        fi
    done
    for ipAddress in `dig +short -t AAAA $domainName`; do
        if [[ $ipAddress =~ $ipV6Regex ]]; then
            echo "[+] DOH IPv6 $ipAddress"
            listOfIPs+=("${ipAddress}")
        fi
    done
done < "$filename"
deleteValues=("::")
for targetValue in "${deleteValues[@]}"; do
  for indexValue in "${!listOfIPs[@]}"; do
    if [[ ${listOfIPs[indexValue]} = $targetValue ]]; then
      unset 'listOfIPs[i]'
    fi
  done
done
echo "Tracking ${#listOfIPs[@]} DoH IPs"
if [[ "${#listOfIPs[@]}" -gt 10 ]]; then
    printf "%s\n" "${listOfIPs[@]}" | sort -u > listDoHIPs.txt
    echo "Updated listDoHIPs.txt"
fi
