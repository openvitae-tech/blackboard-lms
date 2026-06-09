const exportColors = require('./export_colors.json')

module.exports = {
  content: [
    "./public/*.html",
    "./app/helpers/**/*.rb",
    "./app/javascript/**/*.js",
    "./app/views/**/*.{erb,haml,html,slim}",
    // "./node_modules/flowbite/**/*.js",
    "./engines/*/app/helpers/**/*.rb",
    "./engines/*/app/views/**/*.{erb,haml,html,slim}",
    "./engines/*/app/javascript/**/*.js",
  ],
  theme: {
    extend: {
      fontFamily: {
        poppins: ['Poppins'],
        roboto: ['Roboto'],
      },
      colors: {
        // NOTE: disabled-color and line-colour share the same value intentionally; both are kept to avoid refactoring.
        "black":"#000000",
        "black-light":"#121212",
        "danger":"#FF6A6A",
        "danger-dark":"#E84747",
        "danger-light":"#FFE0E0",
        "disabled-color":"#C1C1C1",
        "gold":"#FFC857",
        "gold-light":"#FFF3DB",
        "letter-color":"#333333",
        "letter-color-light":"#666666",
        "line-colour":"#C1C1C1",
        "line-colour-light":"#CFCFCF",
        "primary":"#0041B9",
        "primary-dark":"#001D53",
        "primary-light":"#0057FA",
        "primary-light-50":"#EAF0FD",
        "primary-light-100":"#D9E3F5",
        "cyan":"#06B6D4",
        "teal":"#14B8A6",
        "secondary":"#A9D500",
        "secondary-dark":"#87AA00",
        "secondary-light":"#F2F9D9",
        "slate-grey":"#2D3339",
        "slate-grey-50":"#808285",
        "slate-grey-light":"#D1D3D4",
        "white":"#FFFFFF",
        "white-light":"#FAFAFA",
        "primary-light-200":"#AAC9EC",
        "secondary-light-200":"#B8CB6C",
        "gold-dark":"#EEC062",
        "letter-colour-medium":"#4D4D4D",
        ...exportColors
      },
      backgroundImage: {
        'progress-gradient': 'linear-gradient(90deg, rgb(31, 61, 240) 0.69%, rgb(43, 182, 255) 21.62%, rgb(25, 212, 166) 45.95%, rgb(196, 229, 79) 70.28%, rgb(31, 61, 240) 100.69%)',
      },
      keyframes: {
        'gradient-flow': {
          '0%':   { backgroundPosition: '0% 0%', backgroundSize: '200% 100%' },
          '100%': { backgroundPosition: '-200% 0%', backgroundSize: '200% 100%' },
        },
      },
      animation: {
        'gradient-flow': 'gradient-flow 3s linear infinite',
      },
      borderRadius: {
        '4xl': '2rem',
      },
      dropShadow: {
        small: "0px 2px 6px 0px #1018280F",
      },
    },
  },
  plugins: [
    require("@tailwindcss/forms"),
    require("@tailwindcss/aspect-ratio"),
    require("@tailwindcss/typography"),
    require("@tailwindcss/container-queries"),
    // require("flowbite/plugin"),
  ],
};
