# Gemini User Login Proof of Concept

## Project Description
This repository hosts a simple Proof of Concept (POC) for a user login system built with Flask. It demonstrates basic user authentication with a predefined username and password, along with integration tests to ensure functionality.

## SDLC Framework Adherence
This project adheres to the Software Development Lifecycle (SDLC) framework as defined by the Gemini CLI scaffolding template. The framework enforces a structured workflow for requirements gathering, decomposition, implementation (Test-Driven Development), and quality assurance.

For more details on the SDLC framework, please refer to:
[https://github.com/cwijayasundara/gemini_cli_scafolding](https://github.com/cwijayasundara/gemini_cli_scafolding)

## Getting Started

### Prerequisites
- Python 3.8+
- pip (Python package installer)

### Installation
1.  **Clone the repository:**
    ```bash
    git clone https://github.com/lkarunaratna/gemini-user-login.git
    cd gemini-user-login
    ```
2.  **Create a virtual environment:**
    ```bash
    python -m venv .venv
    ```
3.  **Activate the virtual environment:**
    *   **Windows:**
        ```bash
        .venv\Scripts\activate
        ```
    *   **macOS/Linux:**
        ```bash
        source .venv/bin/activate
        ```
4.  **Install dependencies:**
    ```bash
    pip install -r requirements.txt
    ```

## Running the Application
To run the Flask application:
```bash
flask run
```
The application will typically be available at `http://127.0.0.1:5000/`.

## Running Tests
This project includes integration tests to verify the login functionality.
To run the tests:
```bash
pytest tests/integration/test_login_feature.py
```
*(Note: If you encounter `ModuleNotFoundError: No module named 'app'`, ensure your project root is in your `PYTHONPATH` or activate your virtual environment. The test file includes a workaround for local execution.)*

## SDLC Workflow Overview
This project follows a Lite Mode SDLC workflow:
- **Requirements**: Captured in `docs/requirements.md`.
- **Stories**: Decomposed from requirements into `docs/backlog/`.
- **Implementation**: Follows a Red-Green-Refactor TDD cycle.
- **Validation**: Tests are run to ensure functionality and quality.

For detailed steps on continuing the SDLC workflow, refer to the `GEMINI.md` file in this repository.