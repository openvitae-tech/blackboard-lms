const path = require("path");
const fs = require("fs");

function findGemRoot(gemName) {
  const { execSync } = require("child_process");
  try {
    const result = execSync(
      `bundle exec ruby -e "puts Gem.loaded_specs['${gemName}']&.gem_dir"`,
      { encoding: "utf8", stdio: ["pipe", "pipe", "pipe"] }
    ).trim();
    if (result) return result;
    throw new Error(`gem dir for '${gemName}' was empty`);
  } catch (err) {
    throw new Error(
      `[tailwind.config.js] Could not locate ${gemName} gem: ${err.message}\n` +
      "Run `bundle install` and ensure the gem is present in your bundle."
    );
  }
}

const neoComponentsRoot = findGemRoot("neo_components");

module.exports = {
  content: [
    "./public/*.html",
    "./app/helpers/**/*.rb",
    "./app/javascript/**/*.js",
    "./app/views/**/*.{erb,haml,html,slim}",
    // "./node_modules/flowbite/**/*.js",
    `${neoComponentsRoot}/app/helpers/**/*.rb`,
    `${neoComponentsRoot}/app/views/**/*.{erb,haml,html,slim}`,
    `${neoComponentsRoot}/app/javascript/**/*.js`,
  ],
  theme: {
    extend: {
      fontFamily: {
        poppins: ['Poppins'],
        roboto: ['Roboto'],
      },
      colors: {
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
