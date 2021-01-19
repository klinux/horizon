FROM python:3.5.10-slim

RUN apt-get update && \
    apt-get install -y git gcc

RUN pip install --upgrade pip

RUN pip install django-widget-tweaks

WORKDIR /app

RUN pip install tox
