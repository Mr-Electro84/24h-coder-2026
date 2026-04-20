import { Link, Outlet } from "react-router-dom";

export function Layout() {
  return (
    <div className="layout">
      <header className="layout-header">
        <h1>
          <Link to="/">24h pour coder 2026</Link>
        </h1>
        <a
          href="https://github.com/Lucas-Rosenzweig/24h-coder-2026"
          target="_blank"
          rel="noreferrer"
        >
          GitHub
        </a>
      </header>
      <main className="layout-main">
        <Outlet />
      </main>
      <footer className="layout-footer">
        Galerie auto-générée à partir des <code>game.json</code> du repo.
      </footer>
    </div>
  );
}
