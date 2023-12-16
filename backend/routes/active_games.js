const express = require("express");
const app = express;
const router = app.Router();
const isAuthenticated = require("../middleware/authenticated");

router.use(isAuthenticated);

router.get("/", async (request, response) => {
    const user = request.session.user;
    response.render("active_games.ejs", { pageTitle: 'Active Games', loggedIn: request.session.loggedIn, user});
});

module.exports = router;
