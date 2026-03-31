const path = require('path');

const neoStylesheetsPath = path.resolve(__dirname, '../engines/neo_component/app/assets/stylesheets');

module.exports = {
  plugins: {
    'postcss-import': {
      path: [neoStylesheetsPath]
    },
    tailwindcss: {},
    autoprefixer: {},
  }
};
