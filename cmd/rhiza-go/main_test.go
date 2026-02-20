package main

import (
	"bytes"
	"strings"
	"testing"
)

func TestRun(t *testing.T) {
	var buf bytes.Buffer
	if err := run(&buf); err != nil {
		t.Fatalf("run() returned unexpected error: %v", err)
	}

	output := buf.String()

	wantStrings := []string{
		"Rhiza-Go",
		"Version:",
		"Go Version:",
	}
	for _, want := range wantStrings {
		if !strings.Contains(output, want) {
			t.Errorf("run() output missing %q\ngot:\n%s", want, output)
		}
	}
}

func TestRunOutputFormat(t *testing.T) {
	var buf bytes.Buffer
	if err := run(&buf); err != nil {
		t.Fatalf("run() returned unexpected error: %v", err)
	}

	lines := strings.Split(strings.TrimSpace(buf.String()), "\n")
	if len(lines) < 4 {
		t.Errorf("run() expected at least 4 lines of output, got %d:\n%s", len(lines), buf.String())
	}
}
