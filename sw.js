// 오프라인 저장. 버전은 version.js 에서 관리합니다 (버전이 바뀌면 폰에 새 파일이 반영됨)
importScripts("version.js");
const CACHE = "momenglish-" + self.APP_VERSION;
const FILES = ["./", "index.html", "words.js", "version.js", "manifest.json", "icon-192.png", "icon-512.png"];

self.addEventListener("install", (e) => {
  e.waitUntil(caches.open(CACHE).then((c) => c.addAll(FILES)));
  self.skipWaiting();
});

self.addEventListener("activate", (e) => {
  e.waitUntil(
    caches.keys().then((keys) => Promise.all(keys.filter((k) => k !== CACHE).map((k) => caches.delete(k))))
  );
  self.clients.claim();
});

// 인터넷이 되면 새 파일, 안 되면 저장된 파일 사용
self.addEventListener("fetch", (e) => {
  if (e.request.method !== "GET") return;
  e.respondWith(
    fetch(e.request)
      .then((res) => {
        const copy = res.clone();
        caches.open(CACHE).then((c) => c.put(e.request, copy));
        return res;
      })
      .catch(() => caches.match(e.request, { ignoreSearch: true }))
  );
});
