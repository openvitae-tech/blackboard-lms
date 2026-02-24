const path = require("path");
const fs = require("fs");

function findGemRoot(gemName) {
  const gemPaths = (process.env.GEM_PATH || process.env.GEM_HOME || "").split(":");
  for (const gemPath of gemPaths) {
    const gemsDir = path.join(gemPath, "gems");
    if (!fs.existsSync(gemsDir)) continue;
    const match = fs.readdirSync(gemsDir)
      .filter(e => e.startsWith(`${gemName}-`))
      .sort()
      .pop();
    if (match) return path.join(gemsDir, match);
  }
  return null;
}

const neoComponentsRoot = findGemRoot("neo_components");

module.exports = {
  safelist: [
    // group-has-[input:checked] classes used in neo_components checkbox/radio components
    'group-has-[input:checked]:text-primary',
    'group-has-[input:checked]:border-primary',
    'group-has-[input:checked]:flex',
    'group-has-[input:checked]:text-danger-dark',
    'group-has-[input:checked]:bg-danger-dark',
    'group-has-[input:checked]:bg-primary',
    // Arbitrary-value classes used in neo_components gem ERB views.
    // These are hardcoded in gem templates but Tailwind's standalone binary
    // cannot scan installed gem paths, so they must be safelisted explicitly.
    'max-h-[298px]', 'md:max-w-[310px]', 'h-[120px]',
    'max-h-[104px]', 'md:max-h-[132px]',
    'w-[100px]', 'md:w-[297px]', 'h-[104px]', 'md:h-[132px]',
    'max-w-[148px]', 'md:max-w-[716px]',
    'w-[83px]', 'h-[6px]', 'h-[700px]',
    'max-h-[20px]', 'max-h-[calc(100vh-220px)]',
    'w-[52px]', 'w-[96px]', 'md:w-[120px]',
    'w-[2px]', 'w-[326px]',
    "font-['Poppins']",
  ],
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
        "disabled-color":"#C5C5C5",
        "gold":"#FFC857",
        "gold-light":"#FFF3DB",
        "letter-color":"#333333",
        "letter-color-light":"#666666",
        "line-colour":"#E6E6E6",
        "line-colour-light":"#F2F2F2",
        "primary":"#0041B9",
        "primary-dark":"#001D53",
        "primary-light":"#0057FA",
        "primary-light-50":"#F5F8FF",
        "primary-light-100":"#D9E3F5",
        "secondary":"#A9D500",
        "secondary-dark":"#87AA00",
        "secondary-light":"#F9FFE0",
        "slate-grey":"#2D3339",
        "slate-grey-50":"#808285",
        "slate-grey-light":"#D1D3D4",
        "white":"#FFFFFF",
        "white-light":"#FDFDFD"
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
