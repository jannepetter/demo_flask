#!/bin/bash

# Run migrations
flask db upgrade

# Start the Flask app
exec python3 app.py
