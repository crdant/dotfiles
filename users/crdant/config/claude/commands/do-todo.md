1. Open `todo.md` and select the first unchecked items to work on.
2. Carefully plan out how you will complete that item
3. Create a new branch for implementing your plan, branch names should be of
   the form `type/author/description` with the description using an active
   voice starting with a present tense verb: "feature/crdant/adds-todo-list"
   is a good branch name; "adds-todo-list" and "feature/crdant/todo-list" are
   bad branch names
    - Type should be one of: feature, fix, chore, docs, refactor, test
    - Authors should be the github username of the current user
    - Descriptions should be concise and descriptive
4. Write unit tests that will show your plan is implemented and correct:
    - Unit tests should be small and focused, with the simplest possible
      implementation
5. Validate that your tests fail (you haven't yet implemented the feature)
6. Commit your test and push your branch. Your commit message should:
    - be in active voice
    - describe the "why" behind your changes
    - use present tense with an implied subject of the change being committed
7. Implement your plan:
    - Write robust, well-documented code.
    - Include comprehensive tests and debug logging.
    - Verify that all tests pass.
    - Iterate until you have the simplest possible implementation that passes
      all of your tests.
    - Commit each iteration of your implementation
8. Commit your changes. Your commit message should:
    - be in active voice
    - describe the "why" behind your changes
    - use present tense with an implied subject of the change being committed
9. Check off the items on todo.md
10. Commit your todo.md updates. Your commit message should:
    - be in active voice
    - describe the "why" behind your changes
    - use present tense with an implied subject of the change being committed
11. Push your branch and open a PR in the following style:
    - Titles should be concise (40 characters or less) and use present tense
      with implied subject
    - Body must include two main sections:
      - **TL;DR**: 1-2 line summary of the change, this should be narrative
        and not bulleted
      - **Details**: Paragraph(s) explaining intent and impact, tend toward a
        narrative here as well but you may use bullet points sparingly if
        appropriate
      - Each section should be formated as H2 with a line of dashes under it
        that is the same length as the section title, followed by a blank line
      - Include blank lines between sections
      - Use different verbse to start the Title, the TL;DR, and the Details
        section
    - Use appropriate section headers with dashes underlining each header
    - Always use present tense with the PR as an implied subject
    - Focus on the intent and impact of changes, not reiterate the what that
      can be discovered by reviewing the code changes
    - Never use phrases like "this PR" or "this change" (the PR is the implied
      subject)
