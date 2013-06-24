default:
	ln -sFi $(PWD)/vim/vim $(HOME)/.vim
	ln -sFi $(PWD)/vim/vimrc $(HOME)/.vimrc
	ln -sFi $(PWD)/rtorrentrc/rtorrentrc $(HOME)/.rtorrentrc
	ln -sFi $(PWD)/tmux/tmux.conf $(HOME)/.tmux.conf
	ln -sFi $(PWD)/git/gitignore_global $(HOME)/.gitignore_global

git:
	ln -sFi $(PWD)/git/gitignore_global $(HOME)/.gitignore_global
