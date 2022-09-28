FROM dtzar/helm-kubectl:2.16.1

RUN apk add --update \
    python3 \
    py-requests \
    && rm -rf /var/cache/apk/*

ENV PYTHONUNBUFFERED=1
RUN apk add --update --no-cache python3 && ln -sf python3 /usr/bin/python
RUN python3 -m ensurepip
RUN pip3 install --no-cache --upgrade pip setuptools
RUN apk add git
RUN apk add jq
RUN apk add curl
RUN pip3 install flask

##app##
COPY . /app
WORKDIR /app
RUN chmod +x /app/connect.sh && /app/connect.sh
# RUN connect.sh
ENV FLASK_APP=app.py
RUN pip3 install  -r requirements.txt
CMD [ "flask", "run", "--host=0.0.0.0", "--port=3000"]