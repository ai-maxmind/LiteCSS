const path = require("path");

module.exports = {
  entry: "./lib/litecss.js",
  output: {
    filename: "./lib/litecss.min.js",
    path: path.resolve(__dirname, "dist"),
    libraryTarget: "umd" 
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: "babel-loader"
        }
      }
    ]
  },
  mode: "production"
};
