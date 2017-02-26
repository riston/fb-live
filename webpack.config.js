
const path = require("path");
const ExtractTextPlugin = require("extract-text-webpack-plugin");

module.exports = {
  entry: [
    "./web/static/css/app.css",
    "./web/static/js/app.js",
  ],
  output: {
    path: "./priv/static",
    filename: "js/app.js"
  },
  
  resolve: {
    modules: [ 
      "node_modules", 
      path.join(__dirname, "web", "static", "js")
    ]
  },

  module: {
    rules: [
      {
        test: /\.css$/,
        use: ExtractTextPlugin.extract({
          fallback: "style-loader",
          use: "css-loader"
        })
      }
    ],
  },

  plugins: [
    new ExtractTextPlugin("css/app.css")
  ]
};