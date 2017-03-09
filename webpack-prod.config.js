
const path = require("path");
const ExtractTextPlugin = require("extract-text-webpack-plugin");

module.exports = {

  entry: {
      main: "./web/static/js/main.js",
      vote: "./web/static/js/vote.js",
      app: "./web/static/css/app.css",
  },
  output: {
      filename: "[name].js",
      path: path.resolve(__dirname, "./priv/static/js"),
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
    new ExtractTextPlugin("app.css")
  ]
};