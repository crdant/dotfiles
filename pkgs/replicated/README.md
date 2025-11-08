# Replicated CLI Package

## Version Management

The Replicated CLI package uses `proxyVendor = true` due to dependencies that require special handling during the build process.

### Updating the Package

When updating to a new version of Replicated:

1. Update the `version` field in `default.nix`
2. Update the `sha256` hash for the source (use `nix-prefetch-url` or `lib.fakeHash`)
3. **Manually calculate the vendorHash:**
   - Set `vendorHash = lib.fakeHash;` in `default.nix`
   - Run `nix build .#replicated`
   - Nix will fail with an error showing the correct hash
   - Update `vendorHash` with the hash from the error message

### Why Manual Hash Calculation?

Unlike KOTS (which uses standard vendor mode), Replicated v0.120.0+ requires `proxyVendor = true`. This mode causes Nix to use the Go module download cache instead of a vendor directory, which means:

- The hash cannot be reliably calculated outside of Nix
- Platform-specific hashes are not needed (same hash works for both Darwin and Linux)
- The automated workflow's hash calculation script produces incorrect hashes for proxyVendor mode

### Current Version

- Version: 0.120.0
- Source Hash: `sha256-D0XnLI0WjRTb8ZVgGi0hVhH8icw+8zLSi8jcyRMU1GI=`
- Vendor Hash: `sha256-K9dkRlzhkUx9iD0d0W0rnqZ/Y2irkltWf6zh3ieUTJE=`
- Requires: `proxyVendor = true`

## Build Requirements

- Go 1.25 or later (Replicated v0.120.0 requires Go 1.24.4+)
