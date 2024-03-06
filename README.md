# Dotfiles
Dotfiles for use when setting up environments in MacOS.

## Installation
Review files prior to usage.  May have unintended consequences otherwise. **You have been warned!**

### Setup Oh-My-Zsh
If desired, setup Oh-My-Zsh first (although not necessary).

setup plugins and make changes to zsh file

```
# ~/.zshrc

# Load Oh-my-zsh
export ZSH=~/.oh-my-zsh
source $ZSH/oh-my-zsh.sh

# Load custom configurations
source ~/.zsh/custom/aliases.zsh
source ~/.zsh/custom/functions.zsh
source ~/.zsh/custom/private.zsh
source ~/.zsh/custom/prompt.zsh

# Additional settings...
```

```
~/.zsh/
├── custom/
│   ├── aliases.zsh
│   ├── functions.zsh
│   ├── private.zsh
│   ├── prompt.zsh
│   ├── oh-my-zsh.zsh  # Your Oh-my-zsh customizations
│   └── ...
├── .zshrc
└── ...
```



When installing using the following commands it will dump the `src` directory into whatever directory you're currently in.  It's suggested to place it into `~/projects/dotfiles` however that is not necessary.  Any existing files that overlap will be prompted to move to `~/.backups`

### Using cURL

```sh
cd; curl -#L https://github.com/hessmjr/dotfiles/tarball/master |
tar -xz --strip-components 1 --exclude={README.md,.gitignore,LICENSE} && . bootstrap.sh
```

### Using Wgetb

```sh
cd; wget -O - https://github.com/hessmjr/dotfiles/tarball/master |
tar -xz --strip-components 1 --exclude={README.md,.gitignore,LICENSE} && . bootstrap.sh
```

## License
The MIT License (MIT)

Disclaimer - most of this is compiled from various dotfile repos
