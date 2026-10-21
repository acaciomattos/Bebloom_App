# Domain And API Contracts

## Status And Purpose

This document defines the future server-facing contracts for English Tutor.
It does not introduce a backend, authentication, network calls, or cloud sync
in the current demo.

The Flutter app currently stores a simplified `StudentProgress` record only on
the device. The contracts below preserve those learning concepts while making
them attributable to an authenticated account when a backend is introduced.

## Identity And Roles

### User

```json
{
  "id": "usr_01J...",
  "displayName": "Ana Silva",
  "email": "ana@example.com",
  "role": "student",
  "createdAt": "2026-09-15T12:00:00Z",
  "updatedAt": "2026-09-15T12:00:00Z"
}
```

- `id`: immutable server-generated user identifier.
- `role`: `student` or `tutor` in the first authenticated release.
- `email`: unique account identifier, managed by the authentication provider.
- Dates use ISO 8601 in UTC.

The authenticated session determines the active user. The app must not trust a
user ID sent by the client as authorization to read or modify another user's
data.

### TutorStudentRelationship

```json
{
  "id": "rel_01J...",
  "tutorId": "usr_01J9A...",
  "studentId": "usr_01J8B...",
  "status": "active",
  "linkedAt": "2026-09-15T12:00:00Z",
  "endedAt": null
}
```

- `status`: `active` or `inactive`.
- A tutor may view only students connected through an active relationship.
- A student may view only their own learning data.
- The tutor dashboard belongs to the same app, but is shown only after the
  authenticated role and relationship permissions have been verified.

## Learning Content

Course modules, lessons, vocabulary, and exercises remain teacher-managed
content. Their existing stable IDs in `assets/content/lessons.json` become the
references used by progress records.

- A lesson belongs to one module.
- Vocabulary and exercises belong to one lesson.
- Content IDs must never be reused for different pedagogical content.
- Content can later be delivered by a teacher-content API without changing the
  progress contract.

## Schema Keys And Relationships

The schemas below are logical contracts. `PK` identifies the record uniquely;
`FK` references the primary key in another schema. IDs are opaque strings and
their values do not encode the user role or other business meaning.

| Schema | Primary key | Relationship keys | Relationship |
| --- | --- | --- | --- |
| `users` | `id` | None | One user account, with one role in the first release. |
| `tutor_student_relationships` | `id` | `tutorId` -> `users.id`; `studentId` -> `users.id` | Connects one tutor to one student. The pair (`tutorId`, `studentId`) must be unique while the relationship is active. |
| `course_modules` | `id` | None | One module contains many lessons. |
| `lessons` | `id` | `moduleId` -> `course_modules.id` | Each lesson belongs to one module. |
| `vocabulary_items` | `id` | `lessonId` -> `lessons.id` | Each vocabulary item belongs to one lesson. |
| `exercises` | `id` | `lessonId` -> `lessons.id` | Each exercise belongs to one lesson. In the current asset JSON this is implicit because exercises are nested inside their lesson; it must be explicit when content is stored or served separately. |
| `student_learning_events` | `id` | `studentId` -> `users.id`; `moduleId` -> `course_modules.id`; `lessonId` -> `lessons.id`; `exerciseId` -> `exercises.id`; `vocabularyId` -> `vocabulary_items.id` | Central fact schema for student interactions. Foreign keys are populated when relevant to the event type. |
| `student_progress` | `studentId` | `studentId` -> `users.id`; `lastOpenedLessonId` -> `lessons.id` | One current summary per student. |
| `lesson_completions` | (`studentId`, `lessonId`) | `studentId` -> `users.id`; `lessonId` -> `lessons.id` | Records that a student completed a lesson. |
| `saved_vocabulary` | (`studentId`, `vocabularyId`) | `studentId` -> `users.id`; `vocabularyId` -> `vocabulary_items.id` | Records a vocabulary item saved by a student. |
| `exercise_attempts` | `id` | `eventId` -> `student_learning_events.id`; `studentId` -> `users.id`; `lessonId` -> `lessons.id`; `exerciseId` -> `exercises.id` | Optional detailed read model for exercise-specific queries. Each row corresponds to one `exerciseAnswered` event. |

`student_progress.completedLessonIds` and
`student_progress.savedVocabularyIds` are convenient API summary fields. In a
database-oriented backend, their source records are respectively
`lesson_completions` and `saved_vocabulary`; the API may aggregate them into
the progress response.

Relationship overview:

```text
users.id --< tutor_student_relationships.tutorId
users.id --< tutor_student_relationships.studentId
course_modules.id --< lessons.moduleId
lessons.id --< vocabulary_items.lessonId
lessons.id --< exercises.lessonId
users.id --< student_learning_events.studentId
course_modules.id --< student_learning_events.moduleId
lessons.id --< student_learning_events.lessonId
exercises.id --< student_learning_events.exerciseId
vocabulary_items.id --< student_learning_events.vocabularyId
users.id --1 student_progress.studentId
users.id --< lesson_completions.studentId >-- lessons.id
users.id --< saved_vocabulary.studentId >-- vocabulary_items.id
student_learning_events.id --1 exercise_attempts.eventId
```

