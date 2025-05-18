import os
from flask import Flask

app = Flask(__name__)


@app.route("/hello", methods=["GET", "POST"])
def hello():
    test_var = os.getenv("TESTSECRET")
    return f"Hello, {test_var} world! V0.3"


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
