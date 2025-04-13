// esbuild.config.js (CommonJS style)
const esbuild = require("esbuild");

const buildOptions = {
  entryPoints: ["lib/js/app.js"], // Can be .ts or .tsx too
  outfile: "lib/js/bundle.js",
  bundle: true,
  format: "esm",
  loader: {
    ".js": "jsx",
    ".jsx": "jsx",
    ".ts": "ts",
    ".tsx": "tsx",
  },
  allowOverwrite: true,
  sourcemap: true,
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
