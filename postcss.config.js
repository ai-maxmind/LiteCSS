module.exports = {
  plugins: [
    require('autoprefixer')({
      overrideBrowserslist: [
        "last 15 versions",
        "IE 6",
        "IE 7",
        "IE 8",
        "IE 9",
        "IE 10",
        "IE 11"
      ]
    }),
    require('cssnano')({ preset: 'default' })
  ]
};
