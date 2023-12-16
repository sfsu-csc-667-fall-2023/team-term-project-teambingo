const express = require("express");
const router = express.Router();

router.get("/", (_request, response) => {
    _request.session.destroy((error)=>{
        if(error){
            console.error("Error caught", error);
        }else{
            response.redirect("/");
        }
    })
});

module.exports = router;