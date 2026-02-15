package utils

import "testing"

func TestSanitizePath(t *testing.T) {
	tests := []struct {
		input    string
		expected string
	}{
		{"../../../etc/passwd", "../../../etc/passwd"}, // filepath.Clean preserves relative paths
		{"normal/path", "normal/path"},
		{"path/../to/file", "to/file"}, // filepath.Clean resolves path/..
		{"./test", "test"},
		{"....", "...."},                           // Previously could bypass sanitization, now handled correctly
		{"..../file", "..../file"},                 // Bypass pattern is preserved (not normalized to ..)
		{"multiple///slashes", "multiple/slashes"}, // Duplicate slashes removed
		{".", "."},
	}

	for _, tt := range tests {
		result := SanitizePath(tt.input)
		if result != tt.expected {
			t.Errorf("SanitizePath(%q) = %q, want %q", tt.input, result, tt.expected)
		}
	}
}

func TestContains(t *testing.T) {
	slice := []string{"apple", "banana", "cherry"}

	if !Contains(slice, "banana") {
		t.Error("Expected Contains to return true for 'banana'")
	}

	if Contains(slice, "orange") {
		t.Error("Expected Contains to return false for 'orange'")
	}
}
