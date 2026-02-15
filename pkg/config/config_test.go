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

func TestLoadTemplate_PathTraversal(t *testing.T) {
	tests := []struct {
		name    string
		path    string
		wantErr bool
	}{
		{
			name:    "relative path with traversal",
			path:    "../../../etc/passwd",
			wantErr: true,
		},
		{
			name:    "path with traversal to parent",
			path:    "../../secret.txt",
			wantErr: true,
		},
		{
			name:    "path with complex traversal",
			path:    "safe/../../unsafe/file.txt",
			wantErr: true,
		},
		{
			name:    "path starting with traversal",
			path:    "../config.yml",
			wantErr: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			_, err := LoadTemplate(tt.path)
			if (err != nil) != tt.wantErr {
				t.Errorf("LoadTemplate() error = %v, wantErr %v", err, tt.wantErr)
			}
		})
	}
}

func TestLoadTemplate_ValidPaths(t *testing.T) {
	// Create a temporary directory for testing
	tmpDir := t.TempDir()

	// Test cases for valid paths that should not be rejected
	validPaths := []struct {
		name     string
		createAt string // relative path within tmpDir
	}{
		{
			name:     "simple relative path",
			createAt: "config.yml",
		},
		{
			name:     "nested relative path",
			createAt: "templates/config.yml",
		},
		{
			name:     "deeply nested relative path",
			createAt: ".rhiza/templates/config.yml",
		},
	}

	for _, tt := range validPaths {
		t.Run(tt.name, func(t *testing.T) {
			// Create the directory structure
			fullPath := filepath.Join(tmpDir, tt.createAt)
			if err := os.MkdirAll(filepath.Dir(fullPath), 0755); err != nil {
				t.Fatalf("Failed to create directory: %v", err)
			}

			// Create a valid template file
			content := `repository: test/repo
ref: v1.0.0
include:
  - file.txt
`
			if err := os.WriteFile(fullPath, []byte(content), 0644); err != nil {
				t.Fatalf("Failed to write test file: %v", err)
			}

			// Test that the path is accepted (absolute path to temp file)
			tmpl, err := LoadTemplate(fullPath)
			if err != nil {
				t.Errorf("LoadTemplate() failed for valid path %q: %v", tt.createAt, err)
			}
			if tmpl == nil {
				t.Error("Expected non-nil template")
			}
		})
	}
}
