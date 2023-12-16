const express = require("express");
const bcrypt = require("bcrypt");
const router = express.Router();
const User = require("../models/user.model");
const configureDatabase = require("../../db/db");

router.get("/", (_request, response) => {
    const user = _request.session.user;
    const loggedIn = _request.session.loggedIn;
    response.render("login.ejs", { loginFailed: false, loggedIn: loggedIn });
});

router.post("/", async (request, response) => {
    const { username, password } = request.body;

    const db = configureDatabase();
    await db.connect();

    try {
        // searching for user in db
        const user = await getUserByUsernameAndPassword(db, username, password);
        if (user) {
            request.session.loggedIn = true;
            request.session.user = user;
            response.redirect("/"); // redirect
        } else {
            // auth failed
            response.render("login.ejs", { loginFailed: true, loggedIn: false});
        }
    } catch (error) {
        console.error("Error during login:", error);
        response.status(500).send("Internal server error.");
    } finally {
        db.end();
    }
});

async function getUserByUsernameAndPassword(db, username,password) {
    const query = {
        text: "SELECT * FROM player WHERE username = $1",
        values: [username],
    };

    const result = await db.query(query);
    if (result.rows.length > 0) {
        // User found
        const hashedPassword = result.rows[0].password;
        const isPassCorrect = await bcrypt.compare(password, hashedPassword);
        if(isPassCorrect){
        return new User(result.rows[0]); 
        }
    } else {
        // User not found
        return null;
    }
}

module.exports = router;
