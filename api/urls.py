from django.urls import path

from .views import favicon_view

urlpatterns = [
    path("<str:uri>/", favicon_view, name="favicon"),
]

