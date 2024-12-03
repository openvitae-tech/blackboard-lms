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
      'primary': "#005F6B",
      "primary-light":"#4C9A9A",
      "primary-light-50":"#EEF7F7",
      "secondary": "#585563",
      "line-colour":"#E0E0E0",
      "line-colour-light":"#E6E6E6",
      "danger":"#FF2D1A",
      "danger-light":"#FFF1F0",
      "letter-color":"#333333",
      "letter-color-light":"#5C5C5C",
      "white": "#FFFFFF",
      "gold":"#FFD700",
      "gold-light":"#FFFBE5",
      "slate-grey":"#708090",
      "slate-grey-light":"#F1F2F4",
      "purple":"#3456DA",
      "black": "#000000",
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
