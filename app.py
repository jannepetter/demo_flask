import os
from flask import Flask, request, jsonify
from models import db, User
from flask_migrate import Migrate

app = Flask(__name__)
app.config["SQLALCHEMY_DATABASE_URI"] = os.environ.get("DATABASE_URL")
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

db.init_app(app)
migrate = Migrate(app, db)


@app.route("/hello", methods=["GET", "POST"])
def hello():
    test_var = os.getenv("TESTSECRET")
    return f"Hello, {test_var} world! V0.3"


@app.route("/users", methods=["POST"])
def create_user():

    data = request.get_json()
    if not data or "username" not in data:
        return jsonify({"error": "Username is required"}), 400

    user = User(username=data["username"])

    db.session.add(user)
    db.session.commit()

    return (
        jsonify({"message": "User created", "id": user.id, "username": user.username}),
        201,
    )


@app.route("/users", methods=["GET"])
def get_users():
    users = User.query.all()
    return jsonify([{"id": u.id, "username": u.username} for u in users])


# Run the app
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
