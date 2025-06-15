#!/bin/sh


if [ "$ENV" = "DEV" ]; then
  aerich init -t config.TORTOISE_ORM
  aerich init-db
fi

aerich upgrade

exec uvicorn app:app --host 0.0.0.0 --port 5000 --reload