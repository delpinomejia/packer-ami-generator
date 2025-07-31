# Unicode Encoding Issues in GitLab CI YAML Files

## Problem Description

When working with GitLab CI YAML files on Windows systems, Unicode escape sequences can be inadvertently introduced into the file, causing YAML syntax errors that prevent pipelines from running.

### Symptoms

- GitLab CI pipeline fails with YAML syntax errors
- Error messages indicating invalid characters or unexpected tokens
- Characters appearing as Unicode escape sequences (e.g., `\u003e` instead of `>`)
- Pipeline validation fails even though the YAML appears correct in editors

### Root Cause

The issue occurs when:
1. Files are created or edited on Windows systems with certain text editors
2. Unicode characters are automatically escaped during file operations
3. PowerShell or Windows file operations introduce Unicode encoding issues
4. Copy-paste operations from certain sources introduce Unicode escape sequences

## Common Problematic Characters

| Character | Unicode Escape | Common Location | Impact |
|-----------|----------------|-----------------|---------|
| `>` | `\u003e` | Shell redirects | Breaks file redirection |
| `<` | `\u003c` | Shell redirects | Breaks input redirection |
| `&` | `\u0026` | Shell commands | Breaks command chaining |
| `"` | `\u0022` | String quotes | Breaks string parsing |

## Detection Methods

### Method 1: PowerShell Line Inspection
```powershell
# Check specific line for Unicode characters
Get-Content '.gitlab-ci.yml' | Select-Object -Skip 142 -First 1

# Look for Unicode escape sequences
Select-String -Path '.gitlab-ci.yml' -Pattern '\\u[0-9a-fA-F]{4}'
```

### Method 2: Hex Dump Analysis
```powershell
# Examine file in hexadecimal format
$content = Get-Content '.gitlab-ci.yml' -Raw
$bytes = [System.Text.Encoding]::UTF8.GetBytes($content)
$hex = $bytes | ForEach-Object { '{0:X2}' -f $_ }
Write-Host ($hex -join ' ')
```

### Method 3: Git Diff Review
```bash
# Check for encoding issues in git diff
git diff .gitlab-ci.yml
```

## Solution Strategies

### Strategy 1: Revert to Basic Configuration (Most Reliable)
When dealing with persistent encoding issues, start with a minimal working configuration:

You can start by using our [Sample GitLab CI File](sample-gitlab-ci.yml) as a reference. This basic template ensures no encoding issues and provides a clean slate for further enhancements.

```bash
# Steps to revert back to basics

# 1. Remove the problematic file
git rm .gitlab-ci.yml
git commit -m "Remove problematic GitLab CI file"
git push origin main

# 2. Use the sample GitLab CI template
# This ensures clean UTF-8 encoding from the start
cp docs/troubleshooting/sample-gitlab-ci.yml .gitlab-ci.yml

# 3. Commit and push the sample
git add .gitlab-ci.yml
git commit -m "Setup a clean GitLab CI sample"
git push origin main

# 4. Gradually add complexity using edit tools instead of full replacements
```

### Strategy 2: File Recreation (Traditional Method)
This method works for isolated encoding issues:

```bash
# 1. Backup the problematic file
git mv .gitlab-ci.yml .gitlab-ci.yml.backup

# 2. Create a clean new file using a reliable text editor
# Use VS Code, Notepad++, or similar with UTF-8 encoding

# 3. Copy content manually, avoiding problematic sections
# Pay special attention to shell commands with redirects

# 4. Commit the clean version
git add .gitlab-ci.yml
git commit -m "Fix Unicode encoding issues in GitLab CI YAML"
```

### Strategy 2: PowerShell Character Replacement
For isolated character issues:

```powershell
# Replace specific Unicode escape sequences
(Get-Content '.gitlab-ci.yml' -Raw) -replace '\\u003e', '>' | Set-Content '.gitlab-ci.yml' -Encoding UTF8

# Replace multiple characters
$content = Get-Content '.gitlab-ci.yml' -Raw
$content = $content -replace '\\u003e', '>'
$content = $content -replace '\\u003c', '<'
$content = $content -replace '\\u0026', '&'
$content | Set-Content '.gitlab-ci.yml' -Encoding UTF8
```

### Strategy 3: Unix Tools (WSL/Git Bash)
If available, Unix tools handle encoding more predictably:

```bash
# Use sed to replace Unicode sequences
sed -i 's/\\u003e/>/g' .gitlab-ci.yml
sed -i 's/\\u003c/</g' .gitlab-ci.yml
```

