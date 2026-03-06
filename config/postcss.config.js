const path = require('path');
const fs = require('fs');

function findGemRoot(gemName) {
  const gemPaths = (process.env.GEM_PATH || process.env.GEM_HOME || '').split(':');
  for (const gemPath of gemPaths) {
    const gemsDir = path.join(gemPath, 'gems');
    if (!fs.existsSync(gemsDir)) continue;
    const match = fs.readdirSync(gemsDir)
      .filter(e => e.startsWith(`${gemName}-`))
      .sort()
      .pop();
    if (match) return path.join(gemsDir, match);
  }
  return null;
}

const neoRoot = findGemRoot('neo_components');

module.exports = {
  plugins: {
    'postcss-import': {
      path: neoRoot ? [path.join(neoRoot, 'app/assets/stylesheets')] : []
    },
    tailwindcss: {},
    autoprefixer: {},
  }
};
