if ('serviceWorker' in navigator) {
  window.addEventListener('load', function() {
    navigator.serviceWorker.register('/static/service-worker.js')
      .then(function(reg) {
        console.log('ServiceWorker registered', reg);
        reg.addEventListener('updatefound', () => {
          const newWorker = reg.installing;
          newWorker.addEventListener('statechange', () => {
            if (newWorker.state === 'installed' && navigator.serviceWorker.controller) {
              // New content available
              console.log('New content is available; please refresh.');
            }
          });
        });
      }).catch(function(err) {
        console.error('ServiceWorker registration failed:', err);
      });
  });
}
