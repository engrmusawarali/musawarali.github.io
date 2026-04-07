FROM ruby:slim

LABEL authors="Amir Pourmand,George Araújo,Musawar Ali" \
      description="Docker image for al-folio academic template" \
      maintainer="Musawar Ali"

ENV DEBIAN_FRONTEND=noninteractive \
    EXECJS_RUNTIME=Node \
    JEKYLL_ENV=development \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# Install dependencies
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        git \
        imagemagick \
        inotify-tools \
        locales \
        nodejs \
        python3-pip \
        zlib1g-dev && \
    pip --no-cache-dir install --upgrade --break-system-packages nbconvert && \
    sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen && \
    apt-get clean && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* /tmp/*

# Create non-root user
RUN groupadd -r jekyll && \
    useradd -r -g jekyll jekyll

RUN mkdir -p /srv/jekyll && \
    chown -R jekyll:jekyll /srv/jekyll

WORKDIR /srv/jekyll

COPY --chown=jekyll:jekyll Gemfile Gemfile.lock ./

RUN gem install --no-document jekyll bundler && \
    bundle install --no-cache

COPY --chown=jekyll:jekyll . .

USER jekyll

EXPOSE 8080

CMD ["bundle", "exec", "jekyll", "serve", "--host", "0.0.0.0", "--port", "8080", "--livereload"]
