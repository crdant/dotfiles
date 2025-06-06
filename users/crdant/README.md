# Home Manager Profile Configurations

## 1. Minimal Profile (`minimal.nix`)
**Purpose**: Absolute bare minimum setup
**Modules**: 
- `base.nix`

**Use Cases**: 
- Testing configurations
- Extremely constrained environments
- Bootstrap setups

---

## 2. Basic Profile (`basic.nix`) 
**Purpose**: Essential tools with security
**Modules**:
- `base.nix` 
- `security.nix`

**Use Cases**:
- Simple workstations
- Security-conscious minimal setups
- Personal laptops without development needs

---

## 3. Development Profile (`development.nix`)
**Purpose**: Full development environment with AI tools
**Modules**:
- `base.nix`
- `development.nix` 
- `ai.nix`
- `security.nix`
- `darwin.nix` (macOS only)

**Use Cases**:
- Primary development machines
- Coding workstations
- AI-assisted development workflows

---

## 4. AI Profile (`ai.nix`)
**Purpose**: AI-focused development environment
**Modules**:
- `base.nix`
- `development.nix`
- `ai.nix` 
- `security.nix`
- `darwin.nix` (macOS only)

**Use Cases**:
- AI/ML development
- Heavy AI assistant usage
- Research and experimentation

---

## 5. Cloud Profile (`cloud.nix`)
**Purpose**: Cloud engineering and Kubernetes work
**Modules**:
- `base.nix`
- `cloud.nix`
- `kubernetes.nix`
- `security.nix`
- `darwin.nix` (macOS only)

**Use Cases**:
- DevOps engineers
- Cloud architects
- Kubernetes administrators
- Infrastructure work

---

## 6. Server Profile (`server.nix`)
**Purpose**: Headless/server environments
**Modules**:
- `base.nix`
- `security.nix`
- `kubernetes.nix`
- `cloud.nix`

**Use Cases**:
- Remote servers
- CI/CD environments
- Headless workstations
- Container environments

---

## 7. Full Profile (`full.nix`)
**Purpose**: Complete workstation with all capabilities
**Modules**:
- `base.nix`
- `development.nix`
- `ai.nix`
- `kubernetes.nix`
- `security.nix`
- `cloud.nix`
- `homelab.nix`
- `darwin.nix` (macOS only)

**Use Cases**:
- Primary workstations
- All-in-one development machines
- Maximum functionality setups

---

# Module Breakdown

## Core Modules
- **`base.nix`**: Shell, tmux, core Neovim, basic utilities
- **`security.nix`**: GPG, SSH, SOPS, 1Password, certificates
- **`development.nix`**: Git, languages, LSPs, dev tools
- **`ai.nix`**: Aider, Claude, Goose, MCP servers
- **`kubernetes.nix`**: K8s tools, container utilities
- **`cloud.nix`**: AWS, GCP, Azure, Terraform, Vault
- **`homelab.nix`**: Lab-specific SSH configs
- **`darwin.nix`**: macOS-specific apps and configs

## Profile Matrix

| Profile     | Base | Security | Development | AI | Kubernetes | Cloud | Homelab | Darwin |
|-------------|------|----------|-------------|----|-----------  |-------|---------|--------|
| minimal     | ✓    |          |             |    |             |       |         |        |
| basic       | ✓    | ✓        |             |    |             |       |         |        |
| development | ✓    | ✓        | ✓           | ✓  |             |       |         | ✓*     |
| ai          | ✓    | ✓        | ✓           | ✓  |             |       |         | ✓*     |
| cloud       | ✓    | ✓        |             |    | ✓           | ✓     |         | ✓*     |
| server      | ✓    | ✓        |             |    | ✓           | ✓     |         |        |
| full        | ✓    | ✓        | ✓           | ✓  | ✓           | ✓     | ✓       | ✓*     |

*Darwin module only loads on macOS systems