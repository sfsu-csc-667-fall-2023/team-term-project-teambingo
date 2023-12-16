const { Client } = require("pg");

// Connects to our database
const configureDatabase = () => {
    const db = new Client({
        connectionString: process.env.DB_INTERNAL_URL,
        ssl:true
    });
    return db;
};
  
module.exports = configureDatabase;