#!/bin/bash

RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
PURPLE="\033[0;35m"
NC="\033[0m"

BOLD=$(tput bold)
NORMAL=$(tput sgr0)

REPO="Retropie"
THEME="pixel"

INVALID_OPTION_MESSAGE="Invalid option. Please, enter a valid option (number)."

SRC_THEME_PATH="/etc/emulationstation/themes/$THEME"
SRC_THEME_ICONS_PATH="$SRC_THEME_PATH/retropie/icons"
DEST_THEME_ICONS_PATH="/home/pi/RetroPie/retropiemenu/icons"
BACKUP_ICONS_DIR="backup-icons"
GIT_THEME_URL="https://github.com/$REPO/es-theme-$THEME.git"
CURL_THEME_URL="https://api.github.com/repos/$REPO/es-theme-$THEME"

SRC_SPLASHSCREENS_PATH=$SRC_THEME_PATH
DEST_SPLASHSCREENS_PATH="/home/pi/RetroPie/splashscreens"

SRC_LAUNCHING_IMAGES_PATH="/home/pi/launching-images"
DEST_LAUNCHING_IMAGES_PATH="/opt/retropie/configs"
GIT_LAUNCHING_IMAGES_URL="https://github.com/ehettervik/es-runcommand-splash.git"
CURL_LAUNCHING_IMAGES_URL="https://api.github.com/repos/ehettervik/es-runcommand-splash"

function install_theme_select() {
    text="install"
    if [[ $overwrite == true ]]; then
        text="overwrite"
        echo -e "${YELLOW}${THEME^} theme already installed.${NC}"
    fi
    echo -e "${PURPLE}Do you wish to ${BOLD}$text${PURPLE} ${THEME^} theme?${NC}"
    select yn in "Yes" "No"; do
        case $yn in
            Yes )
                install_theme
            break;;
            No )
                exit
            break;;
            * ) echo -e "${RED}$INVALID_OPTION_MESSAGE${NC}"
        esac
    done
}

function install_theme() {
    check_dependencies
    if [[ -d $SRC_THEME_PATH/.git ]]; then
        cd $SRC_THEME_PATH
        echo -e "${YELLOW}${THEME^} theme already cloned/installed.${NC}"
        check_updates
        if [[ $status == "up-to-date" ]]; then
            install_icons_select
            install_splashscreen_select
            install_launching_images_select
        else
            echo $status
        fi
    else
        if [[ $(curl $CURL_THEME_URL | awk -F\" '/message/ {print $(NF-1)}') == "Not Found" ]]; then
            echo -e "${RED}This repository $CURL_THEME_URL doesn't exist.${NC}"
        else
            echo "Installing ${THEME^} theme ..."
            git clone --depth=1 $GIT_THEME_URL $SRC_THEME_PATH
            success=$?
            if [[ $success -eq 0 ]]; then
                echo -e "${GREEN}${THEME^} theme cloned/installed successfully!${NC}"
                install_icons_select
                install_splashscreen_select
                install_launching_images_select
                echo -e "\nFinishing ...\n"
                echo -e "\n${GREEN}${THEME^} theme installed successfully!${NC}\n"
            else
                echo -e "\n${RED}Something went wrong :_(${NC}"
                echo -e "${RED}Couldn't resolve $GIT_THEME_URL${NC}\n"
            fi
        fi
    fi
}

function uninstall_theme_select() {
    echo -e "${PURPLE}Do you wish to ${BOLD}uninstall${PURPLE} ${THEME^} theme completely?${NC}"
    select yn in "Yes" "No"; do
    case $yn in
        Yes )
            uninstall_theme
        break;;
        No ) exit;;
        * ) echo -e "${RED}$INVALID_OPTION_MESSAGE${NC}"
    esac
    done
}

function uninstall_theme() {
    uninstall_icons
    uninstall_splashscreen
    uninstall_launching_images
    echo -e "\nFinishing ...\n"
    if [[ -d $SRC_THEME_PATH ]]; then
        rm -rf $SRC_THEME_PATH
        echo -e "\n${GREEN}${THEME^} theme removed successfully!${NC}\n"
    else
        echo -e "\nNo ${THEME^} theme repository to remove in $SRC_THEME_PATH/ ... Move along!\n"
    fi
}

