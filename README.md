# README

## About

Blackboard-lms serves as an LMS platform tailored to meet the training demands of the hotel and hospitality industry. Blackboard-lms is an open-source project developed using the Ruby On Rails framework.

## Running in local

### Install postgresql database version 15.x

You can either refer this https://www.postgresql.org/ or use package manager of your os to install postgres. In case of a mac os you can use https://postgresapp.com/ to set it up very easily.

### Install ruby 3.3.0

The first step is to install ruby. In order to install ruby use rbenv or rvm so that you can easily manage the different ruby versions.

Using rbenv or rvm is a personal preference. To use rbenv go to [rbenv](https://github.com/rbenv/rbenv) and for rvm you can go [here](https://rvm.io/)

After installing ruby clone the repo and then you can follow the steps below to setup the application.

```
# Install bundler
$ gem install bundler
```

Go [here](https://nodejs.org/en/download/package-manager) and read about how to install npm and node

```
# install dependencies
# install npm & nodejs
$ npm install flowbite
```

```
# install imagemagick
$ brew install imagemagick
```

```
# run bundle install to install ruby dependencies.
$ bundle install
```

```
# Set your favourite editor to edit credential file
$ export EDITOR="code --wait" # or export EDITOR="vim --wait"

# copy the contents of config/credentials.yml.enc.example file and
# generate your master key and edit the credential file
$ rails credentials:edit
replace the editor content with the copied content, edit and save then close the file.
```

```
# create & setup database
$ cp config/database.yml.example config/database.yml # update test db configuration if required
$ rails db:create
$ rails db:migrate
$ rails db:seed
```

```
# start server
$ bin/dev
```

### Testing

```
$ rspec
$ rspec -f d                 # view test descriptions
$ rspec -f d --tag focus     # view test descriptions and run only focussed sections, usefull for debugging
```

You can run guard to keep running the tests during TDD.

```
$ guard
```

## Running using docker

Install docker in your local and then type `docker-compose up` to run the application using docker in local.
You might have to do some additional setup like generating a master key and setting the RAILS_MASTER_KEY in Dockerfile
