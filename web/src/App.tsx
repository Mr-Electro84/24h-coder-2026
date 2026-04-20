import { BrowserRouter, Route, Routes } from "react-router-dom";
import { Layout } from "./components/Layout";
import { GalleryPage } from "./pages/GalleryPage";
import { GamePage } from "./pages/GamePage";

export default function App() {
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
