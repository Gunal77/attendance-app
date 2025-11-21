/**
 * Migration Runner Script
 * 
 * Usage: node scripts/run_migrations.js
 * 
 * This script runs all SQL migration files in the migrations/ directory
 */

const db = require('../config/db');
const fs = require('fs');
const path = require('path');

async function runMigrations() {
  const client = await db.getClient();
  
  try {
    await client.query('BEGIN');
    console.log('🔄 Running migrations...\n');

    const migrationsDir = path.join(__dirname, '../migrations');
    const files = fs.readdirSync(migrationsDir)
      .filter(file => file.endsWith('.sql'))
      .sort(); // Run in alphabetical order

    console.log(`Found ${files.length} migration files\n`);

    for (const file of files) {
      const filePath = path.join(migrationsDir, file);
      const sql = fs.readFileSync(filePath, 'utf8');
      
      console.log(`Running: ${file}...`);
      
      try {
        await client.query(sql);
        console.log(`  ✅ ${file} completed\n`);
      } catch (error) {
        // Ignore "already exists" errors
        if (error.code === '42P07' || error.message.includes('already exists')) {
          console.log(`  ⚠️  ${file} - Tables already exist (skipping)\n`);
        } else {
          throw error;
        }
      }
    }

    await client.query('COMMIT');
    console.log('✅ All migrations completed successfully!\n');

  } catch (error) {
    await client.query('ROLLBACK');
    console.error('❌ Migration failed:', error.message);
    throw error;
  } finally {
    client.release();
  }
}

// Run migrations
runMigrations()
  .then(() => {
    console.log('✅ Migration script finished');
    process.exit(0);
  })
  .catch((error) => {
    console.error('❌ Migration script failed:', error);
    process.exit(1);
  });

