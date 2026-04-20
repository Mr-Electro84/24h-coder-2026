import { useEffect } from "react";
import { BrowserRouter, Route, Routes } from "react-router-dom";
import { Layout } from "./components/Layout";
import { GalleryPage } from "./pages/GalleryPage";
import { GamePage } from "./pages/GamePage";

function prefetchRuntime() {
  const base = import.meta.env.BASE_URL;
  for (const [href, as] of [
    [`${base}games/_shared/tic80.wasm`, "fetch"],
    [`${base}games/_shared/tic80.js`, "script"],
  ] as const) {
    if (document.head.querySelector(`link[rel="prefetch"][href="${href}"]`)) continue;
    const link = document.createElement("link");
    link.rel = "prefetch";
    link.href = href;
    link.as = as;
    if (as === "fetch") link.crossOrigin = "anonymous";
    document.head.appendChild(link);
  }
}

export default function App() {
  useEffect(prefetchRuntime, []);
  return (
    <BrowserRouter basename={import.meta.env.BASE_URL}>
      <Routes>
        <Route element={<Layout />}>
          <Route index element={<GalleryPage />} />
          <Route path="games/:id" element={<GamePage />} />
          <Route path="*" element={<p>Page introuvable.</p>} />
        </Route>
      </Routes>
    </BrowserRouter>
  );
}
