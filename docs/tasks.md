## Task specifications

- TOC
{:toc}

### Cloze test

One segment of text is shown at a time, with a blank which has to be filled in by one of the options provided.

- Identifier: `cloze`
- Implementation: [`lib/src/tasks/cloze.dart`](https://github.com/saeub/okra/blob/main/lib/src/tasks/cloze.dart)
- Data structure:
  ```json
  {
    "segments": [
      {
        "text": "This is an .",
        "blankPosition": 11,
        "options": ["example", "text", "pineapple"],
        "correctOptionIndex": 0
      },
      {
        "text": "Segment without blanks."
      },
      ...
    ]
  }
  ```
  **NOTE:** There can be at most one blank per segment. Only the first double brackets in the segment will replaced by the blank. `correctOptionIndex` is optional. If it is provided, the participant will get immediate feedback about the correctness after confirming their answer.
- Results data structure:
  ```json
  {
    "chosenOptionIndices": [0, null, ...]
  }
  ```
  **NOTE:** An index of `null` means that there was no blank in this segment.

### Digit span

A random sequence of digits is presented one digit at a time, and the participant is asked to type the sequence from memory. If the sequence was typed correctly, the next sequence will be one digit longer. The task ends after some number of errors has been made.

- Identifier: `digit-span`
- Implementation: [`lib/src/tasks/digit_span.dart`](https://github.com/saeub/okra/blob/main/lib/src/tasks/digit_span.dart)
- Data structure:
  ```json
  {
    "excludeDigits": ["0", "7"],
    "initialLength": 3,
    "maxErrors": 2,
    "secondsShowingDigit": 1.0,
    "secondsBetweenDigits": 2.0
  }
  ```
  **NOTE:** `excludeDigits`, `initialLength`, and `maxErrors` are optional. By default, all digits from 0 to 9 are included, the initial sequence length is 3, and the task ends after 2 failed trials. `secondsShowingDigit` and `secondsBetweenDigits` are optional and default to `0.5` and `1.5`, respectively.
- All results are included in the event logs. The results data is empty.

### Lexical decision

One word is shown at a time. The task is to determine whether it is a real word or a non-word. Similar to the original experiment described by [Meyer and Schvaneveldt (1971)](https://psycnet.apa.org/doi/10.1037/h0031564), but showing single words instead of word pairs (though the task implementation allows newlines in words to display pairs).

- Identifier: `lexical-decision`
- Implementation: [`lib/src/tasks/lexical_decision.dart`](https://github.com/saeub/okra/blob/main/lib/src/tasks/lexical_decision.dart)
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
    "durations": [0.123, 1.234, ...]
  }
  ```
  **NOTE:** Durations are in seconds.

### _n_-back

A single textual stimulus (usually a letter) is shown for 500 milliseconds with 2500 milliseconds between stimuli (these durations can be configured to different values). The participant taps the screen whenever they see the same stimulus as _n_ stimuli back (a "positive" stimulus). Immediate positive or negative feedback is shown after each tap. The sequence of stimuli is randomly generated before each task.

- Identifier: `n-back`
- Implementation: [`lib/src/tasks/n_back.dart`](https://github.com/saeub/okra/blob/main/lib/src/tasks/n_back.dart)
- Data structure:
  ```json
  {
    "n": 2,
    "stimulusChoices": ["A", "B", "C", ...],
    "nStimuli": 20,
    "nPositives": 5,
    "secondsShowingStimulus": 1.0,
    "secondsBetweenStimuli": 2.0
  }
  ```
  **NOTE:** `secondsShowingStimulus` and `secondsBetweenStimuli` are optional and default to `0.5` and `1.5`, respectively.
- Results data structure:
  ```json
  {
    "nTruePositives": 3,
    "nFalsePositives": 1
  }
  ```

### Picture naming

A textual stimulus is shown above a number of pictures. One of the pictures (or optionally a question mark, meaning "don't know") has to be selected.

- Identifier: `picture-naming`
- Implementation: [`lib/src/tasks/picture_naming.dart`](https://github.com/saeub/okra/blob/main/lib/src/tasks/picture_naming.dart)
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

A text is presented, and several single-answer multiple-choice questions have to be answered. On smaller screen sizes, the question panel is expandable and collapsible from the bottom of the screen. On larger screen sizes, it is constantly visible side-by-side with the text. There are two modes of text presentation: `normal`, where all text is presented at once on a single screen, and `self-paced`, where two segments of text are shown at once and the participant advances by tapping the screen.

**NOTE:** The `self-paced` reading type is currently neither optimized nor well tested. At the moment, using it for smaller screen sizes is a bad idea.

- Identifier: `question-answering`
- Implementation: [`lib/src/tasks/question_answering.dart`](https://github.com/saeub/okra/blob/main/lib/src/tasks/question_answering.dart)
- Data structure:
  ```json
  {
    "readingType": "self-paced",
    "text": "First segment.\nSecond segment.",
    "fontSize": 25.0,
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
    ],
    "ratingsBeforeQuestions": [
      {
        "question": "How easy was it?",
        "type": "emoticon",
        "lowExtreme": "very difficult",
        "highExtreme": "very easy"
      }
    ]
  }
  ```
  **NOTE:** In the `normal` reading type, the string is interpreted as Markdown, while in the `self-paced` reading type, every line (separated by `\n`) is interpreted as a plain-text segment. `fontSize` is optional and specifies the font size of the text (not the questions; default is 16.0). `correctAnswerIndex` is optional. If it is provided, the participant will get immediate feedback about the correctness after confirming their answer. `ratingsBeforeQuestions` is optional. If it is provided, the text is shown without questions in the beginning, followed by the specified ratings, followed by the text with questions visible. They follow the same format as the ratings at the end of the task (described in the [API specs](api/index.html)).
- Results data structure:
  ```json
  {
    "chosenAnswerIndices": [0, -1, ...],
    "ratingsBeforeQuestionsAnswers": [3]
  }
  ```

### Reaction time

A single picture of a red balloon is shown at a time, which disappears with a popping animation as soon as it is being touched. A new one then appears in a (uniformly distributed) random location after a configurable amount of time.

- Identifier: `reaction-time`
- Implementation: [`lib/src/tasks/reaction_time.dart`](https://github.com/saeub/okra/blob/main/lib/src/tasks/reaction_time.dart)
- Data structure:
  ```json
  {
    "nStimuli": 20,
    "minSecondsBetweenStimuli": 0,
    "maxSecondsBetweenStimuli": 1.5
  }
  ```
  **NOTE:** `nStimuli` does not include an introductory stimuli, which is already shown when starting the task. If `minSecondsBetweenStimuli` is smaller than `maxSecondsBetweenStimuli`, a (uniformly distributed) random number between them is generated after each stimulus.
- Results data structure:
  ```json
  {
    "reactionTimes": [0.123, 1.234, ...]
  }
  ```
  **NOTE:** Reaction times are in seconds. The reaction time for the introductory stimulus is not included.

### Reading

A text is presented (optionally with a preceding introductory text for context), followed by a series of ratings, followed by a number of single-answer multiple-choice questions to be answered. The questions are shown on the same screen as the text. The text is scrollable, and scrolling events are logged such that the visible range of text at each point in time can be reconstructed.

**NOTE:** On smaller screen sizes, the entire text box (including the font size) is scaled down in order to preserve the number of characters per line across devices.

- Identifier: `reading`
- Implementation: [`lib/src/tasks/reading.dart`](https://github.com/saeub/okra/blob/main/lib/src/tasks/reading.dart)
- Data structure:
  ```json
  {
    "intro": "This is to provide some *context*.",
    "text": "This is an example text.",
    "textWidth": 300,
    "textHeight": 200,
    "fontSize": 25.0,
    "ratings": [
      {
        "question": "How easy was it?",
        "type": "emoticon",
        "lowExtreme": "very difficult",
        "highExtreme": "very easy"
      },
      ...
    ],
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
    ],
  }
  ```
  **NOTE:** `intro` is an optional text in Markdown to be shown before the actual text. `fontSize` is optional and specifies the font size of the text (not the questions; default is 20.0). `questions` is optional. If it is not provided, the questions stage is skipped. `ratings` is optional. If it is not provided, the ratings stage is skipped. Ratings follow the same format as the ratings at the end of the task (described in the [API specs](api/index.html)). `correctAnswerIndex` is optional. If it is provided, the participant will receive feedback and are required to correct their answers. 
- All results are included in the event logs. The results data is empty.

### Simon game

Four buttons are shown. They light up in a specific sequence, which has to be repeated by pressing the buttons in the same order. After each successful repetition, a random item is added to the sequence, and the sequence is shown again. Inspired by the electronic game [Simon](https://en.wikipedia.org/wiki/Simon_(game)).

- Identifier: `simon-game`
- Implementation: [`lib/src/tasks/simon_game.dart`](https://github.com/saeub/okra/blob/main/lib/src/tasks/simon_game.dart)
- Data structure: (no data)
- Results data structure:
  ```json
  {
    "maxCorrectItems": 7
  }
  ```

### Trail making

Circular buttons with numbers or letters are presented, which have to be connected in the correct order by tapping on them. In a variation of the task, the buttons have different colors and have to be connected in a trail of alternating colors (e.g. `black 1` → `white 2` → `black 3` → ...), avoiding distractors (cf. [Kim et al., 2014](https://doi.org/10.1371/journal.pone.0089078)).

- Identifier: `trail-making`
- Implementation: [`lib/src/tasks/trail_making.dart`](https://github.com/saeub/okra/blob/main/lib/src/tasks/trail_making.dart)
- Data structure:
  ```json
  {
    "stimuli": ["1", "2", "3", "4", "5", "6"],
    "colors": ["FFFFFF", "000000"],
    "nDistractors": 4,
    "gridWidth": 5,
    "gridHeight": 7,
    "jiggle": true,
    "randomSeed": 42
  }
  ```
  **NOTE:** `colors` is optional and specifies the alternating colors of the buttons. `nDistractors` is only allowed when there are at least 2 `colors` and specifies the number of distractor buttons (same stimuli, but wrong color). `gridWidth`, `gridHeight`, `jiggle`, and `randomSeed` are all optional and influence random generation of stimulus positions and distractors.
- All results are included in the event logs. The results data is empty.
