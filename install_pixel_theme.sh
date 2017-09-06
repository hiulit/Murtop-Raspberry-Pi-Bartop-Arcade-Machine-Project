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

function install_launching_images_select() {
    echo -e "${PURPLE}Do you wish to ${BOLD}install${PURPLE} launching images for ${THEME^} theme?${NC}"
    select yn in "Yes" "No"; do
        case $yn in
            Yes )
                install_launching_images
            break;;
            No )
                if [[ $from_install_theme == true ]]; then
                    install_icons_select
                else
                    return
                fi
            break;;
            * )
                echo -e "${RED}$INVALID_OPTION_MESSAGE${NC}"
        esac
    done
    exit
}

function copy_launching_images() {
    if [[ ! -d "$SRC_LAUNCHING_IMAGES_PATH" ]]; then
        echo -e "${RED}$SRC_LAUNCHING_IMAGES_PATH/ doesn't exist!${NC}"
        launching_images_systems_select
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
            launching_images_systems_select $overwrite
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
        echo -e "${GREEN}All 'launching.png' ${BOLD}removed${GREEN} from $DEST_LAUNCHING_IMAGES_PATH/ successfully!${NC}"
    else
        echo "No 'launching.png' to remove in $DEST_LAUNCHING_IMAGES_PATH/ ... Move along!"
    fi

    if [[ -d $SRC_LAUNCHING_IMAGES_PATH ]]; then
        rm -rf $SRC_LAUNCHING_IMAGES_PATH
        echo "Finishing ..."
        echo -e "${GREEN}Launching images repository ${BOLD}removed${GREEN} from $SRC_LAUNCHING_IMAGES_PATH/ successfully!.${NC}"
    else
        echo "No launching images repository to remove in $SRC_LAUNCHING_IMAGES_PATH/ ... Move along!"
    fi
}

function install_launching_images() {
    if [[ -d $SRC_LAUNCHING_IMAGES_PATH ]]; then
        if [[  -e $SRC_LAUNCHING_IMAGES_PATH/.git ]]; then
            echo -e "${YELLOW}Launching images repository already installed.${NC}"
            cd $SRC_LAUNCHING_IMAGES_PATH
            check_for_updates
            if [[ $status == "up-to-date" ]]; then
                overwrite=true
                launching_images_systems_select $overwrite
            else
                echo $status
            fi
        fi
    else
        if [[ $(curl $CURL_LAUNCHING_IMAGES_URL | awk -F\" '/message/ {print $(NF-1)}') == "Not Found" ]]; then
            echo -e "${RED}This repository $CURL_THEME_URL doesn't exist.${NC}"
            exit
        else
            git clone --depth=1 $GIT_LAUNCHING_IMAGES_URL $SRC_LAUNCHING_IMAGES_PATH
            success=$?
            if [[ $success -eq 0 ]]; then
                echo -e "${GREEN}Lauching images repository cloned successfully!${NC}"
                overwrite=false
                launching_images_systems_select $overwrite
            else
                echo -e "${RED}Something went wrong :_(${NC}"
                echo -e "${RED}Couldn't resolve $GIT_LAUNCHING_IMAGES_URL${NC}"
            fi
        fi
    fi
}

function launching_images_systems_select() {
    text="install"
    
    if [[ $overwrite == true ]]; then
        text="overwrite"
        echo -e "${YELLOW}Launching images already installed.${NC}"
    fi

    echo -e "${PURPLE}Do you wish to ${BOLD}$text${PURPLE} launching images for each system?${NC}"
    
    select yn in "Yes" "No"; do
        case $yn in
            Yes )
                echo "$overwrite"
                copy_launching_images $overwrite
            break;;
            No )
                if [[ $from_install_theme == true ]]; then
                    install_splashscreen
                else
                    exit
                fi
            break;;
            * ) echo -e "${RED}$INVALID_OPTION_MESSAGE${NC}"
        esac
    done
}

function splashscreen_select() {
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
                if [[ $from_install_theme == true ]]; then
                    launching_images_systems_select
                else
                    exit
                fi
            break;;
            * )
                echo -e "${RED}$INVALID_OPTION_MESSAGE${NC}"
        esac
    done
}

