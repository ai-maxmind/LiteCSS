#!/bin/bash

echo "==> Checking installed libraries..."

if [ ! -d "node_modules" ]; then
    echo "==> node_modules does not exist. Installing libraries..."
    npm install
else
    echo "==> node_modules already exists. Checking for required libraries..."
fi

requiredPackages=(
    "@babel/core"
    "@babel/preset-env"
    "babel-loader"
    "webpack"
    "webpack-cli"
    "rollup"
    "rollup-plugin-babel"
    "@rollup/plugin-node-resolve"
    "@rollup/plugin-commonjs"
)

allPackagesInstalled=true

for pkg in "${requiredPackages[@]}"; do
    isInstalled=$(npm list --depth=0 | grep $pkg)
    if [ -z "$isInstalled" ]; then
        echo "==> Library $pkg is not installed. Installing..."
        npm install $pkg --save-dev
        if [ $? -eq 0 ]; then
            echo "==> $pkg library installed successfully."
        else
            echo "==> Error installing $pkg. Stopping the build process!"
            allPackagesInstalled=false
        fi
    else
        echo "==> The $pkg library has been installed."
    fi
done

if [ "$allPackagesInstalled" = false ]; then
    echo "==> Library installation failed, stopping the build process."
    exit 1
fi

if [ ! -f "babel.config.js" ]; then
    echo "==> Creating babel.config.js file..."
    cat <<EOL > babel.config.js
module.exports = {
  presets: [
    [
      "@babel/preset-env",
      {
        targets: {
          ie: "6",
          android: "2.3"
        },
        useBuiltIns: "usage",
        corejs: 3,
        loose: true,
        bugfixes: true
      }
    ]
  ]
};
EOL
else
    echo "==> The babel.config.js file already exists."
fi

if [ ! -f "webpack.config.js" ]; then
    echo "==> Creating webpack.config.js file..."
    cat <<EOL > webpack.config.js
const path = require("path");

module.exports = {
  entry: "./src/index.js",
  output: {
    filename: "bundle.js",
    path: path.resolve(__dirname, "dist"),
    libraryTarget: "umd"
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: "babel-loader"
      }
    ]
  },
  mode: "production"
};
EOL
else
    echo "==> The webpack.config.js file already exists."
fi

if [ ! -f "rollup.config.js" ]; then
    echo "==> Creating rollup.config.js file..."
    cat <<EOL > rollup.config.js
import babel from "rollup-plugin-babel";
import resolve from "@rollup/plugin-node-resolve";
import commonjs from "@rollup/plugin-commonjs";

export default {
  input: "src/index.js",
  output: {
    file: "dist/bundle-rollup.js",
    format: "umd",
    name: "LegacyFramework"
  },
  plugins: [
    resolve(),
    commonjs(),
    babel({
      exclude: "node_modules/**",
      presets: [
        [
          "@babel/preset-env",
          {
            targets: {
              ie: "6",
              android: "2.3"
            },
            useBuiltIns: "usage",
            corejs: 3
          }
        ]
      ],
      babelHelpers: "bundled"
    })
  ]
};
EOL
else
    echo "==> The rollup.config.js file already exists."
fi

if [ ! -f "package.json" ]; then
    echo "==> Creating package.json file..."
    npm init -y
else
    echo "==> The package.json file already exists."
fi

echo "==> Library check and installation complete!"

echo "==> Start compiling source code..."

npm run build:babel
if [ $? -eq 0 ]; then
    echo "==> Babel compilation completed."
else
    echo "==> Error during Babel compilation. Stop the process!"
    exit 1
fi

npm run build:webpack
if [ $? -eq 0 ]; then
    echo "==> Webpack compilation completed."
else
    echo "==> Error during Webpack compilation. Stop the process!"
    exit 1
fi

npm run build:rollup
if [ $? -eq 0 ]; then
    echo "==> Rollup compilation completed."
else
    echo "==> Error during Rollup compilation. Stop the process!"
    exit 1
fi

echo "==> Build completed!"
