from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include('oidc_provider.urls', namespace='oidc_provider')),
]
