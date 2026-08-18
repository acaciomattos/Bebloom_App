# English Tutor Demo MVP Scope

## Goal

Deliver a first Android demo in Flutter that helps English students access lesson material, study independently, answer simple exercises, and monitor study progress locally on device.

## Included in This Demo

- Home screen with greeting, continue studying shortcut, lesson library entry, and progress entry.
- Lesson library organized by modules and lessons.
- Filtering and visual signaling by level and skill.
- Lesson detail screen with:
  - title;
  - level;
  - objectives;
  - explanation;
  - examples;
  - related vocabulary;
  - exercises;
  - complete lesson action.
- Exercise support for:
  - multiple choice;
  - fill in the blank;
  - simple open question;
  - instant feedback after submission.
- Local progress tracking for:
  - completed lessons;
  - exercise answers;
  - correct answers;
  - last opened lesson;
  - saved vocabulary.
- Vocabulary area with saved words and phrases from lessons.
- Avatar placeholder implemented as a lightweight visual component ready to be replaced later.
- Content loaded from local JSON in assets.
- Local persistence using SharedPreferences.

## Explicitly Out of Scope

- Real login or authentication.
- Backend or cloud sync.
- Payments or subscription logic.
- External APIs.
- Firebase.
- Conversational AI.
- Speech AI correction.
- 3D avatar.
- Voice avatar.
- Teacher dashboard.

## Product Principles

- Keep the code modular and readable.
- Prefer a working demo over premature abstraction.
- Avoid dead code and unnecessary infrastructure.
- Keep content authoring simple through local JSON assets.

