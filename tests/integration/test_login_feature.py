
import pytest
from flask import Flask, url_for
import sys
import os
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..')))
import app

@pytest.fixture
def client():
    app.app.config['TESTING'] = True
    with app.app.test_client() as client:
        yield client

def test_successful_login_attempt(client):
    # Given the user is on the login page
    response = client.get('/login')
    assert response.status_code == 200

    # When they enter the predefined username and password and submit
    # Assuming 'username' and 'password' are the form field names
    # And 'testuser'/'testpassword' are the predefined credentials
    # And the form action is POST to /login
    response = client.post('/login', data=dict(
        username='testuser',
        password='testpassword'
    ), follow_redirects=True)

    # Then they should be successfully authenticated
    # This assertion will fail until the login logic is implemented
    assert b'Login successful' in response.data or b'Dashboard' in response.data # Placeholder for success indication

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
    # This assertion will fail until the login logic is implemented
    assert b'Invalid credentials. Please try again.' not in response.data # This will fail for RED phase
    assert b"Welcome, jsmith! You have successfully logged in." not in response.data # Assert that success message is NOT present
