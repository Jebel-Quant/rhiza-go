// Package utils provides utility functions for the rhiza-go application.
package utils

import (
	"path/filepath"
	"strings"
)

// SanitizePath sanitizes a file path by removing dangerous characters
func SanitizePath(path string) string {
	// Clean the path to normalize it
	path = filepath.Clean(path)
	// Remove any remaining .. sequences after cleaning
	path = strings.ReplaceAll(path, "..", "")
	// Clean up any duplicate slashes that may result
	path = filepath.Clean(path)
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
