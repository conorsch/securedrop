FROM ubuntu:trusty
# Configure environment, keeping things ephemeral and flushing.
ENV PYTHONBUFFERED 0
ENV PYTHONDONTWRITEBYTECODE 1
ENV DEBIAN_FRONTEND noninteractive

# Set locale, otherwise ASCII/UTF-8 problems with docker & python.
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# We need elevated privileges to start, but will drop to securedrop later.
USER root

# Update all packages
RUN apt-get update && \
    apt-get upgrade -y

# Dev dependencies
RUN apt-get install -y \
    libssl-dev \
    ntp \
    python-dev \
    python-pip \
    ruby

# App dependencies (no redis; using a separate container for workers)
RUN apt-get install -y \
        gnupg2 \
        secure-delete

# Gem required for sass; should be removable pending Flask-Assets config.
RUN gem install sass -v 3.4.23 --no-rdoc

# Copy in Python requirements files to force container caching
COPY ./securedrop/requirements/test-requirements.txt /securedrop/requirements/test-requirements.txt
COPY ./securedrop/requirements/securedrop-requirements.txt /securedrop/requirements/securedrop-requirements.txt
RUN pip install -r /securedrop/requirements/test-requirements.txt
RUN pip install -r /securedrop/requirements/securedrop-requirements.txt

# Create unprivileged user for running app. Not using www-data.
RUN adduser --disabled-password --gecos "" securedrop

# Create app directories
RUN mkdir --mode 0700 --parents \
      /var/lib/securedrop \
      /var/lib/securedrop/keys \
      /var/lib/securedrop/store \
      /var/lib/securedrop/tmp
COPY install_files/ansible-base/roles/app/files/test_journalist_key.pub /var/lib/securedrop/test_journalist_key.pub
RUN chown securedrop:securedrop -R /var/lib/securedrop

# Add securedrop app dir late, to utilize container caching layers
ADD ./securedrop /securedrop
RUN chown securedrop:securedrop -R /securedrop
WORKDIR /securedrop

# Initialize application. Not idempotent.
ENV PYTHONPATH=/securedrop
USER securedrop
RUN gpg --homedir /var/lib/securedrop/keys --import /var/lib/securedrop/test_journalist_key.pub
RUN python -c 'import db; db.init_db()'
