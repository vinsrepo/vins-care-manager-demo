const AppDAO = require('../models/sqlite3')
const contractRepository = require('../repository/contractRepository')
const dao = new AppDAO('./db.sqlite3')
const contractRepo = new contractRepository(dao)
module.exports = {
    index: (req, res) => {
        res.render('index', {
            title: 'Flat Admin V.2 - Free Bootstrap Admin Templates'
        });
    },
    deploycontract: (req, res) => {
        res.render('deploy', {
            title: 'deploycontract'
        });
    },
    saveaddresscontract: async (req, res) => {
        var status = true;
        var _error = null;
        var type = req.body.type;
        try {
            await contractRepo.create(req.body.address,type);
        } catch (error) {
            status = false;
            _error = error;
        }
        res.json({
            status: status,
            err: _error
        });
    },
    getaddresscontract: async (req, res) => {
        var status = true;
        var _error = null;
        try {
            var getContracts = await contractRepo.get();
            console.log(getContracts)
            res.json({
                status: status,
                err: _error,
                data: getContracts
            });
        } catch (error) {
            status = false;
            _error = error;
            res.json({
                status: status,
                err: _error,
                data: {}
            });
        }
    }
}