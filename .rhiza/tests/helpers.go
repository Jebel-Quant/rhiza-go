// Package rhizatests provides template validation tests for the rhiza-go project.
//
// These tests validate the template structure, configuration files, bundle definitions,
// Makefile targets, and scripts to ensure the template is well-formed and that
// downstream projects syncing from it will receive a correct set of files.
//
// Run with: make rhiza-test
package rhizatests

import "path/filepath"

// repoRoot caches the repository root path found by findRepoRoot.
var repoRoot = findRepoRoot()

// repoPath returns the absolute path to a file relative to the repository root.
func repoPath(rel string) string {
	return filepath.Join(repoRoot, rel)
}
