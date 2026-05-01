# AGENTIC_AI_USAGE.md

## AI Usage & Agent Workflow

## Overview

I used AI (Claude) as a **structured engineering assistant**, not as a code generator.

The goal was to:
- maintain full control over architecture and decisions
- use AI to accelerate execution
- enforce a disciplined, step-by-step workflow

---

## Process I Followed

1. **Specification First**
   - Created `Spec/PRODUCT_SPEC.md` to clearly define requirements, constraints, and expectations

2. **Planning Before Coding**
   - Prompted AI to propose a full implementation plan
   - Explicitly prevented code generation at this stage

3. **Task-Based Execution**
   - Converted the plan into a strict task system (`tasks/MASTER_TASK.md`)
   - Broke work into small, reviewable tasks
   - Enforced: one task at a time, with approval gates

4. **Controlled Implementation**
   - Each task executed in isolation
   - AI was not allowed to jump ahead or redesign

5. **Continuous Review & Correction**
   - Every output was reviewed
   - Corrections were tracked in `Agents Doc/AGENT_REVIEW.md`

---

## What I Used AI For

- Architecture design and refinement
- Task decomposition
- Implementing isolated tasks
- Identifying edge cases (pagination, offline behavior)
- Maintaining consistency across layers

---

## What I Did NOT Use AI For

- Generating the entire app in one go
- Making architectural decisions without constraints
- Modifying the plan after approval
- Skipping steps or merging tasks

---

## How I Prompted AI (Examples)

### Planning Phase

You are an iOS senior engineer.

DO NOT write code.

Read Spec/PRODUCT_SPEC.md and propose:
- architecture
- pagination strategy
- offline strategy
- error handling

### Task Execution

Read tasks/MASTER_TASK.md.

Execute ONLY the NEXT task.
Stay within scope.
Do not anticipate future tasks.

### Correction Loop

Apply ONLY these corrections.
Do not redesign the plan.
Update Agents Doc/AGENT_REVIEW.md with:
- mistake
- location
- fix

---

## How I Challenged AI (Concrete Examples)

I actively reviewed and corrected AI output. Some examples:

### 1. Clean Architecture Violation (Mapping Layer)

- AI initially suggested mapping inside domain models  
- This would make Domain depend on Data layer (wrong direction)

Fix:
- Moved all mapping to Data/Mappers/
- Repository handles conversion

---

### 2. Incorrect Offline Strategy (Data Loss Risk)

- Initial approach implied clearing cache before fetch

Fix:
- Fetch first, then replace only on success  
- Preserve cached data on failure

---

### 3. Over-Engineering the Domain Layer

- AI introduced unnecessary TransactionPage model

Fix:
- Removed it  
- Kept pagination state in ViewModel

---

## Continuous Improvement Log

All corrections and decisions were tracked in:

`Agents Doc/AGENT_REVIEW.md`

This file documents:
- mistakes identified
- where they occurred
- applied fixes
- lessons learned

---

## Key Principle

I treated AI as:

a fast but junior engineer that needs constraints, guidance, and review

---

## Outcome

- Clear, interview-ready architecture
- Controlled and traceable development process
- Strong handling of edge cases
- No over-engineering

---

## Summary

AI improved speed, but quality came from structure and review.

The most important part was not using AI — it was how I controlled it.
