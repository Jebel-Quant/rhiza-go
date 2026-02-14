// Package utils provides utility functions for the rhiza-go application.
//
// This is starter code — replace or extend it with your own utility functions.
package utils

import (
	"path/filepath"
)

// SanitizePath sanitizes a file path by normalizing it
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
