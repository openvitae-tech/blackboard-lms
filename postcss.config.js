const { execSync } = require('child_process')
const path = require('path')
const fs = require('fs')

function findGemStylesheetsPath() {
  // 1. Env var set by Rails initializer (when tailwindcss:build runs with :environment)
  if (process.env.NEO_COMPONENTS_STYLESHEETS) {
    return process.env.NEO_COMPONENTS_STYLESHEETS
  }

  // 2. Search vendor/bundle (used by bundler-cache: true in GitHub Actions CI)
  const vendorBundlePath = path.resolve(__dirname, 'vendor/bundle/ruby')
  if (fs.existsSync(vendorBundlePath)) {
    for (const rubyVer of fs.readdirSync(vendorBundlePath)) {
      const bundlerGemsPath = path.join(vendorBundlePath, rubyVer, 'bundler/gems')
      if (!fs.existsSync(bundlerGemsPath)) continue
      for (const gemDir of fs.readdirSync(bundlerGemsPath)) {
        if (!gemDir.startsWith('neo_components-')) continue
        const stylesheetsPath = path.join(bundlerGemsPath, gemDir, 'app/assets/stylesheets')
        if (fs.existsSync(stylesheetsPath)) return stylesheetsPath
      }
    }
  }

  // 3. Fallback: ask bundler (works locally in development)
  try {
    const gemRoot = execSync('bundle show neo_components', { encoding: 'utf8' }).trim()
    return `${gemRoot}/app/assets/stylesheets`
  } catch (_e) {
    return null
  }
}

const gemPath = findGemStylesheetsPath()

module.exports = {
  plugins: [
    ['postcss-import', { path: gemPath ? [gemPath] : [] }],
  ]
}
