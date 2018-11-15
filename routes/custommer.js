const router = require('express').Router();
import Custommer from '../app/controllers/CustommerController'
router.get("/",Custommer.index);
router.get("/:addressWarranty/:id",Custommer.detail);
export default router;