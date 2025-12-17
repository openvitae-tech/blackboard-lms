# README

## About

Blackboard-lms is a LMS platform tailored to meet the training demands of the hotel and hospitality industry. Blackboard-lms is an open-source project developed using the Ruby On Rails framework.

## Running in local

Clone the repo and install the dependencies as follows

### Install postgresql database version 15.x

You can either to the [PostgreSQL documentation](https://www.postgresql.org/) or use package manager of your OS to install postgres. On macOs you can use [Postgress.app](https://postgresapp.com/) for easy setup.


#### Running using docker

```bash
sudo docker run -d --name postgresql -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres  -e POSTGRES_DB=blackboard_development -p 5432:5432 postgres:15.4-bookworm
```


### Install redis server

You can refer to [this](https://redis.io/docs/latest/operate/oss_and_stack/install/install-redis/) and install redis. Start the redis server in your local machine


#### Running using docker

```bash
sudo docker run -d --name redis -p 6379:6379 redis:7.2.6-alpine
```

### Install ruby 3.3.0

The first step is to install ruby. In order to install ruby use rbenv or rvm so that you can easily manage the different ruby versions.

Using rbenv or rvm is a personal preference. To use rbenv go to [rbenv](https://github.com/rbenv/rbenv) and for rvm you can go [here](https://rvm.io/)

After installing ruby clone the repo and then you can follow the steps below to setup the application.

### Install bundler

```
$ gem install bundler
```

### install imagemagick
##### OSX
```bash
$ brew install imagemagick
```
##### Ubuntu
```
$ sudo apt install imagemagick
```

### Install ffmpeg
##### OSX
```
$ brew install ffmpeg
```
##### Ubuntu
```
$ sudo apt install ffmpeg
```

### Set your favourite editor to edit credential file
```bash
$ export EDITOR="code --wait" 

# or

$ export EDITOR="vim --wait"
```

Copy the contents of config/credentials.yml.enc.example file and generate your master key and edit the credential file
```bash
$ rails credentials:edit
```
Replace the editor content with the copied content, edit and save then close the file.


### Setup git hooks
You can either install [husky](https://typicode.github.io/husky/get-started.html) or use the git command below to setup the git precommits hooks

```bash
git config core.hooksPath .husky
```

To install Rails dependencies and seed the database by running:

```bash
./bin/setup
```
Start the server by executing following command.

```bash
bin/dev
```

## Testing
Make sure you have setup the test environment as mentioned in the earlier section

You might need to create the db first before running the tests This usually happens while running `./bin/setup`. But incase the db is not created run the following command to create the database.

```bash
$ bundle exec rails db:create -e test
```

```bash
$ bundle exec rspec
$ bundle exec rspec -f d                 # view test descriptions
$ bundle exec rspec -f d --tag focus     # view test descriptions and run only focussed sections, usefull for debugging
```

Note: prefix `bundle exec` if you are unable to run it using `rspec`

You can run `guard` to keep running the tests during TDD.

```
$ guard
```

## Running using docker

Install docker in your local and then build and run the application locally as follows

You can build the containers using `docker compose build` command

`docker compose up` to run the application using docker in local. Docker compose up run the application in a new environment called `docker`. Therefore you need to do some additional setup like generating a master key and setting the RAILS_MASTER_KEY in Dockerfile for the docker environment.
