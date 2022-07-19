"""
A simple mock API to use during development.

Requires Python >= 3.7.

To start the server:
- pip install -r requirements.txt
- python api.py

To register with this API in the app, use the following:
- API URL: http://<ip-address>:5000
- Participant ID: mock_participant
- Registration key: mock_regkey

To register from an Android emulator, use 10.0.2.2 as the IP address.
"""

import requests
from flask import Flask, make_response, request

HOST = "0.0.0.0"
PORT = "5000"
PARTICIPANT_ID = "mock_participant"
REGISTRATION_KEY = "mock_regkey"
DEVICE_KEY = "mock_devkey"

EXAMPLE_IMAGE = "/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/2wBDAQkJCQwLDBgNDRgyIRwhMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjL/wAARCAABAAEDASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwD5/ooooA//2Q=="


def example_rating(type: str = "emoticon"):
    return {
        "question": "Question?",
        "type": type,
        "lowExtreme": "bad",
        "highExtreme": "good",
    }


EXPERIMENTS_TASKS = [
    (
        {
            "id": "1",
            "type": "cloze",
            "title": "Cloze task",
            "instructions": "Fill in the blanks.",
            "nTasks": 3,
            "nTasksDone": 2,
            "hasPracticeTask": True,
            "ratings": [example_rating("emoticon")],
        },
        {
            "segments": [
                {
                    "text": "This is an .",
                    "blankPosition": 11,
                    "options": ["example", "text", "pineapple"],
                    "correctOptionIndex": 0,
                },
                {
                    "text": "This is an .",
                    "blankPosition": 11,
                    "options": ["example", "text", "pineapple"],
                },
                {
                    "text": "This is an example.",
                },
            ],
        },
    ),
    (
        {
            "id": "2",
            "type": "digit-span",
            "title": "Digit span",
            "instructions": "",
            "nTasks": 4,
            "nTasksDone": 2,
        },
        {
            "excludeDigits": [0, 7],
            "initialLength": 3,
            "maxErrors": 2,
        },
    ),
    (
        {
            "id": "3",
            "type": "lexical-decision",
            "title": "Lexical decision task",
            "instructions": "Is it a word?",
            "nTasks": 5,
            "nTasksDone": 0,
            "hasPracticeTask": True,
            "ratings": [example_rating("radio")],
        },
        {
            "words": ["EXAMPLE", "EXALMPE", "EXAMPLE"],
            "correctAnswers": [True, False, True],
        },
    ),
    (
        {
            "id": "4",
            "type": "n-back",
            "title": "2-back task",
            "instructions": "Tap the screen if you see the same letter you saw two letters ago.",
            "nTasks": 3,
            "nTasksDone": 2,
        },
        {
            "n": 2,
            "stimulusChoices": ["A", "B", "C"],
            "nStimuli": 15,
            "nPositives": 5,
        },
    ),
    (
        {
            "id": "5",
            "type": "picture-naming",
            "title": "Picture-naming task",
            "instructions": "Choose the matching picture.",
            "nTasks": 4,
            "nTasksDone": 3,
            "ratings": [example_rating("slider")],
        },
        {
            "showQuestionMark": True,
            "subtasks": [
                {
                    "text": "Example",
                    "pictures": [EXAMPLE_IMAGE, EXAMPLE_IMAGE, EXAMPLE_IMAGE],
                    "correctPictureIndex": 0,
                },
                {
                    "text": "Example",
                    "pictures": [EXAMPLE_IMAGE, EXAMPLE_IMAGE, EXAMPLE_IMAGE],
                    "correctPictureIndex": 1,
                },
                {
                    "text": "Example",
                    "pictures": [EXAMPLE_IMAGE, EXAMPLE_IMAGE, EXAMPLE_IMAGE],
                    "correctPictureIndex": 2,
                },
            ],
        },
    ),
    (
        {
            "id": "6",
            "type": "question-answering",
            "title": "Question answering task (normal)",
            "instructions": "Answer the questions.",
            "nTasks": 3,
            "nTasksDone": 1,
            "ratings": [example_rating("emoticon-reversed"), example_rating("slider")],
        },
        {
            "readingType": "normal",
            "text": "# Title\n\n## Subtitle 1\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.\n\nDuis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.\n\n### Subtitle 2\n\nLorem ipsum",
            "fontSize": 22,
            "questions": [
                {
                    "question": "Question",
                    "answers": ["Answer 1", "Answer 2", "Answer 3"],
                    "correctAnswer": 1,
                },
            ] * 3,
            "ratingsBeforeQuestions": [
                example_rating("emoticon"),
                example_rating("radio"),
            ],
        },
    ),
    (
        {
            "id": "7",
            "type": "reaction-time",
            "title": "Reaction time task",
            "instructions": "Pop the balloons as quickly as possible.",
            "nTasks": 1,
            "nTasksDone": 0,
        },
        {
            "nStimuli": 5,
            "minSecondsBetweenStimuli": 0,
            "maxSecondsBetweenStimuli": 1.5,
        },
    ),
    (
        {
            "id": "8",
            "type": "reading",
            "title": "Reading task",
            "instructions": "",
            "nTasks": 1,
            "nTasksDone": 0,
        },
        {
            "text": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam eget urna sed diam pulvinar efficitur vel tincidunt diam. Aliquam et ante quis lacus pretium tempus quis id dolor. Aenean semper turpis in ex tempus, at egestas dolor consectetur. Vestibulum eu facilisis metus. Nullam nisi turpis, faucibus et vulputate et, aliquet quis urna. Etiam mollis eros nibh, nec congue sem maximus ut. Ut non metus scelerisque, volutpat lectus consequat, sollicitudin augue. Aenean dapibus gravida ex vitae accumsan. Vivamus a commodo nisi. Phasellus tincidunt felis malesuada felis pretium, in aliquam risus commodo.\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam eget urna sed diam pulvinar efficitur vel tincidunt diam. Aliquam et ante quis lacus pretium tempus quis id dolor. Aenean semper turpis in ex tempus, at egestas dolor consectetur. Vestibulum eu facilisis metus. Nullam nisi turpis, faucibus et vulputate et, aliquet quis urna. Etiam mollis eros nibh, nec congue sem maximus ut. Ut non metus scelerisque, volutpat lectus consequat, sollicitudin augue. Aenean dapibus gravida ex vitae accumsan. Vivamus a commodo nisi. Phasellus tincidunt felis malesuada felis pretium, in aliquam risus commodo.\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam eget urna sed diam pulvinar efficitur vel tincidunt diam. Aliquam et ante quis lacus pretium tempus quis id dolor. Aenean semper turpis in ex tempus, at egestas dolor consectetur. Vestibulum eu facilisis metus. Nullam nisi turpis, faucibus et vulputate et, aliquet quis urna. Etiam mollis eros nibh, nec congue sem maximus ut. Ut non metus scelerisque, volutpat lectus consequat, sollicitudin augue. Aenean dapibus gravida ex vitae accumsan. Vivamus a commodo nisi. Phasellus tincidunt felis malesuada felis pretium, in aliquam risus commodo.",
            "textWidth": 300,
            "textHeight": 200,
            "ratings": [example_rating("emoticon")],
            "questions": [
                {
                    "question": f"Question {i + 1}",
                    "answers": ["Answer 1", "Answer 2 is a very long answer, boy I sure hope this still fits on screen!", "Answer 3"],
                    "correctAnswerIndex": i % 3,
                }
                for i in range(3)
            ],
        },
    ),
    (
        {
            "id": "9",
            "type": "simon-game",
            "title": "Simon game",
            "instructions": "Repeat the sequence by tapping the boxes.",
            "nTasks": 6,
            "nTasksDone": 1,
            "hasPracticeTask": True,
        },
        None,
    ),
    (
        {
            "id": "10",
            "type": "trail-making",
            "title": "Trail making task",
            "instructions": "Make those trails",
            "nTasks": 1,
            "nTasksDone": 0,
        },
        {
            "stimuli": [str(i) for i in range(1, 7)],
            "colors": ["FFFFFF", "000000"],
            "nDistractors": 6,
            "gridWidth": 5,
            "gridHeight": 7,
            "randomSeed": 42,
            "jiggle": True,
        },
    ),
]

