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
        "secondary":"#A9D500",
        "secondary-dark":"#87AA00",
        "secondary-light":"#F2F9D9",
        "slate-grey":"#2D3339",
        "slate-grey-50":"#808285",
        "slate-grey-light":"#D1D3D4",
        "white":"#FFFFFF",
        "white-light":"#FAFAFA"
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
