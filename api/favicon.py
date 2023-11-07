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
    """Main function to serve favicon requests"""
    try:
        scheme, domain = validate_uri(uri)
    except Exception as e:
        logger.error(f"Received invalid request.  uri:'{uri}'")
        return JsonResponse(
            format_error_response(400, "Invalid URI", str(e)), status=400
        )

    try:
        return JsonResponse(get_favicon_data_response(scheme, domain))
    except Exception as e:
        return JsonResponse(
            format_error_response(500, "Error retrieving favicon", str(e)), status=500
        )


def validate_uri(uri):
    """Validate and parse the provided uri"""
    if len(uri.split(":")) != 2:
        raise ValueError("Invalid request.")

    scheme, domain = uri.split(":")

    if scheme.lower() not in ["http", "https"]:
        raise ValueError("Invalid Scheme.  Only http or https allowed.")

    try:
        validators.domain(domain)
    except:
        raise ValueError(f"{domain} is not a valid domain.")

    return scheme, domain


def get_favicon_data_response(scheme, domain):
    """Return favicon data as a JSON Object"""
    base_url = f"{scheme}://{domain}"

    # Retrieve the favicon from the domain
    content_type, img_object = get_favicon(base_url)

    # Turn into data string
    encoded_image = base64.b64encode(img_object).decode("utf-8")

    # Return data response
    return {
        "data": [
            {
                "scheme": scheme,
                "domain": domain,
                "data_url": f"data:{content_type};base64,{encoded_image}",
            }
        ]
    }


def get_favicon(base_url):
    """Retrieve the content type and image contents of the favicon"""
    try:
        # Try typical favicon location first
        icon_url = f"{base_url}/favicon.ico"
        logger.info(f"Trying to get favicon from {icon_url}")
        res = requests.get(icon_url, stream=True)
        if res.status_code == 200 and "image/" in res.headers["content-type"]:
            return res.headers["content-type"], res.content
        logger.warning(f"No favicon found at {icon_url}")

        # Parse the sites index page for icon links
        favicon_locations = []
        page = requests.get(base_url)
        soup = BeautifulSoup(page.text, features="lxml")
        for item in soup.find_all(
            "link", attrs={"rel": re.compile("^(shortcut icon|icon)$", re.I)}
        ):
            if "http" not in item.get("href"):
                # Account for relative path
                favicon_locations.append(base_url + item.get("href"))
            else:
                favicon_locations.append(item.get("href"))

        for icon_url in favicon_locations:
            logger.info(f"Trying to get favicon from {icon_url}")
            res = requests.get(icon_url, stream=True)
            if res.status_code == 200 and "image/" in res.headers["content-type"]:
                return res.headers["content-type"], res.content
            logger.warning(f"No favicon found at {icon_url}")

    except requests.exceptions.RequestException:
        logger.error("Failure while trying to retrieve favicon, returning default.")
        return get_default_icon()

    logger.warning("No site defined favicons found.  Using Default")
    return get_default_icon()


def get_default_icon():
    """Return the content type and image data for the default favicon"""
    default_img_binary = open("default_icon.ico", "rb").read()
    return "image/x-icon", default_img_binary


def format_error_response(status_code, title, detail):
    """Format the error response object as JSON"""
    error_obj = {"errors": []}

    error_obj["errors"].append(
        {"status": status_code, "title": title, "detail": detail}
    )
    return error_obj
