FROM python:3-slim-buster

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

COPY ./requirements.txt /app/
RUN pip install -r requirements.txt

COPY . /app/

ENTRYPOINT ["gunicorn", "--bind", "0.0.0.0:5000", "manage:app"]