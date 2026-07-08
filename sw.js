// Minimaler Service Worker: macht die Seite als App installierbar + offline-tauglich.
// Strategie: Netzwerk zuerst (immer aktuell), Cache als Fallback wenn offline.
const CACHE = 'tsg-competition-v1';
self.addEventListener('install', e => { self.skipWaiting(); });
self.addEventListener('activate', e => { e.waitUntil(self.clients.claim()); });
self.addEventListener('fetch', e => {
  if (e.request.method !== 'GET') return;
  e.respondWith(
    fetch(e.request).then(resp => {
      const clone = resp.clone();
      caches.open(CACHE).then(c => c.put(e.request, clone)).catch(() => {});
      return resp;
    }).catch(() => caches.match(e.request))
  );
});
