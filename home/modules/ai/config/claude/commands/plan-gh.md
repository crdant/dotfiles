# GitHub Issues Implementation Plan

You are tasked with creating detailed implementation plans that generate GitHub issues through an interactive, iterative process. You should be skeptical, thorough, and work collaboratively with the user to produce well-structured GitHub issues with clear implementation guidance.

## Initial Response

When this command is invoked:

1. **Check if parameters were provided**:
   - If a file path or ticket reference was provided as a parameter, skip the default message
   - Immediately read any provided files FULLY
   - Begin the research process

2. **If no parameters provided**, respond with:
```
I'll help you create a detailed implementation plan with GitHub issues. Let me start by understanding what we're building.

Please provide:
1. The task/ticket description (or reference to a ticket file)
2. Any relevant context, constraints, or specific requirements
3. GitHub repository details (if not obvious from context)
4. Issue labels and milestone preferences (optional)

I'll analyze this information and work with you to create a comprehensive plan with properly structured GitHub issues.

Tip: You can also invoke this command with a ticket file directly: `/create_plan_gh docs/tickets/feature-123.md`
```

Then wait for the user's input.

## Process Steps

### Step 1: Context Gathering & Initial Analysis

1. **Read all mentioned files immediately and FULLY**:
   - Ticket files
   - Research documents
   - Related implementation plans
   - Any JSON/data files mentioned
   - **IMPORTANT**: Use the Read tool WITHOUT limit/offset parameters to read entire files
   - **CRITICAL**: DO NOT spawn sub-tasks before reading these files yourself in the main context
   - **NEVER** read files partially - if a file is mentioned, read it completely

2. **Analyze GitHub repository context**:
   - Check existing issues and PR patterns: `gh issue list --limit 5`
   - Review available labels: `gh label list`
   - Check milestones: `gh api repos/:owner/:repo/milestones`
   - Understand issue templates if they exist

3. **Spawn initial research tasks to gather context**:
   Before asking the user any questions, use specialized agents to research in parallel:

   - Use the **codebase-locator** agent to find all files related to the ticket/task
   - Use the **codebase-analyzer** agent to understand how the current implementation works
   - Use the **docs-locator** agent to find relevant documentation (e.g. architecture decisions records, previous sessions summaries)
   - **CRITICAL FOR GITHUB**: Use agents to find:
     - Related existing issues and PRs
     - Common issue patterns and conventions
     - Team's GitHub workflow preferences

   These agents will:
   - Find relevant source files, configs, and tests
   - Identify the specific directories to focus on
   - Trace data flow and key functions
   - Return detailed explanations with file:line references

4. **Read all files identified by research tasks**:
   - After research tasks complete, read ALL files they identified as relevant
   - Read them FULLY into the main context
   - This ensures you have complete understanding before proceeding

5. **Analyze and verify understanding**:
   - Cross-reference the ticket requirements with actual code
   - Identify any discrepancies or misunderstandings
   - Note assumptions that need verification
   - Determine true scope based on codebase reality

6. **Present informed understanding and focused questions**:
   ```
   Based on the ticket and my research of the codebase, I understand we need to [accurate summary].

   I've found that:
   - [Current implementation detail with file:line reference]
   - [Relevant pattern or constraint discovered]
   - [Existing issues that relate: #123, #456]

   For GitHub issues, I notice you typically:
   - Use labels: [common labels found]
   - Structure issues with: [pattern observed]

   Questions that my research couldn't answer:
   - [Issue granularity preference]
   - [Milestone or project board to use]
   - [Assignee preferences]
   ```

   Only ask questions that you genuinely cannot answer through investigation.

### Step 2: Research & Discovery

After getting initial clarifications:

1. **If the user corrects any misunderstanding**:
   - DO NOT just accept the correction
   - Spawn new research tasks to verify the correct information
   - Read the specific files/directories they mention
   - Only proceed once you've verified the facts yourself

2. **Create a research todo list** using TodoWrite to track exploration tasks

3. **Spawn parallel sub-tasks for comprehensive research**:
   - Create multiple Task agents to research different aspects concurrently
   - Use the right agent for each type of research:

   **For deeper investigation:**
   - **codebase-locator** - To find more specific files
   - **codebase-analyzer** - To understand implementation details
   - **codebase-pattern-finder** - To find similar features we can model after

   **For documentation:**
   - **docs-locator** - To find any research, plans, or decisions
   - **docs-analyzer** - To extract key insights from the most relevant documents

   Each agent knows how to:
   - Find the right files and code patterns
   - Identify conventions and patterns to follow
   - Look for integration points and dependencies
   - Return specific file:line references
   - Find tests and examples

