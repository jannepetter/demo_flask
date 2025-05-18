FROM python:3.13.1-slim-bookworm

# let system decide. No accidental larger privileges compared to matching host user id
# RUN addgroup --system appgroup && \
#     adduser --system --ingroup appgroup appuser

WORKDIR /app

COPY requirements.txt .
RUN pip3 install -r requirements.txt
COPY . .

# USER appuser

EXPOSE 5000

CMD ["python", "app.py"]

