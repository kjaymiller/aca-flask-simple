from flask import Flask, render_template

app = Flask(__name__)

@app.route('/')
def hello_world(name=None):
    return render_template('index.html', msg="There")

@app.route('/<name>')
def hello_name(name):
    return render_template('index.html', msg=name)
