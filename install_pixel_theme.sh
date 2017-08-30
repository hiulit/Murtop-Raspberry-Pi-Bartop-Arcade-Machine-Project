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

INVALID_OPTION_MESSAGE="Invalid option. Please, enter an option (number)."

SRC_PIXEL_THEME_PATH="/etc/emulationstation/themes/$THEME"
GIT_PIXEL_THEME_URL="https://github.com/$REPO/es-theme-$THEME.git"
CURL_PIXEL_THEME_URL="https://api.github.com/repos/$REPO/es-theme-$THEME"

SRC_SPLASHSCREENS_PATH=$SRC_PIXEL_THEME_PATH
DEST_SPLASHSCREENS_PATH="/home/pi/RetroPie/splashscreens"

SRC_LAUNCHING_IMAGES_PATH="/home/pi/launching-images"
DEST_LAUNCHING_IMAGES_PATH="/opt/retropie/configs"
GIT_LAUNCHING_IMAGES_URL="https://github.com/ehettervik/es-runcommand-splash.git"
CURL_LAUNCHING_IMAGES_URL="https://api.github.com/repos/ehettervik/es-runcommand-splash"

function copy_launching_images() {
    if [[ ! -d "$SRC_LAUNCHING_IMAGES_PATH" ]]; then
        echo -e "${RED}$SRC_LAUNCHING_IMAGES_PATH/ doesn't exist!${NC}"
        exit
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
                echo -e "${RED}The folder /opt/retropie/configs/$(basename "$dir")/ doesn't exist. Can't copy!${NC}"
                ok=false
            fi
        fi
    done

    echo "Finishing ..."
        if [[ $ok != true ]]; then
            overwrite=true
            launch_launching_images_select $overwrite
        else
            echo -e "${GREEN}All (possible) launching images copied successfully!${NC}"
    fi
}

