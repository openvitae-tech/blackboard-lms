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
      secondary: "#4D24E1",
      gray0: "#CFD3D4",
      gray1: "#5E6366",
      gray2:"#838383",
      black0: "#202020",
      black1: "#012301",
      white: "#FFFFFF",
      white1: "#F6FAFF",
      red0: "#DC143C",
      primary0:"#EAF4F7",
      primary1:"#F6FEFF",
      gray3:"#D9D9D9",
      gray4:"#EDEDED",
      gray5:"#585563",
      primary2:"#CADDE1",
      primary3:"#5C99A133",
      sandle:"#EDAE4933",
      gray6:"#5E63661A",
      primary4:"#5C99A1",
      yellow1:"#FEB635",
      gray6:"#9B99A1",
      gray7:"#C3C2C7",
      green0:"#00B48D",
      purple0:"#3456DA",
      green1:"#F2FFFC",
      red1:"#FFF3F5"
    },
    dropShadow: {
      sm: "0px 2px 6px 0px #1018280F",
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
