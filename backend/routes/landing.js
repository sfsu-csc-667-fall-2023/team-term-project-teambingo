const express = require("express");
const router = express.Router();

router.get("/", (_request, response) => {
    const user = _request.session.user;
    response.render("landing.ejs", { pageTitle: "Home", pageContent: "", loggedIn: _request.session.loggedIn, user});
});

module.exports = router;