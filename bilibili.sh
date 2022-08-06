#!/bin/bash
shopt -s expand_aliases
Font_Black="\033[30m"
Font_Red="\033[31m"
Font_Green="\033[32m"
Font_Yellow="\033[33m"
Font_Blue="\033[34m"
Font_Purple="\033[35m"
Font_SkyBlue="\033[36m"
Font_White="\033[37m"
Font_Suffix="\033[0m"

if [ -z "$iface" ]; then
    useNIC=""
fi

if [ -z "$XIP" ]; then
    xForward=""
fi

if ! mktemp -u --suffix=RRC &>/dev/null; then
    is_busybox=1
fi


UA_Browser="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.87 Safari/537.36"
UA_Dalvik="Dalvik/2.1.0 (Linux; U; Android 9; ALP-AL00 Build/HUAWEIALP-AL00)"
WOWOW_Cookie=$(curl -s "https://raw.githubusercontent.com/lmc999/RegionRestrictionCheck/main/cookies" | awk 'NR==3')
TVer_Cookie="Accept: application/json;pk=BCpkADawqM0_rzsjsYbC1k1wlJLU4HiAtfzjxdUmfvvLUQB-Ax6VA-p-9wOEZbCEm3u95qq2Y1CQQW1K9tPaMma9iAqUqhpISCmyXrgnlpx9soEmoVNuQpiyGsTpePGumWxSs1YoKziYB6Wz"


function MediaUnblockTest_BilibiliAnime() {
    echo -n -e " Bilibili Anime Region:\t\t\t->\c"
    local is_global=$(curl $useNIC $xForward --user-agent "${UA_Browser}" -${1} -fsSL --max-time 10 "https://www.bilibili.tv" 2>&1)
    if [[ "$is_global" == "curl"* ]]; then
        echo -n -e "\r Bahamut Anime:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    if [ -z "$is_global" ]; then
        local randsession="$(cat /dev/urandom | head -n 32 | md5sum | head -c 32)"
        local mainland=$(curl $useNIC $xForward --user-agent "${UA_Browser}" -${1} -fsSL --max-time 10 "https://api.bilibili.com/pgc/player/web/playurl?avid=82846771&qn=0&type=&otype=json&ep_id=307247&fourk=1&fnver=0&fnval=16&session=${randsession}&module=bangumi" 2>&1)
        local mainland="$(echo "${mainland}" | python3 -m json.tool 2>/dev/null | grep '"code"' | head -1 | awk '{print $2}' | cut -d ',' -f1)"
        if [ "${mainland}" = "0" ]; then
            echo -n -e "\r Bilibili Anime Region:\t\t${Font_Green}Mainland${Font_Suffix}\n"
            return
        else
            local taiwan=$(curl $useNIC $xForward --user-agent "${UA_Browser}" -${1} -fsSL --max-time 10 "https://api.bilibili.com/pgc/player/web/playurl?avid=50762638&cid=100279344&qn=0&type=&otype=json&ep_id=268176&fourk=1&fnver=0&fnval=16&session=${randsession}&module=bangumi" 2>&1)
            local taiwan="$(echo "${taiwan}" | python3 -m json.tool 2>/dev/null | grep '"code"' | head -1 | awk '{print $2}' | cut -d ',' -f1)"
            if [ "${taiwan}" = "0" ]; then
                echo -n -e "\r Bilibili Anime Region:\t\t${Font_Green}Taiwan${Font_Suffix}\n"
                return
            else
                local result=$(curl $useNIC $xForward --user-agent "${UA_Browser}" -${1} -fsSL --max-time 10 "https://api.bilibili.com/pgc/player/web/playurl?avid=18281381&cid=29892777&qn=0&type=&otype=json&ep_id=183799&fourk=1&fnver=0&fnval=16&session=${randsession}&module=bangumi" 2>&1)
                local result="$(echo "${result}" | python3 -m json.tool 2>/dev/null | grep '"code"' | head -1 | awk '{print $2}' | cut -d ',' -f1)"
                if [ "${result}" = "0" ]; then
                    echo -n -e "\r Bilibili Anime Region:\t\t${Font_Green}Hongkong/Macau${Font_Suffix}\n"
                    return
                fi
            fi
        fi

    else
        local southeastasia=$(curl $useNIC $xForward --user-agent "${UA_Browser}" -${1} -fsSL --max-time 10 "https://api.bilibili.tv/intl/gateway/web/playurl?s_locale=en_US&platform=web&ep_id=347666" 2>&1)
        local southeastasia="$(echo "${southeastasia}" | python3 -m json.tool 2>/dev/null | grep '"code"' | head -1 | awk '{print $2}' | cut -d ',' -f1)"
        if [ "${southeastasia}" = "0" ]; then
            local thai=$(curl $useNIC $xForward --user-agent "${UA_Browser}" -${1} -fsSL --max-time 10 "https://api.bilibili.tv/intl/gateway/web/playurl?s_locale=en_US&platform=web&ep_id=10077726" 2>&1)
            local thai="$(echo "${thai}" | python3 -m json.tool 2>/dev/null | grep '"code"' | head -1 | awk '{print $2}' | cut -d ',' -f1)"
            if [ "${thai}" = "0" ]; then
                echo -n -e "\r Bilibili Anime Region:\t\t${Font_Green}Southeastasia(TH)${Font_Suffix}\n"
                return
            else
                echo -n -e "\r Bilibili Anime Region:\t\t${Font_Green}Southeastasia${Font_Suffix}\n"
                return
            fi
        else
            echo -n -e "\r Bilibili Anime Region:\t\t${Font_Green}Intl${Font_Suffix}\n"
            return
        fi
        
    fi
    echo -n -e "\r Bilibili Anime Region:\t\t${Font_Green}Failed (Network Connection)${Font_Suffix}\n"
}

MediaUnblockTest_BilibiliAnime 4
