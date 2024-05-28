# README

## About 
Blackboard-lms serves as an LMS platform tailored to meet the training demands of the hotel and hospitality industry. Blackboard-lms is an open-source project developed using the Ruby On Rails framework.

### Running in local

Install ruby 3.2.0 using rbenv or rvm

```
# install bundler
$ gem install bundler
# install dependencies
# install node & flowbite
$ npm install flowbite
# install imagemagick
$ brew install imagemagick

$ bundle install

# create & setup database
$ rails db:create
$ rails db:migrate
$ rails db:seed

# start server
$ rails s
# run tests
$ rspec
$ rspec -f d # view test descriptions
$ rspec -f d -f focus # view test descriptions and run only focussed sections, usefull for debugging 
```