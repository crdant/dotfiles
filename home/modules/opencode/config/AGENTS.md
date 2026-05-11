# OpenCode Custom Instructions

## Available Agents

The following specialized agents are available in `~/.config/opencode/agents/`:

- **codebase-analyzer** — Analyzes implementation details, traces data flow, and explains technical workings with precise file:line references.
- **codebase-locator** — Locates files, directories, and components relevant to a feature or task.
- **codebase-pattern-finder** — Finds similar implementations, usage examples, and existing patterns that can be modeled after.
- **docs-analyzer** — Deep analyzer for documentation, ADRs, and session summaries.
- **docs-locator** — Discovers relevant documentation across docs/, adrs/, and sessions/ directories.
- **git-commiter** — Creates thoughtful, atomic git commits with clear messages.
- **pull-request-author** — Creates professional pull request descriptions following team standards.
- **web-search-researcher** — Expert web research specialist for finding accurate, relevant information from web sources.

## MCP Servers

The following MCP servers are configured and available for tool use:

- **fetch** — Web content fetching
- **puppeteer** — Browser automation
- **time** — Time and timezone utilities
- **todoist** — Todoist task management
- **firecrawl** — Web scraping and crawling
- **shortcut** — Shortcut (project management) integration
- **omni** — Omni platform integration
- **github** — GitHub Copilot MCP server
- **mbta** — MBTA transit information
- **google-maps** — Google Maps integration
- **repomix** — Repository packing and analysis

## General Guidelines

- Read files thoroughly before making statements about implementation.
- Trace actual code paths rather than assuming behavior.
- Use file:line references for precision.
- Explain the "why" behind changes, not just the "what".
- When in doubt, search the codebase or documentation agents for context.
