const router = require('express').Router();

import Home from '../app/controllers/HomeController'

router.route('/')
    .get(Home.index);

router.route('/deploycontract')
    .get(Home.deploycontract)
    .post(Home.saveaddresscontract)
router.get('/getaddresscontract',Home.getaddresscontract)

router.route('/login')

export default router;