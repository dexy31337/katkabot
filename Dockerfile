FROM ruby:2.7-alpine

#RUN bundle config --global frozen 1

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

RUN mkdir /app/db

COPY . .

CMD ["./run.rb"]
