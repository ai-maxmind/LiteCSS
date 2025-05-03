import babel from "rollup-plugin-babel";
import resolve from "@rollup/plugin-node-resolve";
import commonjs from "@rollup/plugin-commonjs";

export default {
  input: "./lib/litecss.min.js",
  output: {
    file: "dist/litecss.min.js",
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
