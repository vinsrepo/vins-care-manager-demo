const type ='custommer/'
module.exports = {
    index: (req, res) => {
        res.render(type, {
            title: type,
            type:type,
        });
    },
    detail: (req, res) => {
        res.render(type+'detail', {
            title: type,
            type:type,
            addresspeople:req.params.id,
            addressWarranty:req.params.addressWarranty,
        });
    },
}