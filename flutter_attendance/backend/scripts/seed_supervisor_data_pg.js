/**
 * Seed script for Supervisor App sample data (PostgreSQL version)
 * 
 * Usage: node scripts/seed_supervisor_data_pg.js
 * 
 * This script uses PostgreSQL directly instead of Supabase client
 * and creates:
 * - 1 supervisor account
 * - 20 workers (employees)
 * - 20 projects
 * - Supervisor-worker relations
 * - Supervisor-project relations
 */

const db = require('../config/db');
const bcrypt = require('bcrypt');
const crypto = require('crypto');

const SUPERVISOR_EMAIL = 'supervisor@example.com';
const SUPERVISOR_PASSWORD = 'supervisor123';
const SUPERVISOR_NAME = 'John Supervisor';

// Sample workers data
const workers = [
  { name: 'John Smith', email: 'john.smith@example.com', phone: '+1-555-0101', role: 'Carpenter' },
  { name: 'Michael Johnson', email: 'michael.j@example.com', phone: '+1-555-0102', role: 'Electrician' },
  { name: 'Robert Williams', email: 'robert.w@example.com', phone: '+1-555-0103', role: 'Plumber' },
  { name: 'James Brown', email: 'james.b@example.com', phone: '+1-555-0104', role: 'Mason' },
  { name: 'David Jones', email: 'david.j@example.com', phone: '+1-555-0105', role: 'Painter' },
  { name: 'William Garcia', email: 'william.g@example.com', phone: '+1-555-0106', role: 'Welder' },
  { name: 'Richard Miller', email: 'richard.m@example.com', phone: '+1-555-0107', role: 'Carpenter' },
  { name: 'Joseph Davis', email: 'joseph.d@example.com', phone: '+1-555-0108', role: 'Electrician' },
  { name: 'Thomas Rodriguez', email: 'thomas.r@example.com', phone: '+1-555-0109', role: 'Laborer' },
  { name: 'Charles Martinez', email: 'charles.m@example.com', phone: '+1-555-0110', role: 'Plumber' },
  { name: 'Christopher Anderson', email: 'chris.a@example.com', phone: '+1-555-0111', role: 'Mason' },
  { name: 'Daniel Taylor', email: 'daniel.t@example.com', phone: '+1-555-0112', role: 'Carpenter' },
  { name: 'Matthew Thomas', email: 'matthew.t@example.com', phone: '+1-555-0113', role: 'Electrician' },
  { name: 'Anthony Hernandez', email: 'anthony.h@example.com', phone: '+1-555-0114', role: 'Painter' },
  { name: 'Mark Moore', email: 'mark.m@example.com', phone: '+1-555-0115', role: 'Welder' },
  { name: 'Donald Martin', email: 'donald.m@example.com', phone: '+1-555-0116', role: 'Laborer' },
  { name: 'Steven Jackson', email: 'steven.j@example.com', phone: '+1-555-0117', role: 'Plumber' },
  { name: 'Paul Thompson', email: 'paul.t@example.com', phone: '+1-555-0118', role: 'Mason' },
  { name: 'Andrew White', email: 'andrew.w@example.com', phone: '+1-555-0119', role: 'Carpenter' },
  { name: 'Joshua Harris', email: 'joshua.h@example.com', phone: '+1-555-0120', role: 'Electrician' },
];

