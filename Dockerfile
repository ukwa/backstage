FROM ruby:2.6.8

RUN gem install rails -v 5

RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get install -y nodejs
RUN gem install bundler

WORKDIR /usr/src/app

COPY backstage/Gemfile backstage/Gemfile.lock ./
RUN bundle install

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

COPY backstage/ .

ENV DEPLOY_RELATIVE_URL_ROOT=/intranet

RUN bundle exec rails db:migrate RAILS_ENV=development
RUN RAILS_ENV=development rake assets:precompile

ENV SOLR_URL=http://solr-server:8983/collection

CMD bundle exec rails s -b 0.0.0.0
