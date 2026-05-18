#!/usr/bin/env bash
# --- colors --------

RESET="\033[0m"
BOLD="\033[1m"
RED="\033[31m"  GREEN="\033[32m"  YELLOW="\033[33m"
BLUE="\033[34m" MAGENTA="\033[35m" CYAN="\033[36m"

# -- info gathering ----
get_os()        { sw_vers -productName; }
get_version()   { sw_vers -productVersion; }
get_shell() { basename "$SHELL"; }
get_kernel()    { uname -r; }
get_hostname()  { hostname -s; }
get_user()      { whoami; }
get_uptime() {
    local secs=$(( $(date +%s) - $(sysctl -n kern.boottime | awk '{print $4}' | tr -d ',') ))
    local d=$(( secs / 86400 ))
    local h=$(( (secs % 86400) / 3600 ))
    local m=$(( (secs % 3600) / 60 ))
    echo "${d}d ${h}h ${m}m"
}

get_cpu() {
    sysctl -n machdep.cpu.brand_string | sed 's/(TM)//g;s/(R)//g'
}

get_gpu() {
    system_profiler SPDisplaysDataType 2>/dev/null \
        | awk -F': ' '/Chipset Model/{print $2; exit}'
}


get_memory() {
    local total_bytes=$(sysctl -n hw.memsize)
    local total_gb=$(( total_bytes / 1073741824 ))
    local used_gb=$(vm_stat | awk '
        /Pages active/      { active=$3 }
        /Pages wired/       { wired=$4 }
        /Pages compressed/  { compressed=$3 }
        END { printf "%.1f", (active + wired + compressed) * 4096 / 1073741824 }
    ')
    local percent=$(echo "scale=0; $used_gb * 100 / $total_gb" | bc)
    echo "${used_gb} GiB / ${total_gb} GiB (${percent}%)"
}

get_disk() {
    df -g / | awk 'NR==2 {
        used=$3
        total=$2
        pct=$5
        print used " GiB / " total " GiB (" pct ")"
    }'
}

get_packages() {
    local count=0
    command -v brew &>/dev/null && count=$(brew list --formula 2>/dev/null | wc -l | tr -d ' ')
    echo "${count} (brew)"
}

get_resolution() {
    system_profiler SPDisplaysDataType 2>/dev/null \
        | awk -F': ' '/Resolution/{print $2; exit}' \
        | awk '{print $1, $2, $3}'
}

get_power() {
    local source=$(pmset -g batt | awk 'NR==1{print}')
    local percent=$(pmset -g batt | grep -o '[0-9]*%' | head -1)
    if echo "$source" | grep -q "'AC Power'"; then
        echo "Plugged in (${percent})"
    else
        echo "Battery (${percent})"
    fi
}

get_colors() {
    local line1="" line2=""
    for i in {0..7}; do
        line1+="\033[4${i}m   \033[0m"
    done
    for i in {0..7}; do
        line2+="\033[10${i}m   \033[0m"
    done
    echo -e "${line1}\n${line2}"
}

#--- ascii art ------
print_ascii() {
    cat << 'EOF'
    
    
        
                   x.XxX$$$$$$$$$$$$:::
                 x.:..: ... ..&&$.......:
               x.+:..: .&&.&.+&&;:$;;.;+;:X;
             $$++XxX$$$$$$$$$$$$:..:;;++;;;;:
   xX$$$$$$$$$$$$$$$$$$$$$$X+++;;xX$$$$$$$;::
  +.x:...... ..... .:$$$X+++;;;xX$$$$$$$;:..:
 x. X.......:..X;.:&;+;;;;;   ;;xX$$$$$$$...
+;;;$$$$$$$&&&$$$$$$$$$;;;     ;;;::::;;:..;
 ;.;.;::;;;;;;;;+;;X;;;;;;     ;;;;;:
 XX$XX;:;.::;;+;;;;;;;;;;;
                   
EOF
}

#--- layout -------
print_info() {
    local label="$1" value="$2" color="${3:-$CYAN}"
    printf "  ${color}${BOLD}%-12s${RESET}  %s\n" "$label" "$value"
}

main() {
    local art=()
    while IFS= read -r line; do
        art+=("$line")
    done < <(print_ascii)

    local info=()
    info+=("${BOLD}$(get_user)${RESET}@${BOLD}$(get_hostname)${RESET}")
    info+=("\033[0m$(printf '─%.0s' {1..38})")
    info+=("${GREEN}${BOLD}OS${RESET}            $(get_os) $(get_version)")
    info+=("${GREEN}${BOLD}Kernel${RESET}        $(get_kernel)")
    info+=("${GREEN}${BOLD}Shell${RESET}         $(get_shell)")
    info+=("${GREEN}${BOLD}Uptime${RESET}        $(get_uptime)")
    info+=("${GREEN}${BOLD}CPU${RESET}           $(get_cpu)")
    info+=("${GREEN}${BOLD}GPU${RESET}           $(get_gpu)")
    info+=("${GREEN}${BOLD}Packages${RESET}      $(get_packages)")
    info+=("${GREEN}${BOLD}Resolution${RESET}    $(get_resolution)")
    info+=("${GREEN}${BOLD}Power${RESET}         $(get_power)")
    info+=("${GREEN}${BOLD}Memory${RESET}        $(get_memory)")
    info+=("${GREEN}${BOLD}Disk${RESET}          $(get_disk)")
    info+=("")
    info+=("$(get_colors | head -1)")
    info+=("$(get_colors | tail -1)")

    local total=$(( ${#art[@]} > ${#info[@]} ? ${#art[@]} : ${#info[@]} ))

    for (( i=0; i<total; i++ )); do
        local art_line="${art[$i]:-}"
        local info_line="${info[$i]:-}"
        printf "\033[38;5;208m%-46s  %b\n" "$art_line" "$info_line"
    done

    echo "" 
    
}

main