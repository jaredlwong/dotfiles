#!/usr/bin/env python

import os
import sys
import shutil
import subprocess

dotfiles = [
    '.gitconfig',
    '.gitignore_global',
    '.tmux.conf',
    '.vim',
    '.vimrc',
    '.xmobarrc',
    '.xmonad',
    '.bin',
    '.matplotlib',
    '.bashrc_interactive',
    ('bashrc_dispatch/bashrc_dispatch', '.bashrc'),
    ('bashrc_dispatch/bashrc_dispatch', '.bash_profile'),
    ('bashrc_dispatch/bashrc_dispatch', '.bash_login'),
]

# http://stackoverflow.com/questions/3041986
# /python-command-line-yes-no-input/3041990#3041990
def query_yes_no(question, default="yes"):
    """Ask a yes/no question via raw_input() and return their answer.

    "question" is a string that is presented to the user.
    "default" is the presumed answer if the user just hits <Enter>.
        It must be "yes" (the default), "no" or None (meaning
        an answer is required of the user).

    The "answer" return value is one of "yes" or "no".
    """
    valid = {"yes":True,   "y":True,  "ye":True,
             "no":False,     "n":False}
    if default == None:
        prompt = " [y/n] "
    elif default == "yes":
        prompt = " [Y/n] "
    elif default == "no":
        prompt = " [y/N] "
    else:
        raise ValueError("invalid default answer: '%s'" % default)

    while True:
        sys.stdout.write(question + prompt)
        choice = raw_input().lower()
        if default is not None and choice == '':
            return valid[default]
        elif choice in valid:
            return valid[choice]
        else:
            sys.stdout.write("Please respond with 'yes' or 'no' "\
                             "(or 'y' or 'n').\n")

def install(df, source_path, dest_path):
    if df == '.vim':
        if not os.path.exists(os.path.join(source_path, 'bundle', 'vundle')):
            subprocess.call(['git', 'submodule', 'init'])
            subprocess.call(['git', 'submodule', 'update'])
            subprocess.call(['vim', '+BundleInstall', '+qall'])
    elif 'bashrc_dispatch' in dest_path:
        if not os.path.exists(dest_path):
            subprocess.call(['git', 'submodule', 'init'])
            subprocess.call(['git', 'submodule', 'update'])
    os.symlink(source_path, dest_path)
    print('Linked %s -> %s' % (dest_path, source_path))

def remove_if_exists(dest_path):
    if not os.path.lexists(dest_path):
        return
    if os.path.islink(dest_path):
        os.unlink(dest_path)
    elif os.path.isfile(dest_path):
        os.remove(dest_path)
    elif os.path.isdir(dest_path):
        shutil.rmtree(dest_path)
    else:
        sys.exit('Unknown file type %s' % dest_path)

if __name__ == '__main__':
    HOME = os.environ['HOME']
    dotfile_path = os.path.dirname(os.path.realpath(__file__))
    if not HOME:
        sys.exit('$HOME must be set')
    overwrite_all = False
    overwrite_all_answered = False
    for df in dotfiles:
        if isinstance(df, tuple):
            source_path = os.path.join(dotfile_path, df[0])
            dest_path = os.path.join(HOME, df[1])
        else:
            source_path = os.path.join(dotfile_path, df)
            dest_path = os.path.join(HOME, df)
        if os.path.lexists(dest_path):
            if not overwrite_all_answered:
                overwrite_all = query_yes_no('%s exists.\n'
                    'Would you like to overwrite all any remaining files which'
                    ' already exist?' % dest_path)
                overwrite_all_answered = True
            if overwrite_all or query_yes_no('Would you like to overwrite %s?' % dest_path):
                remove_if_exists(dest_path)
                install(df, source_path, dest_path)
        else:
            install(df, source_path, dest_path)

