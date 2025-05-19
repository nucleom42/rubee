import React from "react";
import { createRoot } from "react-dom/client";
import { App } from "../app/views/App.tsx";

document.addEventListener("DOMContentLoaded", () => {
  const container = document.getElementById("App");
  if (container) {
    const root = createRoot(container);
    root.render(<App />);
  } else {
    console.error('React root element "#App" not found in DOM.');
  }
});
