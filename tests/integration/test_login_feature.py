import pytest
from flask import Flask, url_for
import sys
import os
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..')))
import app # Import the app module directly

# --- Constants from app.py for consistency ---
VALID_USERNAME = app.VALID_USERNAME
VALID_PASSWORD = app.VALID_PASSWORD
SECRET_KEY = app.SECRET_KEY
SUCCESS_DASHBOARD_MESSAGE = app.DASHBOARD_WELCOME_MESSAGE
INVALID_CREDENTIALS_MESSAGE = app.INVALID_CREDENTIALS_MESSAGE
# --- End Constants ---

@pytest.fixture
def client():
    app.app.config['TESTING'] = True
    app.app.config['WTF_CSRF_ENABLED'] = False # Disable CSRF for testing forms if needed
    app.app.config['SECRET_KEY'] = SECRET_KEY # Use the constant from app.py
    with app.app.test_client() as client:
        yield client

def test_successful_login_attempt(client):
    # Given the user is on the login page
    response = client.get('/login')
    assert response.status_code == 200

    # When they enter the predefined username and password and submit
    response = client.post('/login', data=dict(
        username=VALID_USERNAME,
        password=VALID_PASSWORD
    ))
    assert response.status_code == 302
    assert '/dashboard' in response.headers['Location']

    # Manually follow the redirect
    response = client.get(response.headers['Location'])
    assert response.status_code == 200
    assert SUCCESS_DASHBOARD_MESSAGE.encode('utf-8') in response.data

def test_failed_login_attempt(client):
    # Given the user is on the login page
    response = client.get('/login')
    assert response.status_code == 200

    # When they enter incorrect credentials and submit
    response = client.post('/login', data=dict(
        username='wronguser',
        password='wrongpassword'
    ), follow_redirects=True)

    # Then they should be shown an error message
    assert INVALID_CREDENTIALS_MESSAGE.encode('utf-8') in response.data
    assert SUCCESS_DASHBOARD_MESSAGE.encode('utf-8') not in response.data
