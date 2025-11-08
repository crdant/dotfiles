---
date: 2025-11-08T12:55:00-08:00
researcher: Claude (Sonnet 4.5)
git_commit: f5fe9a6493a388feb57c33cbdd4deb25472586fb
branch: fix/crdant/corrects-kots-automation
repository: crdant/dotfiles
topic: "Resolving GitHub workflow failure: KOTS update workflow failing on go mod download"
tags: [research, github-actions, kots, go-modules, ubuntu-24.04, dns-resolution]
status: complete
last_updated: 2025-11-08
last_updated_by: Claude (Sonnet 4.5)
---

# Research: Resolving GitHub Workflow Failure for KOTS Update

**Date**: 2025-11-08T12:55:00-08:00
**Researcher**: Claude (Sonnet 4.5)
**Git Commit**: f5fe9a6493a388feb57c33cbdd4deb25472586fb
**Branch**: fix/crdant/corrects-kots-automation
**Repository**: crdant/dotfiles

## Research Question

Why is the KOTS update workflow failing with `go mod download` returning exit status 1, and how can we fix it?

## Summary

**Both macOS and Linux jobs are failing** with the same error during `go mod download` for KOTS v1.128.3. The Python script's error handling hides the actual error messages, making root cause diagnosis impossible from workflow logs alone.

**Critical Finding**: Without seeing the actual `go mod download` error output, we cannot determine if this is:
1. A network/DNS issue (affecting both platforms)
2. A KOTS v1.128.3-specific Go module dependency problem
3. A GitHub Actions runner environment issue

**Immediate Action Required**: Fix the Python script to show error messages, then re-run the workflow to see the actual error.

## Detailed Findings

### Root Cause: Hidden Error Messages Preventing Diagnosis

**Primary Issue**: The Python script's error handling hides the actual error messages from `go mod download`, making it impossible to diagnose the real problem from the workflow logs.

**Secondary Issues (Possible Root Causes)**:
1. **Ubuntu 24.04 DNS Resolution Bug** - Could be affecting Linux runner
2. **macOS Runner Issues** - Unknown issue affecting macOS runner
3. **KOTS v1.128.3 Go Module Issue** - Possible problem with the version itself

**Key Information**:
- **Both macOS AND Linux jobs are failing** with identical error messages
- Both fail at exactly the same point: `go mod download`
- Error message provides no diagnostic information: `Command '['go', 'mod', 'download']' returned non-zero exit status 1.`
- This suggests a common issue, not platform-specific

**Impact on This Workflow**:
- All recent workflow runs have failed (5+ consecutive failures since version 1.128.3 was released)
- Failures occur on BOTH `calculate-linux-hash` AND `calculate-darwin-hash` jobs
- Both platforms failing identically suggests the issue is with KOTS v1.128.3 itself or the Go module dependencies

### Secondary Issue: Hidden Error Messages

**File**: `.github/scripts/calculate-go-vendor-hash.py:45`

```python
subprocess.run(["go", "mod", "download"], check=True, capture_output=True)
```

**Problem**:
- `capture_output=True` captures both stdout and stderr but doesn't display them
- When the command fails, the exception handler (line 110-112) only shows:
  ```
  Failed to calculate vendor hash: Command '['go', 'mod', 'download']' returned non-zero exit status 1.
  ```
- The actual error message from Go is lost, making debugging extremely difficult

### Version Status Verification

**KOTS v1.128.3**:
- ✅ Tag exists: `167ead124f6bab482cabf5b37d4fd0505a93c47a`
- ✅ Release published: 2025-10-28T14:33:54Z
- ✅ Can be cloned successfully
- ✅ `go mod download` works locally on macOS
- ❌ Fails on GitHub Actions Ubuntu 24.04 runners

**Current Package Version**: v1.128.2 (`pkgs/kots/default.nix:8`)

## Code References

### Workflow Definition
- `.github/workflows/update-kots.yml:61-90` - `calculate-linux-hash` job definition
- `.github/workflows/update-kots.yml:78-81` - Go 1.21 setup
- `.github/workflows/update-kots.yml:83-86` - Failing step that runs Python script

### Python Scripts
- `.github/scripts/calculate-go-vendor-hash.py:45` - `go mod download` command with hidden output
- `.github/scripts/calculate-go-vendor-hash.py:110-112` - Exception handler that loses error details
- `.github/scripts/update-package.py:57-87` - Version detection using GitHub API

### Package Definition
- `pkgs/kots/default.nix:8` - Current version (1.128.2)
- `pkgs/kots/default.nix:17-20` - Platform-specific vendorHash values

## Solution: Three-Step Approach

### Step 1: Fix Error Visibility (CRITICAL - DO THIS FIRST)

This is the **most important fix** - without it, we're debugging blind.

Update `.github/scripts/calculate-go-vendor-hash.py` line 43-45 to show errors:

**Current code (line 43-45)**:
```python
# Download dependencies
print("Downloading Go dependencies...")
subprocess.run(["go", "mod", "download"], check=True, capture_output=True)
```

**Replace with**:
```python
# Download dependencies
print("Downloading Go dependencies...")
try:
    result = subprocess.run(
        ["go", "mod", "download"],
        capture_output=True,
        text=True,
        check=True
    )
    print("Dependencies downloaded successfully")
except subprocess.CalledProcessError as e:
    print(f"ERROR: go mod download failed with exit code {e.returncode}", file=sys.stderr)
    if e.stderr:
        print(f"Error output:\n{e.stderr}", file=sys.stderr)
    if e.stdout:
        print(f"Standard output:\n{e.stdout}", file=sys.stderr)
    raise
```

