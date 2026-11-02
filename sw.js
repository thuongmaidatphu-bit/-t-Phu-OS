// Service Worker cho Web App: Gọi Thợ Tuy Hòa, Tìm Cửa Hàng Quanh Đây (Đất Phú OneBase)
const CACHE_NAME = 'goi-tho-tuy-hoa-pwa-v2';
const STATIC_ASSETS = [
  './',
  './goi_tho_6k.html',
  './manifest.json',
  './logo_datphu.jpg'
];

// Install: Cache static resources
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      return cache.addAll(STATIC_ASSETS);
    })
  );
  self.skipWaiting();
});

// Activate: Clean up old caches
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) => {
      return Promise.all(
        keys.filter((key) => key !== CACHE_NAME).map((key) => caches.delete(key))
      );
    })
  );
  self.clients.claim();
});

// Fetch: Network First for HTML and dynamic API, Cache First for static images
self.addEventListener('fetch', (event) => {
  const req = event.request;
  const url = new URL(req.url);

  // Skip non-GET requests, Chrome extension calls, or dynamic realtime streams
  if (req.method !== 'GET' || url.protocol.startsWith('chrome-extension') || url.pathname.includes('/api/realtime')) {
    return;
  }

  // API calls: Network only or bypass SW cache
  if (url.pathname.startsWith('/api/')) {
    event.respondWith(
      fetch(req).catch(() => new Response(JSON.stringify({ error: 'offline', message: 'Bạn đang ngoại tuyến. Vui lòng kiểm tra kết nối mạng.' }), {
        headers: { 'Content-Type': 'application/json; charset=utf-8' }
      }))
    );
    return;
  }

  // HTML Navigation: Network-First with Cache Fallback (guarantees fresh data)
  if (req.mode === 'navigate' || req.headers.get('accept')?.includes('text/html')) {
    event.respondWith(
      fetch(req)
        .then((networkRes) => {
          if (networkRes && networkRes.status === 200) {
            const clone = networkRes.clone();
            caches.open(CACHE_NAME).then((cache) => cache.put(req, clone));
          }
          return networkRes;
        })
        .catch(() => caches.match(req).then((cached) => cached || caches.match('./goi_tho_6k.html')))
    );
    return;
  }

  // Static Assets (Images, Icons, CSS, JS): Stale-While-Revalidate
  event.respondWith(
    caches.match(req).then((cached) => {
      const fetchPromise = fetch(req).then((networkRes) => {
        if (networkRes && networkRes.status === 200) {
          const clone = networkRes.clone();
          caches.open(CACHE_NAME).then((cache) => cache.put(req, clone));
        }
        return networkRes;
      }).catch(() => null);

      return cached || fetchPromise;
    })
  );
});