app = Flask(__name__)


def check_credentials():
    participant_id = request.headers.get("X-Participant-ID")
    device_key = request.headers.get("X-Device-Key")
    return participant_id == PARTICIPANT_ID and device_key == DEVICE_KEY


@app.route("/", methods=["GET"])
def index():
    code = requests.get(
        "http://api.qrserver.com/v1/create-qr-code/",
        params={
            "data": (f"http://{HOST}:{PORT}\n{PARTICIPANT_ID}\n{REGISTRATION_KEY}")
        },
    ).content
    response = make_response(code)
    response.headers.set("Content-Type", "image/jpeg")
    return response


@app.route("/register", methods=["POST"])
def register():
    if not request.is_json:
        return {"error": "Invalid request"}, 400
    participant_id = request.json.get("participantId")
    registration_key = request.json.get("registrationKey")

    if participant_id == PARTICIPANT_ID and registration_key == REGISTRATION_KEY:
        return {
            "name": "Dev API",
            "participantId": participant_id,
            "deviceKey": "mock_devkey",
        }, 200

    return {"error": "Invalid credentials"}, 401


@app.route("/experiments", methods=["GET"])
def get_experiments():
    if not check_credentials():
        return {"error": "Invalid credentials"}, 401

    return {
        "experiments": [experiment for experiment, _ in EXPERIMENTS_TASKS],
    }, 200


@app.route("/experiments/<experiment_id>", methods=["GET"])
def get_experiment(experiment_id):
    if not check_credentials():
        return {"error": "Invalid credentials"}, 401

    for experiment, _ in EXPERIMENTS_TASKS:
        if experiment["id"] == experiment_id:
            return experiment, 200

    return {"error": f"No experiment with ID {experiment_id}"}, 404


@app.route("/experiments/<experiment_id>/start", methods=["POST"])
def start_experiment(experiment_id):
    if not check_credentials():
        return {"error": "Invalid credentials"}, 401

    if not request.is_json:
        return {"error": "Invalid request"}, 400

    for experiment, task in EXPERIMENTS_TASKS:
        if experiment["id"] == experiment_id:
            return {
                "id": experiment["id"],
                "data": task,
            }

    return {"error": f"No experiment with ID {experiment_id}"}, 404


@app.route("/tasks/<task_id>/finish", methods=["POST"])
def finish_experiment(task_id):
    if not check_credentials():
        return {"error": "Invalid credentials"}, 401

    if not request.is_json:
        return {"error": "Invalid request"}, 400

    for experiment, task in EXPERIMENTS_TASKS:
        if experiment["id"] == task_id:
            print("Received results:", request.json)
            return {}, 200

    return {"error": f"No task with ID {task_id}"}, 404


if __name__ == "__main__":
    app.run(HOST, PORT, debug=True)
