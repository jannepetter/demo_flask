from flask import Flask, request, jsonify

app = Flask(__name__)


@app.route("/hello", methods=["GET", "POST"])
def hello():
    return "Hello, world!"


# Run the app
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
