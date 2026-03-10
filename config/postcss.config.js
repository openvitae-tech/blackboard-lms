const path = require('path');
const fs = require('fs');

function findGemStylesheetsPath(gemName) {
  // Regular gems: $GEM_PATH/<rubyver>/gems/<gemname>-<version>/
  // Git/GitHub gems: $GEM_PATH/<rubyver>/bundler/gems/<gemname>-<sha>/
  const gemPaths = (process.env.GEM_PATH || process.env.GEM_HOME || '').split(':');

  for (const gemPath of gemPaths) {
    // Search regular gems directory
    const gemsDir = path.join(gemPath, 'gems');
    if (fs.existsSync(gemsDir)) {
      const match = fs.readdirSync(gemsDir)
        .filter(e => e.startsWith(`${gemName}-`))
        .sort()
        .pop();
      if (match) {
        const stylesheetsPath = path.join(gemsDir, match, 'app/assets/stylesheets');
        if (fs.existsSync(stylesheetsPath)) return stylesheetsPath;
      }
    }

    // Search bundler/gems directory (used for git/GitHub gems)
    const bundlerGemsDir = path.join(gemPath, 'bundler/gems');
    if (fs.existsSync(bundlerGemsDir)) {
      const match = fs.readdirSync(bundlerGemsDir)
        .filter(e => e.startsWith(`${gemName}-`))
        .sort()
        .pop();
      if (match) {
        const stylesheetsPath = path.join(bundlerGemsDir, match, 'app/assets/stylesheets');
        if (fs.existsSync(stylesheetsPath)) return stylesheetsPath;
      }
    }
  }

  return null;
}

const neoStylesheetsPath = findGemStylesheetsPath('neo_components');

module.exports = {
  plugins: {
    'postcss-import': {
      path: neoStylesheetsPath ? [neoStylesheetsPath] : []
    },
    tailwindcss: {},
    autoprefixer: {},
  }
};
