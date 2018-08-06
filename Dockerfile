FROM ruby:2.3.3

RUN apt-get update -qq && apt-get install -y build-essential nodejs imagemagick libmagickwand-dev

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

RUN gem install foreman

ADD Gemfile* $APP_HOME/
RUN bundle install

ADD . $APP_HOME

# TODO installer webpack