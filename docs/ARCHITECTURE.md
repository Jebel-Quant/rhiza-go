# Rhiza-Go Architecture

Visual diagrams of Rhiza-Go's architecture and component interactions.

## System Overview

```mermaid
flowchart TB
    subgraph User["User Interface"]
        make[make commands]
        local[local.mk]
    end

    subgraph Core[".rhiza/ Core"]
        rhizamk[rhiza.mk<br/>Core Logic]
        maked[make.d/*.mk<br/>Extensions]
        scripts[scripts/<br/>Shell Scripts]
        template[template.yml<br/>Sync Config]
    end

    subgraph Config["Configuration"]
        gomod[go.mod]
        golangci[.golangci.yml]
        precommit[.pre-commit-config.yaml]
        editorconfig[.editorconfig]
    end

    subgraph CI["GitHub Actions"]
        ci[CI Workflow]
        release[Release Workflow]
        security[Security Workflow]
        sync[Sync Workflow]
    end

    make --> rhizamk
    local -.-> rhizamk
    rhizamk --> maked
    rhizamk --> scripts
    maked --> gomod
    ci --> make
    release --> make
    security --> make
    sync --> template
```

## Makefile Hierarchy

```mermaid
flowchart TD
    subgraph Entry["Entry Point"]
        Makefile[Makefile<br/>9 lines]
    end

    subgraph Core["Core Logic"]
        rhizamk[.rhiza/rhiza.mk<br/>268 lines]
    end

    subgraph Extensions["Auto-loaded Extensions"]
        config[00-19: Configuration]
        tasks[20-79: Task Definitions]
        hooks[80-99: Hook Implementations]
    end

    subgraph Local["Local Customization"]
        localmk[local.mk<br/>Not synced]
    end

    Makefile -->|includes| rhizamk
    rhizamk -->|includes| config
    rhizamk -->|includes| tasks
    rhizamk -->|includes| hooks
    rhizamk -.->|optional| localmk
```

## Hook System

```mermaid
flowchart LR
    subgraph Hooks["Double-Colon Targets"]
        pre_install[pre-install::]
        post_install[post-install::]
        pre_sync[pre-sync::]
        post_sync[post-sync::]
        pre_release[pre-release::]
        post_release[post-release::]
        pre_bump[pre-bump::]
        post_bump[post-bump::]
    end

    subgraph Targets["Main Targets"]
        install[make install]
        sync[make sync]
        release[make release]
        bump[make bump]
    end

    pre_install --> install --> post_install
    pre_sync --> sync --> post_sync
    pre_release --> release --> post_release
    pre_bump --> bump --> post_bump
```

## Release Pipeline

```mermaid
flowchart TD
    tag[Push Tag v*] --> validate[Validate Tag]
    validate --> build[Build Go Binaries]
    build --> draft[Draft GitHub Release]
    draft --> upload[Upload Binaries + SBOM]
    draft --> devcontainer[Publish Devcontainer]
    upload --> finalize[Finalize Release]
    devcontainer --> finalize

    subgraph Conditions
        dev_cond{PUBLISH_DEVCONTAINER<br/>= true?}
    end

    draft --> dev_cond
    dev_cond -->|yes| devcontainer
    dev_cond -->|no| finalize
```

## Template Sync Flow

```mermaid
flowchart LR
    upstream[Upstream Rhiza-Go<br/>jebel-quant/rhiza-go] -->|template.yml| sync[make sync]
    sync -->|updates| downstream[Downstream Project]

    subgraph Synced["Synced Files"]
        workflows[.github/workflows/]
        rhiza[.rhiza/]
        configs[Config Files]
    end

    subgraph Preserved["Preserved"]
        localmk[local.mk]
        cmd[cmd/]
        pkg[pkg/]
        internal[internal/]
    end

    sync --> Synced
    downstream --> Preserved
```

## Directory Structure

```mermaid
flowchart TD
    root[Project Root]

    root --> rhiza[.rhiza/]
    root --> github[.github/]
    root --> cmd[cmd/]
    root --> pkg[pkg/]
    root --> internal[internal/]
    root --> docs[docs/]

    rhiza --> rhizamk[rhiza.mk]
    rhiza --> maked[make.d/]
    rhiza --> scripts[scripts/]
    rhiza --> template[template.yml]

    github --> workflows[workflows/]
    workflows --> ci[rhiza_ci.yml]
    workflows --> release[rhiza_release.yml]
    workflows --> codeql[rhiza_codeql.yml]
    workflows --> more[... more]

    maked --> m00[00-19: Config]
    maked --> m20[20-79: Tasks]
    maked --> m80[80-99: Hooks]
```

## CI/CD Workflow Triggers

```mermaid
flowchart TD
    subgraph Triggers
        push[Push]
        pr[Pull Request]
        schedule[Schedule]
        manual[Manual]
        tag[Tag v*]
    end

    subgraph Workflows
        ci[CI]
        codeql[CodeQL]
        release[Release]
        precommit[Pre-commit]
    end

    push --> ci
    push --> codeql
    pr --> ci
    pr --> precommit
    schedule --> codeql
    manual --> ci
    tag --> release
```

## Go Execution Model

```mermaid
flowchart LR
    subgraph Commands
        make[make test]
        direct[go test]
    end

    subgraph Tools
        gotest[go test ./...]
        golint[golangci-lint]
        gofmt[goimports]
        govet[go vet]
    end

    make --> gotest
    make --> golint
    make --> gofmt
    make --> govet

    direct --> gotest
```
