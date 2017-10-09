module.exports = {
  networks: {
    development: {
      host: "https://37d3d7e0.ngrok.io/",
      from: "0xebc5e9481440a6bf09f4fc7bda2c6ab2d89997b0",     
      gas: 4612388,      
      network_id: "*" // Match any network id
    },
    rinkeby: {
      host: "localhost", // This can run locally until the URL from Google Cloud is ready
      port: 8545,
      from: "0xebc5e9481440a6bf09f4fc7bda2c6ab2d89997b0",
      network_id: 4,
      gas: 4612388
    }
  }
};
