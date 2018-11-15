const router = require('express').Router();

import Product from '../app/controllers/ProductController'

// mau router
// router.route('/')
//       .get(todoController.getTodos)
//       .post(todoController.addTodo)
//       .put(todoController.updateTodo);
// router.get('/abc', Product.add);

router.route('/')
     .get(Product.index);
router.route('/add')
     .get(Product.add);
router.route('/edit/')
     .get(Product.edit);
export default router;