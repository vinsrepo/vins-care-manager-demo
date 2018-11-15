const type ='contract/'
module.exports = {
    index: (req, res) => {
        res.render(type, {
            title: 'Flat Admin V.2 - Free Bootstrap Admin Templates',
            type:type,
        });
    },
    add: (req, res) => {
        res.render(type+'add', {
            title: 'Flat Admin V.2 - Free Bootstrap Admin Templates',
            type:type,
        });
    },
    edit: (req, res) => {
        res.render(type+'edit', {
            title: 'Flat Admin V.2 - Free Bootstrap Admin Templates',
            type:type,
            addressWarranty:req.params.addressWarranty,
        });
    },
}