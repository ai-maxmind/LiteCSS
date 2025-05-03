$input = "scss/main.scss"
$output = "dist/litecss.css"
$minified = "dist/litecss.min.css"

if (-not (Test-Path "dist")) { mkdir dist }

$commands = @("sass", "postcss", "browser-sync")
foreach ($cmd in $commands) {
    if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
        Write-Host "Installing $cmd..."
        npm install -g $cmd
    } else {
        Write-Host "$cmd is already installed."
    }
}

if (-not (Get-Command chokidar -ErrorAction SilentlyContinue)) {
    Write-Host "Installing chokidar-cli..."
    npm install -g chokidar-cli
} else {
    Write-Host "chokidar-cli is already installed."
}

if (-not (Test-Path "postcss.config.js")) {
    Write-Host "Creating postcss.config.js..."
    @"
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
"@ | Out-File -Encoding utf8 postcss.config.js

    npm install -g postcss postcss-cli autoprefixer cssnano
}

Write-Host "Compiling SCSS..."
sass $input $output --no-source-map

Write-Host "Minifying CSS..."
postcss $output -o $minified

Write-Host "Starting browser-sync..."
Start-Process browser-sync -ArgumentList "start", "--server", "dist", "--files", "dist\litecss.min.css", "theme-demo.html", "--no-notify"

Write-Host "Watching SCSS for changes using chokidar..."
Start-Process chokidar -ArgumentList "`"scss/**/*.scss`"", "-c", "`"sass $input $output --no-source-map && postcss $output -o $minified && echo [Updated] $minified`""