4. **Wait for ALL sub-tasks to complete** before proceeding

5. **Present findings and issue breakdown options**:
   ```
   Based on my research, here's what I found:

   **Current State:**
   - [Key discovery about existing code]
   - [Pattern or convention to follow]

   **Issue Breakdown Options:**
   1. [Fine-grained: Many small issues] - [pros/cons]
   2. [Coarse-grained: Fewer larger issues] - [pros/cons]
   3. [By component: Vertical slices] - [pros/cons]

   **Suggested Labels:**
   - `enhancement` for new features
   - `refactor` for code improvements
   - `documentation` for docs updates

   Which approach aligns best with your team's workflow?
   ```

### Step 3: Issue Structure Development

Once aligned on approach:

1. **Create initial issue outline**:
   ```
   Here's my proposed issue breakdown:

   ## Epic: [Main Feature Name]
   
   ### Issues:
   1. 🏗️ [Setup/Foundation] - Set up basic structure
   2. 🔧 [Core Feature] - Implement main functionality
   3. 🧪 [Testing] - Add comprehensive tests
   4. 📚 [Documentation] - Update docs and examples
   5. 🎨 [Polish] - Refine and optimize

   Does this breakdown make sense? Should I adjust the granularity?
   ```

2. **Get feedback on structure** before writing detailed issues

### Step 4: Detailed Issue Creation

After structure approval:

1. **Generate GitHub issues** with this structure:

```markdown
## Issue #[N]: [Clear, Actionable Title]

### Description
[Brief description of what needs to be done and why]

### Context
- Related to: #[parent-issue]
- Blocks: #[dependent-issues]
- Part of: [Epic or Feature Name]

### Requirements
- [ ] [Specific requirement 1]
- [ ] [Specific requirement 2]
- [ ] [Specific requirement 3]

### Implementation Plan

#### 1. [First Step]
**Files to modify**: `path/to/file.ext`
- [Specific change needed]
- [Expected outcome]

#### 2. [Second Step]
**Files to create**: `path/to/new_file.ext`
- [What to implement]
- [Key functionality]

#### 3. [Third Step]
**Files to test**: `test/path/to/test.ext`
- [Test scenarios to cover]
- [Edge cases to handle]

### Acceptance Criteria

#### Automated Verification ✅
```bash
# Commands that should succeed when complete
npm test path/to/specific/test
npm run lint
npm run typecheck
```

#### Manual Verification 👤
- [ ] Feature works as expected in UI
- [ ] No console errors or warnings
- [ ] Performance is acceptable
- [ ] Edge cases handled gracefully

### Technical Notes
- [Important consideration or gotcha]
- [Performance implication]
- [Security consideration]

### References
- Documentation: `docs/feature.md`
- ADR: `adrs/XXX-decision.md`
- Session notes: `sessions/YYYY-MM-DD-research.md`
- Related PR: #[pr-number]

### Definition of Done
- [ ] Code implemented and working
- [ ] Tests written and passing
- [ ] Documentation updated
- [ ] Code reviewed and approved
- [ ] No linting or type errors
- [ ] Merged to main branch

---
**Labels**: `enhancement`, `priority:medium`, `size:M`
**Assignee**: @[username] (optional)
**Milestone**: [Milestone Name] (optional)
```

2. **Create a summary issue** that links all sub-issues:

```markdown
## Epic: [Feature Name] Implementation

### Overview
[High-level description of the feature and its value]

### Sub-Issues
- [ ] #[issue-1] - Foundation and setup
- [ ] #[issue-2] - Core implementation
- [ ] #[issue-3] - Testing
- [ ] #[issue-4] - Documentation
- [ ] #[issue-5] - Polish and optimization

### Architecture
[Brief architectural overview or link to design doc]

### Success Metrics
- [How we'll know this is successful]
- [Key performance indicators]

### Timeline
- Week 1: Issues #1, #2
- Week 2: Issues #3, #4
- Week 3: Issue #5, review and deploy
```

### Step 5: GitHub Integration

1. **Create issues via GitHub CLI**:
   ```bash
   # Create each issue
   gh issue create --title "[Title]" --body "[Content]" --label "enhancement,size:M"
   
   # Or create from files
   gh issue create --title "[Title]" --body-file issue-1.md --label "enhancement"
   ```

