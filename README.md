# favicon_service

![Service Diagram](service_diagram.png)

## Overview

This repo encompasses an API designed to retrieve the favicon for the requested domain.  This API is intended for use as a private service for DuckDuckGo systems to retrieve data urls for the requested icons.  These icons would then be returned to the user as part of a search results page.

A request for `/favicon/https:duckduckgo.com` should result in a JSON object containing the data url.  The JSON object will be formatted according to the [JSON API Specification](https://jsonapi.org/).  

## Running the service locally

The first thing we want to do is ensure that you have the right version of python installed on your system.  Using a tool like pyenv can be helpful for this.  The current python version is listed in our .python-version file.  Using pyenv we can install that version like so: `pyenv install <version>`

Next we want to setup and enable our virtualenv.  Virtual environments allow us to isolate our applications dependencies from our system defaults or other applications.  The following commands will setup our virtual environment, activate it, and install our dependencies:

```
python3 -m venv .venv
. .venv/bin/activate
pip install -r requirements.txt
```

If we want to test with caching enabled locally we will need to run our development redis server.  We can accomplish this with docker compose.  Ensure that you have docker installed on your computer and run the following command.

`docker compose -f docker-compose-redis.yml up`

Finally we can run our service!  The following commands set our development specific settings and run the service:

```
export $(xargs < configs/local.env)
python manage.py runserver
```

## Testing

### Unit Tests

We can validate that our code is working as expected through Unit Tests.  The main tests for this project are defined in `api/tests.py`.  You can run the unit tests with the following command:

`python manage.py test`

### Load Tests

Details about how we can perform load tests can be found in the `load_testing` folder.

## Infrastructure

We manage this applications infrastructure through Terraform.  In the `infra` folder you will find a terraform module that creates all the relevant infrastructure for this application.  Also in the infra folder you will find the bootstrap script used to provision a new Ubuntu 20.04 server and run our application.

In order to plan/apply this infrastructure you will need to set your AWS environment variables and execute the following terraform commands like so:

```
export AWS_ACCESS_KEY_ID=<YOUR ACCESS KEY>
export AWS_SECRET_ACCESS_KEY=<YOUR SECRET KEY>
export AWS_DEFAULT_REGION=<YOUR AWS_REGION>
terraform init
terraform plan -var-file="prod.tfvars"
terraform apply -var-file="prod.tfvars"
```