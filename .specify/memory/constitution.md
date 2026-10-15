<!--
Sync Impact Report
- Version change: uninitialized template -> 1.0.0
- Modified principles: placeholder principles -> MVVM and Separation of Concerns; Offline-First
  Data; Test-First Quality; Secure User Data; Observable, Maintainable Delivery
- Added sections: Technology and Architecture Constraints; Development Workflow and Quality Gates
- Removed sections: none
- Templates requiring updates:
  - ✅ .specify/templates/spec-template.md
  - ✅ .specify/templates/tasks-template.md
  - ✅ .specify/templates/plan-template.md (existing Constitution Check retained and aligned)
- Follow-up TODOs: Ratification date is unknown and is marked below for project-owner confirmation.
-->

# Daymark Constitution

## Core Principles

### I. MVVM and Separation of Concerns
Daymark MUST use MVVM with Provider and ChangeNotifier. Views MUST remain focused on
presentation and user interaction. ViewModels MUST own presentation state and actions.
Repositories MUST abstract persistence and synchronization. Business rules MUST remain
independent of Flutter widgets and Firebase so they can be tested without a UI or network.
This separation keeps the Android-first organizer maintainable and testable as features grow.

### II. Offline-First Data
User-facing note, task, important-date, and reminder operations MUST work without network
access. Local persistence MUST be the first source of truth for writes and reads, using Drift
and SQLite where persistence is required. Remote synchronization through Cloud Firestore MUST
be additive and recoverable: transient network failures MUST NOT discard accepted local
changes or block ordinary local use.

### III. Test-First Quality
Every behavior change MUST begin with an automated test that fails for the intended reason,
then be implemented minimally and refactored while the tests remain green. Changes MUST
cover relevant loading, empty, success, and error states. A change is not complete until
`dart format`, `flutter analyze`, and `flutter test` have been run as applicable, and no
new failures are introduced. Tests are the executable definition of acceptance behavior.

### IV. Secure User Data
Authentication MUST use Firebase Authentication as the identity boundary, with email/password
and Google sign-in supported where the feature requires them. User-owned data MUST be
scoped by the authenticated user ID in every local synchronization and Firestore access path.
Client-side checks MUST NOT substitute for Firebase Security Rules. Passwords, credentials,
private keys, note content, and other sensitive data MUST NOT be logged or committed.
Logout and unsynchronized-local-data behavior MUST be specified before implementing
authentication-sensitive features.

### V. Observable, Maintainable Delivery
Features MUST use existing project patterns and the smallest dependency set that satisfies
the requirement; new packages require justification in the implementation plan. Errors MUST
be surfaced through the project’s established notification or error-state patterns rather
than silently ignored. Significant architectural decisions and user-visible behavior MUST
be documented in the relevant README or `docs/decisions/` artifact. Generated files, local
databases, build output, and secrets MUST remain out of commits.

## Technology and Architecture Constraints

- The application is a Flutter/Dart Android-first personal organizer; platform-specific
  code MUST be introduced only when Flutter cannot provide the required capability.
- The architecture MUST preserve MVVM, Provider/ChangeNotifier, repository boundaries,
  Drift/SQLite local persistence, Firebase Authentication, and Cloud Firestore synchronization.
- Implementations MUST preserve the offline-first contract and MUST avoid putting business
  rules directly in widgets or Firebase callbacks.
- The project MUST continue using the repository’s configured analyzer and lint rules unless
  a documented, reviewed exception is necessary.

## Development Workflow and Quality Gates

1. A feature specification MUST state user scenarios, acceptance scenarios, edge cases,
   functional requirements, measurable success criteria, and security/privacy implications.
2. An implementation plan MUST include a Constitution Check covering architecture,
   offline behavior, testing, data isolation, and documentation impact.
3. Tasks MUST be ordered by dependency and grouped by independently testable user story.
   Behavior tasks MUST include a failing test before implementation tasks.
4. Before review, contributors MUST run formatting, static analysis, and the applicable test
   suite. Reviewers MUST reject changes that bypass repository boundaries, weaken user-data
   isolation, or leave error paths untested.
5. Any intentional constitution violation MUST be recorded in the plan’s Complexity Tracking
   table with the rejected simpler alternative and an owner for remediation.

## Governance

This constitution is the highest-level project governance document for feature planning and
implementation. When another practice conflicts with it, the conflict MUST be resolved in
favor of this constitution or explicitly recorded as an approved exception.

Amendments require a documented rationale, an updated Sync Impact Report, a semantic version
change, and review of all dependent Spec Kit templates and project guidance. A MAJOR version
is required for removing or redefining a principle; a MINOR version is required for adding
or materially expanding a principle or mandatory section; a PATCH version is required for
clarifications and non-semantic wording changes.

Every feature plan and implementation review MUST include a Constitution Check. Compliance
MUST be re-evaluated after design and before completion. Exceptions MUST be explicit,
time-bounded where possible, and accompanied by a mitigation or follow-up task.

**Version**: 1.0.0 | **Ratified**: TODO(RATIFICATION_DATE): confirm original adoption date | **Last Amended**: 2026-10-15
