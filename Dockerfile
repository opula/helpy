FROM ruby:2.4

ENV HELPY_VERSION=master \
    RAILS_ENV=production \
    HELPY_HOME=/helpy \
    HELPY_USER=helpy

RUN apt-get update \
  && apt-get upgrade -y \
  && apt-get install -y nodejs postgresql-client imagemagick --no-install-recommends \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/app

VOLUME ["/usr/src/app"]

EXPOSE 3000
EXPOSE 8080

CMD ["./run.sh"]

# docker build --rm -t helpy .
# docker run -dti -p 5010:8080 -v /var/www/helpy/current:/usr/src/app --link  postgres:postgres --name "helpy" helpy
