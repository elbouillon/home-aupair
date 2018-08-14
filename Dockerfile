FROM ruby:2.3.3

RUN apt-get update -qq && apt-get install -y build-essential nodejs imagemagick libmagickwand-dev

# for a JS runtime
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get install -y nodejs

# for yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update -qq && apt-get install -y yarn

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

RUN gem install foreman
RUN gem install rerun
RUN gem install rb-kqueue

ADD Gemfile* $APP_HOME/
RUN bundle install

ADD yarn.lock $APP_HOME/
ADD package.json $APP_HOME/
RUN yarn install

ADD . $APP_HOME
