/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./app/**/*.{js,ts,jsx,tsx,mdx}",
    "./components/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        brand: {
          bg: '#2E2344',      // Váš světlejší Ametyst [cite: 2026-01-20]
          panel: '#3D3058',   // Barva pro pozadí tabulek [cite: 2026-01-20]
          accent: '#A78BFA',  // Jasnější fialová pro nápisy [cite: 2026-01-20]
        },
      },
    },
  },
  plugins: [],
};