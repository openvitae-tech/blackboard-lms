const defaultTheme = require("tailwindcss/defaultTheme");

module.exports = {
  content: [
    "./public/*.html",
    "./app/helpers/**/*.rb",
    "./app/javascript/**/*.js",
    "./app/views/**/*.{erb,haml,html,slim}",
    // "./node_modules/flowbite/**/*.js",
  ],
  theme: {
    extend: {
      fontFamily: {
        montserrat: ['Montserrat'],
      },
    },
    colors: {
      "primary-dark":"#000C24",
      'primary': "#0041B9",
      "primary-light":"#0057FA",
      "primary-light-50":"#F5F8FF",
      "secondary": "#808285",
      "line-colour":"#E6E6E6",
      "line-colour-light":"#EDEDED",
      "danger":"#FF6A6A",
      "danger-light":"#FFE0E0",
      "letter-color":"#404041",
      "letter-color-light":"#8B8B8D",
      "white": "#FFFFFF",
      "gold":"#FFC857",
      "gold-light":"#FFF3DB",
      "slate-grey":"#2D3339",
      "slate-grey-light":"#D1D3D4",
      "purple":"#3456DA",
      "black": "#000000",
      "light-green":"#A9D500",
      "light-green":"#F9FFE0",

    },
    dropShadow: {
      small: "0px 2px 6px 0px #1018280F", 
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
