class productRepository {
  constructor(dao) {
    this.dao = dao
  }

  createTable() {
    const sql = `
       CREATE TABLE IF NOT EXISTS products (
         id INTEGER PRIMARY KEY AUTOINCREMENT,
         address TEXT, created_time integer)`
    return this.dao.run(sql)
  }

  create(address) {
    return this.dao.run(
      'INSERT INTO products (address,created_time) VALUES (?,?)',
      [address,Date.now()])
  }

  getAll() {
    return this.dao.all(`SELECT * FROM projects`)
  }
}
module.exports = productRepository