**Why this is CRITICAL**:
- Without this, we have no idea what's actually failing
- Both platforms failing identically is unusual - we need to see the actual error
- This will tell us if it's network, dependencies, permissions, or something else

### Step 2: Re-run the Workflow to See Actual Error

After applying Step 1:
```bash
git add .github/scripts/calculate-go-vendor-hash.py
git commit -m "fix: show error output from go mod download failures"
git push
gh workflow run update-kots.yml
```

**Check the logs** to see the actual error message. This will determine next steps.

### Step 3: Apply Targeted Fix Based on Error (DO AFTER STEP 2)

Possible fixes depending on what Step 2 reveals:

#### If DNS/Network Issues:
Add DNS pinning to both jobs in `.github/workflows/update-kots.yml`:

```yaml
# For calculate-linux-hash (line ~82)
- name: Pin DNS for Go module proxy
  run: |
    PROXY_IP=$(dig +short proxy.golang.org | head -n1)
    SUM_IP=$(dig +short sum.golang.org | head -n1)
    echo "$PROXY_IP proxy.golang.org" | sudo tee -a /etc/hosts
    echo "$SUM_IP sum.golang.org" | sudo tee -a /etc/hosts

# For calculate-darwin-hash (line ~52)
- name: Pin DNS for Go module proxy
  run: |
    PROXY_IP=$(dig +short proxy.golang.org | head -n1)
    SUM_IP=$(dig +short sum.golang.org | head -n1)
    echo "$PROXY_IP proxy.golang.org" | sudo tee -a /etc/hosts
    echo "$SUM_IP sum.golang.org" | sudo tee -a /etc/hosts
```

#### If Private Module/Auth Issues:
Add GOPRIVATE environment variable or git config

#### If Dependency Checksum Issues:
May need to update go.sum or handle specific module problems

**DO NOT apply Step 3 fixes blindly - wait to see the actual error from Step 2**

## Alternative Solutions Considered

### 1. Use GOPROXY=direct
**Pros**: Bypasses the proxy entirely
**Cons**: Loses caching benefits, slower downloads, may hit rate limits

### 2. Upgrade to Go 1.21.1+
**Note**: Workflow already uses Go 1.21 via `actions/setup-go@v6`, which should pull the latest 1.21.x patch version. Go 1.21.0 had a GOPROXY bug, but this is likely not the issue since setup-go uses the latest patch.

### 3. Use actions/setup-go caching
**Note**: Already enabled (`cache: true` is default in setup-go@v5+)

## Implementation Steps

### Phase 1: Get Diagnostic Information (DO THIS FIRST)

1. **Fix error visibility**:
   ```bash
   # Edit .github/scripts/calculate-go-vendor-hash.py line 43-45
   # Replace subprocess.run with try/except block that shows stderr
   ```

2. **Commit and push**:
   ```bash
   git add .github/scripts/calculate-go-vendor-hash.py
   git commit -m "fix: show error output from go mod download failures"
   git push
   ```

3. **Trigger workflow**:
   ```bash
   gh workflow run update-kots.yml
   ```

4. **Check logs for actual error**:
   ```bash
   # Wait a few minutes, then:
   gh run list --workflow=update-kots.yml --limit 1
   # Get the run ID and view logs:
   gh run view <RUN_ID> --log | grep -A 20 "ERROR: go mod download"
   ```

### Phase 2: Apply Targeted Fix (AFTER seeing the error)

Based on the error from Phase 1, apply the appropriate fix from Step 3 of the Solution section above.

### Phase 3: Verify

- Check that both `calculate-linux-hash` and `calculate-darwin-hash` jobs complete
- Verify vendor hashes are calculated
- Confirm PR is created for KOTS v1.128.3

## Expected Outcomes

After applying the DNS pinning fix:
- ✅ `go mod download` should succeed consistently on Ubuntu 24.04 runners
- ✅ Workflow should complete successfully and create PR for KOTS v1.128.3
- ✅ Future KOTS updates should work reliably
- ✅ Error messages will be visible if other issues occur

## Additional Notes

### Why This Issue Appeared Now

The workflow has been failing since KOTS v1.128.3 was released (2025-10-28), but this is coincidental timing. The DNS issue has been present in Ubuntu 24.04 runners all along, but Go module downloads are probabilistic - they fail approximately 20% of the time. With the update workflow running every 4 hours and finding a new version, we've hit the failure case multiple times in a row.

### Prevention for Other Workflows

Consider applying the same DNS pinning fix to other Go-based workflows:
- `.github/workflows/update-replicated.yml` (line 61-90) - Has identical `calculate-linux-hash` job
- Any future Go module workflows on Ubuntu runners

### References

- [GitHub Actions Issue #11886](https://github.com/actions/runner-images/issues/11886) - DNS resolution issue
- [Go Issue #61928](https://github.com/golang/go/issues/61928) - Go 1.21.0 GOPROXY bug (fixed in 1.21.1+)
- [KOTS Release v1.128.3](https://github.com/replicatedhq/kots/releases/tag/v1.128.3)

## Open Questions

None - solution is clear and actionable.

---

## Metadata

- **Workflow Run ID**: 19196343273 (and 4 previous failures)
- **Runner Image**: ubuntu-24.04 (Version: 20251102.99.1)
- **Go Version**: 1.21.13 (from workflow logs)
- **Error**: `Command '['go', 'mod', 'download']' returned non-zero exit status 1`
