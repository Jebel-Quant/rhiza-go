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
	"io"
	"os"

	"github.com/jebel-quant/rhiza-go/pkg/config"
)

func main() {
	if err := run(os.Stdout); err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}
}

// run executes the application logic, writing output to w.
func run(w io.Writer) error {
	if _, err := fmt.Fprintln(w, "Rhiza-Go - Template System for Go Projects"); err != nil {
		return err
	}
	if _, err := fmt.Fprintln(w, "============================================="); err != nil {
		return err
	}

	cfg, err := config.Load()
	if err != nil {
		return fmt.Errorf("loading configuration: %w", err)
	}

	if _, err := fmt.Fprintf(w, "Version: %s\n", cfg.Version); err != nil {
		return err
	}
	if _, err := fmt.Fprintf(w, "Go Version: %s\n", cfg.GoVersion); err != nil {
		return err
	}
	return nil
}
