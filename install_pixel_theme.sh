#!/usr/bin/env bash

RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
PURPLE="\033[0;35m"
NC="\033[0m"

themes_path="/etc/emulationstation/themes"
icons_path="/home/pi/RetroPie/retropiemenu/icons"
backup_default_icons_dir="backup-default-icons"
splashscreens_path="/home/pi/RetroPie/splashscreens"
launching_images_path="/opt/retropie/configs"

backtitle="Backtitle"

function install_theme() {
    check_dependencies
    if [[ -d "$themes_path/$theme" ]]; then
        if [[ -e "$themes_path/$theme/.git" ]]; then
            echo "${theme^} already installed."
            cd $themes_path/$theme
            input="${theme^}"
            check_updates
            cd -
        else
            rm -rf $themes_path/$theme
            install_theme
        fi
    else
        if [[ $(curl "https://api.github.com/repos/$repo/es-theme-$theme" | awk -F\" '/message/ {print $(NF-1)}') == "Not Found" ]]; then
            dialog --backtitle "$backtitle" --msgbox "This repository https://api.github.com/repos/$repo/es-theme-$theme doesn't exist." 10 40 2>&1 >/dev/tty
        else
            echo "Installing ${theme^} ..."
            git clone --depth 1 "https://github.com/$repo/es-theme-$theme.git" "$themes_path/$theme"
            success=$?
            if [[ $success -eq 0 ]]; then
                echo "${theme^} installed successfully!"
            else
                dialog --backtitle "$backtitle" --msgbox "Something went wrong :_(\nCouldn't resolve https://github.com/$repo/es-theme-$theme.git" 10 40 2>&1 >/dev/tty            
            fi
        fi
    fi
}

function uninstall_theme() {
    uninstall_icons
    uninstall_splashscreen
    uninstall_launching_images
    if [[ -d "$themes_path/$theme" ]]; then
        rm -rf $themes_path/$theme
        echo "${theme^} removed successfully!"
    else
        echo "No '${theme}' folder to remove in $themes_path/ ... Move along!"
    fi
}

function install_icons() {
    check_theme
    if [[ ! -d "$themes_path/$theme/retropie/icons" ]]; then
        echo "There are no icons in ${theme^}. Can't install!"
    else
        if [[ ! -d "$icons_path/$backup_default_icons_dir" ]]; then
            mkdir -p $icons_path/$backup_default_icons_dir
            echo "$icons_path/$backup_default_icons_dir/ created successfully!"
            backup_default_icons
            copy_theme_icons
        else
            copy_theme_icons
        fi
    fi
}

function backup_default_icons() {
    if [[ ! -d "$icons_path" ]]; then
        echo "No icons to backup in $icons_path ... Move along!"
    else
        dest_icons=($icons_path/*)
        for dest_icon in "${dest_icons[@]}"; do
            if [[ -f "$dest_icon" ]]; then
                cp $dest_icon $icons_path/$backup_default_icons_dir
                echo "$icons_path/$backup_default_icons_dir/$(basename "$dest_icon") copied successfully!"
            fi
        done
        echo "All RetroPie's default icons backed up in $icons_path/$backup_default_icons_dir/ successfully!"
    fi
}

function copy_theme_icons() {
    if [[ ! -d "$themes_path/$theme/retropie/icons" ]]; then
        echo "There are no icons in ${theme^}. Can't copy!"
    else
        dest_files=($icons_path/*)
        for dest_file in "${dest_files[@]}"; do
            [ "$dest_file" = "$icons_path/$backup_default_icons_dir" ] && continue
            rm -rf "$dest_file"
            echo "$dest_file removed succesfully!"
        done
        if [[ ! -d $icons_path/$theme-icons ]]; then
            mkdir -p $icons_path/$theme-icons
            echo "$icons_path/$theme-icons/ created succesfully!"
        fi
        src_icons=($themes_path/$theme/retropie/icons/*)
        for src_icon in "${src_icons[@]}"; do
            if [[ -f "$src_icon" ]]; then
                cp $src_icon $icons_path
                echo "$icons_path/$(basename "$src_icon") copied successfully!"
                cp $src_icon $icons_path/$theme-icons
                echo "$icons_path/$theme-icons/$(basename "$src_icon") copied successfully!"
            fi
        done
        echo "All ${theme^} icons copied in $icons_path/ successfully!"
    fi
}

function uninstall_icons() {
    if [[ ! -d "$icons_path/$backup_default_icons_dir" ]]; then
        echo "No icons to uninstall ... Move along!"
    else
        dest_files=($icons_path/*)
        for dest_file in "${dest_files[@]}"; do
            [ "$dest_file" = "$icons_path/$backup_default_icons_dir" ] && continue
            rm -rf "$dest_file"
            echo "$dest_file removed succesfully!"
        done
        backup_icons=($icons_path/$backup_default_icons_dir/*)
        for backup_icon in "${backup_icons[@]}"; do
            if [[ -f "$backup_icon" ]]; then 
                cp $backup_icon $icons_path
                echo "$icons_path/$(basename "$backup_icon") copied successfully!"
            fi
        done
        echo "All icons restored from $icons_path/$backup_default_icons_dir/ succesfully!"
        if [[ -d "$icons_path/$backup_default_icons_dir" ]]; then
            rm -rf $icons_path/$backup_default_icons_dir
            echo "$icons_path/$backup_default_icons_dir/ removed succesfully!"
        fi
    fi
}

function install_splashscreen() {
    check_theme
    if [[ ! -d "$splashscreens_path" ]]; then
        mkdir -p $splashscreens_path
        echo "Splashscreens folder created successfully!"
    fi
    choose_splashscreen
}

function choose_splashscreen() {
    local options=()
    local i=1
    local splashscreens=($(find $themes_path/$theme -maxdepth 1 -type f -iname "*splash*"))
    if [[ $splashscreens ]]; then
        echo $splashscreens
    else
        echo "hola"
    fi
    exit
    for splashscreen in "${splashscreens[@]}"; do
        if [[ -f "$splashscreen" ]]; then 
            options+=("$i" "$(basename "$splashscreen")")
            ((i++))
        fi
    done
    local cmd=(dialog --backtitle "$backtitle" --menu "Choose an option for ${theme^} splashscreen" 15 50 06)
    local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    case "$choice" in
        *)
            if [[ $((choice%2)) -eq 0 ]]; then
                splashscreen="${options[$choice+1]}"
            else
                splashscreen="${options[$choice]}"
            fi
            rm -f $splashscreens_path/*
            cp $themes_path/$theme/$splashscreen $splashscreens_path
            echo "$splashscreen installed successfully!"
            ;; 
    esac
}

function uninstall_splashscreen() {
    if [[ -d "$splashscreens_path" ]]; then
        echo "$splashscreens_path"
        rm -f $splashscreens_path/*
        echo "${theme^} splashscreen removed successfully!"
    else
        echo "No splashscreen to remove ... Move along!"
    fi
}

function install_launching_images() {
    check_dependencies
    check_theme
    if [[ -d "$themes_path/$theme/launching-images" ]]; then
        if [[ -e "$themes_path/$theme/launching-images/.git" ]]; then
            echo "Launching images already installed."
            cd $themes_path/$theme/launching-images
            input="Launching images"
            check_updates
            cd -
        else
            rm -rf $themes_path/$theme/launching-images
            install_launching_images
        fi
    else
        if [[ $(curl "https://api.github.com/repos/$repo/es-runcommand-splash" | awk -F\" '/message/ {print $(NF-1)}') == "Not Found" ]]; then
            dialog --backtitle "$backtitle" --msgbox "This repository https://api.github.com/repos/$repo/es-runcommand-splash doesn't exist." 10 40 2>&1 >/dev/tty
        else
            echo "Installing Launching images ..."
            git clone --depth 1 "https://github.com/$repo/es-runcommand-splash.git" "$themes_path/$theme/launching-images"
            success=$?
            if [[ $success -eq 0 ]]; then
                copy_launching_images
                echo "Launching images installed successfully!"
            else
                dialog --backtitle "$backtitle" --msgbox "Something went wrong :_(\nCouldn't resolve https://github.com/$repo/es-runcommand-splash.git" 6 40 2>&1 >/dev/tty            
            fi
        fi
    fi
}

function copy_launching_images() {
    if [[ ! -d "$themes_path/$theme/launching-images" ]]; then
        install_launching_images
    else
        dirs=($themes_path/$theme/launching-images/*)
        for dir in "${dirs[@]}"; do
            if [[ -d "$dir" ]]; then
                if [[ -d "$launching_images_path/$(basename "$dir")" ]]; then
                    if [[ -e "$launching_images_path/$(basename "$dir")/launching.png" ]]; then
                        echo "There is already a 'launching.png' in $launching_images_path/$(basename "$dir")/"
                    else
                        cp $dir/launching.png $launching_images_path/$(basename "$dir")
                        echo "$launching_images_path/$(basename "$dir")/launching.png copied successfully!"
                    fi
                else
                    echo "The folder $launching_images_path/$(basename "$dir")/ doesn't exist. Can't copy!"
                fi
            fi
        done
        echo "All (possible) launching images copied successfully!"
    fi
}

function uninstall_launching_images() {
    dirs=($launching_images_path/*)
    for dir in "${dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            if [[ -d "$dir" ]]; then
                if [[ -e "$dir/launching.png" ]]; then
                    rm -f $dir/launching.png
                    echo "$dir/launching.png removed successfully!"
                else
                    echo "No 'launching.png' to remove in $dir/ ... Move along!"
                fi
            else
                echo "The folder '$(basename "$dir")' doesn't exist in $dir/"
            fi
        fi
    done
    echo "All (possible) 'launching.png' removed successfully!"
    if [[ -d "$themes_path/$theme/launching-images" ]]; then
        rm -rf $themes_path/$theme/launching-images
        echo "Launching images uninstalled successfully!"
    fi
}

function check_dependencies() {
    if ! which git > /dev/null; then
        echo -e "${RED}ERROR: git is not installed!${NC}"
        echo "Please install it with 'sudo apt-get install git'."
        exit
    fi
    if ! hash git > /dev/null 2>&1; then
        echo -e "${RED}ERROR: git is not installed!${NC}"
        echo "Please install it with 'sudo apt-get install git'."
        exit
    fi
}

function check_updates() {
    echo "Let's see if there are any updates ..."
    git remote update
    UPSTREAM=${1:-'@{u}'}
    LOCAL=$(git rev-parse @)
    REMOTE=$(git rev-parse "$UPSTREAM")
    BASE=$(git merge-base @ "$UPSTREAM")
    if [[ $LOCAL == $REMOTE ]]; then
        output="up to date"
        status="up-to-date"
        dialog --backtitle "$backtitle" --msgbox "$input is $output" 6 40 2>&1 >/dev/tty
    elif [[ $LOCAL == $BASE ]]; then
        output="needs to pull"
        status="needs-to-pull"
        dialog --backtitle "$backtitle" --msgbox "$input $output" 6 40 2>&1 >/dev/tty
    elif [[ $REMOTE == $BASE ]]; then
        output="needs to push"
        status="needs-to-push"
        dialog --backtitle "$backtitle" --msgbox "$input $output" 6 40 2>&1 >/dev/tty
    else
        output="diverged"
        status="diverged"
        dialog --backtitle "$backtitle" --msgbox "$input is $output" 6 40 2>&1 >/dev/tty
    fi
}

function check_theme() {
    if [[ ! -d "$themes_path/$theme" ]]; then
        echo "It seems like ${theme^} it's not installed ..."
        echo "Installing ${theme^} ..."
        install_theme
    fi
}

function try(){

    local themes=(
        "ehettervik pixel"
        "lilbud material"
    )

    while true; do
        local theme
        local repo
        local options=()
        local status=()
        local i=1
      
        for theme in "${themes[@]}"; do
            theme=($theme)
            theme="${theme[1]}"
            if [[ -d "$themes_path/$theme" ]]; then
                if [[ -e "$themes_path/$theme/.git" ]]; then
                    status+=("i")
                    options+=("$i" "Update or Uninstall ${theme^} (installed)")
                else
                    rm -rf "$themes_path/$theme"
                    status+=("n")
                    options+=("$i" "Install ${theme^} (not installed)")
                fi
            else
                status+=("n")
                options+=("$i" "Install ${theme^} (not installed)")
            fi
            ((i++))
        done
        
        local cmd=(dialog --backtitle "$backtitle" --menu "Choose an option" 15 60 06)
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        
        if [[ -n "$choice" && $choice > 0 ]]; then
            theme=(${themes[choice-1]})
            repo="${theme[0]}"
            theme="${theme[1]}"
            if [[ "${status[choice-1]}" == "i" ]]; then
                options=(1 "Update ${theme^}" 2 "Uninstall ${theme^}")
                #~ if [[ -d "$themes_path/$theme/retropie/icons" ]]; then
                    options+=(3 "Extras")
                #~ fi
                cmd=(dialog --backtitle "$backtitle" --menu "Choose an option for ${theme^}" 15 50 06)
                local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
                case "$choice" in
                    1)
                        install_theme $repo $theme
                        ;;
                    2)
                        uninstall_theme $repo $theme
                        ;;
                    3)
                        local options=()
                        local status=()
                        local i=1
                        
                        if [[ -d "$themes_path/$theme/retropie/icons" ]]; then
                            if [[ -d "$icons_path/$backup_default_icons_dir" && -d "$icons_path/$theme-icons" ]]; then
                                status+=("i")
                                options+=("$i" "Update or Uninstall ${theme^} icons (installed)")
                            else
                                status+=("n")
                                options+=("$i" "Install ${theme^} icons (not installed)")
                            fi
                            ((i++))
                        fi
                        
                        if [[ $(find $themes_path/$theme -maxdepth 1 -type f -iname "*splash*") ]]; then
                            if [[ "$(ls -A $splashscreens_path)" ]]; then
                                status+=("i")
                                options+=("$i" "Update or Uninstall ${theme^} splashscreen (installed)")
                            else
                                status+=("n")
                                options+=("$i" "Install ${theme^} splashscreen (not installed)")
                            fi
                            ((i++))
                        fi
    
                        if [[ $(curl "https://api.github.com/repos/$repo/es-runcommand-splash" 2>/dev/null | awk -F\" '/message/ {print $(NF-1)}') != "Not Found" ]]; then
                            if [[ -d "$themes_path/$theme/launching-images" ]]; then
                                status+=("i")
                                options+=("$i" "Update or Uninstall ${theme^} launching images (installed)")
                            else
                                status+=("n")
                                options+=("$i" "Install ${theme^} launching images (not installed)")
                            fi
                        fi
                        
                        cmd=(dialog --backtitle "$backtitle" --menu "Choose an option for ${theme^}" 15 75 06)
                        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
                        case "$choice" in
                            1)
                                if [[ "${status[choice-1]}" == "i" ]]; then
                                    options=(1 "Update ${theme^} icons" 2 "Uninstall ${theme^} icons")
                                    cmd=(dialog --backtitle "$backtitle" --menu "Choose an option for ${theme^} icons" 15 50 06)
                                    local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
                                    case "$choice" in
                                        1)
                                            copy_theme_icons $repo $theme
                                            ;;
                                        2)
                                            uninstall_icons $repo $theme
                                            ;;
                                    esac
                                else
                                    install_icons $repo $theme
                                fi
                                ;;
                            2)
                                if [[ "${status[choice-1]}" == "i" ]]; then
                                    options=(1 "Update ${theme^} splashscreen" 2 "Uninstall ${theme^} splashscreen")
                                    cmd=(dialog --backtitle "$backtitle" --menu "Choose an option for ${theme^} splashscreen" 15 50 06)
                                    local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
                                    case "$choice" in
                                        1)
                                            choose_splashscreen $repo $theme
                                            ;;
                                        2)
                                            uninstall_splashscreen $repo $theme
                                            ;;
                                    esac
                                else
                                    install_splashscreen $repo $theme
                                fi 
                                ;;
                            3)
                                if [[ "${status[choice-1]}" == "i" ]]; then
                                    options=(1 "Update ${theme^} launching images" 2 "Uninstall ${theme^} launching images")
                                    cmd=(dialog --backtitle "$backtitle" --menu "Choose an option for ${theme^} launching images" 15 50 06)
                                    local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
                                    case "$choice" in
                                        1)
                                            install_launching_images $repo $theme
                                            ;;
                                        2)
                                            uninstall_launching_images $repo $theme
                                            ;;
                                    esac
                                else
                                    install_launching_images $repo $theme
                                fi
                                ;;
                        esac
                        ;;
                esac
            else
                install_theme $repo $theme
            fi            
        else
            break
        fi
    done
}

# Call arguments verbatim
$@
