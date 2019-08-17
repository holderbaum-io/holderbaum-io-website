module.exports = {
  plugins: [
    require('postcss-import')({ path: 'source/stylesheets' }),
    require('postcss-preset-env')({ stage: 0 })
  ]
}
