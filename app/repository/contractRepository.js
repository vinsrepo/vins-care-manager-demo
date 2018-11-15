class contractRepository {
  constructor(dao) {
    this.dao = dao
  }

  createTable() {
    const sql = `
       CREATE TABLE IF NOT EXISTS contracts (
         id INTEGER PRIMARY KEY AUTOINCREMENT,
         address TEXT,type integer, created_time integer)`
    return this.dao.run(sql)
  }

  create(address,type) {
    return this.dao.run(
      'INSERT INTO contracts (address,type,created_time) VALUES (?,?,?)',
      [address,type,Date.now()])
  }

  get() {
    return this.dao.get(
      `SELECT * FROM contracts ORDER BY type LIMIT 4`)
  }
}
module.exports = contractRepository