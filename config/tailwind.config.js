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
        poppins: ['Poppins'],
        roboto: ['Roboto'],

      },
    },
    colors: {
      "black": "#000000",
      "black-light": "#121212",
      "danger": "#FF6A6A",
      "danger-dark": "#E84747",
      "danger-light": "#FFE0E0",
      "gold": "#FFC857",
      "gold-light": "#FFF3DB",
      "letter-color": "#333333",
      "letter-color-disabled": "#C5C5C5",
      "letter-color-light": "#666666",
      "line-colour": "#E6E6E6",
      "line-colour-light": "#F2F2F2",
      "primary": "#0041B9",
      "primary-dark": "#001D53",
      "primary-light": "#0057FA",
      "primary-light-50": "#F5F8FF",
      "secondary": "#A9D500",
      "secondary-light": "#F9FFE0",
      "slate-grey": "#2D3339",
      "slate-grey-50": "#808285",
      "slate-grey-light": "#D1D3D4",
      "white": "#FFFFFF",
      "white-light": "#FAFAFA"


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
