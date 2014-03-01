package main

import (
	"os"
	"fmt"
        "path/filepath"
        "os/exec"
)

func symlink(src string, dst string) {
	_, err := os.Lstat(dst)
	if err == nil {
		panic(fmt.Sprintf("File exists %s. Please remove it.", dst))
	}
	if err.(*os.PathError).Err.Error() != "no such file or directory" {
		panic(fmt.Sprintf(fmt.Sprintf("Failed to handle stat of dst %s." +
				" You may need to remove it: %s",
				dst, err)))
	}

	_, err = os.Lstat(src)
	if err != nil {
		panic(fmt.Sprintf(fmt.Sprintf("Failed to stat src %s. %s", src, err)))
	}

	err = os.Symlink(src, dst)
	if err != nil {
		panic(fmt.Sprintf(fmt.Sprintf("Failed to symlink %s->%s. %s",
				src, dst, err)))
	}
}

// requires dotfile path, home path
func install_vim(dp string, hp string) {
	src1 := filepath.Join(dp, ".vim")
	dst1 := filepath.Join(hp, ".vim")
	symlink(src1, dst1)
	src2 := filepath.Join(dp, ".vimrc")
	dst2 := filepath.Join(hp, ".vimrc")
	symlink(src2, dst2)
        var gitcmd *exec.Cmd

	_, err := os.Lstat(filepath.Join(dp, ".vim", "bundle", "vundle"))
	if err == nil {
		fmt.Printf("Skipping vundle clone because" +
				" .vim/bundle/vundle exists")
		goto vundle_init
	}
	if err.(*os.PathError).Err.Error() != "no such file or directory" {
		panic(fmt.Sprintf("Failed to handle stat of" +
				".vim/bundle/vundle %s.", err))
	}
	gitcmd = exec.Command("git", "clone",
			"https://github.com/gmarik/vundle.git",
			filepath.Join(dp, ".vim/bundle/vundle"))
	err = gitcmd.Run()
	if err != nil {
		panic(fmt.Sprintf("Failed to clone vundle. %s", err))
	}

vundle_init:
	vcmd := exec.Command("vim", "+BundleInstall", "+qall")
	err = vcmd.Run()
	if err != nil {
		panic(fmt.Sprintf("Failed to init vundle. %s", err))
	}
}

func main() {
	hp := os.Getenv("HOME")
	if hp == "" {
		panic("HOME environment variable is not set")
	}
	dp := os.Getenv("DOTFILES")
	if dp == "" {
		panic("DOTFILES environment variable is not set")
	}
	install_vim(dp, hp)
}
