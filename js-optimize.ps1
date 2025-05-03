Write-Host "==> Checking installed libraries..."

if (-not (Test-Path "node_modules")) {
    Write-Host "==> node_modules does not exist. Installing libraries..."
    npm install
} else {
    Write-Host "==> node_modules already exists. Checking for required libraries..."
}

$requiredPackages = @(
    "@babel/core",
    "@babel/preset-env",
    "babel-loader",
    "webpack",
    "webpack-cli",
    "rollup",
    "rollup-plugin-babel",
    "@rollup/plugin-node-resolve",
    "@rollup/plugin-commonjs"
)

$allPackagesInstalled = $true

foreach ($pkg in $requiredPackages) {
    $isInstalled = npm list --depth=0 | Select-String -Pattern $pkg
    if (-not $isInstalled) {
        Write-Host "==> Library $pkg is not installed. Installing..."
        npm install $pkg --save-dev
        if ($?) {
            Write-Host "==> $pkg library installed successfully."
        } else {
            Write-Host "==> Error installing $pkg. Stopping the build process!"
            $allPackagesInstalled = $false
        }
    } else {
        Write-Host "==> The $pkg library has been installed."
    }
}

if (-not $allPackagesInstalled) {
    Write-Host "==> Library installation failed, stopping the build process."
    exit 1
}

if (-not (Test-Path "babel.config.js")) {
    Write-Host "==> Creating babel.config.js file..."
    $babelConfigContent = @"
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
"@
    Set-Content -Path "babel.config.js" -Value $babelConfigContent
} else {
    Write-Host "==> The babel.config.js file already exists."
}

if (-not (Test-Path "webpack.config.js")) {
    Write-Host "==> Creating webpack.config.js file..."
    $webpackConfigContent = @"
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
"@
    Set-Content -Path "webpack.config.js" -Value $webpackConfigContent
} else {
    Write-Host "==> The webpack.config.js file already exists."
}

if (-not (Test-Path "rollup.config.js")) {
    Write-Host "==> Creating rollup.config.js file..."
    $rollupConfigContent = @"
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
"@
    Set-Content -Path "rollup.config.js" -Value $rollupConfigContent
} else {
    Write-Host "==> The rollup.config.js file already exists."
}

if (-not (Test-Path "package.json")) {
    Write-Host "==> Creating package.json file..."
    npm init -y
} else {
    Write-Host "==> The package.json file already exists."
}

Write-Host "==> Library check and installation complete!"

Write-Host "==> Start compiling source code..."

npm run build:babel
if ($?) {
    Write-Host "==> Babel compilation completed."
} else {
    Write-Host "==> Error during Babel compilation. Stop the process!"
    exit 1
}

npm run build:webpack
if ($?) {
    Write-Host "==> Webpack compilation completed."
} else {
    Write-Host "==> Error during Webpack compilation. Stop the process!"
    exit 1
}

npm run build:rollup
if ($?) {
    Write-Host "==> Rollup compilation completed."
} else {
    Write-Host "==> Error during Rollup compilation. Stop the process!"
    exit 1
}

Write-Host "==> Build completed!"
