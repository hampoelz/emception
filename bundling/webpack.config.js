const WebpackMode = require('webpack-mode');

module.exports = {
  mode: `${WebpackMode}`,
  entry: './main.js',
  output: {
    filename: '[name].bundle.js',
    clean: true,
  },
  resolve: {
    alias: {
      emception: '../build/emception',
    },
    fallback: {
      'llvm-box.wasm': false,
      'binaryen-box.wasm': false,
      'python.wasm': false,
      'quicknode.wasm': false,
      path: false,
      'node-fetch': false,
      vm: false,
    },
  },
  module: {
    rules: [
      {
        test: /\.wasm$/,
        type: 'asset/resource',
      },
      {
        test: /\.(pack|br|a)$/,
        type: 'asset/resource',
      },
      {
        test: /\.worker\.m?js$/,
        use: ['worker-loader'],
      },
    ],
  },
};
