#!/bin/bash

# Good sources:
# https://github.com/its-a-feature/awesome-osx-command-line
# https://github.com/rusty1s/dotfiles/blob/master/macos/defaults.sh
# https://github.com/rusty1s/dotfiles/blob/master/mac
# https://github.com/mrmachine/dotfiles/blob/master/home/bin/osx-defaults.sh




function msg_header() {
    local args_str="$@"

    echo ""
    echo ""
    echo "===== ===== ====="
    printf "${GREEN}Info:${NC} ${args_str[*]}\n"
    echo "===== ===== ====="
    echo ""
}



function restart_finder() {
    killall Finder 2>/dev/null
    killall cfprefsd 2>/dev/null
}



# Функция для проверки того есть ли у текущего Mac батарея
# то есть является ли текущий Mac - ноутбуком, а не ПК
# Аргументы: -
# Возвращает: -
function does_it_have_battery() {
    if pmset -g batt 2>/dev/null | grep -q "InternalBattery"; then
        return 0
    if pmset -g batt 2>/dev/null | grep -E "Battery|AC"; then
        return 0
    elif ioreg -r -k AppleLowBattery | grep -q "AppleLowBattery"; then
        return 0
    else
        return 1
    fi
}



# Функция для отключения GateKeeper в macOS
# Аргументы: -
# Возвращает: -
function gatekeeper_disable() {
    local macos_version
    macos_version=$(sw_vers -productVersion)

    echo "Start disabling GateKeeper"

    if [[ $(echo "$macos_version 11" | awk '{print ($1 > $2)}') -eq 1 ]]; then
        # echo "Версия macOS больше или равна 11"
        if [[ $(echo "$macos_version 13" | awk '{print ($1 > $2)}') -eq 1 ]]; then
            # echo "Версия macOS больше или равна 13"
            echo "Detected that current macOS 13 or newer"
            spctl --global-disable; open "x-apple.systempreferences:com.apple.preference.security?Security"
        else
            echo "Detected that current macOS 11 or 12"
            sudo spctl --global-disable
        fi
    elif [[ $(echo "$macos_version 10.15.7" | awk '{print ($1 < $2)}') -eq 1 ]]; then
        # echo "Версия macOS 10.15.7 или меньше"
        echo "Detected that current macOS 10.15.7 or older"
        sudo spctl --master-disable
    else
        echo "Couldn't determine the macOS version"
        return 1
    fi

    echo "Now Gatekeeper status is"
    spctl --status
}



# Функция для запуска установки XCode CommandLine Tools
# Аргументы: -
# Возвращает: -
function clt_install() {
    # 1. Создаем временный файл-индикатор, чтобы заставить систему увидеть обновление CLT
    touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress

    # 2. Находим имя актуального пакета обновлений Command Line Tools в репозиториях Apple
    PROD=$(softwareupdate -l | grep "\*.*Command Line" | tail -n 1 | awk -F"*" '{print $2}' | sed -e 's/^ *//' | tr -d '\n')

    # 3. Запускаем установку конкретного пакета
    # Флаг -i устанавливает, -a подтверждает согласие (в новых версиях может не требоваться, но лишним не будет)
    sudo softwareupdate -i "$PROD" --verbose

    # 4. Удаляем временный файл
    rm /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
}



