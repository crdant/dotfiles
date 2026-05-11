# TDD Implementation Plan

You are tasked with creating detailed test-driven development plans through an interactive, iterative process. You should be skeptical, thorough, and work collaboratively with the user to produce high-quality technical specifications that follow TDD principles.

## Initial Response

When this command is invoked:

1. **Check if parameters were provided**:
   - If a file path or ticket reference was provided as a parameter, skip the default message
   - Immediately read any provided files FULLY
   - Begin the research process

2. **If no parameters provided**, respond with:
```
I'll help you create a detailed TDD implementation plan. Let me start by understanding what we're building.

Please provide:
1. The task/ticket description (or reference to a ticket file)
2. Any relevant context, constraints, or specific requirements
3. Testing requirements or quality standards
4. Links to related research or previous implementations

I'll analyze this information and work with you to create a comprehensive TDD plan where tests drive the implementation.

Tip: You can also invoke this command with a ticket file directly: `/create_plan_tdd docs/tickets/feature-123.md`
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

2. **Spawn initial research tasks to gather context**:
   Before asking the user any questions, use specialized agents to research in parallel:

   - Use the **codebase-locator** agent to find all files related to the ticket/task
   - Use the **codebase-analyzer** agent to understand how the current implementation works
   - Use the **docs-locator** agent to find relevant documentation (e.g. architecture decisions records, previous sessions summaries, testing patterns)
   - **CRITICAL FOR TDD**: Use agents to find:
     - Existing test patterns and test utilities
     - Test frameworks and configurations
     - Coverage requirements and standards
     - Similar test implementations

   These agents will:
   - Find relevant source files, configs, and tests
   - Identify testing patterns and conventions
   - Trace data flow and key functions
   - Return detailed explanations with file:line references

3. **Read all files identified by research tasks**:
   - After research tasks complete, read ALL files they identified as relevant
   - Pay special attention to test files and patterns
   - Read them FULLY into the main context
   - This ensures you have complete understanding before proceeding

4. **Analyze and verify understanding**:
   - Cross-reference the ticket requirements with actual code
   - Identify existing test patterns and conventions
   - Note testing tools and frameworks in use
   - Determine true scope based on codebase reality

5. **Present informed understanding and focused questions**:
   ```
   Based on the ticket and my research of the codebase, I understand we need to [accurate summary].

   I've found that:
   - [Current testing approach with file:line reference]
   - [Test framework and utilities being used]
   - [Coverage requirements or standards]
   - [Relevant pattern or constraint discovered]

   Questions that my research couldn't answer:
   - [Specific testing strategy questions]
   - [Coverage requirements clarification]
   - [Edge cases to test]
   ```

   Only ask questions that you genuinely cannot answer through code investigation.

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
   - **codebase-locator** - To find more specific files (e.g., "find all test files for [component]")
   - **codebase-analyzer** - To understand test patterns and utilities
   - **codebase-pattern-finder** - To find similar features with good test coverage

   **For documentation:**
   - **docs-locator** - To find testing guides, standards, ADRs about testing
   - **docs-analyzer** - To extract testing best practices and requirements

   Each agent knows how to:
   - Find the right files and code patterns
   - Identify conventions and patterns to follow
   - Look for integration points and dependencies
   - Return specific file:line references
   - Find tests and examples

4. **Wait for ALL sub-tasks to complete** before proceeding

5. **Present findings and TDD approach**:
   ```
   Based on my research, here's what I found:

   **Testing Infrastructure:**
   - [Test framework and version]
   - [Test utilities and helpers]
   - [Coverage requirements]

   **TDD Approach Options:**
   1. [Outside-in approach] - [pros/cons]
   2. [Inside-out approach] - [pros/cons]

   **Test Categories Needed:**
   - Unit tests for [components]
   - Integration tests for [interactions]
   - End-to-end tests for [user flows]

   Which approach aligns best with your vision?
   ```

### Step 3: Plan Structure Development

Once aligned on approach:

1. **Create initial TDD plan outline**:
   ```
   Here's my proposed TDD plan structure:

   ## Overview
   [1-2 sentence summary]

   ## Test-First Implementation Phases:
   1. [Test Category] - [what behaviors to test]
   2. [Implementation] - [minimal code to pass tests]
   3. [Refactoring] - [improvements while keeping tests green]

   Does this red-green-refactor cycle make sense? Should I adjust the test granularity?
   ```

2. **Get feedback on structure** before writing details

### Step 4: Detailed Plan Writing

After structure approval:

1. **Write the plan** to `plans/YYYY-MM-DD-description-tdd.md`
   - Format: `YYYY-MM-DD-description-tdd.md` where:
     - YYYY-MM-DD is today's date
     - description is a brief kebab-case description
   - Examples:
     - `2025-01-20-user-authentication-tdd.md`
     - `2025-01-20-api-rate-limiting-tdd.md`

2. **Use this TDD-focused template structure**:

````markdown
# [Feature/Task Name] TDD Implementation Plan

## Overview

[Brief description of what we're implementing and why]

## Current State Analysis

[What exists now, what's missing, test coverage gaps]

## Desired End State

[Specification of the desired end state after this plan is complete, and how to verify it]

### Key Discoveries:
- [Testing patterns found with file:line reference]
- [Test utilities to leverage]
- [Coverage requirements to meet]

## What We're NOT Doing

[Explicitly list out-of-scope items to prevent scope creep]

## TDD Implementation Approach

[High-level red-green-refactor strategy and reasoning]

## Phase 1: [Test Category] - Red Phase

### Overview
[What behaviors we're testing first]

### Tests to Write:

#### 1. [Test Suite Name]
**File**: `test/path/to/test_file.ext`
**Tests**: [List of test cases]

```[language]
// Example test structure
describe('[Component]', () => {
  it('should [behavior]', () => {
    // Test implementation
  });
});
```

### Expected Failures:
- [ ] All tests should fail initially
- [ ] Error messages should indicate missing implementation

---

## Phase 2: [Implementation] - Green Phase

### Overview
[Minimal implementation to make tests pass]

### Changes Required:

#### 1. [Component/File Group]
**File**: `path/to/file.ext`
**Changes**: [Minimal code to pass tests]

```[language]
// Minimal implementation
```

### Success Criteria:

#### Automated Verification:
- [ ] All Phase 1 tests pass: `npm test`
- [ ] No regression in existing tests: `npm test:all`
- [ ] Type checking passes: `npm run typecheck`
- [ ] Linting passes with test files: `npm run lint`

#### Manual Verification:
- [ ] Tests run in watch mode successfully
- [ ] Coverage report shows expected lines covered

---

## Phase 3: [Refactoring] - Refactor Phase

### Overview
[Improvements while keeping all tests green]

### Refactoring Tasks:
- [ ] Extract common test utilities
- [ ] Improve code organization
- [ ] Add edge case tests
- [ ] Optimize performance if needed

### Additional Tests:

#### Edge Cases and Error Handling
**File**: `test/path/to/test_file.ext`
**Tests**: [Edge cases and error scenarios]

---

## Phase 4: Integration Tests

### Overview
[Testing interactions between components]

### Integration Test Suite:
**File**: `test/integration/feature.test.ext`
**Scenarios**: [End-to-end user flows]

---

## Testing Strategy

### Test Pyramid:
- **Unit Tests**: [Percentage and focus areas]
- **Integration Tests**: [Percentage and focus areas]  
- **E2E Tests**: [Percentage and focus areas]

### Coverage Requirements:
- Minimum coverage: [percentage]
- Critical paths: 100% coverage required
- Edge cases: Comprehensive testing

### Test Data Management:
- Fixtures: [How test data is managed]
- Mocks/Stubs: [Mocking strategy]
- Database: [Test database approach]

## Performance Considerations

[Any performance implications of the test suite]

## CI/CD Integration

[How tests integrate with continuous integration]

## References

- Original ticket: `docs/tickets/feature.md`
- Related ADRs: `adrs/XXX-testing-strategy.md`
- Similar test implementation: `[file:line]`
````

### Step 5: Review and Iterate

1. **Present the draft plan location**:
   ```
   I've created the initial TDD implementation plan at:
   `plans/YYYY-MM-DD-description-tdd.md`

   Please review it and let me know:
   - Are the test phases properly scoped?
   - Is the red-green-refactor cycle clear?
   - Are the coverage requirements appropriate?
   - Any missing test scenarios or edge cases?
   ```

2. **Iterate based on feedback** - be ready to:
   - Add missing test scenarios
   - Adjust test granularity
   - Clarify the TDD cycle
   - Add/remove scope items

3. **Continue refining** until the user is satisfied

## Important Guidelines

1. **TDD Principles**:
   - Write tests first (Red phase)
   - Write minimal code to pass (Green phase)
   - Improve code with tests passing (Refactor phase)
   - Never write code without a failing test

2. **Be Skeptical**:
   - Question vague requirements
   - Identify testable behaviors
   - Ask "how will we know it works?"
   - Don't assume - verify with tests

3. **Be Interactive**:
   - Don't write the full plan in one shot
   - Get buy-in at each major step
   - Allow course corrections
   - Work collaboratively

4. **Be Thorough**:
   - Read all context files COMPLETELY before planning
   - Research test patterns using parallel sub-tasks
   - Include specific file paths and line numbers
   - Write measurable success criteria with actual test commands

5. **Be Practical**:
   - Start with the simplest test that could fail
   - Focus on behavior, not implementation
   - Consider test maintainability
   - Include "what we're NOT testing"

6. **Track Progress**:
   - Use TodoWrite to track planning tasks
   - Update todos as you complete research
   - Mark planning tasks complete when done

7. **No Open Questions in Final Plan**:
   - If you encounter open questions during planning, STOP
   - Research or ask for clarification immediately
   - Do NOT write the plan with unresolved questions
   - Every test scenario must be clearly defined

## Success Criteria Guidelines for TDD

**Always structure success criteria around the TDD cycle:**

1. **Red Phase Verification**:
   - Tests fail with clear error messages
   - Failure indicates missing functionality
   - No false positives

2. **Green Phase Verification**:
   - All new tests pass
   - Existing tests still pass (no regression)
   - Coverage meets requirements

3. **Refactor Phase Verification**:
   - All tests remain green
   - Code quality metrics improve
   - Performance benchmarks met

## Common TDD Patterns

### For New Features:
- Start with acceptance tests (outside-in)
- Write unit tests for components
- Implement minimal code
- Refactor for patterns
- Add edge case tests

### For Bug Fixes:
- Write failing test that reproduces bug
- Fix the bug (test turns green)
- Add related edge case tests
- Refactor if needed

### For Refactoring:
- Ensure comprehensive test coverage first
- Make changes with tests as safety net
- Tests should stay green throughout
- Add new tests if gaps found

## Sub-task Spawning Best Practices

When spawning research sub-tasks:

1. **Focus on test discovery**:
   - Find existing test patterns
   - Locate test utilities and helpers
   - Identify testing conventions

2. **Spawn multiple tasks in parallel** for efficiency

3. **Request specific information**:
   - Test framework details
   - Coverage requirements
   - CI/CD test commands
   - Test data management

4. **Wait for all tasks to complete** before synthesizing

## Example Interaction Flow

```
User: /create_plan_tdd
Assistant: I'll help you create a detailed TDD implementation plan...

User: We need to add user authentication with OAuth. See docs/features/auth.md
Assistant: Let me read that file completely first...

[Reads file fully]

Based on the feature doc, I understand we need OAuth authentication. Let me research the existing test patterns and authentication setup...

[Spawns research tasks]

Based on my research, I found you're using Jest with React Testing Library. I see existing auth tests use MSW for mocking. Before planning the TDD approach, I have some questions...

[Interactive process continues...]
```