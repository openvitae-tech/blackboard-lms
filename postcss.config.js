// NEO_COMPONENTS_STYLESHEETS is set by lib/tasks/tailwind_neo_components.rake
// before the Tailwind CLI is spawned, so @import paths in the gem are resolved.
const gemStylesheetPaths = process.env.NEO_COMPONENTS_STYLESHEETS
  ? [process.env.NEO_COMPONENTS_STYLESHEETS]
  : []

module.exports = {
  plugins: [
    ['postcss-import', { path: gemStylesheetPaths }],
  ]
}
