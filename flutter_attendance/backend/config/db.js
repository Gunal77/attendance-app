const { Pool } = require('pg');
const env = require('./env');

const pool = new Pool({
  connectionString: env.databaseUrl,
  ssl: env.databaseUrl.includes('supabase.co')
    ? { rejectUnauthorized: false }
    : undefined,
});

pool.on('error', (err) => {
  console.error('Unexpected database error', err);
});

const initializeDatabase = async () => {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    await client.query(`
      CREATE TABLE IF NOT EXISTS users (
        id UUID PRIMARY KEY,
        email TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        created_at TIMESTAMPTZ DEFAULT NOW()
      )
    `);

    await client.query(`
      CREATE TABLE IF NOT EXISTS attendance_logs (
        id UUID PRIMARY KEY,
        user_id UUID REFERENCES users(id) ON DELETE CASCADE,
        check_in_time TIMESTAMPTZ NOT NULL,
        check_out_time TIMESTAMPTZ,
        image_url TEXT,
        latitude DOUBLE PRECISION,
        longitude DOUBLE PRECISION,
        created_at TIMESTAMPTZ DEFAULT NOW()
      )
    `);

    await client.query(`
      CREATE INDEX IF NOT EXISTS idx_attendance_logs_user_id
      ON attendance_logs (user_id)
    `);

    await client.query('COMMIT');
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('Failed to initialize database', error);
    throw error;
  } finally {
    client.release();
  }
};

module.exports = {
  pool,
  query: (text, params) => pool.query(text, params),
  getClient: () => pool.connect(),
  initializeDatabase,
};

