#!/bin/bash

INPUT="scss/lite.scss"
OUTPUT="dist/litecss.css"
MINIFIED="dist/litecss.min.css"

mkdir -p dist

for cmd in sass autoprefixer cssnano postcss postcss-cli browser-sync inotifywait; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "❌ Missing $cmd. Checking npm/node..."
    if ! command -v npm &>/dev/null; then
      echo "❌ Missing npm. Install Node.js first."
      exit 1
    fi
    echo "➕ Installing $cmd..."
    
    if ! npm install -g "$cmd" 2>npm-error.log; then
      if grep -q "EACCES" npm-error.log; then
        echo "❌ Cannot install $cmd due to permission error (EACCES)."
        echo "👉 Recommended solution:"
        echo "1️⃣  mkdir -p ~/.npm-global"
        echo "2️⃣  npm config set prefix '~/.npm-global'"
        echo "3️⃣  Add to ~/.bashrc or ~/.zshrc:"
        echo "    export PATH=\$HOME/.npm-global/bin:\$PATH"
        echo "4️⃣  source ~/.bashrc  # or ~/.zshrc"
        echo "5️⃣  Retry: npm install -g $cmd"
        rm npm-error.log
        exit 1
      else
        echo "❌ Unable to install $cmd. Check for errors in npm-error.log"
        exit 1
      fi
    else
      echo "✅ $cmd installed successfully."
    fi
    rm -f npm-error.log
  else
    echo "✅ $cmd has been installed."
  fi
done


if [ ! -f postcss.config.js ]; then
  echo "⚙️ Creating postcss.config.js..."
  cat <<EOF > postcss.config.js
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
EOF
  npm install -g postcss postcss-cli autoprefixer cssnano
fi

echo "🎨 Compiling SCSS..."
sass "$INPUT" "$OUTPUT"

echo "🗜️ Minify CSS..."
npx postcss "$OUTPUT" -o "$MINIFIED"

browser-sync start --server dist --files "dist/litecss.min.css" "theme-demo.html" --no-notify &

echo "👀 Watching $INPUT and minifying on change..."
inotifywait -m -e close_write scss | while read -r path action file; do
  echo "🔄 SCSS file changes → build..."
  sass "$INPUT" "$OUTPUT" --no-source-map
  echo "✅ Compile done → minify..."
  npx postcss "$OUTPUT" -o "$MINIFIED"
  echo "🚀 Updated CSS: $MINIFIED"
done
