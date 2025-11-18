const path = require('path');
const dotenv = require('dotenv');

dotenv.config({
  path: path.resolve(process.cwd(), '.env'),
});

const requiredVariables = [
  'DATABASE_URL',
  'JWT_SECRET',
  'SUPABASE_URL',
  'SUPABASE_SERVICE_ROLE_KEY',
  'SUPABASE_BUCKET',
];

const missing = requiredVariables.filter((key) => !process.env[key]);

if (missing.length) {
  throw new Error(`Missing required environment variables: ${missing.join(', ')}`);
}

const config = {
  nodeEnv: process.env.NODE_ENV || 'development',
  port: Number.parseInt(process.env.PORT, 10) || 4000,
  databaseUrl: process.env.DATABASE_URL,
  jwtSecret: process.env.JWT_SECRET,
  supabaseUrl: process.env.SUPABASE_URL,
  supabaseServiceRoleKey: process.env.SUPABASE_SERVICE_ROLE_KEY,
  supabaseBucket: process.env.SUPABASE_BUCKET,
};

module.exports = config;

