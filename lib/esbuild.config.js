// esbuild.config.js (CommonJS style)
const esbuild = require("esbuild");
const inlineCss = require("esbuild-plugin-inline-css");

const buildOptions = {
  entryPoints: ["js/app.js"], // Can be .ts or .tsx too
  outfile: "js/bundle.js",
  bundle: true,
  format: "esm",
  loader: {
    ".js": "jsx",
    ".jsx": "jsx",
    ".ts": "ts",
    ".tsx": "tsx",
    ".css": "css",
  },
  plugins: [inlineCss()],
  allowOverwrite: true,
  minify: true,
  sourcemap: false,
};

async function run() {
  if (process.argv.includes("--watch")) {
    const ctx = await esbuild.context(buildOptions);
    await ctx.watch();
    console.log("👀 Watching for changes...");
  } else {
    await esbuild.build(buildOptions);
    console.log("✅ Build complete");
  }
}

run().catch((err) => {
  console.error("Build failed:", err);
  process.exit(1);
});
