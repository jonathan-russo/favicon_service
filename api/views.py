from .favicon import serve_favicon_req
from django.views.decorators.cache import cache_page
import os


@cache_page(os.getenv("CACHE_TTL", 60 * 15))  # Defaults to 15 minutes
def favicon_view(request, uri):
    return serve_favicon_req(request, uri)
