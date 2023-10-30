from .favicon import serve_favicon_req

def favicon_view(request, uri):
    return serve_favicon_req(request, uri)