# Функция для базовой настройки Finder
# Аргументы: -
# Возвращает: -
function finder_setup_base() {
    # --- 1. Основные ---

    # Показывать жесткие диски на рабочем столе
    echo "Show hard drives on the desktop"
    defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
    defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true
    defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true

    # Скрыть подключенные серверы на рабочем столе
    echo "Hide connected servers on the desktop"
    defaults write com.apple.finder ShowMountedServersOnDesktop -bool false

    # Новое окно Finder открывает папку пользователя (путь к Home)
    # PfHm - это код домашней папки в настройках Apple
    echo "A new Finder window opens the user's folder"
    defaults write com.apple.finder NewWindowTarget -string "PfHm"
    defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

    # Открывать папки в новых окнах, а не во вкладках
    echo "Open folders in new windows, not in tabs"
    defaults write com.apple.finder FinderSpawnInNewWindow -bool true
    defaults write com.apple.finder FinderSpawnTab -bool false


    # --- 2. Боковое меню (Sidebar) ---

    # Скрыть "Недавние" из бокового меню
    echo 'Hide "Recent" from the side menu'
    defaults write com.apple.finder ShowRecentPromotedPlaces -bool false

    # Скрыть "Теги" в боковом меню
    echo 'Hide "Tags" in the side menu'
    defaults write com.apple.finder ShowRecentTags -bool false
    defaults write com.apple.finder SidebarTagsSctionDisclosedState -bool false

    # Скрыть "iCloud" в боковом меню
    echo 'Hide "iCloud" in the side menu'
    defaults write com.apple.finder SidebarShowingiCloudDesktop -bool true

    # --- 3. Дополнения ---

    # Показывать все расширения файлов
    echo "Show all file extensions"
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true

    # Показывать скрытые папки и файлы
    echo "Show all hidden files and folders"
    defaults write com.apple.finder AppleShowAllFiles -bool true

    # Отключить предупреждение при смене расширений
    echo "Disable file extension change warning"
    defaults write com.apple.finder FXEnableExtensionsChangeWarning -bool false

    # Позволить закрыть Finder по Command + Q
    echo "Allow quitting finder via ⌘ + Q."
    defaults write com.apple.finder QuitMenuItem -bool true

    # Отображать папки вверху (В окнах и на рабочем столе)
    echo "Not display folders at the top"
    defaults write com.apple.finder _FXSortFoldersFirst -bool false
    defaults write com.apple.finder _FXSortFoldersFirstOnDesktop -bool false

    # Поиск в текущей папке (по умолчанию SCcf)
    echo "Search in the current folder"
    defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"


    # --- 4. Панель инструментов (Toolbar) ---

    # Включаем строку пути и строку состояния для удобства (бонус)
    echo "Enabling the path bar and status bar"
    defaults write com.apple.finder ShowPathbar -bool true
    defaults write com.apple.finder ShowStatusBar -bool true

    restart_finder
}




# Функция для настройки установки общего вида всех папок в Finder
# Аргументы: -
# Возвращает: -
function finder_setup_view() {
    # Удалить везде файл .DS_Store кроме примонтированных разделов (и подключенных накопителей)
    echo "Removing file .DS_Store in current macOS without other disks"
    sudo find -x / -name ".DS_Store" -type f -depth -exec rm -f {} \;

    # Запретить создание .DS_Store на сетевых дисках
    echo "Enabling the setting: Prohibit creation file .DS_Store on network drives"
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool TRUE

    # Запретить создание на USB дисках
    echo "Enabling the setting: Prohibit creation file .DS_Store on USB disks"
    defaults write com.apple.desktopservices DSDontWriteUSBStores -bool TRUE

    # Выставить предпочитаемый вид как список
    echo "Set preferred view as a list"
    defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

    # Показать столбец "Дата добавления"
    echo 'Show the "Date added" column'
    defaults write com.apple.finder FXArrangeByViewOptions -dict "listviewOptions" -dict "showDateAdded" -bool true

    restart_finder
}



