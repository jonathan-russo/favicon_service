# favicon_service

## API Structure

This API uses concepts from the [JSON API Specification](https://jsonapi.org/)

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


