import React from "react";
import { createRoot } from "react-dom/client";
import { App } from "../app/views/app.tsx";

document.addEventListener("DOMContentLoaded", () => {
  const container = document.getElementById("app");
  if (container) {
    const root = createRoot(container);
    root.render(<App />);
  } else {
    console.error('React root element "#app" not found in DOM.');
  }
});
