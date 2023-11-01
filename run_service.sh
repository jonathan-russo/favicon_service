#!/usr/bin/env bash

# Check for env input
if [[ -z $1 ]]; then
  echo "Please specify an environment config file"
fi

export $(xargs < $1)
gunicorn favicon_service.wsgi
