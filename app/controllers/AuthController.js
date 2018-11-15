// this is auth controller
module.exports = {
    index: (req, res) => {
        res.render('login', {
            title: 'Login'
        });
    }
} 