function install_icons_select() {
    text="install"
    if [[ $overwrite == true ]]; then
        text="overwrite"
        echo -e "${YELLOW}There are already icons for ${THEME^} theme installed.${NC}"
    fi
    echo -e "${PURPLE}Do you wish to ${BOLD}$text${PURPLE} ${THEME^} theme's ${BOLD}icons${PURPLE}?${NC}"
    select yn in "Yes" "No"; do
        case $yn in
            Yes )
                install_icons
            break;;
            No )
                return
            break;;
            * ) echo -e "${RED}$INVALID_OPTION_MESSAGE${NC}"
        esac
    done
}

function install_icons() {
    if [[ ! -d $SRC_THEME_ICONS_PATH ]]; then
        echo "It seems like ${THEME^} theme it's not installed ..."
        install_theme_select
    elif [[ ! "$(ls -A $SRC_THEME_ICONS_PATH)" ]]; then
        echo -e "${RED}Can't install icons because $SRC_THEME_ICONS_PATH/ is empty!${NC}"
    else
        if [[ ! -d $DEST_THEME_ICONS_PATH/$BACKUP_ICONS_DIR ]]; then
            echo -e "\nCreating '$BACKUP_ICONS_DIR' folder in $DEST_THEME_ICONS_PATH/ ...\n"
            mkdir $DEST_THEME_ICONS_PATH/$BACKUP_ICONS_DIR
            echo -e "\n${GREEN}$DEST_THEME_ICONS_PATH/$BACKUP_ICONS_DIR/ created successfully!${NC}\n"
            backup_default_icons
            copy_theme_icons
        else
            if [[ "$(ls -A $DEST_THEME_ICONS_PATH/$BACKUP_ICONS_DIR)" ]]; then
                if [[ $overwrite == true ]]; then
                    copy_theme_icons
                else
                    overwrite=true
                    install_icons_select $overwrite
                fi
            else
                backup_default_icons
            fi
        fi
    fi
}

