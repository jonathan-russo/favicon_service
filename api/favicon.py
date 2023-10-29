from django.http import JsonResponse
from django.core.validators import URLValidator
import requests
import json
import validators

def serve_favicon_req(request, uri):
    try:
        scheme, domain = validate_uri(uri)
    except Exception as e:
        return JsonResponse(format_error(400, "Invalid URI", str(e)), status=400)

    return JsonResponse({"data": f"Getting FavIcon for scheme: {scheme} , domain:{domain}"})

def validate_uri(uri):
    scheme,domain = uri.split(":")

    valid = True

    if scheme.lower() not in ["http","https"]:
        raise Exception("Invalid Scheme.  Only http or https allowed.")

    try:
        validators.domain(domain)
        print("String: '" + domain + "' is a valid URL")
    except:
        print("String:'" + domain + "' is not valid URL")
        raise Exception(f"{domain} is not a valid domain.")

    return scheme, domain

def get_favicon(scheme,domain):
    baseUrl = f"{scheme}://{{domain}"

    # Try typical favicon location 
    res = request.get(baseUrl + "/favicon.ico", stream=True)


def format_error(status_code,title, detail):
    error_obj={ "errors": []}
    
    error_obj['errors'].append(
        {
            "status" : status_code,
            "title"  : title,
            "detail" : detail
        }
    )
    return error_obj

#def get_favicon(uri):

