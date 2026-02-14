// Command rhiza-go is a starter application demonstrating the rhiza-go template structure.
//
// This is example code — replace it with your own application logic.
// It shows how to use the standard Go project layout:
//   - cmd/ for application entry points
//   - pkg/ for public library packages
//   - internal/ for private internal packages
package main

import (
	"fmt"
	"os"

	"github.com/jebel-quant/rhiza-go/pkg/config"
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
