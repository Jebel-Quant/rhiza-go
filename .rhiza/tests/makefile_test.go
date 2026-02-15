package rhizatests

import (
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"testing"
)

// TestMakefileTargetsExist validates that key Makefile targets are defined.
func TestMakefileTargetsExist(t *testing.T) {
	requiredTargets := []string{
		"install",
		"build",
		"test",
		"fmt",
		"lint",
		"clean",
		"help",
		"validate",
		"rhiza-test",
		"sync",
		"bump",
		"release",
		"security",
	}

	// Get all available targets using make -pn
	cmd := exec.Command("make", "-pn")
	cmd.Dir = findRepoRoot(t)
	output, err := cmd.CombinedOutput()
	if err != nil {
		// make -pn can return non-zero but still produce useful output
		if len(output) == 0 {
			t.Fatalf("failed to list make targets: %v", err)
		}
	}

	outputStr := string(output)
	// Parse target lines (lines matching "^targetname:")
	definedTargets := make(map[string]bool)
	for _, line := range strings.Split(outputStr, "\n") {
		line = strings.TrimSpace(line)
		if strings.HasPrefix(line, "#") || line == "" {
			continue
		}
		if idx := strings.Index(line, ":"); idx > 0 {
			target := strings.TrimSpace(line[:idx])
			// Filter out file-based targets (contain / or .)
			if !strings.Contains(target, "/") && !strings.Contains(target, ".") && target != "" {
				definedTargets[target] = true
			}
		}
	}

	for _, target := range requiredTargets {
		t.Run(target, func(t *testing.T) {
			if !definedTargets[target] {
				t.Errorf("required Makefile target %q not found", target)
			}
		})
	}
}

// TestMakefileIncludesRhiza validates that the Makefile includes rhiza.mk.
func TestMakefileIncludesRhiza(t *testing.T) {
	makefilePath := filepath.Join(findRepoRoot(t), "Makefile")
	//nolint:gosec // Reading Makefile is intended
	data, err := os.ReadFile(makefilePath)
	if err != nil {
		t.Fatalf("failed to read Makefile: %v", err)
	}

	content := string(data)
	if !strings.Contains(content, "include .rhiza/rhiza.mk") {
		t.Error("Makefile should include .rhiza/rhiza.mk")
	}
}

// findRepoRoot returns the repository root by walking up from the current
// directory looking for go.mod. If the repository root cannot be determined,
// the test is failed immediately.
func findRepoRoot(t *testing.T) string {
	t.Helper()

	dir, err := os.Getwd()
	if err != nil {
		t.Fatalf("failed to determine repository root: %v", err)
	}

	for {
		if _, err := os.Stat(filepath.Join(dir, "go.mod")); err == nil {
			return dir
		}
		parent := filepath.Dir(dir)
		if parent == dir {
			t.Fatalf("failed to find repository root (no go.mod found)")
		}
		dir = parent
	}
}