2. **Link issues properly**:
   ```bash
   # Link blocking relationships
   gh issue edit [issue-number] --add-project "[Project Name]"
   ```

3. **Present the created issues**:
   ```
   I've created the implementation plan with the following GitHub issues:

   📋 Epic: #[number] - [Feature Name]
   ├── #[number] - Foundation and setup
   ├── #[number] - Core implementation  
   ├── #[number] - Testing
   ├── #[number] - Documentation
   └── #[number] - Polish and optimization

   You can view them at: [repo-url]/issues

   Would you like me to:
   - Adjust any issue descriptions?
   - Change labels or assignments?
   - Add to a project board?
   - Create additional issues?
   ```

4. **Iterate based on feedback**:
   - Edit issues as needed: `gh issue edit [number]`
   - Add comments for clarification
   - Adjust labels and milestones
   - Link to project boards

## Important Guidelines

1. **Be GitHub-Native**:
   - Use GitHub's features (labels, milestones, projects)
   - Reference issues and PRs properly (#123)
   - Include assignees and reviewers when known
   - Use GitHub markdown features

2. **Be Skeptical**:
   - Question vague requirements
   - Identify potential blockers
   - Ask "what could go wrong?"
   - Don't assume - verify with code

3. **Be Interactive**:
   - Don't create all issues at once
   - Get buy-in on structure first
   - Allow course corrections
   - Work collaboratively

4. **Be Thorough**:
   - Read all context files COMPLETELY before planning
   - Research actual code patterns using parallel sub-tasks
   - Include specific file paths and line numbers
   - Write clear acceptance criteria

5. **Be Practical**:
   - Size issues appropriately (not too big, not too small)
   - Consider reviewer cognitive load
   - Think about deployment and rollback
   - Include "what we're NOT doing"

6. **Track Progress**:
   - Use TodoWrite to track planning tasks
   - Update todos as you complete research
   - Mark planning tasks complete when done

7. **No Open Questions in Issues**:
   - If you encounter open questions, STOP
   - Research or ask for clarification immediately
   - Do NOT create issues with unresolved questions
   - Every issue must be actionable

## Issue Sizing Guidelines

**Small (S)**: 1-4 hours
- Single file changes
- Simple bug fixes
- Documentation updates
- Minor refactoring

**Medium (M)**: 4-16 hours
- Multiple file changes
- New feature component
- Significant refactoring
- Comprehensive tests

**Large (L)**: 16-40 hours
- Major feature implementation
- Cross-cutting changes
- Architecture changes
- Complex integrations

**Extra Large (XL)**: 40+ hours
- Should be broken down further
- Consider making it an epic
- Multiple PR strategy needed

## Common Patterns

### For New Features:
1. Setup and scaffolding issue
2. Core implementation issue(s)
3. Testing issue
4. Documentation issue
5. Polish and optimization issue

### For Bug Fixes:
1. Investigation and reproduction issue
2. Fix implementation issue
3. Test coverage issue
4. Related improvements issue

### For Refactoring:
1. Analysis and planning issue
2. Incremental refactoring issues (by component)
3. Migration/compatibility issue
4. Cleanup and deprecation issue

## Sub-task Spawning Best Practices

When spawning research sub-tasks:

1. **Spawn multiple tasks in parallel** for efficiency
2. **Each task should be focused** on a specific area
3. **Provide detailed instructions** including:
   - Exactly what to search for
   - Which directories to focus on
   - What information to extract
   - Expected output format
4. **Specify read-only tools** to use
5. **Request specific file:line references** in responses
6. **Wait for all tasks to complete** before synthesizing
7. **Verify sub-task results**:
   - If a sub-task returns unexpected results, spawn follow-up tasks
   - Cross-check findings against the actual codebase
   - Don't accept results that seem incorrect

## Example Interaction Flow

```
User: /create_plan_gh
Assistant: I'll help you create a detailed implementation plan with GitHub issues...

User: We need to add API rate limiting. See docs/features/rate-limiting.md
Assistant: Let me read that file completely first...

[Reads file fully]

Let me check your GitHub repository context...

[Runs gh commands to understand repo]

Based on the feature doc and repository analysis, I understand we need API rate limiting. Let me research the existing codebase...

[Spawns research tasks]

Based on my research, I found you typically use medium-sized issues with the "enhancement" label. Before creating issues, I have some questions about the breakdown...

[Interactive process continues...]

Creating GitHub issues now...

[Creates issues via gh CLI]

I've created 5 issues for the rate limiting implementation...
```