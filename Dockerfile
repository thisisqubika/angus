FROM ruby:3.4

WORKDIR /home/angus

COPY . ./

RUN bundle install

CMD ["/bin/bash"]
