## System architecture and technical overview

Okra, as a client-side application, is embedded in a client-server framework. The server-side implementation is largely up to the researcher creating and distributing the experiments, to keep the distribution logic and server infrastructure as flexible as possible. An example server implementation can be found [here](https://github.com/saeub/okra-server-example).

### Terminology

**Experiment:** Has a set of tasks of a single type, which are to be completed in a specific order. A list of available experiments is shown to participants on the home screen of the app.

**Task:** A single isolated unit of an experiment to be solved without interruption. Cannot be re-started if canceled.

**Task type:** Defines the rules and presentation of a task, i.e. what the participant sees while solving a task (e.g. cloze test or picture naming). This does not include the title, instructions, ratings, or the specific contents of the task, all of which are customizable either on the experiment-level or the task-level. All task types are hard-coded into the app, but customizable in the task data.

**Task data:** The specific contents of a task, including assets (e.g. texts or images) and task-specific configurations. The format of this data depends on the task type (see the [task specifications](tasks.md) for details).

**API:** A server endpoint which delivers experiments and tasks to participants. Defined by a base URL (e.g. `https://example.com/api`) An API may have many registered participants, and a participant may register with many APIs, and no data will be shared between APIs.

### Client-server communication

A participant who has the app installed on their device may register with one or more APIs. After registering, they get an API-specific participant ID which is then used to identify the participant in subsequent HTTP requests.

#### Participant registration and authentication

To register with an API, a participant needs:

- The API base URL.
- The participant ID.
- A registration key.

These can be entered manually, or combined into a QR code (separated by `\n`) and scanned in the API registration screen of the app. The app then sends a `POST` request to `<base-url>/register` with the participant ID and registration key, the server assigns a device key and sends it to the client in the response (see the [API specification](api/index.html) for details).

To identify and authenticate participants, two tokens are needed:

- The participant ID, specific to the API and the participant.
- A device key, assigned when registering with the API and stored on the client device, to authenticate the participant. When the participant changes their device, this must be re-assigned.

These two tokens are included in the header of subsequent HTTP requests to that API.

#### Experiment and task distribution

The app fetches experiments and task data through HTTP requests and JSON. A simplified example:

```
# Get the list of available experiments
Request:  GET /experiments
Response: [experiment "1", experiment "2", ...]

# Assign and start a task
Request:  POST /experiments/1/start
Response: [task data for task "a" in experiment "1"]

# Finish a task
Request:  POST /tasks/a/finish [results]
Response: []

# Assign and start another task
Request:  POST /experiments/1/start
Response: [task data for task "b" in experiment "1"]
```

Note that the order in which tasks within an experiment are assigned to a participant is completely up to the server. Since the participant's ID is included in every request, task assignment may be decided based on individual participants and the previously assigned tasks.
