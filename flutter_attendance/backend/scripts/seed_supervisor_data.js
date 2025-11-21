/**
 * Seed script for Supervisor App sample data
 * 
 * Usage: node scripts/seed_supervisor_data.js
 * 
 * This script creates:
 * - 1 supervisor account
 * - 20 workers (employees)
 * - 20 projects
 * - Supervisor-worker relations
 * - Supervisor-project relations
 */

const { supabase } = require('../config/supabaseClient');
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
  try {
    console.log('🌱 Starting seed process...\n');

    // 1. Create Supervisor
    console.log('1. Creating supervisor...');
    const passwordHash = await bcrypt.hash(SUPERVISOR_PASSWORD, 12);
    const supervisorId = crypto.randomUUID();

    const { data: existingSupervisor, error: checkError } = await supabase
      .from('supervisors')
      .select('id')
      .eq('email', SUPERVISOR_EMAIL)
      .maybeSingle();

    if (checkError && checkError.code !== 'PGRST116') {
      throw checkError;
    }

    let finalSupervisorId = supervisorId;

    if (existingSupervisor) {
      console.log('   Supervisor already exists, using existing ID...');
      finalSupervisorId = existingSupervisor.id;
    } else {
      const { error: supervisorError } = await supabase.from('supervisors').insert({
        id: supervisorId,
        name: SUPERVISOR_NAME,
        email: SUPERVISOR_EMAIL,
        password_hash: passwordHash,
        phone: '+1-555-0000',
      });

      if (supervisorError) {
        throw supervisorError;
      }
      console.log('   ✅ Supervisor created:', SUPERVISOR_EMAIL);
    }

    // 2. Create Workers (Employees)
    console.log('\n2. Creating workers...');
    const workerIds = [];
    for (const worker of workers) {
      const workerId = crypto.randomUUID();
      const { error: workerError } = await supabase.from('employees').upsert({
        id: workerId,
        name: worker.name,
        email: worker.email,
        phone: worker.phone,
        role: worker.role,
      }, { onConflict: 'email' });

      if (workerError) {
        console.log(`   ⚠️  Error creating worker ${worker.name}:`, workerError.message);
      } else {
        // Get the actual ID (in case it already existed)
        const { data: existing } = await supabase
          .from('employees')
          .select('id')
          .eq('email', worker.email)
          .single();
        workerIds.push(existing?.id || workerId);
        console.log(`   ✅ Worker created: ${worker.name}`);
      }
    }

    // 3. Create Projects
    console.log('\n3. Creating projects...');
    const projectIds = [];
    for (const project of projects) {
      const projectId = crypto.randomUUID();
      const { error: projectError } = await supabase.from('projects').upsert({
        id: projectId,
        name: project.name,
        location: project.location,
        start_date: project.start_date,
        end_date: project.end_date,
        description: project.description,
        budget: project.budget,
      }, { onConflict: 'name' });

      if (projectError) {
        console.log(`   ⚠️  Error creating project ${project.name}:`, projectError.message);
      } else {
        const { data: existing } = await supabase
          .from('projects')
          .select('id')
          .eq('name', project.name)
          .single();
        projectIds.push(existing?.id || projectId);
        console.log(`   ✅ Project created: ${project.name}`);
      }
    }

    // 4. Link Workers to Supervisor
    console.log('\n4. Linking workers to supervisor...');
    for (const workerId of workerIds) {
      const { error: relationError } = await supabase
        .from('worker_supervisor_relation')
        .upsert({
          worker_id: workerId,
          supervisor_id: finalSupervisorId,
        }, { onConflict: 'worker_id,supervisor_id' });

      if (relationError) {
        console.log(`   ⚠️  Error linking worker:`, relationError.message);
      }
    }
    console.log(`   ✅ Linked ${workerIds.length} workers to supervisor`);

    // 5. Link Projects to Supervisor
    console.log('\n5. Linking projects to supervisor...');
    for (const projectId of projectIds) {
      const { error: relationError } = await supabase
        .from('supervisor_projects_relation')
        .upsert({
          project_id: projectId,
          supervisor_id: finalSupervisorId,
        }, { onConflict: 'supervisor_id,project_id' });

      if (relationError) {
        console.log(`   ⚠️  Error linking project:`, relationError.message);
      }
    }
    console.log(`   ✅ Linked ${projectIds.length} projects to supervisor`);

    console.log('\n🎉 Seed process completed successfully!');
    console.log('\n📋 Login Credentials:');
    console.log(`   Email: ${SUPERVISOR_EMAIL}`);
    console.log(`   Password: ${SUPERVISOR_PASSWORD}`);
    console.log('\n');

  } catch (error) {
    console.error('❌ Error seeding data:', error);
    process.exit(1);
  }
}

seedData();

