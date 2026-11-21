// ?⑥뼱???붾㈃??怨좎튇 ?ㅼ뿉??VERSION ?レ옄瑜??щ젮二쇱꽭??(?곗뿉 ??踰꾩쟾??諛섏쁺?⑸땲??
const VERSION = "v5";
const FILES = ["./", "index.html", "words.js", "manifest.json", "icon-192.png", "icon-512.png"];

self.addEventListener("install", (e) => {
  e.waitUntil(caches.open(VERSION).then((c) => c.addAll(FILES)));
  self.skipWaiting();
});

self.addEventListener("activate", (e) => {
  e.waitUntil(
    caches.keys().then((keys) => Promise.all(keys.filter((k) => k !== VERSION).map((k) => caches.delete(k))))
  );
  self.clients.claim();
});

// ?명꽣?룹씠 ?섎㈃ ???뚯씪, ???섎㈃ ??λ맂 ?뚯씪 ?ъ슜
self.addEventListener("fetch", (e) => {
  if (e.request.method !== "GET") return;
  e.respondWith(
    fetch(e.request)
      .then((res) => {
        const copy = res.clone();
        caches.open(VERSION).then((c) => c.put(e.request, copy));
        return res;
      })
      .catch(() => caches.match(e.request, { ignoreSearch: true }))
  );
});
