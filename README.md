# Dotfiles
Dotfiles for use when setting up environments in MacOS or Ubuntu.


## Installation
Review files prior to usage.  May have unintended consequences otherwise. **You have been warned!**

When installing using the following commands it will dump the `src` file into whatever directory you're currently in.  Suggestion to place files in `~/projects/dotfiles` however it is not necessary.  Any existing files that overlap will be prompted to move to `~/.backups`

### Using cURL
Using cURL on MacOS

```sh
cd; curl -#L https://github.com/hessmjr/dotfiles/tarball/master |
tar -xz --strip-components 1 --exclude={README.md,.gitignore,LICENSE} && . bootstrap.sh
```

### Using Wget
Using wget on Ubuntu

```sh
cd; wget
```

## License
The MIT License (MIT)

Disclaimer - most of this is compiled from various dotfile repos
