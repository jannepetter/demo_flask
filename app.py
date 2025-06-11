from fastapi import FastAPI, Request
from tortoise.contrib.fastapi import register_tortoise
from config import TORTOISE_ORM
from models import User

app = FastAPI()

register_tortoise(
    app, config=TORTOISE_ORM, generate_schemas=True, add_exception_handlers=True
)


@app.get("/users")
async def get_users(request: Request):
    users = await User.all().values("id", "name")
    return users


@app.get("/create_user")
async def create(request: Request):
    user = await User.create(name="alice")
    return f"Created user {user.id}"


@app.get("/")
async def home():
    return "works"


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
