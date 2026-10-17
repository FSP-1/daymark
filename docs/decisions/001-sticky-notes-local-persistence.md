# Decision 001: Local persistence for Sticky Notes

## Status

Accepted

## Decision

Sticky Notes uses Drift over SQLite as its local source of truth, behind a repository
interface. The application does not use authentication, Firebase, Firestore, remote
databases, or synchronization for this feature.

## Rationale

The feature must work offline and preserve notes across application restarts. Drift provides
typed SQLite access and an isolated database construction path for tests while keeping
persistence details out of the domain and presentation layers.

## Alternatives rejected

- In-memory state cannot preserve notes across restarts.
- A key-value preference store is not appropriate for a structured notes collection or
  deterministic persistence-failure tests.
- Remote storage and synchronization violate the approved feature scope and offline-first
  constraints.
