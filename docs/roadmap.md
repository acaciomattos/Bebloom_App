# English Tutor Demo Roadmap

## Product And Data Alignment

- The current demo represents a single student studying locally. "English Tutor" is the product name, not a signed-in tutor profile.
- Keep the student experience focused on self-study. A tutor dashboard should be a separate, role-protected experience for viewing assigned students and their progress.
- SharedPreferences remains demo-only local storage. It cannot synchronize progress between devices.
- In the future architecture, local storage is a cache for offline use, not the source of truth. Progress belongs to the authenticated student account and must be restored after reinstalling the app, clearing app data, or signing in on another device.
- Before introducing multi-device use, define backend-neutral contracts for `User`, `TutorStudentRelationship`, and `StudentProgress`.
- Future progress records must include `studentId`, `updatedAt`, and timestamps for relevant learning events, in addition to the current lesson, exercise, and saved-vocabulary identifiers. These fields support synchronization and conflict resolution after offline study on more than one device.
- `StudentProgressRepository` is the persistence boundary used by the app. SharedPreferences is isolated behind `ProgressCache`, so a future remote repository can be introduced without rewriting feature screens.
- The tutor dashboard will be integrated into the same app. It will be available only to authenticated users with the `tutor` role and an authorized view of assigned students.
- Cross-device synchronization and AI-assisted correction are not priorities for the next development phase.

## Next Steps

1. Define the shared domain and API contracts. Completed in `docs/domain_and_api_contracts.md`.
2. Wait for teacher-provided material, then add lessons and modules using it as the content reference.
3. Add login, student/tutor roles, student-tutor relationships, and a role-protected tutor dashboard in the same app.
4. Add a backend for account-based progress recovery and teacher-managed content. Multi-device synchronization can follow later.
5. Add audio and dedicated listening activities when reference material is available.
6. Add speaking recording and playback practice.
7. Evaluate AI-assisted correction only after privacy, terms of use, cost, and token-management requirements are defined.
8. Replace the avatar placeholder with a voice-enabled avatar.
