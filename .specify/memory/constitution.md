<!--
Sync Impact Report
- Version change: 1.0.0 -> 1.1.0
- Modified principles:
  - MVVM and Separation of Concerns -> I. Arquitectura mantenible
  - Offline-First Data -> IV. Funcionamiento offline-first
  - Test-First Quality -> II. TDD obligatorio y V. Calidad y pruebas
  - Secure User Data -> VI. Seguridad y privacidad
  - Observable, Maintainable Delivery -> VII. Documentación y Git
- Added principles: III. SDD antes de implementar; VIII. Alcance y finalización
- Added sections: Migration Mode; Target Technology Stack; Constraints;
  Development Workflow and Quality Gates
- Removed sections: none
- Templates requiring updates:
  - ✅ .specify/templates/plan-template.md
  - ✅ .specify/templates/spec-template.md
  - ✅ .specify/templates/tasks-template.md
- Follow-up TODOs: Ratification date remains unknown and requires project-owner confirmation.
-->

# Daymark Constitution

## Migration Mode

**Mode**: UPGRADE

**Justification**: Daymark is an existing Flutter/Dart application. Work MUST preserve its
repository history and evolve the current codebase incrementally, without rewriting unrelated
functionality or introducing an unapproved backend.

## Core Principles

### I. Arquitectura mantenible
Daymark MUST remain an Android-first application developed with Flutter and Dart. The
architecture MUST use MVVM with Provider and ChangeNotifier. Views MUST focus on presentation
and user interaction; ViewModels MUST own presentation state and actions; repositories MUST
separate data access from presentation; and data sources MUST remain replaceable behind those
repositories. Business rules MUST NOT depend on widgets, Firebase, Firestore, or other
external services. New dependencies MUST be justified in the plan, and unnecessary
complexity MUST be rejected. This preserves testability and keeps the organizer evolvable.

### II. TDD obligatorio
Behavior changes MUST follow Red -> Green -> Refactor. An automated test MUST be written
first and executed before implementation; it MUST fail for the expected reason. The minimum
implementation MUST then be added to make the test pass, followed by refactoring without
breaking the test suite. Contributors MUST NOT claim that a test passes unless that test was
actually executed and passed.

### III. SDD antes de implementar
Before coding, the feature MUST define requirements, user scenarios, acceptance criteria,
edge cases, scope boundaries, and security/privacy implications. The specification, technical
plan, and ordered tasks MUST be reviewed and mutually consistent before implementation.
Requirements, tests, code, and documentation MUST remain traceable and aligned. Scope MUST NOT
expand beyond the approved specification without an explicit rationale and approval.

### IV. Funcionamiento offline-first
Local operations MUST work without Internet access. Local persistence MUST be the primary
on-device source of truth, and remote synchronization MUST be decoupled from local use.
Conflict resolution, synchronization errors, retry behavior, and pending changes MUST have
defined behavior before synchronization is implemented. Firebase, Firestore, and any definitive
remote database MUST NOT be added until their implementation is part of an approved
specification and plan.

### V. Calidad y pruebas
Changed Dart code MUST be formatted with `dart format`. The project MUST remain free of
static-analysis errors under `flutter analyze`, and applicable tests MUST be run with
`flutter test`. Bug fixes MUST include regression tests. Features MUST cover empty, loading,
error, success, and relevant boundary states. A task MUST NOT be considered complete when
these checks or the feature's acceptance criteria remain unverified.

### VI. Seguridad y privacidad
Secrets, credentials, private keys, and service-account material MUST NOT enter the repository.
When authentication is introduced, every user's data MUST be isolated by authenticated user ID.
Private note content and credentials MUST NOT be logged. Before implementing remote
synchronization, the specification MUST define logout behavior and the treatment of local
changes that remain unsynchronized.

### VII. Documentación y Git
Technical documentation and README guidance MUST remain aligned with delivered behavior.
Significant architectural decisions MUST be recorded in `docs/decisions/`. Changes MUST be
small, focused, and represented by descriptive commits. Generated artifacts, local databases,
build output, and secrets MUST NOT be committed. Unrelated changes MUST NOT be included in an
approved feature.

### VIII. Alcance y finalización
Implementation MUST be limited to functionality approved in the current specification. A task
is complete only after its automated tests and acceptance criteria have been verified. The
completion report MUST identify changed files, commands executed, results, and remaining
limitations. Unverified claims of completion are non-compliant.

## Target Technology Stack

| Component | Target Version | Notes |
|-----------|----------------|-------|
| Language | Dart SDK 3.13.5 or compatible | Version constrained by `pubspec.yaml` |
| Framework | Flutter | Android-first; other platforms remain supported by the project |
| State management | Provider and ChangeNotifier | Required MVVM presentation boundary |
| Local persistence | Drift and SQLite | Must remain local-first when persistence is added |
| Authentication | Firebase Authentication | Only after an approved specification |
| Remote synchronization | Cloud Firestore | Only after an approved specification |
| Testing and analysis | `flutter test`, `flutter analyze`, `dart format` | Required quality gates |

## Constraints

- Local behavior MUST NOT require network access.
- Business rules MUST remain independent of Flutter widgets and external services.
- Firebase, Firestore, and a definitive remote database are out of scope until explicitly
  approved by specification and plan.
- Dependency additions MUST include need, alternatives considered, and impact in the plan.
- Platform-specific code MUST be limited to capabilities unavailable through Flutter.
- Repository and project conventions MUST be reused unless a documented exception is approved.

## Development Workflow and Quality Gates

1. Create or update the feature specification before implementation.
2. Complete the plan's Constitution Check before research and repeat it after design.
3. Create ordered tasks with explicit dependencies; put failing tests before behavior code.
4. Implement only the approved scope and record intentional exceptions in Complexity Tracking.
5. Run `dart format`, `flutter analyze`, and `flutter test` as applicable before completion.
6. Update documentation and architectural decision records when behavior or design changes.
7. Report the changed files, commands, results, and remaining limitations.

## Governance

This constitution is the highest-level governance document for Daymark feature specification,
planning, implementation, review, and completion. When another project practice conflicts with
it, the conflict MUST be resolved in favor of this constitution or recorded as an approved
exception.

Amendments MUST include a rationale, an updated Sync Impact Report, a semantic version change,
and a review of dependent templates and project guidance. MAJOR increments are required for
removing or redefining a principle. MINOR increments are required for adding a principle,
mandatory section, or materially stronger rule. PATCH increments are reserved for
non-semantic clarifications.

Every plan and implementation review MUST include a Constitution Check. Compliance MUST be
re-evaluated after design and before completion. Exceptions MUST identify the affected rule,
reason, rejected simpler alternative, mitigation, and follow-up owner.

**Version**: 1.1.0 | **Ratified**: TODO(RATIFICATION_DATE): confirm original adoption date | **Last Amended**: 2026-10-15
