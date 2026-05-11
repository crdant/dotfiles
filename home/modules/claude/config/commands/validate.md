# Validate Implementation

You are tasked with validating that an implementation (from either a plan or GitHub issue) was correctly executed, verifying all success criteria, checking conformance to documented patterns, and identifying any deviations or issues.

## Initial Setup

When invoked:

1. **Determine what to validate**:
   - If a plan path is provided: Validate that specific plan
   - If a GitHub issue number is provided: Validate that issue's implementation
   - If neither provided: Auto-detect from recent commits and context
   
2. **Check conversation context**:
   - If in existing conversation: Review what was implemented in this session
   - If fresh start: Discover implementation through git and codebase analysis

3. **Gather initial evidence**:
   ```bash
   # Check recent commits for references
   git log --oneline -n 20
   
   # Look for plan/issue references in commits
   git log --grep="plan" --grep="#" --oneline -n 10
   
   # Check working directory status
   git status
   ```

## Auto-Detection Process

If no specific target provided:

1. **Search for validation targets**:
   ```bash
   # Check for recent plan files
   ls -lt plans/*.md | head -5
   
   # Check for issue references in recent commits
   git log --oneline -n 10 | grep -E "#[0-9]+"
   
   # Check sessions for recent implementations
   ls -lt sessions/*implementation*.md | head -5
   ```

2. **Present findings to user**:
   ```
   I found these recent implementations to validate:
   
   Plans:
   - plans/2025-01-20-auth-tdd.md (modified 2 hours ago)
   
   GitHub Issues:
   - #456 referenced in recent commits
   
   Sessions:
   - sessions/2025-01-20-rate-limiting-implementation.md
   
   Which would you like me to validate, or should I validate the most recent?
   ```

## Validation Process

### Step 1: Context Gathering

1. **Read the implementation source completely**:
   - For plans: Read the full plan file with checkmarks
   - For issues: Read issue and all comments via `gh issue view`
   - For sessions: Read the session summary

2. **Spawn parallel research tasks** to understand context:
   
   ```
   Task 1 - Find related documentation:
   Use docs-locator to find:
   - ADRs related to this feature area
   - Previous session summaries for context
   - Technical documentation about patterns
   
   Task 2 - Analyze implementation:
   Use codebase-analyzer to:
   - Identify all changed files
   - Understand the implementation approach
   - Find test coverage
   
   Task 3 - Extract patterns and standards:
   Use docs-analyzer to:
   - Extract coding standards from ADRs
   - Identify required patterns
   - Find validation criteria from docs
   ```

3. **Read all identified files**:
   - Changed source files from git diff
   - Test files that should exist
   - Related documentation
   - Previous validation sessions if any

### Step 2: Systematic Validation

For each component/phase to validate:

1. **Check implementation completeness**:
   - For plans: Verify checkmarks match actual implementation
   - For issues: Verify all requirements addressed
   - Cross-reference with git diff

2. **Verify against patterns and standards**:
   - Check if implementation follows patterns from ADRs
   - Verify naming conventions from docs
   - Ensure architectural decisions are respected

3. **Run automated verification**:
   ```bash
   # Run all tests
   npm test  # or appropriate test command
   
   # Check linting
   npm run lint  # or appropriate lint command
   
   # Type checking
   npm run typecheck  # or appropriate command
   
   # Build verification
   npm run build  # if applicable
   
   # Coverage check
   npm run coverage  # if available
   ```

4. **Analyze test coverage**:
   - Verify tests exist for new functionality
   - Check if tests follow documented patterns
   - Ensure edge cases are covered

5. **Deep validation using agents**:
   
   Spawn specialized validation tasks:
   ```
   Task 1 - Pattern Conformance:
   Research if the implementation follows established patterns.
   Check similar implementations for consistency.
   
   Task 2 - Integration Points:
   Verify all integration points work correctly.
   Check for potential conflicts or regressions.
   
   Task 3 - Documentation Completeness:
   Check if docs were updated appropriately.
   Verify API documentation if applicable.
   ```

### Step 3: Generate Validation Report

Create comprehensive validation summary:

