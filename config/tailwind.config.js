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
        montserrat: ["Montserrat"],
        poppins: ["poppins"],
        roboto: ["roboto"],
      },
    },
    colors: {
      primary: "#0041B9",
      "primary-light": "#0057FA",
      "primary-light-50": "#F5F8FF",
      "primary-dark": "#000C24",
      secondary: "#808285",
      "secondary-light-50": "#F9FFE0",
      "line-colour": "#E6E6E6",
      "line-colour-light": "#EDEDED",
      danger: "#FF2D1A",
      "danger-light": "#FFF1F0",
      "letter-color": "#333333",
      "letter-color-light": "#5C5C5C",
      white: "#FFFFFF",
      gold: "#FFD700",
      "gold-light": "#FFFBE5",
      "slate-grey": "#708090",
      "slate-grey-light": "#F1F2F4",
      purple: "#3456DA",
      black: "#000000",
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
