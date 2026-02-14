package rhizatests

import (
	"os"
	"testing"
)

// TestRequiredFilesExist validates that all expected files exist in the repository.
func TestRequiredFilesExist(t *testing.T) {
	requiredFiles := []struct {
		path        string
		description string
	}{
		{".go-version", "Go version file"},
		{"go.mod", "Go module definition"},
		{"go.sum", "Go module checksums"},
		{".golangci.yml", "GolangCI-Lint configuration"},
		{"Makefile", "Top-level Makefile"},
		{".gitignore", "Git ignore rules"},
		{".editorconfig", "Editor configuration"},
		{".pre-commit-config.yaml", "Pre-commit hooks configuration"},
		{"VERSION", "Project version file"},
		{"README.md", "Project README"},
		{".rhiza/rhiza.mk", "Rhiza core Makefile"},
		{".rhiza/.cfg.toml", "Rhiza configuration"},
		{".rhiza/.env", "Rhiza environment variables"},
		{".rhiza/template-bundles.yml", "Template bundle definitions"},
	}

	for _, f := range requiredFiles {
		t.Run(f.description, func(t *testing.T) {
			if _, err := os.Stat(repoPath(f.path)); os.IsNotExist(err) {
				t.Errorf("required file missing: %s (%s)", f.path, f.description)
			}
		})
	}
}

// TestRequiredDirectoriesExist validates that key directories exist.
func TestRequiredDirectoriesExist(t *testing.T) {
	requiredDirs := []struct {
		path        string
		description string
	}{
		{"cmd", "Application entry points"},
		{"pkg", "Public library packages"},
		{"internal", "Private internal packages"},
		{".rhiza", "Rhiza configuration directory"},
		{".rhiza/make.d", "Makefile includes directory"},
		{".rhiza/scripts", "Scripts directory"},
		{".rhiza/tests", "Template tests directory"},
		{"docs", "Documentation directory"},
	}

	for _, d := range requiredDirs {
		t.Run(d.description, func(t *testing.T) {
			info, err := os.Stat(repoPath(d.path))
			if os.IsNotExist(err) {
				t.Errorf("required directory missing: %s (%s)", d.path, d.description)
			} else if err == nil && !info.IsDir() {
				t.Errorf("expected directory but found file: %s", d.path)
			}
		})
	}
}
