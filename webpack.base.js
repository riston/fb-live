
const path = require("path");
const ExtractTextPlugin = require("extract-text-webpack-plugin");

module.exports = {
  entry: {
      main: "./web/static/main/main.js",
      animal: "./web/static/animal/animal.js",
      hand: "./web/static/hand/hand.js",
      city: "./web/static/city/city.js",
      maze: "./web/static/maze/maze.js",
  },
  
  output: {
      filename: "[name].js",
      path: path.resolve(__dirname, "./priv/static/js"),
  },

  resolve: {
    modules: [ 
      "node_modules", 
      path.join(__dirname, "web", "static")
    ]
  },

  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /(node_modules|bower_components)/,
        use: {
          loader: "babel-loader",
          options: {
            presets: ["env"]
          }
        }
      },
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
    new ExtractTextPlugin("[name].css")
  ]
};