## Prevention Best Practices

### 1. Editor Configuration
- **VS Code**: Set encoding to UTF-8 without BOM
- **Notepad++**: Use UTF-8 encoding, avoid UTF-8 with BOM
- **PowerShell ISE**: Avoid for YAML editing due to encoding issues

### 2. File Creation Guidelines
```powershell
# When creating files in PowerShell, use explicit UTF-8 encoding
$content | Out-File -FilePath '.gitlab-ci.yml' -Encoding UTF8
```

### 3. Git Configuration
```bash
# Ensure Git handles line endings properly
git config core.autocrlf false
git config core.eol lf
```

### 4. Validation Workflow
Always validate YAML files before committing:

```bash
# Use a YAML validator
python -c "import yaml; yaml.safe_load(open('.gitlab-ci.yml', 'r'))"

# Or use online validators for quick checks
```

## Emergency Quick Fix

If you need an immediate fix for a failing pipeline:

```bash
# 1. Identify the problematic line (usually shown in GitLab CI error)
# 2. Edit the file directly in GitLab's web interface
# 3. Make minimal changes to fix the Unicode character
# 4. Commit directly through the web interface
# 5. Pull changes to local repository
```

## Testing and Verification

### 1. Local YAML Validation
```python
# Python validation script
import yaml
try:
    with open('.gitlab-ci.yml', 'r', encoding='utf-8') as file:
        yaml.safe_load(file)
    print("✅ YAML syntax is valid")
except yaml.YAMLError as e:
    print(f"❌ YAML syntax error: {e}")
```

### 2. GitLab CI Lint API
```bash
# Use GitLab's CI Lint API (requires access token)
curl --header "PRIVATE-TOKEN: your-token" \
     --header "Content-Type: application/json" \
     --data '{"content": "$(cat .gitlab-ci.yml)"}' \
     "https://gitlab.com/api/v4/ci/lint"
```

## Real-World Example

In our project, the issue manifested as:
```yaml
# Problematic line (line 143)
- echo "AMI_ID=$AMI_ID" \u003e ami-details.env

# Fixed line
- echo "AMI_ID=$AMI_ID" > ami-details.env
```

The `\u003e` Unicode escape sequence was preventing proper shell redirection, causing the entire pipeline to fail with a YAML parsing error.

## ✅ Success Story: Complete Resolution

**Date**: January 31, 2025  
**Project**: AWS AMI Builder with Packer  
**Issue Duration**: Multiple attempts over several hours  
**Final Resolution**: Strategy 1 (Revert to Basic Configuration)

### What Worked:
1. **Deleted the problematic file completely** using `git rm .gitlab-ci.yml`
2. **Created a basic GitLab CI template** via GitLab's web interface
3. **Pulled the clean template** to local repository
4. **Simplified the pipeline** to basic functionality without complex redirects
5. **Verified no Unicode escape sequences** using PowerShell validation
6. **Successfully pushed and deployed** - pipeline runs without errors

### Key Learnings:
- **Windows encoding persistence**: Even after multiple edit attempts, Unicode characters persisted
- **Edit tool limitations**: Traditional find-and-replace couldn't resolve deep encoding issues
- **GitLab web interface reliability**: Creating files through GitLab's interface ensures clean UTF-8
- **Simplification effectiveness**: Basic configuration eliminated all encoding variables
- **Progressive complexity**: Start simple, then gradually add features

### Final Status:
```bash
# Pipeline now runs successfully with:
✅ No Unicode escape sequences
✅ Clean YAML syntax validation
✅ Successful GitLab CI execution
✅ Ready for progressive enhancement
```

**Recommendation**: Always start with basic GitLab CI templates and build complexity gradually rather than attempting to fix encoding issues in complex configurations.

## Additional Resources

- [GitLab CI YAML Syntax Reference](https://docs.gitlab.com/ee/ci/yaml/)
- [YAML Specification](https://yaml.org/spec/1.2/spec.html)
- [Unicode Character Database](https://unicode.org/charts/)
- [PowerShell Encoding Documentation](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_character_encoding)

## Related Issues

- Windows line ending issues (`CRLF` vs `LF`)
- BOM (Byte Order Mark) problems in UTF-8 files
- PowerShell output encoding inconsistencies
- Git autocrlf configuration conflicts

---

**Last Updated**: 2025-01-31  
**Project**: AWS AMI Builder with Packer  
**Severity**: High (Pipeline Breaking)  
**Tags**: `gitlab-ci`, `yaml`, `unicode`, `encoding`, `windows`, `troubleshooting`
