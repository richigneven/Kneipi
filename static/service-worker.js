const CACHE_NAME = 'kneipi-v1';
const PRECACHE_URLS = [
  '/',
  '/offline.html',
  '/static/manifest.json'
];

// Install: pre-cache the shell
self.addEventListener('install', event => {
  self.skipWaiting();
  event.waitUntil(
    caches.open(CACHE_NAME).then(cache => cache.addAll(PRECACHE_URLS))
  );
});

// Activate: cleanup old caches
self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys().then(keys => Promise.all(
      keys.filter(k => k !== CACHE_NAME).map(k => caches.delete(k))
    ))
  );
  self.clients.claim();
});

// Fetch: try network, fallback to cache; for navigation return offline fallback
self.addEventListener('fetch', event => {
  if (event.request.mode === 'navigate') {
    event.respondWith(
      fetch(event.request).catch(() => caches.match('/offline.html'))
    );
    return;
  }

  event.respondWith(
    caches.match(event.request).then(response => {
      return response || fetch(event.request).then(resp => {
        // Optionally cache new requests here
        return resp;
      }).catch(() => {
        return caches.match('/offline.html');
      });
    })
  );
});
