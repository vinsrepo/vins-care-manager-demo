module.exports = {
    helper: () => {
        console.log('My helper.')
    },
    checkAuth(req, res, next) {
        if (!req.session.user_id) {
          res.send('You are not authorized to view this page');
        } else {
          next();
        }
    }
}