# Dotfiles
Dotfiles for use when setting up environments in MacOS or Ubuntu.


## Installation
Review files prior to usage.  May have unintended consequences otherwise. **You have been warned!**

When installing using the following commands it will dump the `src` directory into whatever directory you're currently in.  It's suggested to place it into `~/projects/dotfiles` however that is not necessary.  Any existing files that overlap will be prompted to move to `~/.backups`

### Using cURL

```sh
cd; curl -#L https://github.com/hessmjr/dotfiles/tarball/master |
tar -xz --strip-components 1 --exclude={README.md,.gitignore,LICENSE} && . bootstrap.sh
```

### Using Wget

```sh
cd; wget -O - https://github.com/hessmjr/dotfiles/tarball/master |
tar -xz --strip-components 1 --exclude={README.md,.gitignore,LICENSE} && . bootstrap.sh
```

## License
The MIT License (MIT)

Disclaimer - most of this is compiled from various dotfile repos
