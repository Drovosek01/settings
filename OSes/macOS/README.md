## macOS

- [macOS](#macos)
  - [Приложения и утилиты для экспорта и импорта настроек:](#приложения-и-утилиты-для-экспорта-и-импорта-настроек)
  - [Полезные статьи и обсуждения на тему переноса настроек macOS:](#полезные-статьи-и-обсуждения-на-тему-переноса-настроек-macos)
  - [Содержание:](#содержание)
  - [ИТОГО](#итого)


В macOS многие настройки сосредоточены в паре мест и они читаемы и копируемы. В основном это файлы в `/Library/Preferences` и в `~/Library/Preferences` и в "реестре" настроек `defaults`. Настройки программ сторонних разработчиков зачастую тоже хранятся в этих директориях но не всегда.


### Приложения и утилиты для экспорта и импорта настроек:

- https://github.com/lra/mackup
- https://github.com/alichtman/shallow-backup
- https://github.com/clintmod/macprefs
- https://github.com/zenangst/Syncalicious
- https://github.com/rgcr/m-cli
- https://github.com/mathiasbynens/dotfiles
  - https://github.com/mathiasbynens/dotfiles/blob/main/.macos
  - https://github.com/pawelgrzybek/dotfiles/blob/master/setup-macos.sh

### Полезные статьи и обсуждения на тему переноса настроек macOS:

- https://pawelgrzybek.com/change-macos-user-preferences-via-command-line/
- https://www.reddit.com/r/MacOS/comments/wnn3ob/is_there_a_way_to_save_system_preferences/
- https://cpojer.net/posts/set-up-a-new-mac-fast
- https://superuser.com/questions/718486/how-can-i-save-common-os-x-settings-to-be-restored-on-a-fresh-install

### Содержание:

1. [Ручная настройка](./Ручная%20настройка.md)
2. [Настройка SHELL'ов](./shells.md)
3. [Автоматизированная настройка](./Автоматизированная%20настройка.md)
4. [Полезные программы](./Полезные%20программы.md)

### ИТОГО

Все, что есть в файле [Ручная настройка](./Ручная%20настройка.md) мне удалось автоматизировать кодом на `Bash 3`. Достаточно выполнить файл [setup_macos.sh](./files/setup_macos.sh) (от имени обычного пользователя, а не из под root, права администратора запросятся сами в ходе выполнения).

После окончания его выполнения - перезапустить компьютер.
Потом можно скачивать и устанавливать [Программы](./Полезные%20программы.md)