## Central Student Interaction Fact

`student_learning_events` is the fact schema that centralizes a student's
interactions with the app. Each row represents one action at a specific time;
it is append-only and must not be overwritten when the student performs a new
action.

```json
{
  "id": "evt_01J...",
  "studentId": "usr_01J8B...",
  "eventType": "exerciseAnswered",
  "moduleId": "foundations",
  "lessonId": "verb-to-be",
  "exerciseId": "verb-to-be-1",
  "vocabularyId": null,
  "isCorrect": true,
  "occurredAt": "2026-09-15T12:04:00Z",
  "recordedAt": "2026-09-15T12:04:01Z"
}
```

Supported first-release event types:

| `eventType` | Required relationship keys | Purpose |
| --- | --- | --- |
| `lessonOpened` | `studentId`, `lessonId` | Updates the last lesson opened and study history. |
| `lessonCompleted` | `studentId`, `lessonId` | Marks completion of a lesson. |
| `exerciseAnswered` | `studentId`, `lessonId`, `exerciseId` | Stores the answer result in `isCorrect`. |
| `vocabularySaved` | `studentId`, `lessonId`, `vocabularyId` | Adds a vocabulary item to the student's saved list. |
| `vocabularyRemoved` | `studentId`, `lessonId`, `vocabularyId` | Removes a vocabulary item from the student's saved list. |

- `occurredAt`: when the action happened on the device.
- `recordedAt`: when the backend accepted the event. It is generated by the
  server and supports auditing and later synchronization diagnostics.
- `moduleId`: optional because it can be derived from `lessonId`; keeping it on
  the event makes progress reporting faster. The backend must validate that it
  matches the lesson's module.
- `isCorrect`: required only for `exerciseAnswered`; it is `null` for the other
  event types.
- `exerciseId` and `vocabularyId`: `null` unless the event type requires them.

`student_progress`, `lesson_completions`, and `saved_vocabulary` are derived
state schemas. They exist to load the app and tutor dashboard efficiently; they
are not the historical source of truth. In an initial backend, the event and
its affected state can be written in the same database transaction. This does
not require an event bus or a complex event-sourcing implementation.

## Student Learning Data

### StudentProgress

`StudentProgress` is the current summary used to render the learner screens.
It is scoped to one student account.

```json
{
  "studentId": "usr_01J8B...",
  "completedLessonIds": ["verb-to-be"],
  "savedVocabularyIds": ["vocab-be-happy"],
  "lastOpenedLessonId": "verb-to-be",
  "updatedAt": "2026-09-15T12:05:00Z"
}
```

- `studentId`: server-side owner of the progress. It is derived from the
  authenticated session for write operations.
- `completedLessonIds`: lesson IDs explicitly marked as completed.
- `savedVocabularyIds`: vocabulary IDs saved by the student.
- `lastOpenedLessonId`: most recently opened lesson, or `null` before study
  begins.
- `updatedAt`: last server-side update of the summary.

### ExerciseAttempt

The current demo stores only the latest boolean result per exercise. The
server contract retains useful learning history without requiring the raw text
of open responses to be shown to a tutor by default.

```json
{
  "id": "attempt_01J...",
  "studentId": "usr_01J8B...",
  "lessonId": "verb-to-be",
  "exerciseId": "verb-to-be-1",
  "isCorrect": true,
  "answeredAt": "2026-09-15T12:04:00Z"
}
```

- `isCorrect`: result calculated from the version of the exercise that was
  presented to the student.
- `answeredAt`: event timestamp used for progress history and future conflict
  handling.
- Storing `submittedAnswer` is optional and should require a defined product
  purpose, retention period, and access rule. It is not required for the first
  backend release.

## Minimum Server Operations

These are logical operations, not an implementation commitment to REST, GraphQL,
or a particular backend provider.

| Operation | Actor | Access rule |
| --- | --- | --- |
| Read own progress | Student | Own account only |
| Record lesson opened/completed | Student | Own account only |
| Record exercise attempt | Student | Own account only |
| Save or remove vocabulary | Student | Own account only |
| Read assigned student summaries | Tutor | Active tutor-student relationship required |
| Manage course content | Authorized teacher/admin | Not available to students or tutors by default |

The first remote release should support account-based progress recovery after
reinstalling the app or clearing app data. Full simultaneous multi-device sync
is explicitly a later concern.

## Local Cache Transition

`StudentProgressRepository` keeps feature screens and the app controller
independent from the persistence mechanism. `ProgressCache` is the local-cache
contract currently implemented with SharedPreferences. A future repository may
load remote progress, update that cache for offline use, and send learning
changes to the server.

Until authentication and backend work begin, SharedPreferences remains the
only source of progress in the demo and contains no real account identity.

## Current Demo Mapping

| Current local field | Future account-based contract |
| --- | --- |
| `completedLessonIds` | `StudentProgress.completedLessonIds` |
| `exerciseResults` | Latest result summary plus `ExerciseAttempt` history |
| `savedVocabularyIds` | `StudentProgress.savedVocabularyIds` |
| `lastOpenedLessonId` | `StudentProgress.lastOpenedLessonId` |
