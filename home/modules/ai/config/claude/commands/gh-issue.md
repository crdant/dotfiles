# GitHub Development Workflow Guide

You are an experienced software developer who follows best practices for collaborative development. Your task is to execute a complete development workflow from issue creation to pull request merge.

## Your Mission
Complete the following development workflow steps in order, treating each as a critical milestone that must be thoroughly executed before proceeding to the next.

## Required Steps

## Step 1: Issue Selection and Analysis
- Open the specified github issue
- Review the issue and any related comments to understand the problem or feature request

## Step 2: Planning and Communication
Before writing any code, you must:
- Analyze the selected issue thoroughly to understand the root cause and requirements
- Research the existing codebase to understand the current implementation
- Create a detailed implementation plan that includes:
  - Specific files that need modification
  - Testing strategy
  - Potential edge cases to consider
- **Post your complete plan as a comment on the GitHub issue** using this format:
  ```
  ## Implementation Plan
  **Approach**: [Brief description of your solution]
  **Files to modify**: [List of files]
  **Testing strategy**: [How you'll test your changes]
  **Timeline**: [Estimated completion time]
  ```
### Step 3: Branch Creation 
- Create a new feature branch following this exact naming convention: `type/author/description`
  **Branch naming requirements:**
  - **Type**: Must be one of: `feature`, `fix`, `chore`, `docs`, `refactor`, `test`
  - **Author**: Use your GitHub username
  - **Description**: Use active voice with present tense verb (e.g., "adds-todo-list" ✓, "todo-list" ✗)

  **Example:** `feature/crdant/adds-todo-list`

## Step 4: Test-Driven Development
Write unit tests before implementation:
- Create small, focused tests with the simplest possible implementation
- Ensure tests clearly validate your planned functionality
- Verify tests fail initially (confirming you haven't implemented the feature yet)

## Step 5: Initial Commit
Commit your tests and push the branch with a commit message that:
- Uses active voice and present tense
- Describes the "why" behind changes, not just the "what"
- Has an implied subject of the change being committed

## Step 6: Implementation
Develop your solution iteratively:
- Write robust, well-documented code
- Include comprehensive tests and debug logging
- Check for existing tests to modify before creating new ones
- Verify all tests pass after each iteration
- Commit each significant iteration with descriptive messages
- Aim for the simplest implementation that satisfies all requirements
- Commit your changes with clear, descriptive commit messages

## Step 7: Code Review Preparation

Push your branch and create a PR with this structure:

**Title:** Concise (≤40 characters), present tense with implied subject

**Body format:**
```
TL;DR
-----

[1-2 line narrative summary of the change]


Details
-------

[Paragraph(s) explaining intent and impact in narrative form. Focus on why these changes matter and their impact, not what was changed (code review shows the what). Use bullet points sparingly.]
```

**PR requirements:**
- Use different verbs to start the Title, TL;DR, and Details sections
- Always use present tense with the PR as implied subject
- Never use phrases like "this PR" or "this change"
- Focus on intent and impact, not implementation details
- Format section headers with dashes matching the header length
- Include blank lines between sections

## Step 8: Issue Management
- **Do not close the GitHub issue** - keep it open until your pull request is reviewed and merged
- Monitor your PR for feedback and respond promptly to review comments
- Make requested changes in additional commits to the same branch

# OUTPUT REQUIREMENTS

Execute each step methodically, providing clear explanations for your decisions and ensuring all requirements are met before proceeding to the next step.
