const defaultTheme = require("tailwindcss/defaultTheme");

module.exports = {
  content: [
    "./public/*.html",
    "./app/helpers/**/*.rb",
    "./app/javascript/**/*.js",
    "./app/views/**/*.{erb,haml,html,slim}",
    "./node_modules/flowbite/**/*.js",
  ],
  theme: {
    extend: {
      fontFamily: {
        montserrat: ['Montserrat'],
      },
    },
    colors: {
      primary: "#005F6B",
      primaryLight:"#4C9A9A",
      primaryLight50:"#EEF7F7",
      secondary: "#585563",
      borderColour:"#E0E0E0",
      borderColourLight:"#E6E6E6",
      danger:"#FF2D1A",
      dangerLight:"#FFF1F0",
      textLight:"#5C5C5C",
      white: "#FFFFFF",
      gold:"#FFD700",
      goldLight:"#FFFBE5",
      slateGrey:"#708090",
      slateGrey50:"#F1F2F4",

      white1: "#F6FAFF",
      primary0:"#EAF4F7",
      purple0:"#3456DA",   
    },
    dropShadow: {
      sm: "0px 2px 6px 0px #1018280F",
      medium:"0px 0px 4px 0px #33333329",

    },
  },
  plugins: [
    require("@tailwindcss/forms"),
    require("@tailwindcss/aspect-ratio"),
    require("@tailwindcss/typography"),
    require("@tailwindcss/container-queries"),
    require("flowbite/plugin"),
  ],
};
