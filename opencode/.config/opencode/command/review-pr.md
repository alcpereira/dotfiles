---
description: comprehensive multi-agent PR review with consensus analysis
---

You are orchestrating a comprehensive multi-agent code review using 10 independent parallel review sessions with deliberation on outlier findings.

Input: PR number or URL = $ARGUMENTS

---

## Architecture Overview

This review system works in 5 phases:

1. **Spawn Phase**: Launch 10 parallel Task agents, each doing an independent review
2. **Extract Phase**: Parse session IDs and findings from each task output
3. **Aggregate Phase**: Deduplicate findings and calculate consensus levels
4. **Deliberation Phase**: Ask non-detecting sessions about outlier findings
5. **Consolidation Phase**: Present high-confidence vs requires-verification findings

**CRITICAL**: Each phase must complete before moving to the next. Do NOT skip phases.

---

## Phase 1: Spawn 10 Parallel Reviews

Inform the user you're starting a comprehensive review with 10 parallel independent sessions.

**Launch 10 Task tools in parallel** (single response with 10 tool calls):

```
For i=1 to 10:
  task(
    description: "Review session {i}/10"
    prompt: "/review-strict pr $ARGUMENTS

FORBIDDEN: npm, yarn, pnpm, bun, git checkout/commit/push/merge/rebase, gh pr create/merge, Write/Edit tools"
    subagent_type: "general"
  )
```

**Wait for all 10 tasks to complete.** This will take 3-5 minutes.

---

## Phase 2: Extract Session Data

From each of the 10 task outputs, extract:

1. **Session ID**: Look for `<task_metadata>` block:

   ```
   <task_metadata>
   session_id: 01JKHW8...
   </task_metadata>
   ```

   Extract the session ID using pattern: `session_id:\s*([^\s<]+)`

2. **Findings JSON**: Look for JSON code block:
   ```json
   {
     "findings": [...],
     "task_context": {...}
   }
   ```
   Parse the JSON from the markdown code block.

**If a task failed or has no parseable JSON, skip it and note the failure.**

Create an internal data structure:

```javascript
sessions = [
  {
    sessionId: "01JKHW8...",
    sessionNumber: 1,
    findings: [...parsed findings...],
    success: true
  },
  // ... repeat for all 10 sessions
]
```

---

## Phase 3: Aggregate Findings

### Step 3.1: Compute Similarity Hashes

For each finding across all sessions, compute a similarity hash to detect duplicates:

```
similarity_hash = `${file}:${line_start}-${line_end}:${category}`
```

Example: `src/auth.ts:45-47:security`

### Step 3.2: Group by Similarity

Group all findings with the same similarity hash together.

For each unique finding:

- Track which sessions detected it: `detected_by: [sessionId1, sessionId2, ...]`
- Count detection rate: `detection_rate = detected_by.length / total_sessions`
- Calculate consensus level:
  - **unanimous**: detection_rate >= 0.70 (7+ out of 10 sessions)
  - **majority**: detection_rate >= 0.50 and < 0.70 (5-6 sessions)
  - **minority**: detection_rate >= 0.30 and < 0.50 (3-4 sessions)
  - **outlier**: detection_rate < 0.30 (1-2 sessions)

### Step 3.3: Select Representative Finding

For each group, select the finding with the highest confidence score as the representative.

Internal data structure after aggregation:

```javascript
aggregated = [
  {
    ...representative_finding,
    detected_by: [sessionId1, sessionId2],
    detection_rate: 0.2,
    consensus_level: "outlier",
    original_confidence: 0.85,
  },
  // ... more findings
];
```

---

## Phase 4: Deliberation on Low-Consensus Findings

For each finding where `detection_rate < 0.50` (detected by fewer than half the sessions):

This includes:

- **Minority**: 3-4 sessions detected it (30-49%)
- **Outlier**: 1-2 sessions detected it (<30%)

Deliberate on ALL severities (high, medium, low). Low-severity findings dismissed by deliberation can be excluded from final output.

Perform deliberation:

### Step 4.1: Select All Non-Detecting Sessions

From sessions that did NOT detect this outlier finding:

- Select ALL non-detecting sessions (typically 8-9 sessions)
- Get their session IDs

This maximizes statistical validity and leverages all available context.

### Step 4.2: Ask Follow-Up Question in Parallel

For EACH non-detecting session, **continue the existing session** with a follow-up question (run all in parallel):

```
task(
  description: "Deliberation on outlier"
  prompt: "Re-examine:

**File**: {outlier.file}
**Lines**: {outlier.line_start}-{outlier.line_end}
**Code**:
```

{outlier.code_snippet}

````

Session flagged as {outlier.severity} {outlier.category}:
\"{outlier.title}\"

Reasoning: {outlier.description}

Agree? JSON only:
```json
{
  \"position\": \"agree\" | \"disagree\" | \"uncertain\",
  \"reasoning\": \"technical explanation\",
  \"confidence\": 0.8
}
```"
  subagent_type: "general"
  session_id: "{SESSION_ID_FROM_PHASE_2}"
)
````

**IMPORTANT**:

- Use `session_id` parameter to continue the existing review session
- This preserves the session's context from the original review
- The agent will have full context about the PR

### Step 4.3: Parse Deliberation Responses

From each deliberation task output, extract the JSON response.

Count the positions:

- `agrees = responses.filter(r => r.position === "agree").length`
- `disagrees = responses.filter(r => r.position === "disagree").length`
- `uncertain = responses.filter(r => r.position === "uncertain").length`
- `total = agrees + disagrees + uncertain`

### Step 4.4: Enhanced Confidence Adjustment

Calculate agreement rate: `agreement_rate = agrees / total`

Adjust confidence based on agreement rate:

```javascript
if (agreement_rate >= 0.5) {
  // Majority agrees with outlier - upgrade confidence
  confidence_multiplier = 1.3 + (agreement_rate - 0.5); // Range: 1.3 to 1.8
} else if (agreement_rate <= 0.2) {
  // Strong disagreement - significant downgrade
  confidence_multiplier = 0.3;
} else {
  // Weak to moderate disagreement - downgrade
  confidence_multiplier = 0.7 - agreement_rate; // Range: 0.5 to 0.5
}

finding.adjusted_confidence = Math.min(
  1.0,
  original_confidence * confidence_multiplier,
);
```

Add deliberation summary to the finding:

```javascript
finding.deliberation_summary = `${agrees}/${total} agreed, ${disagrees}/${total} disagreed, ${uncertain}/${total} uncertain (${total} sessions consulted)`;
```

### Step 4.5: Reverse Deliberation (Optional)

If `agreement_rate < 0.3` (strong disagreement with the outlier finding):

- Ask the 1-2 sessions that DID detect the issue to justify their reasoning
- Continue those detecting sessions with:

````
task(
  description: "Verify detector reasoning"
  prompt: "You flagged this issue in your review:

**File**: {outlier.file}
**Lines**: {outlier.line_start}-{outlier.line_end}
\"{outlier.title}\"

However, {disagrees}/{total} other sessions disagreed when asked about this specific issue.

Please re-examine your reasoning. Was this a valid finding? Provide JSON:
```json
{
  \"still_valid\": true | false,
  \"justification\": \"detailed explanation of why you flagged this\",
  \"confidence\": 0.8
}
```"
  subagent_type: "general"
  session_id: "{DETECTOR_SESSION_ID}"
)
````

If detector's `still_valid === false` or provides weak justification:

- Further reduce confidence: `adjusted_confidence *= 0.5`

---

## Phase 5: Consolidate & Present

### Step 5.1: Categorize Findings

**High Confidence** (present these as likely real issues):

- `detection_rate >= 0.50` (majority or unanimous: 5+ sessions detected) AND
- `(adjusted_confidence OR confidence) >= 0.7`

**Requires Verification** (present these as "worth investigating"):

- `detection_rate < 0.50` (minority or outlier: <5 sessions detected) AND
- `(adjusted_confidence OR confidence) >= 0.5` (after deliberation adjustment)

**Excluded** (do not show):

- `detection_rate < 0.50` AND `(adjusted_confidence OR confidence) < 0.5` (dismissed by deliberation)
- Any finding with very low confidence regardless of detection rate

### Step 5.2: Sort Findings

Within each category, sort by:

1. Severity (high → medium → low)
2. Confidence (highest → lowest)

---

## Output Format

Present the consolidated findings in this format:

### 🔴 High Confidence Findings

**These findings were detected by multiple independent review sessions:**

For each high-confidence finding:

```
[{SEVERITY}] {file}:{line_start}-{line_end} - {title}

{description}

Suggested fix: {suggested_fix}

📊 Consensus: Detected by {detected_by.length}/10 sessions ({detection_rate * 100}%)
🎯 Confidence: {adjusted_confidence OR confidence}
```

---

### ⚠️ Requires Verification

**These findings were detected by fewer than half the sessions but survived deliberation:**

For each low-consensus finding:

```
[{SEVERITY}] {file}:{line_start}-{line_end} - {title}

{description}

Suggested fix: {suggested_fix}

📊 Consensus: Detected by {detected_by.length}/10 sessions ({detection_rate * 100}%)
🔍 Deliberation: {deliberation_summary}
🎯 Adjusted Confidence: {adjusted_confidence}
```

**Note**: Deliberation summary format: "X/Y agreed, A/Y disagreed, B/Y uncertain (Y sessions consulted)"

---

### 📊 Review Summary

```
✅ Sessions completed: {successful_sessions}/10
📝 Total unique findings: {aggregated.length}
   - High confidence: {high_confidence_count}
   - Requires verification: {requires_verification_count}
   - Excluded (low confidence/severity): {excluded_count}
🤝 Agreement rate: {(unanimous + majority) / total * 100}%
```

---

## Error Handling

- Task fails: Continue with remaining tasks, note in summary
- JSON parsing fails: Skip that session, continue with others
- Deliberation fails: Keep original confidence
- If <7 sessions succeed: Adjust consensus thresholds proportionally

---

## Important Notes

- **Each session is independent**: No cross-contamination of context or findings
- **50% threshold**: Findings detected by <50% of sessions (fewer than 5) undergo full deliberation with all non-detecting sessions
- **Deliberation filters noise**: Low-consensus findings dismissed by deliberation are excluded from output, reducing false positives
- **Consensus builds confidence**: High-confidence findings require 50%+ detection rate AND confidence ≥0.7
- **Reverse verification**: When most sessions disagree, detectors are asked to justify their findings
- **Human review required**: This is a pre-review tool, not a replacement for human judgment