// Sample projects data
const projects = [
  { name: 'Downtown Office Complex', location: '123 Main Street, Downtown', start_date: '2024-01-01', end_date: '2024-06-30', description: 'Construction of a 10-story office building', budget: 5000000 },
  { name: 'Residential Apartment Building', location: '456 Oak Avenue, Midtown', start_date: '2024-02-01', end_date: '2024-09-30', description: '5-story residential apartment complex with 50 units', budget: 3500000 },
  { name: 'Shopping Mall Expansion', location: '789 Commerce Boulevard, Uptown', start_date: '2024-01-15', end_date: '2024-08-31', description: 'Expansion of existing shopping mall with new wing', budget: 8000000 },
  { name: 'Hospital Renovation', location: '321 Medical Drive, Health District', start_date: '2024-03-01', end_date: '2024-11-30', description: 'Renovation and expansion of emergency department', budget: 12000000 },
  { name: 'School Building Construction', location: '654 Education Lane, School District', start_date: '2024-02-15', end_date: '2024-12-31', description: 'New elementary school building with 20 classrooms', budget: 4500000 },
  { name: 'Warehouse Facility', location: '987 Industrial Park, North Side', start_date: '2024-01-20', end_date: '2024-07-31', description: 'Large warehouse facility for logistics company', budget: 6000000 },
  { name: 'Parking Garage', location: '147 Parking Plaza, Downtown', start_date: '2024-03-15', end_date: '2024-10-31', description: 'Multi-level parking garage with 500 spaces', budget: 3000000 },
  { name: 'Hotel Construction', location: '258 Hospitality Road, Tourist Area', start_date: '2024-02-01', end_date: '2025-01-31', description: '200-room luxury hotel with conference facilities', budget: 15000000 },
  { name: 'Bridge Rehabilitation', location: '369 River Crossing, Highway 101', start_date: '2024-04-01', end_date: '2024-12-31', description: 'Structural rehabilitation of main bridge', budget: 10000000 },
  { name: 'Retail Store Chain', location: '741 Shopping Center, Multiple Locations', start_date: '2024-02-15', end_date: '2024-08-31', description: 'Construction of 5 new retail stores across city', budget: 4000000 },
  { name: 'Sports Complex', location: '852 Athletic Avenue, Sports District', start_date: '2024-05-01', end_date: '2025-03-31', description: 'Multi-purpose sports complex with indoor/outdoor facilities', budget: 20000000 },
  { name: 'Data Center', location: '963 Tech Park, Industrial Zone', start_date: '2024-03-01', end_date: '2024-11-30', description: 'Secure data center facility with backup power systems', budget: 18000000 },
  { name: 'Senior Living Community', location: '159 Retirement Road, Residential Area', start_date: '2024-04-15', end_date: '2025-02-28', description: 'Senior living facility with 100 units and amenities', budget: 25000000 },
  { name: 'Road Infrastructure Upgrade', location: '357 Highway Improvement, Major Arteries', start_date: '2024-03-20', end_date: '2024-12-31', description: 'Upgrade and expansion of major road network', budget: 15000000 },
  { name: 'Museum Extension', location: '486 Cultural Boulevard, Arts District', start_date: '2024-06-01', end_date: '2025-04-30', description: 'Extension to existing museum with new exhibition halls', budget: 7000000 },
  { name: 'Manufacturing Plant', location: '528 Factory Street, Industrial Zone', start_date: '2024-04-01', end_date: '2025-01-31', description: 'New manufacturing facility for automotive parts', budget: 22000000 },
  { name: 'Library Modernization', location: '639 Book Lane, Educational District', start_date: '2024-05-15', end_date: '2024-11-30', description: 'Modernization of public library with new technology', budget: 5500000 },
  { name: 'Water Treatment Plant', location: '741 Utility Way, Service District', start_date: '2024-06-01', end_date: '2025-05-31', description: 'New water treatment facility to serve growing population', budget: 30000000 },
  { name: 'Commercial Plaza', location: '852 Business Center, Commercial District', start_date: '2024-04-20', end_date: '2024-12-31', description: 'Mixed-use commercial plaza with offices and retail', budget: 9000000 },
  { name: 'Community Center', location: '963 Community Drive, Residential Neighborhood', start_date: '2024-07-01', end_date: '2025-03-31', description: 'New community center with recreational and meeting facilities', budget: 6000000 },
];

