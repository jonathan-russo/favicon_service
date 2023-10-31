# favicon_service

# Running the service locally

The first thing we want to do is ensure that you have the right version of python installed on your system.  Using a tool like pyenv can be helpful for this.  The current python version is listed in our .python-version file.  Using pyenv we can install that version like so: `pyenv install <version>`

Next we want to setup and enable our virtualenv.  Virtual environments allow us to isolate our applications dependencies from our system defaults or other applications.  The following commands will setup our virtual environment, activate it, and install our dependencies:

```
python3 -m venv .venv
. .venv/bin/activate
pip install -r requirements.txt
```

Next we will want to run our development redis server.  We can accomplish this with docker compose.  Ensure that you have docker installed on your computer and run the following command.

`docker compose -f docker-compose-redis.yml up`

Finally we can run our service!

`python manage.py runserver`

# API Structure

This API uses concepts from the [JSON API Specification](https://jsonapi.org/)
