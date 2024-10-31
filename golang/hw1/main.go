package main

import (
	"fmt"
	"io"
	"os"
	"path/filepath"
)

func lastEntityIndex(entries []os.DirEntry, printFiles bool) int {
	length := len(entries)
	if printFiles {
		return length - 1
	}

	for i := length - 1; i >= 0; i-- {
		if entries[i].IsDir() {
			return i
		}
	}
	return 0
}

func formatEntryName(entry os.DirEntry) string {
	entryName := entry.Name()

	if !entry.IsDir() {
		if info, err := entry.Info(); err == nil {
			size := info.Size()
			if size == 0 {
				entryName += " (empty)"
			} else {
				entryName += fmt.Sprintf(" (%db)", size)
			}
		}
	}

	return entryName
}

func dirTreeRecursive(out io.Writer, path string, printFiles bool, tabs string) error {
	entries, err := os.ReadDir(path)
	if err != nil {
		return err
	}

	lastEntityIndex := lastEntityIndex(entries, printFiles)

	for i, entry := range entries {
		isDir := entry.IsDir()
		entryName := formatEntryName(entry)

		isLastEntity := lastEntityIndex == i

		suffix := "├───"
		if isLastEntity {
			suffix = "└───"
		}

		if isDir || printFiles {
			fmt.Fprintln(out, tabs+suffix+entryName)
		}

		if isDir {
			subPath := filepath.Join(path, entryName)
			subTab := tabs + "│\t"
			if isLastEntity {
				subTab = tabs + "\t"
			}
			err := dirTreeRecursive(out, subPath, printFiles, subTab)
			if err != nil {
				return err
			}
		}

	}

	return nil
}

func dirTree(out io.Writer, path string, printFiles bool) error {
	return dirTreeRecursive(out, path, printFiles, "")
}

func main() {
	out := os.Stdout
	if !(len(os.Args) == 2 || len(os.Args) == 3) {
		panic("usage go run main.go . [-f]")
	}
	path := os.Args[1]
	printFiles := len(os.Args) == 3 && os.Args[2] == "-f"

	err := dirTree(out, path, printFiles)
	if err != nil {
		panic(err.Error())
	}
}
