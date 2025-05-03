module.exports = {
    presets: [
      [
        "@babel/preset-env",
        {
          targets: {
            ie: "6",
            android: "2.3",
            opera_mini: "all",
            blackberry: "7"
          },
          useBuiltIns: "usage",
          corejs: 3,
          loose: true,
          bugfixes: true
        }
      ]
    ]
  };
  