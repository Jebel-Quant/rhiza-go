package rhizatests

import (
	"os"
	"os/exec"
	"strings"
	"testing"
)

// TestMakefileTargetsExist validates that key Makefile targets are defined.
func TestMakefileTargetsExist(t *testing.T) {
	requiredTargets := []string{
		"install",
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
	cmd.Dir = findRepoRoot()
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
	makefilePath := repoPath("Makefile")
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
