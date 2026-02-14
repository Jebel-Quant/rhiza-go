package rhizatests

import (
	"os"
	"testing"

	"gopkg.in/yaml.v3"
)

// TestGolangciYmlParses validates that .golangci.yml is valid YAML.
func TestGolangciYmlParses(t *testing.T) {
	path := repoPath(".golangci.yml")
	//nolint:gosec // Reading linter config is intended
	data, err := os.ReadFile(path)
	if err != nil {
		t.Fatalf("failed to read .golangci.yml: %v", err)
	}

	var config map[string]interface{}
	if err := yaml.Unmarshal(data, &config); err != nil {
		t.Fatalf(".golangci.yml is not valid YAML: %v", err)
	}

	// Validate expected top-level keys
	expectedKeys := []string{"run", "linters", "linters-settings", "issues"}
	for _, key := range expectedKeys {
		if _, ok := config[key]; !ok {
			t.Errorf(".golangci.yml missing expected top-level key: %s", key)
		}
	}
}

// TestGolangciYmlHasLinters validates that linters are configured.
func TestGolangciYmlHasLinters(t *testing.T) {
	path := repoPath(".golangci.yml")
	//nolint:gosec // Reading linter config is intended
	data, err := os.ReadFile(path)
	if err != nil {
		t.Fatalf("failed to read .golangci.yml: %v", err)
	}

	var config struct {
		Linters struct {
			Enable []string `yaml:"enable"`
		} `yaml:"linters"`
	}
	if err := yaml.Unmarshal(data, &config); err != nil {
		t.Fatalf("failed to parse .golangci.yml: %v", err)
	}

	if len(config.Linters.Enable) == 0 {
		t.Error(".golangci.yml should have at least one linter enabled")
	}

	// Verify some essential linters are present
	essentialLinters := []string{"govet", "errcheck", "staticcheck"}
	enabled := make(map[string]bool)
	for _, l := range config.Linters.Enable {
		enabled[l] = true
	}

	for _, l := range essentialLinters {
		t.Run(l, func(t *testing.T) {
			if !enabled[l] {
				t.Errorf("essential linter %q should be enabled in .golangci.yml", l)
			}
		})
	}
}
