package rhizatests

import (
	"os"
	"regexp"
	"strings"
	"testing"
)

// TestGoVersionFileExists validates that .go-version exists and is non-empty.
func TestGoVersionFileExists(t *testing.T) {
	path := repoPath(".go-version")
	//nolint:gosec // Reading version file is intended
	data, err := os.ReadFile(path)
	if err != nil {
		t.Fatalf("failed to read .go-version: %v", err)
	}

	version := strings.TrimSpace(string(data))
	if version == "" {
		t.Fatal(".go-version file is empty")
	}
}

// TestGoVersionIsValid validates that .go-version contains a valid Go version number.
func TestGoVersionIsValid(t *testing.T) {
	path := repoPath(".go-version")
	//nolint:gosec // Reading version file is intended
	data, err := os.ReadFile(path)
	if err != nil {
		t.Fatalf("failed to read .go-version: %v", err)
	}

	version := strings.TrimSpace(string(data))

	// Go version format: major.minor or major.minor.patch
	goVersionPattern := regexp.MustCompile(`^[0-9]+\.[0-9]+(\.[0-9]+)?$`)
	if !goVersionPattern.MatchString(version) {
		t.Errorf(".go-version contains invalid version %q (expected format: X.Y or X.Y.Z)", version)
	}
}

// TestProjectVersionFileExists validates that VERSION file exists and is valid semver.
func TestProjectVersionFileExists(t *testing.T) {
	path := repoPath("VERSION")
	//nolint:gosec // Reading version file is intended
	data, err := os.ReadFile(path)
	if err != nil {
		t.Fatalf("failed to read VERSION: %v", err)
	}

	version := strings.TrimSpace(string(data))
	if version == "" {
		t.Fatal("VERSION file is empty")
	}

	// Semver format: major.minor.patch with optional pre-release
	semverPattern := regexp.MustCompile(`^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.]+)?$`)
	if !semverPattern.MatchString(version) {
		t.Errorf("VERSION contains invalid semver %q (expected format: X.Y.Z)", version)
	}
}

// TestGoModVersionMatchesGoVersion validates that go.mod references the same
// Go version as .go-version (at least the major.minor).
func TestGoModVersionMatchesGoVersion(t *testing.T) {
	// Read .go-version
	goVersionPath := repoPath(".go-version")
	//nolint:gosec // Reading version file is intended
	goVersionData, err := os.ReadFile(goVersionPath)
	if err != nil {
		t.Fatalf("failed to read .go-version: %v", err)
	}
	goVersion := strings.TrimSpace(string(goVersionData))

	// Extract major.minor from .go-version
	parts := strings.SplitN(goVersion, ".", 3)
	if len(parts) < 2 {
		t.Fatalf("invalid .go-version format: %s", goVersion)
	}
	expectedMajorMinor := parts[0] + "." + parts[1]

	// Read go.mod
	goModPath := repoPath("go.mod")
	//nolint:gosec // Reading go.mod is intended
	goModData, err := os.ReadFile(goModPath)
	if err != nil {
		t.Fatalf("failed to read go.mod: %v", err)
	}

	goModContent := string(goModData)
	goDirective := regexp.MustCompile(`(?m)^go\s+([0-9]+\.[0-9]+)`)
	matches := goDirective.FindStringSubmatch(goModContent)
	if len(matches) < 2 {
		t.Fatal("go.mod does not contain a 'go' directive")
	}

	if matches[1] != expectedMajorMinor {
		t.Errorf("go.mod version %q does not match .go-version %q", matches[1], expectedMajorMinor)
	}
}
