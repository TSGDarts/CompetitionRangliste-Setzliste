// TSG Competition – Service Worker: OneSignal Web-Push + einfache Offline-Fähigkeit.
importScripts("https://cdn.onesignal.com/sdks/web/v16/OneSignalSDK.sw.js");

const CACHE = 'tsg-competition-v2';
self.addEventListener('install', e => { self.skipWaiting(); });
self.addEventListener('activate', e => { e.waitUntil(self.clients.claim()); });
self.addEventListener('fetch', e => {
  if (e.request.method !== 'GET') return;
  try { if (new URL(e.request.url).origin !== self.location.origin) return; } catch (err) { return; }
  e.respondWith(
    fetch(e.request).then(resp => {
      const clone = resp.clone();
      caches.open(CACHE).then(c => c.put(e.request, clone)).catch(() => {});
      return resp;
    }).catch(() => caches.match(e.request))
  );
});
