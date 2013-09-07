#!/usr/bin/env bash

DOTFILES_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOTFILES=$(find $DOTFILES_ROOT -maxdepth 2 -mindepth 2 -not -path '*.git*' -not -path '*lib*')

set -e

echo ''

info () {
  printf "  [ \033[00;34m..\033[0m ] $1\n"
}

user () {
  printf "\r  [ \033[0;33m?\033[0m ] $1\n"
}

success () {
  printf "\r\033[2K  [ \033[00;32mOK\033[0m ] $1\n"
}

fail () {
  printf "\r\033[2K  [\033[0;31mFAIL\033[0m] $1\n"
  echo ''
  exit
}

link_files () {
  ln -s $1 $2
  success "linked $1 to $2"
}

install_vim () {
  info 'Installing vundle'
  git submodule init
  git submodule update
  vim +BundleInstall +qall
  info 'Vim plugins installed'
}

install_dotfiles () {
  info 'installing dotfiles'

  overwrite_all=false
  backup_all=false
  skip_all=false

  for source in $DOTFILES; do
    dest="$HOME/.`basename \"$source\"`"

    echo $dest
    if [ -f $dest ] || [ -d $dest ] || [ -h $dest ]
    then

      overwrite=false
      backup=false
      skip=false

      if [ "$overwrite_all" == "false" ] && [ "$backup_all" == "false" ] && [ "$skip_all" == "false" ]
      then
        user "File already exists: $dest, what do you want to do?\n  [s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all?"
        read -n 1 action

        case "$action" in
          o )
            overwrite=true;;
          O )
            overwrite_all=true;;
          b )
            backup=true;;
          B )
            backup_all=true;;
          s )
            skip=true;;
          S )
            skip_all=true;;
          * )
            ;;
        esac
      fi

      if [ "$overwrite" == "true" ] || [ "$overwrite_all" == "true" ]
      then
        rm -rf $dest
        success "removed $dest"
      fi

      if [ "$backup" == "true" ] || [ "$backup_all" == "true" ]
      then
        mv $dest $dest\.backup
        success "moved $dest to $dest.backup"
      fi

      if [ "$skip" == "false" ] && [ "$skip_all" == "false" ]
      then
        link_files $source $dest
        if [[ "$dest" == *.vim ]]
        then
            install_vim
        fi
      else
        success "skipped $source"
      fi

    else
      link_files $source $dest
    fi

  done
}

install_dotfiles


echo ''
echo '  All installed!'

