# Research: Sticky Notes

## Persistence decision

**Decision**: Use Drift backed by SQLite for the local notes store, behind a repository
interface.

**Rationale**:

- The current project has no persistence dependency or existing data layer.
- The Daymark Constitution names Drift and SQLite as the local persistence target and
  requires local-first behavior.
- Drift provides typed queries, durable on-device storage, and testable database
  construction without introducing a remote service.
- A repository boundary keeps validation and business rules independent of Flutter widgets
  and the database implementation.

**Dependencies to justify in the implementation plan**:

- `drift`: runtime typed SQLite access.
- `drift_flutter`: Flutter-compatible database file location and initialization.
- `drift_dev`: generated database code during development.
- `build_runner`: generated code tooling during development.

**Alternatives considered**:

- In-memory state: rejected because it cannot satisfy persistence across application restarts.
- `shared_preferences`: rejected because a structured notes collection and persistence-failure
  testing are better represented by a typed local database, and the Constitution names Drift
  and SQLite.
- Firebase, Firestore, a remote database, or synchronization: rejected because they are
  explicitly out of scope in the specification.

## Existing project findings

- The repository is a Flutter application targeting Android first, with standard platform
  folders and a single `lib/main.dart` entry point.
- The current UI is the default counter sample and does not yet establish application layers.
- `pubspec.yaml` constrains Dart to `^3.13.5`; direct runtime dependencies currently include
  only Flutter and `cupertino_icons`.
- `test/widget_test.dart` contains only the default counter smoke test and must be replaced
  or narrowed so it does not assert removed out-of-scope behavior.
- `analysis_options.yaml` uses `flutter_lints` and excludes generated/platform directories.
- No existing clarification, knowledge graph, data model, contracts, or architecture research
  artifacts were found for this feature.

## Testing decision

Use Flutter's built-in `flutter_test` for unit, repository/database, and widget acceptance
tests. Keep database tests isolated with an in-memory SQLite database or test database
factory, while acceptance tests inject a deterministic repository fake. A platform-level
restart test must use a temporary application database location or an isolated test fixture
so it verifies durable storage without sharing state with other tests.

