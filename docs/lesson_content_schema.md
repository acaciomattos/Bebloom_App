# Lesson Content JSON Schema

The demo reads lesson content from `assets/content/lessons.json`.

## Root Shape

```json
{
  "modules": [
    {
      "id": "foundations",
      "title": "Foundations",
      "description": "Core beginner structures and study material.",
      "level": "Beginner",
      "lessons": []
    }
  ]
}
```

## Module Fields

- `id`: unique module identifier.
- `title`: module name shown in the UI.
- `description`: short module summary.
- `level`: one of `Beginner`, `Elementary`, `Intermediate`.
- `lessons`: array of lesson objects.

## Lesson Fields

- `id`: unique lesson identifier.
- `moduleId`: parent module identifier.
- `title`: lesson title.
- `level`: one of `Beginner`, `Elementary`, `Intermediate`.
- `skills`: array using `Grammar`, `Vocabulary`, `Speaking`, `Listening`, `Reading`.
- `objectives`: array of learning goals.
- `explanation`: main lesson explanation text.
- `examples`: array of sample sentences or short examples.
- `vocabulary`: array of vocabulary items.
- `exercises`: array of exercise items.

## Vocabulary Item Fields

- `id`: unique vocabulary identifier.
- `word`: target word or phrase.
- `translation`: learner-friendly translation.
- `example`: example sentence.
- `lessonId`: originating lesson identifier.

## Exercise Fields

- `id`: unique exercise identifier.
- `type`: one of `multipleChoice`, `fillBlank`, `openQuestion`.
- `question`: prompt shown to the student.
- `options`: required for `multipleChoice`, optional otherwise.
- `correctAnswer`: canonical correct answer.
- `acceptedAnswers`: optional additional accepted answers for open or fill-blank items.
- `feedback`: feedback text shown after submission.
- `skill`: skill tag such as `Grammar`, `Vocabulary`, `Speaking`, `Listening`, or `Reading`.

## Authoring Notes

- Keep IDs stable so local progress remains valid across app restarts.
- Prefer short explanations and clear examples for demo lessons.
- Add new modules without changing the app structure as long as the same schema is preserved.

