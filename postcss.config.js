const { execSync } = require('child_process')

let gemStylesheetPaths = []
try {
  const gemRoot = execSync(
    "bundle exec ruby -e \"require 'neo_components'; puts NeoComponents::Engine.gem_root\"",
    { encoding: 'utf8' }
  ).trim()
  gemStylesheetPaths = [`${gemRoot}/app/assets/stylesheets`]
} catch (_e) {
  // gem not available, skip
}

module.exports = {
  plugins: [
    ['postcss-import', { path: gemStylesheetPaths }],
  ]
}
