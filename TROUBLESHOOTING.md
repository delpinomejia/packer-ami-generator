# Troubleshooting Guide

This document contains common issues encountered during the development and deployment of the Packer AMI Generator GitLab CI pipeline, along with their solutions.

## Known Issues

### 1. Permission Denied on Package Management Commands

**Issue**: GitLab CI pipeline fails with permission denied errors when trying to run `apt-get` or `apt` commands.

```bash
E: Could not open lock file /var/lib/apt/lists/lock - open (13: Permission denied)
```

**Root Cause**: GitLab runner doesn't have sufficient privileges to manage system packages.

**Solutions Attempted**:
- ✗ Adding `sudo` to commands - Still failed with permission errors
- ✗ Using `apt` instead of `apt-get` - Same permission issues
- ✅ **Final Solution**: Eliminated package installation dependency entirely

**Working Solution**:
```yaml
# Instead of installing bc package:
before_script:
  - apt-get install -y bc

# Use awk for calculations (pre-installed on most Unix systems):
script:
  - BUILD_TIME_HOURS=$(awk "BEGIN {printf \"%.4f\", $ESTIMATED_BUILD_TIME_MINUTES / 60}")
```

### 2. Artifact File Not Found: `cost_estimate.env`

**Issue**: GitLab CI shows warning about missing artifact file.

```bash
WARNING: cost_estimate.env: no matching files.
```

**Root Cause**: File creation timing issues or incorrect artifact configuration.

**Solutions Applied**:
1. **File Creation Method**: Changed from `printf` to `echo` for better compatibility
2. **Artifact Type**: Changed from `dotenv` reports to simple `paths` artifacts
3. **File Verification**: Added comprehensive debugging output

**Working Solution**:
```yaml
script:
  - echo "INSTANCE_TYPE=$INSTANCE_TYPE" > cost_estimate.env
  - echo "HOURLY_COST=$HOURLY_COST" >> cost_estimate.env
  - echo "TOTAL_COST=$TOTAL_COST" >> cost_estimate.env
  - ls -la cost_estimate.env || echo "File not found!"
  - cat cost_estimate.env || echo "Cannot read file!"

artifacts:
  paths:
    - cost_estimate.env
  expire_in: 1 hour
```

### 3. Unicode Encoding Issues in YAML

**Issue**: YAML file contains encoded characters like `\u003e` instead of `>`.

**Root Cause**: Text editor or Git client converting characters to Unicode escapes.

**Solutions**:
- Ensure YAML file is saved with UTF-8 encoding
- Use simple `echo` commands instead of complex heredoc syntax
- Verify file content before committing

### 4. Container vs Local Runner Compatibility

**Issue**: Pipeline configured for Docker containers but running on local Debian runner.

**Original Configuration** (Problematic):
```yaml
cost_estimate:
  stage: cost-estimate
  image: alpine:latest  # Ignored by local runner
  before_script:
    - apk add --no-cache bash bc  # Alpine package manager
```

**Fixed Configuration**:
```yaml
cost_estimate:
  stage: cost-estimate
  tags:
    - homelab
    - local
  # No image - runs directly on Debian runner
  # No before_script - uses standard tools only
```

### 5. Package Installation Alternatives

**Issue**: Unable to install required packages (`bc` for calculations).

**Alternative Solutions**:
- **AWK**: Use for decimal calculations (pre-installed)
- **Python**: Available on most systems for complex math
- **Bash arithmetic**: Limited to integers only

**Recommended Approach**:
```bash
# Instead of: echo "scale=4; $A / $B" | bc
# Use: awk "BEGIN {printf \"%.4f\", $A / $B}"
```

## Best Practices Learned

### 1. Minimize External Dependencies
- Use standard Unix tools when possible (`awk`, `grep`, `cut`, `sed`)
- Avoid installing packages that require elevated privileges
- Test with minimal tool requirements

### 2. Pipeline Environment Awareness
- Understand whether your runner uses Docker containers or runs directly on host
- Match package managers to actual environment (apt for Debian, apk for Alpine)
- Consider runner user permissions and sudo availability

### 3. Artifact Management
- Use simple `paths` artifacts for regular files
- Reserve `dotenv` artifacts for properly formatted environment files
- Always verify artifact creation with debugging output

### 4. File Operations
- Use `echo` for simple file creation instead of `printf` or complex redirects
- Verify file existence and contents before pipeline stage completion
- Handle encoding issues by using plain text operations

### 5. Cost Management
- Always include cost estimation for AWS resource creation
- Make cost information visible in pipeline logs
- Consider manual approval stages for expensive operations

## Debugging Commands

### Verify GitLab Runner Environment
```bash
# Check operating system
cat /etc/os-release

# Check available tools
which awk grep cut bc python3

# Check user permissions
whoami
groups
sudo -l  # If sudo is available
```

### File Creation Debugging
```bash
# Verify file creation
ls -la filename.env
file filename.env
wc -c filename.env

# Check file contents
cat filename.env
hexdump -C filename.env  # Check for encoding issues
```

### Cost Calculation Testing
```bash
# Test awk calculations
awk "BEGIN {printf \"%.4f\", 30 / 60}"  # Should output: 0.5000
awk "BEGIN {printf \"%.4f\", 0.0208 * 0.5}"  # Should output: 0.0104
```

## Pipeline Evolution Summary

1. **Initial Setup**: Alpine container with `apk` package manager
2. **Permission Issues**: Added `sudo` commands
3. **Local Runner Discovery**: Switched to Debian `apt` commands  
4. **Permission Persistence**: Removed `sudo` requirement
5. **Final Solution**: Eliminated package installation entirely

## Success Metrics

The pipeline is considered successful when:
- ✅ All stages complete without permission errors
- ✅ `cost_estimate.env` file is created and found
- ✅ Cost calculations display correctly in logs
- ✅ Artifacts are properly collected between stages
- ✅ AMI build proceeds without dependency issues

## Additional Resources

- [GitLab CI YAML Reference](https://docs.gitlab.com/ee/ci/yaml/)
- [Packer Documentation](https://www.packer.io/docs)
- [AWS AMI Building Best Practices](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AMIs.html)
- [Debian Package Management](https://www.debian.org/doc/manuals/debian-reference/ch02.en.html)

---

*This troubleshooting guide was created based on real issues encountered during pipeline development. Keep it updated as new issues are discovered and resolved.*
