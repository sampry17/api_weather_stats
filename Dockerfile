FROM ruby:2.7.6

RUN apt-get update -qq && apt-get install -y nodejs yarn

RUN gem install bundler -v 2.4.22

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY . .

CMD ["rails", "server", "-b", "0.0.0.0"]
