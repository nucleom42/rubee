import { useEffect } from "react";

export function RedirectToBackend({ url }: { url: string }) {
  useEffect(() => {
    window.location.replace(url);
  }, []);

  return null; // or a spinner while redirecting
}