function install_splashscreen_select() {
    echo -e "${PURPLE}Do you wish to ${BOLD}install${PURPLE} a splashscreen for ${THEME^} theme?${NC}"
    select yn in "Yes" "No"; do
        case $yn in
            Yes )
                install_splashscreen
            break;;
            No )
                #if [[ $from_install_theme == true ]]; then
                   # install_launching_images_select
                #else
                   # exit
                #fi
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
            echo "Creating 'splashscreens' folder in /home/pi/RetroPie/ ..."
            cd /home/pi/RetroPie
            mkdir splashscreens
            echo -e "${GREEN}Splashscreens folder created successfully!${NC}"
            splashscreen_select $from_install_theme
        else
            if [[ "$(ls -A /home/pi/RetroPie/splashscreens)" ]]; then
                echo -e "${YELLOW}There is already a splashscreen installed.${NC}"
                echo -e "${PURPLE}Do you wish to ${BOLD}overwrite${PURPLE} the splashscreen?${NC}"
                
                select yn in "Yes" "No"; do
                    case $yn in
                        Yes )
                            echo "Removing splashscreen ..."
                            rm -f /home/pi/RetroPie/splashscreens/*
                            echo "Splashscreen removed successfully!"
                            splashscreen_select
                        break;;
                        No )
                            return
                        break;;
                        * ) echo -e "${RED}$INVALID_OPTION_MESSAGE${NC}"
                    esac
                done
            else
                splashscreen_select
            fi
        fi
    fi
}

function uninstall_splashscreen() {
    if [[ -d $DEST_SPLASHSCREENS_PATH ]]; then
        rm -rf $DEST_SPLASHSCREENS_PATH
        echo -e "${GREEN}Splashscreen ${BOLD}removed${GREEN} from $DEST_SPLASHSCREENS_PATH/ successfully!${NC}"
    else
        echo "No 'launching.png' to remove in $DEST_SPLASHSCREENS_PATH/ ... Move along!"
    fi
}

function check_for_updates() {
    echo "Let's see if there are any updates ..."
    git remote update

    UPSTREAM=${1:-'@{u}'}
    LOCAL=$(git rev-parse @)
    REMOTE=$(git rev-parse "$UPSTREAM")
    BASE=$(git merge-base @ "$UPSTREAM")

    if [[ $LOCAL == $REMOTE ]]; then
        output="${GREEN}Up-to-date${NC}"
        status="up-to-date"
        #if [[  ]]; then
            overwrite=true
        #else
            #overwrite=false
        #fi
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

function check_directory() {
    if [[ -d $directory_to_check ]]; then
        echo -e "${RED}$directory_to_check doesn't exist${NC}"
    fi
    if [[ -d $directory_to_check/.git ]]; then
        echo -e "${YELLOW}${THEME^} theme repository already cloned/installed.${NC}"
    fi
}

function install_theme() {
    if hash git >/dev/null 2>&1; then
        if [[ -d $SRC_THEME_PATH/.git ]]; then
            cd $SRC_THEME_PATH
            echo -e "${YELLOW}${THEME^} theme repository already cloned/installed.${NC}"
            check_for_updates
            if [[ $status == "up-to-date" ]]; then
                install_icons_select
                install_splashscreen_select
                install_launching_images_select
            else
                echo $status
            fi
        else
            echo "Installing ${THEME^} theme ..."
            
            if [[ $(curl $CURL_THEME_URL | awk -F\" '/message/ {print $(NF-1)}') == "Not Found" ]]; then
                echo -e "${RED}This repository $CURL_THEME_URL doesn't exist.${NC}"
            else
                git clone --depth=1 $GIT_THEME_URL $SRC_THEME_PATH
                success=$?
                if [[ $success -eq 0 ]]; then
                    from_install_theme=true
                    echo -e "${GREEN}${THEME^} theme cloned/installed successfully!${NC}"
                    install_icons_select
                    install_splashscreen_select
                    install_launching_images_select
                    echo "Finishing..."
                    echo -e "${GREEN}${THEME^} theme installed successfully!${NC}"
                else
                    echo -e "${RED}Something went wrong :_(${NC}"
                    echo -e "${RED}Couldn't resolve $GIT_THEME_URL${NC}"
                fi
            fi
        fi
        if [[ $from_install_theme != true ]]; then
            if [[ -d $SRC_THEME_PATH/.git ]]; then
                cd $SRC_LAUNCHING_IMAGES_PATH
                echo -e "${YELLOW}Launching images repository already cloned/installed.${NC}"
                check_for_updates
                if [[ $status == "up-to-date" ]]; then
                    overwrite=true
                    launching_images_systems_select $overwrite
                else
                    echo $status
                fi
            fi
        fi
    else
        echo -e "${RED}git NOT installed.${ND}"
        echo -e "${PURPLE}Do you wish to ${BOLD}install${PURPLE} git?${NC}"
        select yn in "Yes" "No"; do
            case $yn in
                Yes ) sudo apt-get install git lsb-release; break;;
                No ) exit;;
                * ) echo -e "${RED}Invalid option. Please, enter an option (a number).${NC}"
            esac
        done
    fi
}

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
                return
            break;;
            * ) echo -e "${RED}$INVALID_OPTION_MESSAGE${NC}"
        esac
    done
}

function install_icons_select() {
    text="install"
    
    if [[ $overwrite == true ]]; then
        text="overwrite"
        echo -e "${YELLOW}There are already icons installed!${NC}"
    fi
    
    echo -e "${PURPLE}Do you wish to ${BOLD}$text${PURPLE} ${THEME^} theme's icons?${NC}"
    select yn in "Yes" "No"; do
        case $yn in
            Yes )
                install_icons $overwrite
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
        echo -e "${RED}Can't ${BOLD}uninstall${RED} icons! There are no icons installed.${NC}"
    else
        dest_icons=($DEST_THEME_ICONS_PATH/*)
        for dest_icon in "${dest_icons[@]}"; do
            if [[ -f "$dest_icon" ]]; then
                #echo "$dest_icon"
                #echo $(basename "$dest_icon")
                echo "Removing '$(basename "$dest_icon")' from $DEST_THEME_ICONS_PATH/$BACKUP_ICONS_DIR/ ..."
                rm $dest_icon
                echo -e "${GREEN}'$(basename "$dest_icon")' removed successfully!${NC}"
                ok=true
            fi
        done
        
        backup_icons=($DEST_THEME_ICONS_PATH/$BACKUP_ICONS_DIR/*)
        for backup_icon in "${backup_icons[@]}"; do
            if [[ -f "$backup_icon" ]]; then
                #echo "$backup_icon"
                #echo $(basename "$backup_icon")
                echo "Copying '$(basename "$backup_icon")' to $DEST_THEME_ICONS_PATH/ ..."
                cp $backup_icon $DEST_THEME_ICONS_PATH/
                echo -e "${GREEN}'$(basename "$backup_icon")' copied successfully!${NC}"
                backup_ok=true
            fi
        done
        
        if [[ $backup_ok == true ]]; then
            echo -e "${GREEN}All icons ${BOLD}restored${GREEN} from $DEST_THEME_ICONS_PATH/$BACKUP_ICONS_DIR/ succesfully!${NC}"
            if [[ -d $DEST_THEME_ICONS_PATH/$BACKUP_ICONS_DIR ]]; then
                echo "Removing $DEST_THEME_ICONS_PATH/$BACKUP_ICONS_DIR/ ..."
                rm -rf $DEST_THEME_ICONS_PATH/$BACKUP_ICONS_DIR
                echo -e "${GREEN}'$BACKUP_ICONS_DIR' folder ${BOLD}removed${GREEN} from $DEST_THEME_ICONS_PATH/ succesfully!${NC}"
            fi
        fi
    fi
}

function install_icons() {
    if [[ ! -d $SRC_THEME_ICONS_PATH ]]; then
        echo -e "${RED}$SRC_THEME_ICONS_PATH/ doesn't exist!${NC}"
        exit
    else
        if [[ ! "(ls -A $SRC_THEME_ICONS_PATH)" ]]; then
            echo -e "${RED}$SRC_THEME_ICONS_PATH/ is empty!${NC}"
            exit
        fi
    fi
    
    if [[ ! -d $DEST_THEME_ICONS_PATH/$BACKUP_ICONS_DIR ]]; then
        echo "Creating '$BACKUP_ICONS_DIR' in $DEST_THEME_ICONS_PATH/ ..."
        mkdir $DEST_THEME_ICONS_PATH/$BACKUP_ICONS_DIR
        echo -e "${GREEN}'$BACKUP_ICONS_DIR' ${BOLD}created${GREEN} in $DEST_THEME_ICONS_PATH/ successfully!${NC}"
    else
        if [[ ! "(ls -A $DEST_THEME_ICONS_PATH/$BACKUP_ICONS_DIR)" ]]; then
            echo -e "${RED}$DEST_THEME_ICONS_PATH/$BACKUP_ICONS_DIR/ is empty!${NC}"
        else
            if [[ $overwrite != true ]]; then
                overwrite=true
                install_icons_select $overwrite
            fi
        fi
    fi
    
    if [[ $overwrite != true ]]; then
        dest_icons=($DEST_THEME_ICONS_PATH/*)
        for dest_icon in "${dest_icons[@]}"; do
            if [[ -f "$dest_icon" ]]; then
                #echo "$dest_icon"
                #echo $(basename "$dest_icon")
                echo "Copying '$(basename "$dest_icon")' into $DEST_THEME_ICONS_PATH/$BACKUP_ICONS_DIR/ ..."
                cp $dest_icon $DEST_THEME_ICONS_PATH/$BACKUP_ICONS_DIR
                echo -e "${GREEN}$DEST_THEME_ICONS_PATH/$BACKUP_ICONS_DIR/$(basename "$dest_icon") copied successfully!${NC}"
                ok=true
            fi
        done
        
        echo "Finishing ..."
        if [[ $ok == true ]]; then
            echo -e "${GREEN}All RetroPie's default icons ${BOLD}backed up${GREEN} in $DEST_THEME_ICONS_PATH/$BACKUP_ICONS_DIR/ successfully!${NC}"
        fi
    fi
    
    src_icons=($SRC_THEME_ICONS_PATH/*)
    for src_icon in "${src_icons[@]}"; do
        if [[ -f "$src_icon" ]]; then
            #echo "$src_icon"
            #echo $(basename "$src_icon")
            echo "Copying '$(basename "$src_icon")' into $DEST_THEME_ICONS_PATH/ ..."
            cp $src_icon $DEST_THEME_ICONS_PATH
            echo -e "${GREEN}$DEST_THEME_ICONS_PATH/$(basename "$src_icon") copied successfully!${NC}"
            ok=true
        fi
    done
    
    echo "Finishing ..."
    if [[ $ok == true ]]; then
        echo -e "${GREEN}All ${THEME^} theme's icons ${BOLD}copied${GREEN} in $DEST_THEME_ICONS_PATH/$BACKUP_ICONS_DIR/ successfully!${NC}"
    fi
}

function uninstall_theme() {
    uninstall_theme_select
}

function uninstall_theme_select() {
    echo -e "${PURPLE}Do you wish to ${BOLD}uninstall${PURPLE} ${THEME^} theme completely?${NC}"
    select yn in "Yes" "No"; do
    case $yn in
        Yes )
            uninstall_icons
            uninstall_splashscreen
            uninstall_launching_images
            echo "Finishing ..."
            if [[ -d $SRC_THEME_PATH ]]; then
                rm -rf $SRC_THEME_PATH
                echo -e "${GREEN}${THEME^} theme ${BOLD}removed${GREEN} from EmulationStation successfully!${NC}"
            else
                echo "No ${THEME^} theme repository to remove in $SRC_THEME_PATH/ ... Move along!"
            fi
        break;;
        No ) exit;;
        * ) echo -e "${RED}$INVALID_OPTION_MESSAGE${NC}"
    esac
    done
}

# Call arguments verbatim
$@