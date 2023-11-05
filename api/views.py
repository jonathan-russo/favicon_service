from .favicon import serve_favicon_req
from django.views.decorators.cache import cache_page

@cache_page(60 * 15)
def favicon_view(request, uri):
    return serve_favicon_req(request, uri)

def health_view(request):
    return "Healthy!"