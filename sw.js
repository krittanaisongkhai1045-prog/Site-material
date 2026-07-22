/* Service worker — network-first สำหรับหน้าเว็บ (index.html) เพื่อให้เห็นเวอร์ชันล่าสุดเสมอเมื่อออนไลน์ */
const CACHE = 'sitemat-v43';
const ASSETS = ['./', './index.html', './manifest.json', './icon-192.png', './icon-512.png'];

self.addEventListener('install', e => {
  e.waitUntil(caches.open(CACHE).then(c => c.addAll(ASSETS)).then(() => self.skipWaiting()));
});
self.addEventListener('activate', e => {
  e.waitUntil(caches.keys().then(keys => Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k)))).then(() => self.clients.claim()));
});
self.addEventListener('fetch', e => {
  const req = e.request;
  const url = new URL(req.url);
  if (url.origin !== location.origin) return; // CDN / Supabase → ผ่านไปเน็ตตรง ๆ
  const isHTML = req.mode === 'navigate' || (req.headers.get('accept') || '').includes('text/html');
  if (isHTML) {
    // network-first: ดึงตัวใหม่ก่อน ถ้าออฟไลน์ค่อยใช้ที่ cache
    e.respondWith(
      fetch(req).then(res => { const c = res.clone(); caches.open(CACHE).then(ch => ch.put(req, c)).catch(()=>{}); return res; })
                .catch(() => caches.match(req).then(h => h || caches.match('./index.html')))
    );
    return;
  }
  // ไฟล์อื่น ๆ (ไอคอน ฯลฯ): cache-first
  e.respondWith(caches.match(req).then(hit => hit || fetch(req).then(res => { const c = res.clone(); caches.open(CACHE).then(ch => ch.put(req, c)).catch(()=>{}); return res; })));
});
