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
