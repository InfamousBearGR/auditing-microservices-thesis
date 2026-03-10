import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import viteTsconfigPaths from "vite-tsconfig-paths";
import i18nextLoader from "vite-plugin-i18next-loader";

const buildTimestamp = Date.now();

export default defineConfig({
  base: "/",
  plugins: [
    react({
      jsxImportSource: "@emotion/react",
      babel: {
        plugins: ["@emotion/babel-plugin"],
      },
    }),
    i18nextLoader({ paths: ["src/shared/services/languages"] }),
    viteTsconfigPaths(),
  ],
  build: {
    sourcemap: true,
    rollupOptions: {
      output: {
        entryFileNames: `assets/[name].${buildTimestamp}.js`,
        chunkFileNames: `assets/[name].${buildTimestamp}.js`,
        assetFileNames: `assets/[name].${buildTimestamp}.[ext]`,
      },
    },
  },
  server: {
    host: "localhost",
    // this ensures that the browser opens upon server start
    open: true,
    // this sets a default port to 3000
    port: 5000,
  },
});
