## Настройка оболочек

`bash` в macOS не обновлялся с 2007 года, а с ~2019 года (или когда вышла macOS 10.15) `zsh` стала стандартной оболочкой в терминале.

Поэтому настраивать `bash` мало смысла, лучше переходить на `zsh`.

### Обязательные действия

1. Установка CommandLineTools
   - В терминале выполнить `xcode-select --install`
   - Или скачать CommandLineTools c https://developer.apple.com/download/all/ сопоставимую с версией XCode с https://xcodereleases.com/
2. Установить [Brew.sh](https://brew.sh/)
   - В терминале выполнить `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
   - Выполнить команды `eval` которые будут в конце установки
3. Обновить Git
   - В терминале выполнить `brew install git`

### Статьи по zsh

- https://dev.to/mbrookson/level-up-your-terminal-2o6p
- https://gist.github.com/n1snt/454b879b8f0b7995740ae04c5fb5b7df
- https://medium.com/@nmpiash/fixing-autocompletion-on-macos-in-zsh-and-jetbrains-terminal-for-git-plus-solving-insecure-bda5d04a7f68
- https://scriptingosx.com/2019/08/moving-to-zsh-part-8-scripting-zsh/


### Что сделать для настройки zsh

В терминале выполнить команды:
```sh
brew install zsh-autosuggestions
brew install zsh-syntax-highlighting
```

По пути `~/.zshrc` создать этот файл, если его там нет и добавить текст из файла `.zshrc` из этого репозитория