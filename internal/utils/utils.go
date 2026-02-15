// Package utils provides utility functions for the rhiza-go application.
//
// This is starter code — replace or extend it with your own utility functions.
package utils

import (
	"path/filepath"
)

// SanitizePath normalizes a file path using filepath.Clean.
//
// Note: This does NOT prevent directory traversal attacks. The function preserves
// relative path components (like ../../../etc/passwd). Callers must validate the
// result is within allowed directories if security is a concern.
//
// For secure path handling, use filepath.Join with a base directory and verify
// the result with filepath.Rel or strings.HasPrefix to ensure it stays within bounds.
func SanitizePath(path string) string {
	// Clean the path to normalize it
	return filepath.Clean(path)
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
