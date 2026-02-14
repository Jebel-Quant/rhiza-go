package main

import (
	"fmt"
	"os"

	"github.com/Jebel-Quant/rhiza-go/pkg/config"
)

func main() {
	fmt.Println("Rhiza-Go - Template System for Go Projects")
	fmt.Println("=============================================")

	cfg, err := config.Load()
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error loading configuration: %v\n", err)
		os.Exit(1)
	}

	fmt.Printf("Version: %s\n", cfg.Version)
	fmt.Printf("Go Version: %s\n", cfg.GoVersion)
}
