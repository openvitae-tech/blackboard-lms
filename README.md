# README

## About

Blackboard-lms serves as an LMS platform tailored to meet the training demands of the hotel and hospitality industry. Blackboard-lms is an open-source project developed using the Ruby On Rails framework.

## Running in local

### Install postgresql database version 15.x

You can either refer this https://www.postgresql.org/ or use package manager of your os to install postgres. In case of a mac os you can use https://postgresapp.com/ to set it up very easily.

### Install redis server

You can refer to [this](https://redis.io/docs/latest/operate/oss_and_stack/install/install-redis/) and install redis. Start the redis server in your local machine

### Install ruby 3.3.0

The first step is to install ruby. In order to install ruby use rbenv or rvm so that you can easily manage the different ruby versions.

Using rbenv or rvm is a personal preference. To use rbenv go to [rbenv](https://github.com/rbenv/rbenv) and for rvm you can go [here](https://rvm.io/)

After installing ruby clone the repo and then you can follow the steps below to setup the application.

```
# Install bundler
$ gem install bundler
```

```
# install imagemagick
$ brew install imagemagick
```

```
# Set your favourite editor to edit credential file
$ export EDITOR="code --wait" # or export EDITOR="vim --wait"

# copy the contents of config/credentials.yml.enc.example file and
# generate your master key and edit the credential file
$ rails credentials:edit
replace the editor content with the copied content, edit and save then close the file.
```

To install Rails dependencies and seed the database by running:

```bash
./bin/setup
```
Start the server by executing following command.

```bash
bin/dev
```

### Testing
Make sure you have setup the test environment as mentioned in the earlier section
```
$ rspec
$ rspec -f d                 # view test descriptions
$ rspec -f d --tag focus     # view test descriptions and run only focussed sections, usefull for debugging
```
Note: prefix `bundle exec` if you are unable to run it using `rspec`

You can run guard to keep running the tests during TDD.

```
$ guard
```

## Running using docker

Install docker in your local and then build and run the application locally as follows

You can build the containers using `docker-compose build` command

`docker-compose up` to run the application using docker in local.
You might have to do some additional setup like generating a master key and setting the RAILS_MASTER_KEY in Dockerfile
