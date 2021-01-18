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
        "experiments": [
            get_experiment("123")[0],
        ],
    }, 200


@app.route("/experiments/<experiment_id>", methods=["GET"])
def get_experiment(experiment_id):
    if not check_credentials():
        return {"error": "Invalid credentials"}, 401

    if experiment_id == "123":
        return {
            "id": "123",
            "type": "cloze",
            "title": "Cloze test",
            "instructions": "Fill in the gaps.",
            "nTasks": 3,
            "nTasksDone": 2,
        }, 200
    else:
        return {"error": f"No experiment with ID {experiment_id}"}, 404


@app.route("/experiments/<experiment_id>/start", methods=["POST"])
def start_experiment(experiment_id):
    if not check_credentials():
        return {"error": "Invalid credentials"}, 401

    if not request.is_json:
        return {"error": "Invalid request"}, 400

    if experiment_id == "123":
        return {
            "id": "abc",
            "data": {
                "segments": [
                    "This is an example of a {{cloze|close|kloze}} test.",
                ],
            },
        }

    return {"error": f"No experiment with ID {experiment_id}"}, 404


@app.route("/tasks/<task_id>/finish", methods=["POST"])
def finish_experiment(task_id):
    if not check_credentials():
        return {"error": "Invalid credentials"}, 401

    if not request.is_json:
        return {"error": "Invalid request"}, 400

    if task_id == "abc":
        print("Received results:", request.json)
        return {}, 200

    return {"error": f"No task with ID {task_id}"}, 404


if __name__ == "__main__":
    app.run(HOST, PORT, debug=True)