function backup_default_icons() {
    dest_icons=($DEST_THEME_ICONS_PATH/*)
    for dest_icon in "${dest_icons[@]}"; do
        if [[ -f "$dest_icon" ]]; then
            echo "Copying '$(basename "$dest_icon")' into $DEST_THEME_ICONS_PATH/$BACKUP_ICONS_DIR/ ..."
            cp $dest_icon $DEST_THEME_ICONS_PATH/$BACKUP_ICONS_DIR
            echo -e "${GREEN}$DEST_THEME_ICONS_PATH/$BACKUP_ICONS_DIR/$(basename "$dest_icon") copied successfully!${NC}"
        fi
    done
    echo -e "\nFinishing ...\n"
    echo -e "\n${GREEN}All RetroPie's default icons backed up in $DEST_THEME_ICONS_PATH/$BACKUP_ICONS_DIR/ successfully!${NC}\n"
}

function copy_theme_icons() {
    src_icons=($SRC_THEME_ICONS_PATH/*)
    for src_icon in "${src_icons[@]}"; do
        if [[ -f "$src_icon" ]]; then
            echo "Copying '$(basename "$src_icon")' into $DEST_THEME_ICONS_PATH/ ..."
            cp $src_icon $DEST_THEME_ICONS_PATH
            echo -e "${GREEN}$DEST_THEME_ICONS_PATH/$(basename "$src_icon") copied successfully!${NC}"
        fi
    done
    echo -e "\nFinishing ...\n"
    echo -e "\n${GREEN}All ${THEME^} theme's icons copied in $DEST_THEME_ICONS_PATH/ successfully!${NC}\n"
}

function uninstall_icons_select() {
    echo -e "${PURPLE}Do you wish to ${BOLD}uninstall${PURPLE} ${THEME^} theme's icons?${NC}"
    select yn in "Yes" "No"; do
        case $yn in
            Yes )
                uninstall_icons
            break;;
            No )
                return
            break;;
            * ) echo -e "${RED}$INVALID_OPTION_MESSAGE${NC}"
        esac
    done
}

function uninstall_icons() {
    if [[ ! -d $DEST_THEME_ICONS_PATH/$BACKUP_ICONS_DIR ]]; then
        echo "No icons to restore in $DEST_THEME_ICONS_PATH/$BACKUP_ICONS_DIR ... Move along!"
    else
        dest_icons=($DEST_THEME_ICONS_PATH/*)
        for dest_icon in "${dest_icons[@]}"; do
            if [[ -f "$dest_icon" ]]; then
                echo "Removing '$(basename "$dest_icon")' from $DEST_THEME_ICONS_PATH/ ..."
                rm $dest_icon
                echo -e "${GREEN}$DEST_THEME_ICONS_PATH/$(basename "$dest_icon") removed successfully!${NC}"
                ok=true
            fi
        done
        backup_icons=($DEST_THEME_ICONS_PATH/$BACKUP_ICONS_DIR/*)
        for backup_icon in "${backup_icons[@]}"; do
            if [[ -f "$backup_icon" ]]; then
                echo "Copying '$(basename "$backup_icon")' to $DEST_THEME_ICONS_PATH/ ..."
                cp $backup_icon $DEST_THEME_ICONS_PATH/
                echo -e "${GREEN}$DEST_THEME_ICONS_PATH/$(basename "$backup_icon") copied successfully!${NC}"
                backup_ok=true
            fi
        done
        if [[ $backup_ok == true ]]; then
            echo -e "\n${GREEN}All icons restored from $DEST_THEME_ICONS_PATH/$BACKUP_ICONS_DIR/ succesfully!${NC}\n"
            if [[ -d $DEST_THEME_ICONS_PATH/$BACKUP_ICONS_DIR ]]; then
                echo "Removing $DEST_THEME_ICONS_PATH/$BACKUP_ICONS_DIR/ ..."
                rm -rf $DEST_THEME_ICONS_PATH/$BACKUP_ICONS_DIR
                echo -e "\n${GREEN}$DEST_THEME_ICONS_PATH/$BACKUP_ICONS_DIR/ removed succesfully!${NC}\n"
            fi
        fi
    fi
}

function install_splashscreen_select() {
    text="install"    
    if [[ $overwrite == true ]]; then
        text="overwrite"
        echo -e "${YELLOW}There is already a splashscreen for ${THEME^} theme installed.${NC}"
    fi
    echo -e "${PURPLE}Do you wish to ${BOLD}$text${PURPLE} ${THEME^} theme's ${BOLD}splashscreen${PURPLE}?${NC}"
    select yn in "Yes" "No"; do
        case $yn in
            Yes )
                install_splashscreen
            break;;
            No )
                return
            break;;
            * )
                echo -e "${RED}$INVALID_OPTION_MESSAGE${NC}"
        esac
    done
}

function install_splashscreen() {
    if [[ ! -d $SRC_THEME_PATH ]]; then
        echo -e "${RED}${THEME^} theme doesn't exist. Can't install splashscreens!${NC}"
        install_theme_select
    else
        if [[ ! -d $DEST_SPLASHSCREENS_PATH ]]; then
            echo -e "Creating 'splashscreens' folder in /home/pi/RetroPie/ ..."
            cd /home/pi/RetroPie
            mkdir splashscreens
            echo -e "${GREEN}Splashscreens folder created successfully!${NC}"
            choose_splashscreen_select
        else
            if [[ "$(ls -A /home/pi/RetroPie/splashscreens)" ]]; then
                if [[ $overwrite == true ]]; then
                    rm -f $DEST_SPLASHSCREENS_PATH/*
                    choose_splashscreen_select
                else
                    overwrite=true
                    install_splashscreen_select $overwrite
                fi
            else
                choose_splashscreen_select
            fi
        fi
    fi
}

function choose_splashscreen_select() {
    echo -e "${PURPLE}Do you wish the 16:9 (widescreen) or the 4:3 (squarescreen) splashscreen?${NC}"
    select splashscreen in "16:9 (widescreen)" "4:3 (squarescreen)" "None"; do
        case $splashscreen in
            "16:9 (widescreen)" )
                cp $SRC_SPLASHSCREENS_PATH/splash16-9.png $DEST_SPLASHSCREENS_PATH
                echo -e "${GREEN}$splashscreen splashscreen copied successfully!${NC}"
            break;;
            "4:3 (squarescreen)" )
                cp $SRC_SPLASHSCREENS_PATH/splash4-3.png $DEST_SPLASHSCREENS_PATH
                echo -e "${GREEN}$splashscreen splashscreen copied successfully!${NC}"
            break;;
            "None" )
                return
            break;;
            * )
                echo -e "${RED}$INVALID_OPTION_MESSAGE${NC}"
        esac
    done
}

function uninstall_splashscreen() {
    if [[ -d $DEST_SPLASHSCREENS_PATH ]]; then
        rm -f $DEST_SPLASHSCREENS_PATH/*
        echo -e "\n${GREEN}Splashscreen removed from $DEST_SPLASHSCREENS_PATH/ successfully!${NC}\n"
    else
        echo -e "${YELLOW}No splashscreen to remove in $DEST_SPLASHSCREENS_PATH/ ... Move along!${NV}"
    fi
}

function install_launching_images_select() {
    text="install"
    if [[ $overwrite == true ]]; then
        text="overwrite"
        echo -e "${YELLOW}There are already launching images for ${THEME^} theme installed.${NC}"
    fi
    echo -e "${PURPLE}Do you wish to ${BOLD}$text${PURPLE} ${THEME^} theme's ${BOLD}launching images${PURPLE}?${NC}"
    select yn in "Yes" "No"; do
        case $yn in
            Yes )
                install_launching_images
            break;;
            No )
                return
            break;;
            * )
                echo -e "${RED}$INVALID_OPTION_MESSAGE${NC}"
        esac
    done
    exit
}

function install_launching_images_systems_select() {
    text="install"
    if [[ $overwrite == true ]]; then
        text="overwrite"
        echo -e "${YELLOW}Launching images already installed.${NC}"
    fi
    echo -e "${PURPLE}Do you wish to ${BOLD}$text${PURPLE} ${THEME^} theme's ${BOLD}launching images for each system${PURPLE}?${NC}"
    select yn in "Yes" "No"; do
        case $yn in
            Yes )
                copy_launching_images $overwrite
            break;;
            No )
                return
            break;;
            * ) echo -e "${RED}$INVALID_OPTION_MESSAGE${NC}"
        esac
    done
}

function copy_launching_images() {
    if [[ ! -d "$SRC_LAUNCHING_IMAGES_PATH" ]]; then
        echo -e "${RED}$SRC_LAUNCHING_IMAGES_PATH/ doesn't exist!${NC}"
        install_launching_images_systems_select
    fi
    dirs=($SRC_LAUNCHING_IMAGES_PATH/*)
    #echo "There are ${#dirs[@]}" directories in the current path
    for dir in "${dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            #dir="${dir%/}"
            #echo "$dir"
            #echo $(basename "$dir")
            if [[ -d "$DEST_LAUNCHING_IMAGES_PATH/$(basename "$dir")" ]]; then
                if [[ -e "$DEST_LAUNCHING_IMAGES_PATH/$(basename "$dir")/launching.png" ]] && [[ $overwrite != true ]]; then
                    echo -e "${YELLOW}There is already a 'launching.png' in $DEST_LAUNCHING_IMAGES_PATH/$(basename "$dir")/${NC}"
                    ok=false
                else
                    echo "Copying 'launching.png' into $DEST_LAUNCHING_IMAGES_PATH/$(basename "$dir")/ ..."
                    cp $dir/launching.png $DEST_LAUNCHING_IMAGES_PATH/$(basename "$dir")
                    echo -e "${GREEN}$DEST_LAUNCHING_IMAGES_PATH/$(basename "$dir")/launching.png copied successfully!${NC}"
                    ok=true
                fi
            else
                echo -e "${YELLOW}The folder $DEST_LAUNCHING_IMAGES_PATH/$(basename "$dir")/ doesn't exist. Can't copy!${NC}"
                ok=false
            fi
        fi
    done
    echo -e "\nFinishing ...\n"
    if [[ $ok != true ]]; then
        overwrite=true
        install_launching_images_systems_select $overwrite
    else
        echo -e "\n${GREEN}All (possible) launching images copied successfully!${NC}\n"
    fi
}

function install_launching_images() {
    if [[ -d $SRC_LAUNCHING_IMAGES_PATH ]]; then
        if [[  -e $SRC_LAUNCHING_IMAGES_PATH/.git ]]; then
            echo -e "${YELLOW}Launching images repository already installed.${NC}"
            cd $SRC_LAUNCHING_IMAGES_PATH
            check_updates
            if [[ $status == "up-to-date" ]]; then
                install_launching_images_systems_select
            else
                echo $status
            fi
        fi
    else
    echo "Installing launching images for ${THEME^} theme ..."
        if [[ $(curl $CURL_LAUNCHING_IMAGES_URL | awk -F\" '/message/ {print $(NF-1)}') == "Not Found" ]]; then
            echo -e "${RED}This repository $CURL_THEME_URL doesn't exist.${NC}"
            exit
        else
            git clone --depth=1 $GIT_LAUNCHING_IMAGES_URL $SRC_LAUNCHING_IMAGES_PATH
            success=$?
            if [[ $success -eq 0 ]]; then
                echo -e "${GREEN}Lauching images repository cloned/installed successfully!${NC}"
                install_launching_images_systems_select
            else
                echo -e "${RED}Something went wrong :_(${NC}"
                echo -e "${RED}Couldn't resolve $GIT_LAUNCHING_IMAGES_URL${NC}"
            fi
        fi
    fi
}

function uninstall_launching_images() {
    if [[ ! -d $DEST_LAUNCHING_IMAGES_PATH ]]; then
        echo -e "${RED}$DEST_LAUNCHING_IMAGES_PATH/ doesn't exist!${NC}"
        exit
    else
        if [[ ! "$(ls -A $DEST_LAUNCHING_IMAGES_PATH)" ]]; then
            echo -e "${RED}$DEST_LAUNCHING_IMAGES_PATH/ is empty!${NC}"
            exit
        fi
    fi
    dirs=($DEST_LAUNCHING_IMAGES_PATH/*)
    for dir in "${dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            if [[ -d "$dir" ]]; then
                if [[ -e "$dir/launching.png" ]]; then
                    echo "Removing 'launching.png' from $dir/ ..."
                    rm -f $dir/launching.png
                    echo -e "${GREEN}$dir/launching.png removed successfully!${NC}"
                    ok=true
                else
                    echo "No 'launching.png' to remove in $dir/ ... Move along!"
                fi
            else
                echo -e "${RED}The folder '$(basename "$dir")' doesn't exist in $dir/${NC}"
            fi
        fi
    done
    echo -e "\nFinishing ...\n"
    if [[ $ok == true ]]; then
        echo -e "${GREEN}All (possible) 'launching.png' removed successfully!${NC}"
    else
        echo -e "\nNo 'launching.png' to remove ... Move along!\n"
    fi
    echo -e "\nFinishing ...\n"
    if [[ -d $SRC_LAUNCHING_IMAGES_PATH ]]; then
        rm -rf $SRC_LAUNCHING_IMAGES_PATH
        echo -e "${GREEN}Launching images repository removed from $SRC_LAUNCHING_IMAGES_PATH/ successfully!.${NC}"
    else
        echo -e "\nNo launching images repository to remove in $SRC_LAUNCHING_IMAGES_PATH/ ... Move along!\n"
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
        output="${GREEN}Up-to-date${NC}"
        status="up-to-date"
    elif [[ $LOCAL == $BASE ]]; then
        output="Need to pull"
        status="need-to-pull"
    elif [[ $REMOTE == $BASE ]]; then
        output="Need to push"
        status="need-to-push"
    else
        output="Diverged"
        status="diverged"
    fi
    echo -e $output
}

# declare -F | cut -d ' ' -f3

#~ install_theme_select

# Call arguments verbatim
$@