# Функция для настройки Dock
# Аргументы: -
# Возвращает: -
function dock_setup_view() {
    # 1. Полная очистка списка приложений в Dock
    echo "Reset Dock"
    defaults write com.apple.dock persistent-apps -array

    # 2. Функция для добавления приложения в Dock
    add_to_dock() {
        local app_path="$1"
        local app_name=$(basename "$app_path" .app)
        
        if [ -d "$app_path" ]; then
            # Правильная структура для Dock
            defaults write com.apple.dock persistent-apps -array-add "
<dict>
    <key>tile-data</key>
    <dict>
        <key>file-data</key>
        <dict>
            <key>_CFURLString</key>
            <string>file://$app_path</string>
            <key>_CFURLStringType</key>
            <integer>15</integer>
        </dict>
        <key>file-label</key>
        <string>$app_name</string>
        <key>file-type</key>
        <integer>41</integer>
    </dict>
    <key>tile-type</key>
    <string>file-tile</string>
</dict>"
            echo "✓ Added to Dock: $app_name"
        else
            echo "✗ App not found: $app_path"
            return 1
        fi
    }

    # 3. Добавление ваших приложений
    echo "Adding apps to Dock"
    add_to_dock "/System/Applications/Launchpad.app"
    add_to_dock "/System/Applications/System Settings.app" # Для macOS Ventura и новее
    add_to_dock "/Applications/System Preferences.app"    # Для El Capitan и старых систем
    add_to_dock "/Applications/Safari.app"
    add_to_dock "/System/Applications/Utilities/Terminal.app" # Путь в новых ОС
    add_to_dock "/Applications/Utilities/Terminal.app"        # Путь в старых ОС

    # 4. Перезапуск Dock для применения изменений
    killall Dock
    restart_finder
}




# Функция для включения возможности использовать Touch ID при выполнении sudo в Терминале
# Аргументы: -
# Возвращает: -
function use_touchid_on_sudo() {
    # Prevent ask write password on second display
    # https://apple.stackexchange.com/questions/259093/can-touch-id-on-mac-authenticate-sudo-in-terminal/306324#comment694328_466029
    defaults write com.apple.security.authorization ignoreArd -bool TRUE

    if [[ $(echo "$macos_version 14" | awk '{print ($1 > $2)}') -eq 1 ]]; then
        # echo "Версия macOS больше или равна 14"
        echo "Detected that current macOS 14 or newer"

        # https://github.com/rtrouton/rtrouton_scripts/blob/main/rtrouton_scripts/enable_and_disable_touch_id_for_sudo/enable_touch_id_auth_for_sudo.sh
        local touch_id_template_file="/etc/pam.d/sudo_local.template"
        local touch_id_auth_file="/etc/pam.d/sudo_local"

        if [ -f "$touch_id_auth_file" ]; then
            if grep -q "#auth       sufficient     pam_tid.so" "$touch_id_auth_file" ; then
                sudo sed -i '' -e 's,#auth       sufficient     pam_tid.so,auth       sufficient     pam_tid.so,g' "$touch_id_auth_file"
            else
                sudo mv "$touch_id_auth_file" "${touch_id_auth_file}.bak"
                sudo cp "$touch_id_template_file" "$touch_id_auth_file"
                sudo sed -i '' -e 's,#auth       sufficient     pam_tid.so,auth       sufficient     pam_tid.so,g' "$touch_id_auth_file"
            fi
        else
            sudo cp "$touch_id_template_file" "$touch_id_auth_file"
            sudo sed -i '' -e 's,#auth       sufficient     pam_tid.so,auth       sufficient     pam_tid.so,g' "$touch_id_auth_file"
        fi
    elif [[ $(echo "$macos_version 13.7.9" | awk '{print ($1 < $2)}') -eq 1 ]]; then
        # echo "Версия macOS 13.7.9 или меньше"
        echo "Detected that current macOS 13.7.9 or older"

        if ! grep -q "pam_tid.so" "/etc/pam.d/sudo"; then
            sudo su root -c 'chmod +w /etc/pam.d/sudo && echo "auth       sufficient     pam_tid.so\n$(cat /etc/pam.d/sudo)" > /etc/pam.d/sudo && chmod -w /etc/pam.d/sudo'
        fi
    else
        echo "Couldn't determine the macOS version"
        return 1
    fi
}



