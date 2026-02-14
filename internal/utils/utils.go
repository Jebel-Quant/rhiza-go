package utils

import (
	"path/filepath"
	"strings"
)

// SanitizePath sanitizes a file path by removing dangerous characters
func SanitizePath(path string) string {
	// Clean the path to remove path traversal attempts
	path = filepath.Clean(path)
	// Remove any remaining .. sequences
	path = strings.ReplaceAll(path, "..", "")
	return path
}

// Contains checks if a string slice contains a specific string
func Contains(slice []string, item string) bool {
	for _, s := range slice {
		if s == item {
			return true
		}
	}
	return false
}
