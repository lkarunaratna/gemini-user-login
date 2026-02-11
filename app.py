from flask import Flask, render_template, request, redirect, url_for, flash

app = Flask(__name__)
app.secret_key = 'supersecretkey' # Replace with a strong secret key in production

@app.route('/')
def home():
    return redirect(url_for('login'))

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']

        if username == 'jsmith' and password == '123456':
            flash('Login successful!', 'success')
            return redirect(url_for('dashboard'))
        else:
            flash('Invalid credentials. Please try again.', 'danger')
    return render_template('login.html')

@app.route('/dashboard')
def dashboard():
    # This would be a protected route in a real application
    return "Welcome, jsmith! You have successfully logged in."

if __name__ == '__main__':
    app.run(debug=True)