function uninstall_launching_images() {
    if [[ ! -d $DEST_LAUNCHING_IMAGES_PATH ]]; then
        echo -e "${RED}$DEST_LAUNCHING_IMAGES_PATH/ doesn't exist!${NC}"
        exit
    else
        if [[ ! "(ls -A $DEST_LAUNCHING_IMAGES_PATH)" ]]; then
            echo -e "${RED}$DEST_LAUNCHING_IMAGES_PATH/ is empty!${NC}"
            exit
        fi
    fi

    dirs=($DEST_LAUNCHING_IMAGES_PATH/*)

    #echo "There are ${#dirs[@]}" directories in the current path

    for dir in "${dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            #dir="${dir%/}"
            #echo "$dir"
            #echo $(basename "$dir")
            if [[ -d "$dir" ]]; then
                if [[ -e "$dir/launching.png" ]]; then
                    echo -e "${RED}Removing 'launching.png' from $dir/ ...${NC}"
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

    echo "Finishing ..."
    
    if [[ $ok == true ]]; then
        echo -e "${GREEN}All 'launching.png' removed from $DEST_LAUNCHING_IMAGES_PATH/ successfully!${NC}"
    else
        echo "No 'launching.png' to remove in $DEST_LAUNCHING_IMAGES_PATH/ ... Move along!"
    fi

    if [[ -d $SRC_LAUNCHING_IMAGES_PATH ]]; then
        rm -rf $SRC_LAUNCHING_IMAGES_PATH
        echo "Finishing ..."
        echo -e "${GREEN}Launching images repository removed from $SRC_LAUNCHING_IMAGES_PATH/ successfully!.${NC}"
    else
        echo "No launching images repository to remove in $SRC_LAUNCHING_IMAGES_PATH/ ... Move along!"
    fi
}

function install_launching_images() {
    if [[ -d $SRC_LAUNCHING_IMAGES_PATH ]]; then
        if [[  -e $SRC_LAUNCHING_IMAGES_PATH/.git ]]; then
            echo -e "${YELLOW}Launching images repository already installed.${NC}"
            echo "Let's see if there are any updates ..."
            cd $SRC_LAUNCHING_IMAGES_PATH
            git remote update

            UPSTREAM=${1:-'@{u}'}
            LOCAL=$(git rev-parse @)
            REMOTE=$(git rev-parse "$UPSTREAM")
            BASE=$(git merge-base @ "$UPSTREAM")

            if [[ $LOCAL == $REMOTE ]]; then
                echo -e "${GREEN}Up-to-date${NC}"
                #if [[  ]]; then
                    overwrite=true
                #else
                    #overwrite=false
                #fi
                launch_launching_images_select $overwrite
            elif [[ $LOCAL == $BASE ]]; then
                echo "Need to pull"
                git pull
            elif [[ $REMOTE == $BASE ]]; then
                echo "Need to push"
            else
                echo "Diverged"
            fi
        fi
    else
        if [[ $(curl $CURL_LAUNCHING_IMAGES_URL | awk -F\" '/message/ {print $(NF-1)}') == "Not Found" ]]; then
            echo -e "${RED}This repository doesn't exist.${NC}"
            exit
        else
            git clone --depth=1 $GIT_LAUNCHING_IMAGES_URL $SRC_LAUNCHING_IMAGES_PATH
            success=$?
            if [[ $success -eq 0 ]]; then
                echo -e "${GREEN}Lauching images repository cloned successfully!${NC}"
                overwrite=false
                launch_launching_images_select $overwrite
            else
                echo -e "${RED}Something went wrong :_(${NC}"
                echo -e "${RED}Couldn't resolve $GIT_LAUNCHING_IMAGES_URL${NC}"
            fi
        fi
    fi
}

function launch_launching_images_select() {
    text="install"
    
    if [[ $overwrite == true ]];then
        text="overwrite"
    fi

    echo -e "${PURPLE}Do you wish to ${BOLD}$text${PURPLE} launching images for each system?${NC}"
    
    select yn in "Yes" "No"; do
        case $yn in
            Yes )
                echo "$overwrite"
                copy_launching_images $overwrite
            break;;
            No ) exit;;
            * ) echo -e "${RED}$INVALID_OPTION_MESSAGE${NC}"
        esac
    done
}

function launch_splashscreen_select() {
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
            "None" ) exit;;
            * )
                echo -e "${RED}$INVALID_OPTION_MESSAGE${NC}"
        esac
    done
}

function install_splashscreen() {
    if [[ ! -d $SRC_PIXEL_THEME_PATH ]]; then
        echo -e "${RED}Pixel theme doesn't exist. Can't install splashscreens!${NC}"
        launch_pixel_theme_select
     else
        if [[ ! -d $DEST_SPLASHSCREENS_PATH ]]; then
            echo "Creating 'splashscreens' folder in /home/pi/RetroPie/ ..."
            cd /home/pi/RetroPie
            mkdir splashscreens
            echo -e "${GREEN}Splashscreens folder created successfully!${NC}"
            launch_splashscreen_select
        else
            if [[ "$(ls -A /home/pi/RetroPie/splashscreens)" ]]; then
                echo "There is already a splashscreen! Do you want to overwrite it?"
                
                select yn in "Yes" "No"; do
                    case $yn in
                        Yes )
                            echo "Removing splashscreen..."
                            rm -f /home/pi/RetroPie/splashscreens/*
                            echo "Splashscreen removed successfully!"
                            launch_splashscreen_select
                        break;;
                        No ) exit;;
                        * ) echo -e "${RED}$INVALID_OPTION_MESSAGE${NC}"
                    esac
                done
            else
                launch_splashscreen_select
            fi
        fi
    fi
}

function uninstall_splashscreen() {
    if [[ -d $DEST_SPLASHSCREENS_PATH ]]; then
        rm -rf $DEST_SPLASHSCREENS_PATH
        echo -e "${GREEN}Splashscreen removed from $DEST_SPLASHSCREENS_PATH/ successfully!${NC}"
    else
        echo "No splashscreen to be removed in $DEST_SPLASHSCREENS_PATH/ ... Move along!"
    fi
}

function launch_pixel_theme_select() {
    echo -e "${PURPLE}Do you wish to install Pixel theme?${NC}"
    select yn in "Yes" "No"; do
        case $yn in
            Yes )
                install_pixel_theme
            break;;
            No ) exit;;
            * ) echo -e "${RED}$INVALID_OPTION_MESSAGE${NC}"
        esac
    done
}

function install_pixel_theme() {
    if hash git >/dev/null 2>&1; then
        if [[ -d $SRC_PIXEL_THEME_PATH/.git ]]; then
            cd $SRC_PIXEL_THEME_PATH
            echo -e "${YELLOW}Pixel theme repository already installed.${NC}"
            echo "Let's see if there are any updates..."
            git remote update

            UPSTREAM=${1:-'@{u}'}
            LOCAL=$(git rev-parse @)
            REMOTE=$(git rev-parse "$UPSTREAM")
            BASE=$(git merge-base @ "$UPSTREAM")

            if [[ $LOCAL == $REMOTE ]]; then
                echo -e "${GREEN}Up-to-date${NC}"
                
                #if [[  ]]; then
                    overwrite=true
                #else
                    #overwrite=false
                #fi
            elif [[ $LOCAL == $BASE ]]; then
                echo "Need to pull"
                git pull
            elif [[ $REMOTE == $BASE ]]; then
                echo "Need to push"
            else
                echo "Diverged"
            fi
        else
            echo "Installing Pixel theme..."
            
            if [[ $(curl $CURL_PIXEL_THEME_URL | awk -F\" '/message/ {print $(NF-1)}') == "Not Found" ]]; then
                echo -e "${RED}This repository doesn't exist.${NC}"
            else
                git clone --depth=1 $GIT_PIXEL_THEME_URL $SRC_PIXEL_THEME_PATH
                success=$?
                if [[ $success -eq 0 ]]; then
                    echo -e "${GREEN}Pixel theme cloned successfully!${NC}"
                    install_splashscreen
                    install_launching_images
                    echo "Finishing..."
                    echo -e "${GREEN}Pixel theme installed successfully!${NC}"
                else
                    echo -e "${RED}Something went wrong :_(${NC}"
                    echo -e "${RED}Couldn't resolve $git_pixel_theme_url${NC}"
                fi
            fi
        fi
    else
        echo -e "${RED}git NOT installed.${ND}"
        echo "Do you wish to install git?"
        select yn in "Yes" "No"; do
            case $yn in
                Yes ) sudo apt-get install git lsb-release; break;;
                No ) exit;;
                * ) echo -e "${RED}Invalid option. Please, enter an option (a number).${NC}"
            esac
        done
    fi
}

function uninstall_pixel_theme() {
    uninstall_splashscreen
    uninstall_launching_images

    echo "Finishing ..."
    
    if [[ -d $SRC_PIXEL_THEME_PATH ]]; then
        rm -rf $SRC_PIXEL_THEME_PATH
        echo -e "${GREEN}Pixel theme removed from EmulationStation successfully!${NC}"
    else
        echo "No Pixel theme repository to remove in $SRC_PIXEL_THEME_PATH/ ... Move along!"
    fi
}

# Call arguments verbatim
$@