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

### Strategy 1: File Recreation (Recommended)
This is the most reliable method for severe encoding issues:

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

### 5. Online YAML Validation (Recommended)
For comprehensive validation without local tools:

**yamllint.com** - The most reliable online YAML validator:
1. Visit: https://www.yamllint.com/
2. Copy your entire `.gitlab-ci.yml` content
3. Paste it into the text area
4. Click "Go" to validate
5. Review any errors with specific line numbers

**PowerShell helper to copy content:**
```powershell
# Copy YAML content to clipboard for online validation
Get-Content .gitlab-ci.yml -Raw | Set-Clipboard
Write-Host "YAML content copied to clipboard - paste into yamllint.com" -ForegroundColor Green
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

## Real-World Examples

### Example 1: Unicode Escape Sequences
In our project, the issue manifested as:
```yaml
# Problematic line (line 143)
- echo "AMI_ID=$AMI_ID" \u003e ami-details.env

# Fixed line
- echo "AMI_ID=$AMI_ID" > ami-details.env
```

The `\u003e` Unicode escape sequence was preventing proper shell redirection, causing the entire pipeline to fail with a YAML parsing error.

### Example 2: before_script Configuration Errors
Another common issue encountered:
```yaml
# Problematic configuration - improper nested format
before_script:
    - >
      echo "Starting process";
      echo "Setting variables";

# Fixed configuration - simple array format
before_script:
    - echo "Starting process"
    - echo "Setting variables"
```

Error: `before_script config should be a string or a nested array of strings up to 10 levels deep`

### Example 3: Indentation Issues
```yaml
# Problematic - inconsistent indentation
build-ami:
  stage: build
  timeout: 45m
before_script:  # Wrong indentation level
    - echo "test"

# Fixed - consistent 2-space indentation
build-ami:
  stage: build
  timeout: 45m
  before_script:
    - echo "test"
```

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