async function seedData() {
  const client = await db.getClient();
  
  try {
    await client.query('BEGIN');
    console.log('🌱 Starting seed process...\n');

    // 1. Create Supervisor
    console.log('1. Creating supervisor...');
    const passwordHash = await bcrypt.hash(SUPERVISOR_PASSWORD, 12);
    const supervisorId = crypto.randomUUID();

    // Check if supervisor exists
    const existingSupervisor = await client.query(
      'SELECT id FROM supervisors WHERE email = $1',
      [SUPERVISOR_EMAIL]
    );

    let finalSupervisorId = supervisorId;

    if (existingSupervisor.rows.length > 0) {
      console.log('   Supervisor already exists, using existing ID...');
      finalSupervisorId = existingSupervisor.rows[0].id;
    } else {
      await client.query(
        `INSERT INTO supervisors (id, name, email, password_hash, phone)
         VALUES ($1, $2, $3, $4, $5)
         ON CONFLICT (email) DO NOTHING`,
        [supervisorId, SUPERVISOR_NAME, SUPERVISOR_EMAIL, passwordHash, '+1-555-0000']
      );
      console.log('   ✅ Supervisor created:', SUPERVISOR_EMAIL);
    }

    // 2. Create Workers (Employees)
    console.log('\n2. Creating workers...');
    const workerIds = [];
    for (const worker of workers) {
      const workerId = crypto.randomUUID();
      const result = await client.query(
        `INSERT INTO employees (id, name, email, phone, role)
         VALUES ($1, $2, $3, $4, $5)
         ON CONFLICT (email) DO UPDATE SET name = EXCLUDED.name, phone = EXCLUDED.phone, role = EXCLUDED.role
         RETURNING id`,
        [workerId, worker.name, worker.email, worker.phone, worker.role]
      );
      
      if (result.rows.length > 0) {
        workerIds.push(result.rows[0].id);
        console.log(`   ✅ Worker created: ${worker.name}`);
      } else {
        // If conflict, get existing ID
        const existing = await client.query(
          'SELECT id FROM employees WHERE email = $1',
          [worker.email]
        );
        if (existing.rows.length > 0) {
          workerIds.push(existing.rows[0].id);
          console.log(`   ✅ Worker already exists: ${worker.name}`);
        }
      }
    }

    // 3. Create Projects
    console.log('\n3. Creating projects...');
    const projectIds = [];
    for (const project of projects) {
      // Check if project already exists
      const existing = await client.query(
        'SELECT id FROM projects WHERE name = $1',
        [project.name]
      );

      let projectId;
      if (existing.rows.length > 0) {
        projectId = existing.rows[0].id;
        // Update existing project
        await client.query(
          `UPDATE projects SET 
           location = $1,
           start_date = $2,
           end_date = $3,
           description = $4,
           budget = $5
           WHERE id = $6`,
          [
            project.location,
            project.start_date,
            project.end_date,
            project.description,
            project.budget,
            projectId,
          ]
        );
        projectIds.push(projectId);
        console.log(`   ✅ Project updated: ${project.name}`);
      } else {
        projectId = crypto.randomUUID();
        await client.query(
          `INSERT INTO projects (id, name, location, start_date, end_date, description, budget)
           VALUES ($1, $2, $3, $4, $5, $6, $7)`,
          [
            projectId,
            project.name,
            project.location,
            project.start_date,
            project.end_date,
            project.description,
            project.budget,
          ]
        );
        projectIds.push(projectId);
        console.log(`   ✅ Project created: ${project.name}`);
      }
    }

    // 4. Link Workers to Supervisor
    console.log('\n4. Linking workers to supervisor...');
    let linkedWorkers = 0;
    for (const workerId of workerIds) {
      try {
        await client.query(
          `INSERT INTO worker_supervisor_relation (worker_id, supervisor_id)
           VALUES ($1, $2)
           ON CONFLICT (worker_id, supervisor_id) DO NOTHING`,
          [workerId, finalSupervisorId]
        );
        linkedWorkers++;
      } catch (error) {
        console.log(`   ⚠️  Error linking worker ${workerId}:`, error.message);
      }
    }
    console.log(`   ✅ Linked ${linkedWorkers} workers to supervisor`);

    // 5. Link Projects to Supervisor
    console.log('\n5. Linking projects to supervisor...');
    let linkedProjects = 0;
    for (const projectId of projectIds) {
      try {
        await client.query(
          `INSERT INTO supervisor_projects_relation (project_id, supervisor_id)
           VALUES ($1, $2)
           ON CONFLICT (supervisor_id, project_id) DO NOTHING`,
          [projectId, finalSupervisorId]
        );
        linkedProjects++;
      } catch (error) {
        console.log(`   ⚠️  Error linking project ${projectId}:`, error.message);
      }
    }
    console.log(`   ✅ Linked ${linkedProjects} projects to supervisor`);

    await client.query('COMMIT');

    console.log('\n🎉 Seed process completed successfully!');
    console.log('\n📋 Login Credentials:');
    console.log(`   Email: ${SUPERVISOR_EMAIL}`);
    console.log(`   Password: ${SUPERVISOR_PASSWORD}`);
    console.log('\n');

  } catch (error) {
    await client.query('ROLLBACK');
    console.error('❌ Error seeding data:', error);
    throw error;
  } finally {
    client.release();
  }
}

// Run the seed
seedData()
  .then(() => {
    console.log('✅ Seed script finished');
    process.exit(0);
  })
  .catch((error) => {
    console.error('❌ Seed script failed:', error);
    process.exit(1);
  });

