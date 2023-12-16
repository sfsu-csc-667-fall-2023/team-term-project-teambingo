const express = require("express");
const router = express.Router();
const configureDatabase = require("../../db/db");
const isAuthenticated = require("../middleware/authenticated");

router.use(isAuthenticated);
const db = configureDatabase();

router.get("/:gamecode", (request, response) => {
    const user = request.session.user;
    console.log(request.params);
    const gamecode = request.params.gamecode;
    const gameData = getGameData(gamecode);

    if (gameData) {
        response.render("game.ejs", { pageTitle: 'In game', gameData, loggedIn: request.session.loggedIn , user, gamecode});
    } else {
        response.status(404).send("Game not found :(");
    }
});

async function getGameData(gamecode) {
    const query = {
        text: "SELECT * FROM game where gamecode = $1",
        values: [gamecode],
    };

    const result = await db.query(query);
    return result.rows[0];
}

module.exports = router;