package rhizatests

import (
	"os"
	"strings"
	"testing"

	"gopkg.in/yaml.v3"
)

// bundleConfig represents the structure of template-bundles.yml.
type bundleConfig struct {
	Version string                   `yaml:"version"`
	Bundles map[string]bundleDetails `yaml:"bundles"`
}

// bundleDetails holds info about a single bundle.
type bundleDetails struct {
	Description string   `yaml:"description"`
	Required    bool     `yaml:"required"`
	Standalone  bool     `yaml:"standalone"`
	Requires    []string `yaml:"requires"`
	Files       []string `yaml:"files"`
}

// loadBundles parses the template-bundles.yml file.
func loadBundles(t *testing.T) *bundleConfig {
	t.Helper()
	bundlePath := repoPath(".rhiza/template-bundles.yml")
	//nolint:gosec // Reading template bundles file is intended
	data, err := os.ReadFile(bundlePath)
	if err != nil {
		t.Fatalf("failed to read template-bundles.yml: %v", err)
	}
	var cfg bundleConfig
	if err := yaml.Unmarshal(data, &cfg); err != nil {
		t.Fatalf("failed to parse template-bundles.yml: %v", err)
	}
	return &cfg
}

// TestTemplateBundlesParses validates that template-bundles.yml is valid YAML.
func TestTemplateBundlesParses(t *testing.T) {
	cfg := loadBundles(t)
	if cfg.Version == "" {
		t.Error("template-bundles.yml should have a version field")
	}
	if len(cfg.Bundles) == 0 {
		t.Error("template-bundles.yml should define at least one bundle")
	}
}

// TestCoreBundleIsRequired validates that the core bundle is marked as required.
func TestCoreBundleIsRequired(t *testing.T) {
	cfg := loadBundles(t)
	core, ok := cfg.Bundles["core"]
	if !ok {
		t.Fatal("core bundle not found in template-bundles.yml")
	}
	if !core.Required {
		t.Error("core bundle should be marked as required")
	}
	if len(core.Files) == 0 {
		t.Error("core bundle should list at least one file")
	}
}

// TestBundleDependenciesExist validates that bundle dependencies reference existing bundles.
func TestBundleDependenciesExist(t *testing.T) {
	cfg := loadBundles(t)
	for name, bundle := range cfg.Bundles {
		for _, dep := range bundle.Requires {
			if _, ok := cfg.Bundles[dep]; !ok {
				t.Errorf("bundle %q requires non-existent bundle %q", name, dep)
			}
		}
	}
}

// TestBundleFilesExist validates that every file listed in template-bundles.yml exists.
func TestBundleFilesExist(t *testing.T) {
	cfg := loadBundles(t)

	// Files/dirs that are known to not exist yet (planned for future phases)
	// These are referenced in bundle definitions but not yet created.
	knownMissing := map[string]string{
		"tests/benchmarks":                       "benchmark directory planned for future",
		".github/workflows/rhiza_benchmarks.yml": "benchmark workflow planned for future",
		".rhiza/make.d/presentation.mk":          "presentation make targets not yet created",
		".github/workflows/rhiza_book.yml":       "book workflow planned for future",
	}

	for bundleName, bundle := range cfg.Bundles {
		for _, filePath := range bundle.Files {
			// Clean the path (remove trailing slashes, etc.)
			filePath = strings.TrimSpace(filePath)
			if filePath == "" {
				continue
			}

			t.Run(bundleName+"/"+filePath, func(t *testing.T) {
				fullPath := repoPath(filePath)
				if _, err := os.Stat(fullPath); os.IsNotExist(err) {
					if reason, known := knownMissing[filePath]; known {
						t.Skipf("known missing (planned): %s - %s", filePath, reason)
					} else {
						t.Errorf("bundle %q references non-existent file: %s", bundleName, filePath)
					}
				}
			})
		}
	}
}

// TestBundleHasDescriptions validates that all bundles have descriptions.
func TestBundleHasDescriptions(t *testing.T) {
	cfg := loadBundles(t)
	for name, bundle := range cfg.Bundles {
		if strings.TrimSpace(bundle.Description) == "" {
			t.Errorf("bundle %q has no description", name)
		}
	}
}

// TestNoDuplicateFilesAcrossBundles checks for files that appear in multiple bundles
// (informational — duplicates are allowed but noteworthy).
func TestNoDuplicateFilesAcrossBundles(t *testing.T) {
	cfg := loadBundles(t)
	fileToBundle := make(map[string][]string)

	for name, bundle := range cfg.Bundles {
		for _, f := range bundle.Files {
			f = strings.TrimSpace(f)
			if f != "" {
				fileToBundle[f] = append(fileToBundle[f], name)
			}
		}
	}

	for f, bundles := range fileToBundle {
		if len(bundles) > 1 {
			t.Logf("note: file %q appears in multiple bundles: %s", f, strings.Join(bundles, ", "))
		}
	}
}