```markdown
# Validation Report: [Implementation Name]

**Date**: [Current date]
**Type**: [Plan/Issue/Session]
**Source**: [Path or issue number]

## Implementation Status

✅ **Completed**:
- [Component/Phase] - Fully implemented and tested
- [Component/Phase] - Matches specifications

⚠️ **Partial**:
- [Component/Phase] - Missing [specific aspect]

❌ **Not Implemented**:
- [Component/Phase] - [Reason]

## Automated Verification Results

| Check | Status | Details |
|-------|--------|---------|
| Tests | ✅ Pass | All 45 tests passing |
| Lint | ⚠️ Warning | 3 minor warnings |
| Types | ✅ Pass | No type errors |
| Build | ✅ Pass | Build successful |
| Coverage | ✅ 92% | Exceeds 90% requirement |

## Pattern Conformance

### Follows ADRs:
- ✅ ADR-001: Uses approved authentication pattern
- ✅ ADR-005: Follows error handling standards
- ⚠️ ADR-007: Logging could be more comprehensive

### Matches Existing Patterns:
- API endpoints follow RESTful conventions
- Error messages consistent with existing format
- Test structure matches established patterns

## Code Quality Assessment

### Strengths:
- Clean separation of concerns
- Well-documented functions
- Comprehensive error handling
- Good test coverage

### Areas for Improvement:
- Some functions could be decomposed further
- Missing JSDoc comments on utilities
- Could benefit from more integration tests

## Deviations from Specification

### Justified Deviations:
- Used `Map` instead of object for performance (improvement)
- Added input validation not in original spec (enhancement)

### Unjustified Deviations:
- Missing rate limit on one endpoint
- Error message format inconsistent

## Edge Cases and Risks

### Handled:
- Empty input validation
- Concurrent request handling
- Network timeout scenarios

### Not Handled:
- Very large payload edge case
- Specific browser compatibility issue

## Manual Testing Checklist

### UI/UX Verification:
- [ ] Feature displays correctly in all browsers
- [ ] Error messages are user-friendly
- [ ] Loading states work properly
- [ ] Responsive design functions

### Integration Testing:
- [ ] Works with existing authentication
- [ ] Database transactions complete properly
- [ ] Third-party integrations function
- [ ] Performance acceptable under load

## Recommendations

### Must Fix Before Merge:
1. Add missing rate limit to `/api/endpoint`
2. Fix error message format inconsistency
3. Address linting warnings

### Should Consider:
1. Add integration test for [scenario]
2. Improve logging per ADR-007
3. Add performance monitoring

### Future Improvements:
1. Consider caching strategy for frequently accessed data
2. Implement batch processing for bulk operations
3. Add telemetry for usage patterns

## Session Summary

This validation found the implementation to be [percentage]% complete with [number] issues requiring attention. The code quality is [assessment] and follows most established patterns.

**Next Steps**:
1. Address "Must Fix" items
2. Run validation again after fixes
3. Create PR once all critical issues resolved
```

### Step 4: Create Session Document

Save validation session for future reference:

1. **Create session file**: `sessions/YYYY-MM-DD-validation-[feature].md`

```markdown
---
date: [ISO date]
type: validation
feature: [feature name]
plan: [plan file if applicable]
issue: [issue number if applicable]
result: [pass/partial/fail]
---

# Validation Session: [Feature]

## What Was Validated
[Brief description of the implementation being validated]

## Validation Approach
[How the validation was conducted]

## Key Findings
[Important discoveries during validation]

## Issues Found
[List of problems identified]

## Recommendations Applied
[What was fixed during or after validation]

## Lessons Learned
[Insights for future implementations]
```

2. **Update the source**:
   - For plans: Add validation status comment to plan file
   - For issues: Post validation summary as GitHub comment

### Step 5: Communicate Results

Based on validation outcome:

#### If validation passes:
```
✅ Validation Complete - Implementation Ready

The implementation successfully meets all requirements with only minor issues that don't block merge.

See full validation report: sessions/YYYY-MM-DD-validation-[feature].md

Ready for PR creation and review.
```

#### If validation partially passes:
```
⚠️ Validation Complete - Issues Need Resolution

The implementation is mostly complete but has issues that should be addressed:

Critical Issues:
- [Issue 1]
- [Issue 2]

See full report: sessions/YYYY-MM-DD-validation-[feature].md

Please address critical issues before creating PR.
```

#### If validation fails:
```
❌ Validation Failed - Significant Work Needed

The implementation has significant gaps or issues:

[List major problems]

See full report: sessions/YYYY-MM-DD-validation-[feature].md

Recommend reviewing the plan/issue requirements and addressing gaps.
```

## Working with Existing Context

If you were part of the implementation:
- Review the conversation history
- Check your todo list for what was claimed complete
- Be honest about shortcuts or incomplete items
- Focus on objective validation despite being involved

## Important Guidelines

1. **Be thorough but practical** - Focus on what matters for quality and maintainability
2. **Check pattern conformance** - Validate against ADRs and documented standards
3. **Run all automated checks** - Never skip verification commands
4. **Document everything** - Create a session record for future reference
5. **Think critically** - Question if the implementation truly solves the problem
6. **Consider maintenance** - Will this be maintainable long-term?
7. **Use agents wisely** - Parallelize research for efficiency

## Validation Checklist

Always verify:
- [ ] All planned components are implemented
- [ ] Automated tests pass
- [ ] Code follows patterns from ADRs
- [ ] No regressions introduced
- [ ] Error handling is robust
- [ ] Documentation updated appropriately
- [ ] Test coverage meets standards
- [ ] Performance is acceptable
- [ ] Security considerations addressed
- [ ] Manual test steps are clear

## Integration with Other Commands

Recommended workflow:

1. `/plan` or `/plan-tdd` - Create the implementation plan
2. `/gh-issue` - Implement the plan or issue
3. `/validate` - Verify implementation correctness
4. Make fixes based on validation
5. `/validate` again if significant changes
6. Create PR once validation passes

The validation works best when you have:
- Committed your changes (can analyze git diff)
- Run initial tests locally
- Completed the implementation phase

## Example Usage

```
User: /validate plans/2025-01-20-auth-tdd.md
Assistant: I'll validate the implementation of the auth TDD plan. Let me start by reading the plan and analyzing what was implemented...

[Reads plan, spawns research tasks, runs verification]

I've completed validation of the authentication implementation. Here's the summary:

✅ 85% Complete - Minor issues to address

The implementation follows the TDD plan well with good test coverage (94%). However, there are a few issues...

[Provides detailed report]

Full validation report saved to: sessions/2025-01-20-validation-auth.md
```

Remember: Good validation is constructive, helping improve code quality before it reaches production. Be thorough but supportive, focusing on actionable feedback.