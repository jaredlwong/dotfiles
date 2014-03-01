package main

import (
	"os"
	"fmt"
        "path/filepath"
)

func symlink(src string, dst string) {
	_, err := os.Lstat(dst)
	if err == nil {
		panic(fmt.Sprintf("File exists %s. Please remove it.", dst))
	}
	if err.(*os.PathError).Err.Error() != "no such file or directory" {
		panic(fmt.Sprintf("Failed to handle stat of dst %s." +
				" You may need to remove it: %s",
				dst, err))
	}

	_, err = os.Lstat(src)
	if err != nil {
		panic(fmt.Sprintf("Failed to stat src %s. %s", src, err))
	}

	err = os.Symlink(dst, src)
	if err != nil {
		panic(fmt.Sprintf("Failed to symlink %s->%s. %s",
				dst, src, err))
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
}

func main() {
	dp, err := filepath.Abs(filepath.Dir(os.Args[0]))
	if err != nil {
		panic(fmt.Sprintf("Couldn't get abs path of script. %s", err))
	}
	hp := os.Getenv("HOME")
	if hp == "" {
		panic("HOME environment variable is not set")
	}
	install_vim(dp, hp)
}
