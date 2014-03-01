install:
	autoconf install.ac > install.sh

update-vundle:
	vim +BundleInstall +qall
