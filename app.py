import logging
from flask import Flask, render_template, request, redirect, url_for, flash

logging.basicConfig(level=logging.DEBUG) # Configure logging level
logger = logging.getLogger(__name__)

app = Flask(__name__)

# --- Constants ---
SECRET_KEY = 'supersecretkey' # Replace with a strong secret key in production
VALID_USERNAME = 'jsmith'
VALID_PASSWORD = '123456'
SUCCESS_MESSAGE = 'Login successful!'
INVALID_CREDENTIALS_MESSAGE = 'Invalid credentials. Please try again.'
DASHBOARD_WELCOME_MESSAGE = "Welcome, jsmith! You have successfully logged in."
# --- End Constants ---

app.secret_key = SECRET_KEY

@app.route('/')
def home():
    return redirect(url_for('login'))

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        if username == VALID_USERNAME and password == VALID_PASSWORD:
            flash(SUCCESS_MESSAGE, 'success')
            return redirect(url_for('dashboard'))
        else:
            flash(INVALID_CREDENTIALS_MESSAGE, 'danger')
    return render_template('login.html')

@app.route('/dashboard')
def dashboard():
    # This would be a protected route in a real application
    return DASHBOARD_WELCOME_MESSAGE

if __name__ == '__main__':
    app.run(debug=True)
