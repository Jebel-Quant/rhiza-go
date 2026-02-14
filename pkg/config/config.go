// Package config handles loading and managing configuration for the rhiza-go application.
package config

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"gopkg.in/yaml.v3"
)

// Config represents the rhiza-go configuration
type Config struct {
	Version   string `yaml:"version"`
	GoVersion string `yaml:"go_version"`
}

// Load reads configuration from .rhiza/.cfg.toml or returns defaults
func Load() (*Config, error) {
	cfg := &Config{
		Version:   "0.1.0",
		GoVersion: "1.23",
	}

	// Try to read .go-version file
	goVersionPath := filepath.Join(".", ".go-version")
	// #nosec G304 -- Reading version file from project root is safe
	if data, err := os.ReadFile(goVersionPath); err == nil {
		cfg.GoVersion = strings.TrimSpace(string(data))
	}

	return cfg, nil
}

// Template represents a rhiza template configuration
type Template struct {
	Repository string   `yaml:"repository"`
	Ref        string   `yaml:"ref"`
	Include    []string `yaml:"include"`
	Exclude    []string `yaml:"exclude"`
}

// LoadTemplate reads template configuration from .rhiza/template.yml
func LoadTemplate(path string) (*Template, error) {
	// #nosec G304 -- Reading template file from specified path is intended
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, fmt.Errorf("failed to read template file: %w", err)
	}

	var tmpl Template
	if err := yaml.Unmarshal(data, &tmpl); err != nil {
		return nil, fmt.Errorf("failed to parse template YAML: %w", err)
	}

	return &tmpl, nil
}
