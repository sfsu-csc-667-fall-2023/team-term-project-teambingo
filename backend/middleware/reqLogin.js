function requireLogin(req, res, next) {
    if (!req.session.loggedIn) {
      return res.redirect("/login"); 
    }
    next(); // so it keeps going
  }
  
  module.exports = requireLogin;