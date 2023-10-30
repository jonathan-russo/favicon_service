from django.http import JsonResponse
from django.core.validators import URLValidator
import requests
import json
import validators
import base64
from bs4 import BeautifulSoup
import re
import logging

logger = logging.getLogger(__name__)

def serve_favicon_req(request, uri):
    try:
        scheme, domain = validate_uri(uri)
    except Exception as e:
        return JsonResponse(format_error_response(400, "Invalid URI", str(e)), status=400)

    try:
        return JsonResponse(
            get_favicon_data_response(scheme, domain)
        )
    except Exception as e:
        return JsonResponse(format_error_response(500, "Error retrieving favicon", str(e)), status=500)


def validate_uri(uri):
    if len(uri.split(":")) != 2:
        raise ValueError("Invalid request.")
    
    scheme,domain = uri.split(":")

    valid = True

    if scheme.lower() not in ["http","https"]:
        raise ValueError("Invalid Scheme.  Only http or https allowed.")

    try:
        validators.domain(domain)
    except:
        raise ValueError(f"{domain} is not a valid domain.")

    return scheme, domain

def get_favicon_data_response(scheme, domain):
    base_url = f"{scheme}://{domain}"
    try:
        content_type, img_object = get_favicon(base_url)
    except Exception as e:
        raise e

    #Turn into data string
    encoded_image = base64.b64encode(img_object).decode('utf-8')

    #Return data response
    return { 
        "data": [{
            "scheme" : scheme, 
            "domain" : domain,
            "data_url": f"data:{content_type};base64,{encoded_image}"
        }]
    }

def get_favicon(base_url):

    favicon_locations = [
        f"{base_url}/favicon.ico" #Typical favicon location 
    ]
    try:
        page = requests.get(base_url)
        soup = BeautifulSoup(page.text, features="lxml")
        for item in soup.find_all('link', attrs={'rel': re.compile("^(shortcut icon|icon)$", re.I)}):
            if "http" not in item.get('href'):
                # Account for relative path
                favicon_locations.append(base_url + item.get('href'))
            else:
                favicon_locations.append(item.get('href'))
        
        for icon_url in favicon_locations:
            logger.info(f"Trying to get favicon from {icon_url}")
            res = requests.get(icon_url, stream=True)
            if res.status_code == 200 and "image/" in res.headers['content-type']:
                return res.headers['content-type'], res.content
            logger.warning(f"No favicon found at {icon_url}")
    except requests.exceptions.RequestException:
        logger.error("Failure while trying to retrieve favicon, returning default.")
        return get_default_icon()
    
    logger.warning("No site defined favicons found.  Using Default")
    return get_default_icon()
    
def get_default_icon():
    default_img_binary = open("default_icon.ico", 'rb').read()
    return "image/x-icon", default_img_binary


def format_error_response(status_code,title, detail):
    error_obj={ "errors": []}
    
    error_obj['errors'].append(
        {
            "status" : status_code,
            "title"  : title,
            "detail" : detail
        }
    )
    return error_obj


