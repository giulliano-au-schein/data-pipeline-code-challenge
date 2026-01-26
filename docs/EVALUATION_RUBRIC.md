# Senior Data Engineer - Evaluation Rubric

## Scoring Guide

- **4 - Exceptional:** Exceeds expectations, demonstrates senior-level expertise
- **3 - Strong:** Meets expectations, solid implementation
- **2 - Adequate:** Basic implementation with room for improvement
- **1 - Needs Work:** Missing key elements or significant issues
- **0 - Not Attempted:** Task not completed

---

## Section 1: Data Quality (25%)

### 1.1 Deduplication Handling (0-4)

| Score | Criteria |
|-------|----------|
| 4 | Identifies duplicate payments proactively, implements robust deduplication with window functions or dbt_utils, documents approach |
| 3 | Handles duplicates correctly, uses standard deduplication pattern |
| 2 | Notices duplicates but implementation has edge cases |
| 1 | Partially handles duplicates or misses the issue |
| 0 | Does not address duplicate payments |

**Candidate Score:** ___ / 4

**Notes:**
```




```

### 1.2 NULL Handling & Data Validation (0-4)

| Score | Criteria |
|-------|----------|
| 4 | Comprehensive NULL handling with COALESCE/NULLIF, business-appropriate defaults, documented decisions |
| 3 | Good NULL handling for most fields |
| 2 | Basic NULL handling, some inconsistencies |
| 1 | Minimal attention to NULLs |
| 0 | NULLs not addressed |

**Candidate Score:** ___ / 4

### 1.3 Testing Coverage (0-4)

| Score | Criteria |
|-------|----------|
| 4 | Comprehensive tests: uniqueness, not_null, relationships, custom business rules, freshness |
| 3 | Good test coverage on key models and columns |
| 2 | Basic tests on primary keys only |
| 1 | Few or inadequate tests |
| 0 | No tests implemented |

**Candidate Score:** ___ / 4

---

## Section 2: Pipeline Design (25%)

### 2.1 Idempotency (0-4)

| Score | Criteria |
|-------|----------|
| 4 | Pipeline can run multiple times safely, handles all edge cases, explains approach |
| 3 | Good idempotency design, minor edge cases |
| 2 | Basic idempotency but some issues |
| 1 | Pipeline has idempotency problems |
| 0 | Not idempotent |

**Candidate Score:** ___ / 4

### 2.2 Incremental Loading (0-4)

| Score | Criteria |
|-------|----------|
| 4 | Proper incremental models with appropriate unique_key and merge strategy, handles late-arriving data |
| 3 | Good incremental implementation |
| 2 | Basic incremental but missing edge cases |
| 1 | Attempted but flawed implementation |
| 0 | All full refreshes |

**Candidate Score:** ___ / 4

### 2.3 Error Handling (0-4)

| Score | Criteria |
|-------|----------|
| 4 | Comprehensive error handling: retries, alerting, data quality gates, graceful failures |
| 3 | Good error handling in DAG |
| 2 | Basic error handling |
| 1 | Minimal error consideration |
| 0 | No error handling |

**Candidate Score:** ___ / 4

---

## Section 3: Code Quality (20%)

### 3.1 dbt Best Practices (0-4)

| Score | Criteria |
|-------|----------|
| 4 | Follows all dbt conventions: CTEs, naming, ref(), source(), macros where appropriate |
| 3 | Good adherence to best practices |
| 2 | Some best practices followed |
| 1 | Inconsistent practices |
| 0 | Poor code structure |

**Candidate Score:** ___ / 4

### 3.2 Documentation (0-4)

| Score | Criteria |
|-------|----------|
| 4 | Excellent docs: model descriptions, column descriptions, documented decisions and trade-offs |
| 3 | Good documentation on key models |
| 2 | Basic documentation |
| 1 | Minimal documentation |
| 0 | No documentation |

**Candidate Score:** ___ / 4

### 3.3 Modularity & Reusability (0-4)

| Score | Criteria |
|-------|----------|
| 4 | Well-organized project structure, reusable macros, clear separation of concerns |
| 3 | Good organization |
| 2 | Adequate structure |
| 1 | Poor organization |
| 0 | No structure |

**Candidate Score:** ___ / 4

---

## Section 4: Problem-Solving (15%)

### 4.1 Data Discovery Process (0-4)

| Score | Criteria |
|-------|----------|
| 4 | Thoroughly explores data before coding, identifies issues proactively, asks clarifying questions |
| 3 | Good exploration process |
| 2 | Some exploration but misses issues |
| 1 | Minimal exploration |
| 0 | Jumps straight to coding |

**Candidate Score:** ___ / 4

### 4.2 Debugging Approach (0-4)

| Score | Criteria |
|-------|----------|
| 4 | Systematic debugging: isolates issues, uses logs effectively, validates assumptions |
| 3 | Good debugging skills |
| 2 | Eventually solves issues but inefficiently |
| 1 | Struggles with debugging |
| 0 | Cannot debug effectively |

**Candidate Score:** ___ / 4

---

## Section 5: System Design (15%)

### 5.1 Scalability Considerations (0-4)

| Score | Criteria |
|-------|----------|
| 4 | Discusses partitioning, clustering, incremental strategies, knows when to optimize |
| 3 | Good scalability awareness |
| 2 | Basic understanding |
| 1 | Limited scalability thinking |
| 0 | No scalability consideration |

**Candidate Score:** ___ / 4

### 5.2 Production Readiness (0-4)

| Score | Criteria |
|-------|----------|
| 4 | Considers monitoring, alerting, runbooks, SLAs, failure modes |
| 3 | Good production thinking |
| 2 | Some production considerations |
| 1 | Minimal production awareness |
| 0 | No production thinking |

**Candidate Score:** ___ / 4

---

## Final Score Calculation

| Section | Weight | Score (0-4) | Weighted |
|---------|--------|-------------|----------|
| Data Quality | 25% | ___ | ___ |
| Pipeline Design | 25% | ___ | ___ |
| Code Quality | 20% | ___ | ___ |
| Problem-Solving | 15% | ___ | ___ |
| System Design | 15% | ___ | ___ |
| **TOTAL** | **100%** | | **___** |

### Score Interpretation

| Score Range | Recommendation |
|-------------|----------------|
| 3.5 - 4.0 | Strong Hire |
| 3.0 - 3.4 | Hire |
| 2.5 - 2.9 | Lean Hire (with reservations) |
| 2.0 - 2.4 | Lean No Hire |
| < 2.0 | No Hire |

---

## Interviewer Notes

### Strengths Observed:
```




```

### Areas for Development:
```




```

### Communication & Collaboration:
```




```

### Overall Recommendation:

[ ] Strong Hire
[ ] Hire
[ ] Lean Hire
[ ] Lean No Hire
[ ] No Hire

**Rationale:**
```




```

---

**Interviewer:** ___________________
**Date:** ___________________
