## Task specifications

- TOC
{:toc}

### Cloze test

One segment of text is shown at a time, with a blank which has to be filled in by one of the options provided.

- Identifier: `cloze`
- Implementation: [`lib/src/tasks/cloze.dart`](https://github.com/saeub/okra/blob/master/lib/src/tasks/cloze.dart)
- Data structure:
  {% raw %}```json
  {
      "segments": [
          {
              "text": "This is an .",
              "blankPosition": 11,
              "options": ["example", "text", "pineapple"],
              "correctOptionIndex": 0
          },
          {
              "text": "Segment without blanks.",
          },
          ...
      ]
  }
  ```{% endraw %}
  **NOTE:** There can be at most one blank per segment. Only the first double brackets in the segment will replaced by the blank. `correctOptionIndex` is optional. If it is provided, the participant will get immediate feedback about the correctness after confirming their answer.
- Results data structure:
  ```json
  {
      "chosenOptionIndices": [0, null, ...]
  }
  ```
  **NOTE:** An index of `null` means that there was no blank in this segment.

### Lexical decision

One word is shown at a time. The task is to determine whether it is a real word or a non-word. Similar to the original experiment described by [Meyer and Schvaneveldt (1971)](https://psycnet.apa.org/record/1972-04123-001), but showing single words instead of word pairs (though the task implementation allows newlines in words to display pairs).

- Identifier: `lexical-decision`
- Implementation: [`lib/src/tasks/lexical_decision.dart`](https://github.com/saeub/okra/blob/master/lib/src/tasks/lexical_decision.dart)
- Data structure:
  ```json
  {
      "words": ["WORD", "WROD", ...],
      "correctAnswers": [true, false, ...]
  }
  ```
  **NOTE:** `correctAnswers` is optional and must be the same length as `words`. If it is provided, the participant will get immediate feedback about the correctness of their answer.
- Results data structure:
  ```json
  {
      "answers": [true, false, ...],
      "durations": [123, 234, ...]
  }
  ```
  **NOTE:** Durations are in milliseconds.

### Picture naming

A textual stimulus is shown above a number of pictures. One of the pictures (or optionally a question mark, meaning "don't know") has to be selected.

- Identifier: `picture-naming`
- Implementation: [`lib/src/tasks/picture_naming.dart`](https://github.com/saeub/okra/blob/master/lib/src/tasks/picture_naming.dart)
- Data structure:
  ```json
  {
      "showQuestionMark": true,
      "subtasks": [
          {
              "text": "Horse",
              "pictures": [
                  "base64-encoded image",
                  "base64-encoded image",
                  "base64-encoded image"
              ],
              "correctPictureIndex": 0
          },
          ...
      ]
  }
  ```
  **NOTE:** The image should be adequately resized and compressed before encoding, especially for large numbers of subtasks, to keep HTTP response sizes low. `correctPictureIndex` is optional. If it is provided, the participant will get immediate feedback about the correctness after confirming their answer.
- Results data structure:
  ```json
  {
      "chosenPictureIndices": [0, -1, ...]
  }
  ```
  **NOTE:** An index of `-1` means the question mark.

### Question answering

A text is presented, and after reading, several single-answer multiple-choice questions have to be answered. There are two modes of text presentation: `normal`, where all text is presented at once on a single screen, and `self-paced`, where two segments of text are shown at once and the participant advances by tapping the screen.

- Identifier: `question-answering`
- Implementation: [`lib/src/tasks/question_answering.dart`](https://github.com/saeub/okra/blob/master/lib/src/tasks/question_answering.dart)
- Data structure:
  ```json
  {
      "readingType": "self-paced",
      "text": "First segment.\nSecond segment.",
      "questions": [
          {
              "question": "Question?",
              "answers": [
                  "Answer 1",
                  "Answer 2",
              ],
              "correctAnswerIndex": 0
          },
          ...
      ]
  }
  ```
  **NOTE:** In the `normal` reading type, the string is interpreted as Markdown, while in the `self-paced` reading type, every line (separated by `\n`) is interpreted as a plain-text segment. `correctAnswerIndex` is optional. If it is provided, the participant will get immediate feedback about the correctness after confirming their answer.
- Results data structure:
  ```json
  {
      "chosenAnswerIndices": [0, -1, ...]
  }
  ```
