package config

import (
	"os"
	"path/filepath"
	"testing"
)

func TestLoad(t *testing.T) {
	cfg, err := Load()
	if err != nil {
		t.Fatalf("Load() failed: %v", err)
	}

	if cfg.Version == "" {
		t.Error("Version should not be empty")
	}

	if cfg.GoVersion == "" {
		t.Error("GoVersion should not be empty")
	}
}

func TestLoadTemplate(t *testing.T) {
	// Create a temporary template file
	tmpDir := t.TempDir()
	templatePath := filepath.Join(tmpDir, "template.yml")

	content := `repository: Jebel-Quant/rhiza-go
ref: v0.1.0
include:
  - Makefile
  - .golangci.yml
exclude:
  - .rhiza/scripts/custom/*
`

	if err := os.WriteFile(templatePath, []byte(content), 0644); err != nil {
		t.Fatalf("Failed to write test template: %v", err)
	}

	tmpl, err := LoadTemplate(templatePath)
	if err != nil {
		t.Fatalf("LoadTemplate() failed: %v", err)
	}

	if tmpl.Repository != "Jebel-Quant/rhiza-go" {
		t.Errorf("Expected repository 'Jebel-Quant/rhiza-go', got '%s'", tmpl.Repository)
	}

	if tmpl.Ref != "v0.1.0" {
		t.Errorf("Expected ref 'v0.1.0', got '%s'", tmpl.Ref)
	}

	if len(tmpl.Include) != 2 {
		t.Errorf("Expected 2 include patterns, got %d", len(tmpl.Include))
	}

	if len(tmpl.Exclude) != 1 {
		t.Errorf("Expected 1 exclude pattern, got %d", len(tmpl.Exclude))
	}
}
