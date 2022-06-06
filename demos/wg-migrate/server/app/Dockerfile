FROM python:3.9-slim


RUN apt-get update && apt-get install -y \
    net-tools \
    iputils-ping \
    iproute2 \
    curl

WORKDIR /app
COPY . /app

RUN pip3 install -r requirements.txt

CMD ["python3", "app.py"]