# Функция для создания файла .zshrc с заготовленным содержимым
# или добавления этого содержимого в существующий файл
# Аргументы: -
# Возвращает: -
function setup_zshrc() {
    local ZSHRC_PATH="$HOME/.zshrc"

    # Содержимое, которое нужно добавить
    # Используем переменную, чтобы сохранить форматирование
    local ZSHRC_NEW_CONTENT="
zstyle ':completion:*' menu select

source \$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh


autoload -Uz compinit promptinit
compinit
promptinit

#
# SETOPT
#

# do not store duplications
setopt HIST_IGNORE_DUPS
# removes blank lines from history
setopt HIST_REDUCE_BLANKS

setopt CORRECT
setopt CORRECT_ALL

#
# ALIASES
#

alias ll='ls -al'
alias cds='codesign --force --deep --sign -'

"

    if [ ! -f "$ZSHRC_PATH" ]; then
        echo "$ZSHRC_NEW_CONTENT" > "$ZSHRC_PATH"
    else
        echo ".zshrc already exist and new info will be added to it"

        echo "" >> "$ZSHRC_PATH"
        echo "# ===== Added using auto setup script =====" >> "$ZSHRC_PATH"
        echo "" >> "$ZSHRC_PATH"
        echo "$ZSHRC_NEW_CONTENT" >> "$ZSHRC_PATH"
    fi
}



