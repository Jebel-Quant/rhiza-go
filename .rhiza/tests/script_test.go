package rhizatests

import (
	"os"
	"strings"
	"testing"
)

// TestReleaseScriptExists validates that release.sh exists.
func TestReleaseScriptExists(t *testing.T) {
	path := repoPath(".rhiza/scripts/release.sh")
	if _, err := os.Stat(path); os.IsNotExist(err) {
		t.Fatal("release.sh not found at .rhiza/scripts/release.sh")
	}
}

// TestReleaseScriptIsExecutable validates that release.sh has execute permissions.
func TestReleaseScriptIsExecutable(t *testing.T) {
	path := repoPath(".rhiza/scripts/release.sh")
	info, err := os.Stat(path)
	if err != nil {
		t.Fatalf("failed to stat release.sh: %v", err)
	}

	mode := info.Mode()
	if mode&0o111 == 0 {
		t.Errorf("release.sh is not executable (mode: %o)", mode)
	}
}

// TestReleaseScriptHasShebang validates that release.sh starts with a shebang line.
func TestReleaseScriptHasShebang(t *testing.T) {
	path := repoPath(".rhiza/scripts/release.sh")
	//nolint:gosec // Reading script file is intended
	data, err := os.ReadFile(path)
	if err != nil {
		t.Fatalf("failed to read release.sh: %v", err)
	}

	content := string(data)
	if !strings.HasPrefix(content, "#!/") {
		t.Error("release.sh should start with a shebang line (#!/...)")
	}
}

// TestReleaseScriptReadsVersionFile validates that release.sh references the VERSION file.
func TestReleaseScriptReadsVersionFile(t *testing.T) {
	path := repoPath(".rhiza/scripts/release.sh")
	//nolint:gosec // Reading script file is intended
	data, err := os.ReadFile(path)
	if err != nil {
		t.Fatalf("failed to read release.sh: %v", err)
	}

	content := string(data)
	if !strings.Contains(content, "VERSION") {
		t.Error("release.sh should reference the VERSION file")
	}
}
