## .rhiza/make.d/go-test.mk - Testing and benchmarking targets for Go
# This file provides targets for running the test suite with coverage and
# executing performance benchmarks.

# Declare phony targets (they don't produce files)
.PHONY: test test-verbose test-short benchmark test-coverage test-race

# Minimum coverage percent for tests to pass
COVERAGE_THRESHOLD ?= 80

##@ Development and Testing

test: install ## run all tests
	@printf "${BLUE}[INFO] Running tests...${RESET}\n"
	@$(GO_BIN) test ./... -v -cover

test-verbose: install ## run tests with verbose output
	@printf "${BLUE}[INFO] Running tests with verbose output...${RESET}\n"
	@$(GO_BIN) test ./... -v -coverprofile=coverage.out
	@$(GO_BIN) tool cover -html=coverage.out -o coverage.html
	@printf "${BLUE}[INFO] Coverage report generated: coverage.html${RESET}\n"

test-short: install ## run short tests (skip long-running tests)
	@printf "${BLUE}[INFO] Running short tests...${RESET}\n"
	@$(GO_BIN) test ./... -short

test-coverage: install ## run tests with coverage report
	@printf "${BLUE}[INFO] Running tests with coverage...${RESET}\n"
	@$(GO_BIN) test ./... -coverprofile=coverage.out -covermode=atomic
	@$(GO_BIN) tool cover -func=coverage.out
	@$(GO_BIN) tool cover -html=coverage.out -o coverage.html
	@printf "${BLUE}[INFO] Coverage report: coverage.html${RESET}\n"
	@COVERAGE=$$($(GO_BIN) tool cover -func=coverage.out | grep total | awk '{print $$3}' | sed 's/%//'); \
	if [ -n "$$COVERAGE" ]; then \
	  if [ "$$(printf '%s\n' "$$COVERAGE" "$(COVERAGE_THRESHOLD)" | sort -n | head -n1)" = "$(COVERAGE_THRESHOLD)" ]; then \
	    printf "${GREEN}[PASS] Coverage $$COVERAGE%% meets threshold $(COVERAGE_THRESHOLD)%%${RESET}\n"; \
	  else \
	    printf "${RED}[FAIL] Coverage $$COVERAGE%% below threshold $(COVERAGE_THRESHOLD)%%${RESET}\n"; \
	    exit 1; \
	  fi; \
	fi

test-race: install ## run tests with race detector
	@printf "${BLUE}[INFO] Running tests with race detector...${RESET}\n"
	@$(GO_BIN) test ./... -race

benchmark: install ## run performance benchmarks
	@printf "${BLUE}[INFO] Running benchmarks...${RESET}\n"
	@$(GO_BIN) test ./... -bench=. -benchmem -run=^$$ -benchtime=5s
