import { useEffect, useRef, useState } from "react";

export function PlayerFrame({ slug, title }: { slug: string; title: string }) {
  const [active, setActive] = useState(false);
  const containerRef = useRef<HTMLDivElement>(null);
  const iframeRef = useRef<HTMLIFrameElement>(null);
  const src = `${import.meta.env.BASE_URL}games/${slug}/index.html`;

  useEffect(() => {
    if (!active) return;
    iframeRef.current?.focus();
    const onKey = (e: KeyboardEvent) => {
      if (
        document.activeElement === iframeRef.current &&
        ["ArrowUp", "ArrowDown", "ArrowLeft", "ArrowRight", " "].includes(e.key)
      ) {
        e.preventDefault();
      }
      if (e.key === "Escape") {
        setActive(false);
        (document.activeElement as HTMLElement)?.blur();
      }
    };
    window.addEventListener("keydown", onKey, { capture: true });
    return () => window.removeEventListener("keydown", onKey, { capture: true });
  }, [active]);

  const fullscreen = () => {
    const el = containerRef.current;
    if (!el) return;
    if (document.fullscreenElement) {
      document.exitFullscreen();
    } else {
      el.requestFullscreen?.();
    }
  };

  return (
    <div>
      <div className="player-frame" ref={containerRef}>
        <iframe
          ref={iframeRef}
          src={src}
          title={title}
          allow="fullscreen; gamepad"
          tabIndex={0}
        />
        {!active && (
          <button
            type="button"
            className="player-overlay"
            onClick={() => setActive(true)}
          >
            ▶ Cliquez pour jouer
          </button>
        )}
      </div>
      <div className="player-controls">
        <button type="button" onClick={fullscreen}>Plein écran</button>
        {active && (
          <button type="button" onClick={() => setActive(false)}>
            Quitter (Échap)
          </button>
        )}
      </div>
    </div>
  );
}
