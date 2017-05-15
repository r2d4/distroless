package main

import (
	"fmt"
	"os"
)

func main() {
	fmt.Println("Args:", os.Args)
	contents := os.Args[1]

	f, err := os.Create(os.Args[2])
	if err != nil {
		panic(err)
	}

	defer f.Close()
	f.Write([]byte(contents))
}
