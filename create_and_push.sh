#!/usr/bin/env bash
set -euo pipefail

BRANCH="pwa/kneipi"
COMMIT_MSG="chore: add Django kneipi starter (tappy app) with PWA support"

echo "Switching to branch ${BRANCH} (creating locally if needed)..."
if git show-ref --verify --quiet "refs/heads/${BRANCH}"; then
  git checkout "${BRANCH}"
else
  git checkout -b "${BRANCH}"
fi

echo "Creating directories..."
mkdir -p kneipi tappy templates static/icons static

cat > .gitignore <<'EOF'
__pycache__/
*.py[cod]
*$py.class

# Django stuff:
*.log
*.pot
*.pyc
local_settings.py
db.sqlite3
/staticfiles
/media

# Virtualenv
venv/
.env
.envrc
EOF

cat > requirements.txt <<'EOF'
Django>=4.2
whitenoise
gunicorn
EOF

cat > README.md <<'EOF'
# Kneipi — Django starter (Tappy app) with PWA support

This repository contains a minimal Django starter for the "Kneipi" bars/taverns directory with PWA support. The main Django project is named `kneipi` and the app containing the bar models is `tappy`.

Quick start (local dev):

1. In your Codespace terminal (at repo root):
   - git fetch
   - git checkout pwa/kneipi

2. Create and activate a virtual environment:
   python -m venv venv
   source venv/bin/activate    # macOS / Linux
   venv\Scripts\activate       # Windows

3. Install dependencies:
   pip install -r requirements.txt

4. Run migrations and create a superuser:
   python manage.py migrate
   python manage.py createsuperuser

5. Run the dev server:
   python manage.py runserver

Open http://127.0.0.1:8000/

PWA:
- manifest.json is at /static/manifest.json
- Service worker is at /static/service-worker.js and registered by /static/sw-register.js
- Add icons under static/icons/ (icon-192.png and icon-512.png) to enable installability.

Notes:
- This starter uses SQLite for local development. For production, switch to PostgreSQL and configure SECRET_KEY and DEBUG appropriately via environment variables.
- Replace the placeholder SECRET_KEY in kneipi/settings.py with a secure secret in production.
- For serving static files in production, WhiteNoise is included (configured). Consider using a proper static file host in production.
EOF

cat > manage.py <<'EOF'
#!/usr/bin/env python
import os
import sys

def main():
    os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'kneipi.settings')
    try:
        from django.core.management import execute_from_command_line
    except ImportError as exc:
        raise ImportError("Couldn't import Django.") from exc
    execute_from_command_line(sys.argv)

if __name__ == '__main__':
    main()
EOF

cat > kneipi/__init__.py <<'EOF'
# package marker for the Django project
EOF

cat > kneipi/settings.py <<'EOF'
import os
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent

# SECURITY: Replace this with a secure key for production
SECRET_KEY = os.environ.get('DJANGO_SECRET_KEY', 'replace-me-with-a-secure-key')

DEBUG = True

ALLOWED_HOSTS = ['*']

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'tappy',
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'whitenoise.middleware.WhiteNoiseMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
]

ROOT_URLCONF = 'kneipi.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [BASE_DIR / 'templates'],
        'APP_DIRS': True,
        'OPTIONS': {'context_processors': [
            'django.template.context_processors.debug',
            'django.template.context_processors.request',
            'django.contrib.auth.context_processors.auth',
            'django.contrib.messages.context_processors.messages',
        ]},
    },
]

WSGI_APPLICATION = 'kneipi.wsgi.application'

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': BASE_DIR / 'db.sqlite3',
    }
}

AUTH_PASSWORD_VALIDATORS = []

LANGUAGE_CODE = 'en-us'
TIME_ZONE = 'UTC'
USE_I18N = True
USE_TZ = True

STATIC_URL = '/static/'
STATIC_ROOT = BASE_DIR / 'staticfiles'
STATICFILES_DIRS = [BASE_DIR / 'static']

DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'
EOF

cat > kneipi/urls.py <<'EOF'
from django.contrib import admin
from django.urls import path, include
from django.views.generic import TemplateView

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include('tappy.urls')),
    path('offline.html', TemplateView.as_view(template_name='offline.html'), name='offline'),
]
EOF

cat > kneipi/wsgi.py <<'EOF'
import os
from django.core.wsgi import get_wsgi_application

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'kneipi.settings')
application = get_wsgi_application()
EOF

cat > tappy/__init__.py <<'EOF'
# Tappy app
EOF

cat > tappy/apps.py <<'EOF'
from django.apps import AppConfig

class TappyConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'tappy'
EOF

cat > tappy/models.py <<'EOF'
from django.db import models

class Bar(models.Model):
    name = models.CharField(max_length=255)
    description = models.TextField(blank=True)
    address = models.CharField(max_length=512, blank=True)
    city = models.CharField(max_length=128, blank=True)
    postal_code = models.CharField(max_length=20, blank=True)
    latitude = models.FloatField(null=True, blank=True)
    longitude = models.FloatField(null=True, blank=True)
    tags = models.CharField(max_length=255, blank=True, help_text="Comma-separated tags")
    primary_image = models.URLField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.name

class Review(models.Model):
    bar = models.ForeignKey(Bar, on_delete=models.CASCADE, related_name='reviews')
    rating = models.PositiveSmallIntegerField(default=5)
    text = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Review for {self.bar.name} ({self.rating})"
EOF

cat > tappy/admin.py <<'EOF'
from django.contrib import admin
from .models import Bar, Review

@admin.register(Bar)
class BarAdmin(admin.ModelAdmin):
    list_display = ('name', 'city', 'created_at')
    search_fields = ('name', 'city', 'tags')

@admin.register(Review)
class ReviewAdmin(admin.ModelAdmin):
    list_display = ('bar', 'rating', 'created_at')
    search_fields = ('bar__name',)
EOF

cat > tappy/views.py <<'EOF'
from django.shortcuts import render, get_object_or_404
from .models import Bar

def index(request):
    q = request.GET.get('q', '')
    if q:
        bars = Bar.objects.filter(name__icontains=q)[:50]
    else:
        bars = Bar.objects.all()[:50]
    return render(request, 'index.html', {'bars': bars, 'q': q})

def detail(request, pk):
    bar = get_object_or_404(Bar, pk=pk)
    return render(request, 'detail.html', {'bar': bar})
EOF

cat > tappy/urls.py <<'EOF'
from django.urls import path
from . import views

app_name = 'tappy'

urlpatterns =
