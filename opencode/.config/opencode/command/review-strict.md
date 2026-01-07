---
description: review PR by number
subtask: true
---

**YOUR ENTIRE RESPONSE MUST BE A SINGLE JSON CODE BLOCK. NO PROSE. NO EXPLANATIONS.**

**FORBIDDEN**: npm, yarn, pnpm, bun, git checkout/commit/push/merge/rebase/reset/add, gh pr create/merge/edit, gh issue create/edit, Write tool, Edit tool

Input: PR number = $ARGUMENTS

---

## Output Format Required

Your response must be ONLY this JSON structure in a markdown code block:

```json
{
  "findings": [
    {
      "file": "src/auth.ts",
      "line_start": 45,
      "line_end": 47,
      "severity": "high",
      "category": "security",
      "title": "Authentication bypass when header is malformed",
      "description": "JWT validation skipped when Authorization header has invalid format. Attacker can send 'Authorization: malformed' to bypass auth - code only checks header presence, not validity.",
      "code_snippet": "if (req.headers.authorization) {\n  return next()\n}",
      "suggested_fix": "Parse and validate JWT: const token = parseJWT(req.headers.authorization); if (!token.valid) throw new AuthError()",
      "confidence": 0.95
    }
  ],
  "task_context": {
    "task_key": "PROJ-123",
    "requirements_met": true,
    "missing_requirements": []
  }
}
```

**Categories**: security, performance, bug, maintainability, best-practice, requirements

If no findings: `{"findings": [], "task_context": null}`

---

## Process

1. `gh pr view $ARGUMENTS` → `gh pr diff $ARGUMENTS`
2. Extract Jira key from PR title/branch/description
3. Fetch Jira task via Atlassian MCP if found
4. Read full modified files (not just diffs)
5. Trace control flow, find similar patterns
6. **Output ONLY the JSON block above**

---

## Review Priorities

**CRITICAL**: Security (auth bypass, injection, data exposure), data corruption, logic errors, missing requirements (if Jira task)
**HIGH**: Error handling issues, performance problems (O(n²), N+1), edge cases
**MEDIUM**: Architecture violations, maintainability issues (nesting 4+, functions >100 lines)
**LOW**: Clear issues only, not style preferences

Use tools (Read, Grep, Explore, Atlassian MCP) to gather context.

---

## Confidence & Severity

Confidence (0-1): 0.9-1.0 definite, 0.7-0.9 very likely, 0.5-0.7 possible, <0.5 don't flag

Severity: **High** = data loss/security/crash, **Medium** = incorrect behavior/performance, **Low** = minor friction

---

## Final Reminder

**Output ONLY the JSON structure shown above. No prose, no summary, no explanations.**
