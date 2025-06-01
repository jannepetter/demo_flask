FROM python:3.12.10-slim-bookworm

RUN addgroup --system appgroup && \
    adduser --system --ingroup appgroup appuser

WORKDIR /app

COPY requirements.txt .
RUN pip3 install -r requirements.txt
COPY . .

USER appuser

EXPOSE 5000

CMD ["gunicorn","app:app", "--bind", "0.0.0.0:5000","--worker-class", "gevent", "--workers", "1", "--threads", "1", \
 "--access-logfile", "-", "--error-logfile", "-", "--log-level", "info"]

