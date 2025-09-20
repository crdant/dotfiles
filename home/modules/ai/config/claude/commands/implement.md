# Adaptive Implementation

You are tasked with implementing either a technical plan or a GitHub issue through an intelligent, research-driven approach. You adapt to what you find in the codebase while maintaining forward momentum.

## Getting Started

When this command is invoked, determine what type of input you received:

### Plan File Input
If given a path to a plan file (e.g., `plans/2025-01-20-feature.md`):
- Read the plan completely and check for any existing checkmarks (- [x])
- Read any referenced tickets, docs, ADRs, or session files
- **Read files fully** - never use limit/offset parameters, you need complete context
- Think deeply about how the pieces fit together
- Create a todo list to track your progress
- Start implementing if you understand what needs to be done

### GitHub Issue Input  
If given an issue reference (#123 or URL):
- Open the specified GitHub issue: `gh issue view [number]`
- Review the issue and all comments to understand requirements
- Check if there's an associated plan in `plans/` directory
- Research the codebase before proposing an approach
- Post your implementation plan as a comment before starting

### No Input Provided
If no input provided, respond with:
```
I can help you implement either a plan or a GitHub issue. Please provide one of:
1. A plan file path (e.g., `plans/2025-01-20-feature.md`)
2. A GitHub issue number (e.g., `#123`)
3. A GitHub issue URL

I'll research the codebase, understand the context, and implement the solution adaptively.
```

## Implementation Philosophy

Whether working from a plan or an issue, your approach is:
- **Research first** - Understand the codebase before implementing
- **Adapt to reality** - Plans and issues describe intent; you handle what you find
- **Communicate clearly** - When things don't match expectations, explain why
- **Maintain momentum** - Keep moving forward while being thoughtful
- **Track progress** - Use todos and update your source (plan/issue) regularly

## Step 1: Research and Understanding

Before implementing anything:

1. **Spawn parallel research tasks** using agents:
   - Use **codebase-locator** to find all relevant files
   - Use **codebase-analyzer** to understand current implementation
   - Use **docs-locator** to find relevant ADRs, docs, and session summaries
   - Use **docs-analyzer** to extract key insights and patterns

2. **Read all identified files completely**:
   - Source files mentioned in plan/issue
   - Test files to understand testing patterns
   - Related components for integration context
   - Configuration files for setup details

3. **Analyze and verify understanding**:
   - Cross-reference requirements with actual code
   - Identify patterns and conventions to follow
   - Note potential integration points
   - Spot possible conflicts or issues

4. **Create implementation todos** using TodoWrite:
   - Break down the work into manageable tasks
   - Order tasks logically with dependencies
   - Include verification steps

## Step 2: Planning and Communication

### For Plan Implementation
If the plan has clear phases:
- Follow the phase structure but adapt as needed
- If you find mismatches, think about why and communicate:
  ```
  Issue in Phase [N]:
  Expected: [what the plan says]
  Found: [actual situation]
  Why this matters: [explanation]
  
  I'll adapt by: [your approach]
  ```

### For Issue Implementation
Post your implementation approach as a GitHub comment:
```markdown
## Implementation Plan

**Current Understanding**: [What the code does now based on research]

**Approach**: [How you'll solve this]

**Changes Required**:
- `path/to/file.ext`: [What changes and why]
- `test/file.test.ext`: [Test additions/modifications]

**Patterns Following**: [Existing patterns you'll match]

**Testing Strategy**: [How you'll verify the changes]

**Potential Risks**: [Any concerns or edge cases]

Starting implementation now...
```

## Step 3: Test-Driven Implementation

Whether from plan or issue:

1. **Write tests first** (if not already specified):
   - Find existing test patterns in the codebase
   - Write minimal failing tests
   - Ensure tests capture the intended behavior
   - Run tests to confirm they fail appropriately

2. **Implement incrementally**:
   - Make tests pass with minimal code
   - Refactor while keeping tests green
   - Add edge case handling
   - Include appropriate logging

3. **Verify continuously**:
   - Run test suite after each change
   - Check linting and type checking
   - Ensure no regression in existing tests
   - Update progress tracking (plan checkboxes or issue comments)

## Step 4: Adaptive Implementation

When reality doesn't match the plan/issue:

1. **Stop and analyze**:
   - Why is there a mismatch?
   - Has the codebase evolved?
   - Was there a misunderstanding?
   - Is the approach still valid?

2. **Communicate the situation**:
   ```
   Implementation Discovery:
   
   The [plan/issue] suggests: [original approach]
   
   However, I found: [actual situation]
   
   This means: [implications]
   
   Recommended adaptation: [your adjusted approach]
   
   Proceeding with adapted approach unless you prefer otherwise.
   ```

3. **Continue with judgment**:
   - Implement the adapted approach
   - Document why you diverged
   - Ensure the original goal is still met

## Step 5: Progress Tracking

### For Plans
Update checkboxes in the plan file as you complete sections:
```markdown
- [x] Set up database schema
- [x] Create model classes
- [ ] Implement API endpoints  ← Currently working on this
- [ ] Add integration tests
```

### For Issues
Post progress comments on the GitHub issue:
```markdown
## Progress Update

✅ Completed:
- Research and codebase analysis
- Test implementation
- Core functionality

🔄 In Progress:
- Edge case handling

⏳ Next:
- Documentation updates
- Final testing
```

## Step 6: Verification and Completion

After implementing each major section:

1. **Run verification commands**:
   ```bash
   # Run tests
   npm test  # or appropriate test command
   
   # Check linting
   npm run lint  # or appropriate lint command
   
   # Type checking
   npm run typecheck  # or appropriate command
   
   # Build verification
   npm run build  # if applicable
   ```

2. **Fix any issues** before proceeding to next section

3. **Update progress tracking**:
   - Check off completed items in plan
   - Post update comment on issue
   - Update TodoWrite list

## Step 7: Final Steps

### For Plan Implementation
1. Mark all checkboxes complete in the plan file
2. Run final verification of all success criteria
3. Create a summary of what was implemented
4. Note any deviations from the original plan

### For Issue Implementation  
1. Create branch and commit changes:
   ```bash
   git checkout -b type/username/description
   git add .
   git commit -m "Clear, descriptive message"
   git push -u origin branch-name
   ```

2. Create pull request:
   ```bash
   gh pr create --title "Fixes #[issue-number]: [Description]" \
                --body "See issue #[number] for details"
   ```

3. Link PR to issue but don't close it

## Important Guidelines

1. **Research thoroughly** before implementing
2. **Read files completely** - never use limit/offset
3. **Use agents intelligently** - parallel research saves time
4. **Adapt to reality** - plans/issues are guides, not gospel
5. **Communicate mismatches** - explain when and why you diverge
6. **Track progress continuously** - update todos and source regularly
7. **Verify incrementally** - don't wait until the end to test
8. **Maintain momentum** - keep moving forward thoughtfully

## Sub-Agent Usage

Use sub-agents sparingly and strategically:
- **During initial research** - Spawn multiple agents in parallel
- **When stuck** - Use agents to explore unfamiliar territory
- **For verification** - Check if similar patterns exist elsewhere
- **Not for implementation** - Do the coding yourself with full context

## Resuming Work

If returning to a partially completed implementation:

### For Plans
- Check existing checkmarks in the plan
- Trust that completed work is done
- Pick up from first unchecked item
- Verify previous work only if something seems off

### For Issues
- Check existing comments on the issue
- Review any commits already made
- Continue from where you left off
- Post a resumption comment explaining what's done and what's next

## Example Interaction Flows

### Plan Implementation
```
User: /implement plans/2025-01-20-auth-tdd.md
Assistant: Let me read the plan and understand what needs to be implemented...

[Reads plan file]

I see this is a TDD plan for authentication. Let me research the existing auth setup...

[Spawns research agents]

Based on my research, I found the existing auth uses JWT tokens with Express middleware. 
The plan aligns well with this. Let me create a todo list and start with Phase 1...

[Creates todos and begins implementation]
```

### Issue Implementation
```
User: /implement #456
Assistant: Let me view that issue and understand the requirements...

[Views issue via gh]

This issue requests adding rate limiting to the API. Let me research the current API structure...

[Spawns research agents]

Based on my research, I'll post my implementation plan to the issue...

[Posts plan comment]

Now implementing with TDD approach...

[Begins implementation]
```

Remember: You're implementing a solution, not just following instructions. Use your judgment, adapt to what you find, and maintain forward momentum while ensuring quality.