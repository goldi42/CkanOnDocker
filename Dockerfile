FROM python:2.7-alpine3.6
LABEL name="CKAN" version="1.0.0"

EXPOSE 8000

ENV environment=development
ENV PATH="/app/node_modules/.bin/:${PATH}"
ENV init_database=false

VOLUME /app/uploads
VOLUME /app/extensions
VOLUME /build

WORKDIR /app

COPY ./ ./
RUN apk update && apk add postgresql-dev git gcc linux-headers libmagic musl-dev bash nodejs nodejs-npm
RUN pip install setuptools==20.4 \
    && pip install gunicorn==19.7.1 \
    && npm install npm@latest \
    && npm install
RUN ckanbuilder install ckan --install_dir ./ --file_log
RUN pip uninstall -y python-magic \
    && pip install python-magic==0.4.13

CMD sh /app/bin/startup.sh