# Функция для установки пакетного менеджера homebrew
# или его обновления, если он существует
# Аргументы: -
# Возвращает: -
function setup_homebrew() {
    # Проверяем наличие Homebrew
    if command -v brew &> /dev/null; then
        echo "Homebrew exist. Updating it..."
        
        # Обновляем Homebrew
        brew update
        brew upgrade
        
        # Очищаем кэш
        brew cleanup
    else
        # Проверяем Command Line Tools
        if ! xcode-select -p &> /dev/null; then
            clt_install
            # Ждем установки
            sleep 10
        fi
        
        # Устанавливаем Homebrew
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Добавляем в PATH для Apple Silicon
        if [[ $(uname -m) == "arm64" ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            # Для Intel
            if ! grep -q "eval \"\$($BREW_PREFIX/bin/brew shellenv)\"" ~/.bash_profile 2>/dev/null; then
                echo 'eval "$('"$BREW_PREFIX"'/bin/brew shellenv)"' >> ~/.bash_profile
                eval "$($BREW_PREFIX/bin/brew shellenv)"
            fi
        fi
        
        echo "Homebrew installed"
    fi
    
    echo "Adding packages for ZSH"
    brew install git
    brew install zsh-autosuggestions
    brew install zsh-syntax-highlighting
}



# Функция для установки настроек, которые не подпадают под единую категорию
# или его обновления, если он существует
# Аргументы: -
# Возвращает: -
function setup_other() {
    # --- 1. Обновление ПО: Отключить автообновление ---
    # Отключаем автоматическую проверку, загрузку и установку
    echo "Disabling automatic verification, download, and installation..."

    sudo softwareupdate --schedule off
    sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled -bool false
    sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticDownload -bool false
    sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate CriticalUpdateInstall -bool false
    sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate ConfigDataInstall -bool false
    sudo defaults write /Library/Preferences/com.apple.commerce AutoUpdate -bool false
    sudo defaults write /Library/Preferences/com.apple.commerce AutoUpdateRestartRequired -bool false
    defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticDownload -bool false
    defaults write /Library/Preferences/com.apple.SoftwareUpdate CriticalUpdateInstall -bool false
    defaults write /Library/Preferences/com.apple.SoftwareUpdate ConfigDataInstall -bool false
    defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled -bool false



    # --- 2. Мышь: Инверсия прокрутки (Natural Scrolling) ---
    # false — выключает "естественную" прокрутку (делает как в Windows)
    echo "Setting up the mouse scroll inversion..."
    defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false
    # defaults write -g com.apple.swipescrolldirection -bool false

    # Для трекпада тоже отключаем (если есть)
    defaults write com.apple.AppleMultitouchTrackpad TrackpadScroll -bool false
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadScroll -bool false


    # --- 3. Экономия энергии (pmset) ---
    echo "Setting up energy savings..."

    sudo pmset powernap 0

    if ! does_it_have_battery; then
        echo "... for laptop"
        sudo pmset -a lidwake 1 # включает автоматическое пробуждение при открытии крышки ноутбука
    else
        echo "... for desktop"
        # Флаг -a применяет настройки ко всем режимам (аккумулятор и сеть)
        # 3.1. Не переводить Mac в режим сна при выключенном дисплее
        sudo pmset -a sleep 0
        sudo pmset -a displaysleep 0
        # 3.2 Не переводить диски в режим сна (disksleep)
        sudo pmset -a disksleep 0

        # Дополнительные настройки
        sudo pmset -a hibernatemode 0 # отключает безопасный спящий режим (safe sleep)
        sudo pmset -a ttyskeepawake 1 # система не будет засыпать при активных SSH/telnet сессиях
        sudo pmset -a acwake 0 # отключает пробуждение при подключении к зарядке/сети
        sudo pmset -a womp 0 # отключает пробуждение по сети (Wake-on-LAN)
        sudo pmset -a standby 0 # отключает автоматический переход в standby режим (в глубокий сон)
        sudo pmset -a proximitywake 0 # отключает пробуждение от близлежащих Apple устройств
        sudo pmset -a tcpkeepalive 0 # отключает поддержку сетевых соединений в режиме сна
    fi


    # --- 4. Заставка: Показывать с часами ---
    # Показывать заставку с часами
    echo "Show a screen saver with a clock..."
    defaults write com.apple.screensaver showClock -bool true

    # Устанавливаем время запуска заставки (в секундах)
    defaults -currentHost write com.apple.screensaver idleTime -int 1200

    # Убираем прозрачность (для производительности)
    # defaults write com.apple.universalaccess reduceTransparency -bool true




    # --- 5. Клавиатура: Источники ввода (Русская - ПК) ---

    local MAC_MODEL=$(sysctl -n hw.model)

    if [[ $MAC_MODEL != *"MacBook"* ]]; then
        # Сначала получим текущие раскладки
        current_layouts=$(defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleEnabledInputSources 2>/dev/null || echo "")

        # Удаляем старую русскую раскладку если есть
        if [[ -n "$current_layouts" ]]; then
            # Это сложная операция, лучше сделать через PlistBuddy
            /usr/libexec/PlistBuddy -c "Delete :AppleEnabledInputSources" ~/Library/Preferences/com.apple.HIToolbox.plist 2>/dev/null || true
        fi

        # Создаем массив с раскладками
        cat > /tmp/keyboard_layouts.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<array>
    <dict>
        <key>InputSourceKind</key>
        <string>Keyboard Layout</string>
        <key>KeyboardLayout ID</key>
        <integer>0</integer>
        <key>KeyboardLayout Name</key>
        <string>U.S.</string>
    </dict>
    <dict>
        <key>InputSourceKind</key>
        <string>Keyboard Layout</string>
        <key>KeyboardLayout ID</key>
        <integer>-23691</integer>
        <key>KeyboardLayout Name</key>
        <string>Russian</string>
    </dict>
    <dict>
        <key>InputSourceKind</key>
        <string>Keyboard Layout</string>
        <key>KeyboardLayout ID</key>
        <integer>-23695</integer>
        <key>KeyboardLayout Name</key>
        <string>Russian - PC</string>
    </dict>
</array>
</plist>
EOF

        # Устанавливаем раскладки
        defaults write ~/Library/Preferences/com.apple.HIToolbox AppleEnabledInputSources -array \
            '{ InputSourceKind = "Keyboard Layout"; "KeyboardLayout ID" = 0; "KeyboardLayout Name" = "U.S."; }' \
            '{ InputSourceKind = "Keyboard Layout"; "KeyboardLayout ID" = -23695; "KeyboardLayout Name" = "Russian - PC"; }'

        # Устанавливаем русскую - PC как активную
        defaults write ~/Library/Preferences/com.apple.HIToolbox AppleCurrentKeyboardLayoutInputSourceID -string "com.apple.keylayout.RussianWin"
        defaults write ~/Library/Preferences/com.apple.HIToolbox AppleSelectedInputSources -array \
            '{ InputSourceKind = "Keyboard Layout"; "KeyboardLayout ID" = -23695; "KeyboardLayout Name" = "Russian - PC"; }'

        # by Gemini

        # Это сложная настройка. Мы прописываем идентификатор раскладки "Russian-PC" (ID 19452)
        # Внимание: для вступления в силу может потребоваться Log Out
        defaults write com.apple.HIToolbox AppleEnabledInputSources -array-add '<dict><key>InputSourceKind</key><string>Keyboard Layout</string><key>KeyboardLayout ID</key><integer>19452</integer><key>KeyboardLayout Name</key><string>Russian-PC</string></dict>'
    fi




    # --- 6. Клавиатура: Поменять местами Control и Command ---

    echo "Swapping Control and Command..."

    # by Gemini

    # Мы меняем Modifier Keys. 
    # Коды кнопок: 2 = Control, 5 = Command.
    # Настройка применяется к конкретному VendorID/ProductID клавиатуры.
    # Данная команда применяет это глобально для стандартных клавиатур:
    defaults write -g com.apple.keyboard.modifiermapping.1452-630-0 -array-add '<dict><key>HIDKeyboardModifierMappingDst</key><integer>30064771300</integer><key>HIDKeyboardModifierMappingSrc</key><integer>30064771298</integer></dict>'
    defaults write -g com.apple.keyboard.modifiermapping.1452-630-0 -array-add '<dict><key>HIDKeyboardModifierMappingDst</key><integer>30064771298</integer><key>HIDKeyboardModifierMappingSrc</key><integer>30064771300</integer></dict>'

    # by DeepSeek

    defaults write -g com.apple.keyboard.modifiermapping.1452-832-0 -array \
        '<dict><key>HIDKeyboardModifierMappingSrc</key><integer>30064771299</integer><key>HIDKeyboardModifierMappingDst</key><integer>30064771300</integer></dict>' \
        '<dict><key>HIDKeyboardModifierMappingSrc</key><integer>30064771300</integer><key>HIDKeyboardModifierMappingDst</key><integer>30064771299</integer></dict>'
    # Для внешней клавиатуры
    defaults write -g com.apple.keyboard.modifiermapping.1133-14145-0 -array \
        '<dict><key>HIDKeyboardModifierMappingSrc</key><integer>30064771299</integer><key>HIDKeyboardModifierMappingDst</key><integer>30064771300</integer></dict>' \
        '<dict><key>HIDKeyboardModifierMappingSrc</key><integer>30064771300</integer><key>HIDKeyboardModifierMappingDst</key><integer>30064771299</integer></dict>'



    # --- Применение ---

    restart_finder
    killall SystemUIServer 2>/dev/null || true
}





if [ $(id -u) -eq 0 ]; then
    echo "root user detected! Relaunch script under default user"
    exit 1
fi


msg_header "Start install XCode CommandLine Tools"
clt_install

msg_header "Disabling GateKeeper"
gatekeeper_disable

msg_header "Setup base Finder settings"
finder_setup_base

msg_header "Reset folder view settings in all system"
finder_setup_view

msg_header "Setup Dock view"
dock_setup_view

msg_header "Setup using Touch ID on sudo in Terminal"
use_touchid_on_sudo

msg_header "Setup custom .zshrc"
setup_zshrc

msg_header "Setup Homebrew"
setup_homebrew

msg_header "Other setup"
setup_other


echo "All done"
echo "Restart Mac!"
