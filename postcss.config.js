const { execSync } = require('child_process')

let gemStylesheetPaths = []

if (process.env.NEO_COMPONENTS_STYLESHEETS) {
  gemStylesheetPaths = [process.env.NEO_COMPONENTS_STYLESHEETS]
} else {
  try {
    const gemRoot = execSync('bundle show neo_components', { encoding: 'utf8' }).trim()
    gemStylesheetPaths = [`${gemRoot}/app/assets/stylesheets`]
  } catch (_e) {
    // gem not available, skip
  }
}

module.exports = {
  plugins: [
    ['postcss-import', { path: gemStylesheetPaths }],
  ]
}
