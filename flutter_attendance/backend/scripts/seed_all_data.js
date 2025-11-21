/**
 * Comprehensive Seed Script - All Apps Data
 * 
 * This script creates interconnected sample data for:
 * - Admin Portal (admins)
 * - Supervisor App (supervisors, workers, projects, relations)
 * - Worker Attendance App (users, attendance records)
 * 
 * Usage: node scripts/seed_all_data.js
 */

const db = require('../config/db');
const bcrypt = require('bcrypt');
const crypto = require('crypto');

// ============================================
// SAMPLE DATA
// ============================================

// Admin accounts
const admins = [
  { name: 'Admin User', email: 'admin@example.com', password: 'admin123', phone: '+1-555-0001' },
  { name: 'System Admin', email: 'system@example.com', password: 'admin123', phone: '+1-555-0002' },
];

// Supervisor accounts
const supervisors = [
  { name: 'John Supervisor', email: 'supervisor@example.com', password: 'supervisor123', phone: '+1-555-1000' },
  { name: 'Sarah Manager', email: 'sarah@example.com', password: 'supervisor123', phone: '+1-555-1001' },
  { name: 'Mike Foreman', email: 'mike@example.com', password: 'supervisor123', phone: '+1-555-1002' },
];

// Workers (for attendance app - users table)
const workers = [
  { name: 'John Smith', email: 'john.smith@worker.com', password: 'worker123', phone: '+1-555-0101', role: 'Carpenter' },
  { name: 'Michael Johnson', email: 'michael.j@worker.com', password: 'worker123', phone: '+1-555-0102', role: 'Electrician' },
  { name: 'Robert Williams', email: 'robert.w@worker.com', password: 'worker123', phone: '+1-555-0103', role: 'Plumber' },
  { name: 'James Brown', email: 'james.b@worker.com', password: 'worker123', phone: '+1-555-0104', role: 'Mason' },
  { name: 'David Jones', email: 'david.j@worker.com', password: 'worker123', phone: '+1-555-0105', role: 'Painter' },
  { name: 'William Garcia', email: 'william.g@worker.com', password: 'worker123', phone: '+1-555-0106', role: 'Welder' },
  { name: 'Richard Miller', email: 'richard.m@worker.com', password: 'worker123', phone: '+1-555-0107', role: 'Carpenter' },
  { name: 'Joseph Davis', email: 'joseph.d@worker.com', password: 'worker123', phone: '+1-555-0108', role: 'Electrician' },
  { name: 'Thomas Rodriguez', email: 'thomas.r@worker.com', password: 'worker123', phone: '+1-555-0109', role: 'Laborer' },
  { name: 'Charles Martinez', email: 'charles.m@worker.com', password: 'worker123', phone: '+1-555-0110', role: 'Plumber' },
  { name: 'Christopher Anderson', email: 'chris.a@worker.com', password: 'worker123', phone: '+1-555-0111', role: 'Mason' },
  { name: 'Daniel Taylor', email: 'daniel.t@worker.com', password: 'worker123', phone: '+1-555-0112', role: 'Carpenter' },
  { name: 'Matthew Thomas', email: 'matthew.t@worker.com', password: 'worker123', phone: '+1-555-0113', role: 'Electrician' },
  { name: 'Anthony Hernandez', email: 'anthony.h@worker.com', password: 'worker123', phone: '+1-555-0114', role: 'Painter' },
  { name: 'Mark Moore', email: 'mark.m@worker.com', password: 'worker123', phone: '+1-555-0115', role: 'Welder' },
  { name: 'Donald Martin', email: 'donald.m@worker.com', password: 'worker123', phone: '+1-555-0116', role: 'Laborer' },
  { name: 'Steven Jackson', email: 'steven.j@worker.com', password: 'worker123', phone: '+1-555-0117', role: 'Plumber' },
  { name: 'Paul Thompson', email: 'paul.t@worker.com', password: 'worker123', phone: '+1-555-0118', role: 'Mason' },
  { name: 'Andrew White', email: 'andrew.w@worker.com', password: 'worker123', phone: '+1-555-0119', role: 'Carpenter' },
  { name: 'Joshua Harris', email: 'joshua.h@worker.com', password: 'worker123', phone: '+1-555-0120', role: 'Electrician' },
];

// Projects
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

// ============================================
// SEED FUNCTIONS
// ============================================

async function seedAllData() {
  const client = await db.getClient();
  
  try {
    await client.query('BEGIN');
    console.log('🌱 Starting comprehensive seed process...\n');

    // ============================================
    // 1. CREATE ADMINS
    // ============================================
    console.log('1. Creating admin accounts...');
    const adminIds = [];
    for (const admin of admins) {
      const passwordHash = await bcrypt.hash(admin.password, 12);
      
      // Check if admin exists
      const existing = await client.query(
        'SELECT id FROM admins WHERE email = $1',
        [admin.email]
      );
      
      let adminId;
      if (existing.rows.length > 0) {
        adminId = existing.rows[0].id;
        // Update existing admin
        await client.query(
          `UPDATE admins SET 
           name = $1,
           password_hash = $2,
           phone = $3
           WHERE id = $4`,
          [admin.name, passwordHash, admin.phone, adminId]
        );
        adminIds.push(adminId);
        console.log(`   ✅ Admin updated: ${admin.email}`);
      } else {
        adminId = crypto.randomUUID();
        // Use explicit timestamp with microsecond precision
        const createdAt = new Date();
        createdAt.setMilliseconds(createdAt.getMilliseconds() + adminIds.length);
        await client.query(
          `INSERT INTO admins (id, name, email, password_hash, phone, created_at)
           VALUES ($1, $2, $3, $4, $5, $6)`,
          [adminId, admin.name, admin.email, passwordHash, admin.phone, createdAt.toISOString()]
        );
        adminIds.push(adminId);
        console.log(`   ✅ Admin created: ${admin.email}`);
      }
    }

    // ============================================
    // 2. CREATE SUPERVISORS
    // ============================================
    console.log('\n2. Creating supervisor accounts...');
    const supervisorIds = [];
    for (const supervisor of supervisors) {
      const passwordHash = await bcrypt.hash(supervisor.password, 12);
      
      // Check if supervisor exists
      const existing = await client.query(
        'SELECT id FROM supervisors WHERE email = $1',
        [supervisor.email]
      );
      
      let supervisorId;
      if (existing.rows.length > 0) {
        supervisorId = existing.rows[0].id;
        // Update existing supervisor
        await client.query(
          `UPDATE supervisors SET 
           name = $1,
           password_hash = $2,
           phone = $3
           WHERE id = $4`,
          [supervisor.name, passwordHash, supervisor.phone, supervisorId]
        );
        supervisorIds.push(supervisorId);
        console.log(`   ✅ Supervisor updated: ${supervisor.email}`);
      } else {
        supervisorId = crypto.randomUUID();
        await client.query(
          `INSERT INTO supervisors (id, name, email, password_hash, phone)
           VALUES ($1, $2, $3, $4, $5)`,
          [supervisorId, supervisor.name, supervisor.email, passwordHash, supervisor.phone]
        );
        supervisorIds.push(supervisorId);
        console.log(`   ✅ Supervisor created: ${supervisor.email}`);
      }
    }

    // ============================================
    // 3. CREATE WORKERS (Users table for attendance app)
    // ============================================
    console.log('\n3. Creating worker accounts (users table)...');
    const workerUserIds = [];
    for (const worker of workers) {
      const passwordHash = await bcrypt.hash(worker.password, 12);
      
      // Check if user exists
      const existing = await client.query(
        'SELECT id FROM users WHERE email = $1',
        [worker.email]
      );
      
      let userId;
      if (existing.rows.length > 0) {
        userId = existing.rows[0].id;
        // Update password
        await client.query(
          'UPDATE users SET password_hash = $1 WHERE id = $2',
          [passwordHash, userId]
        );
        workerUserIds.push({ userId, worker });
        console.log(`   ✅ Worker user updated: ${worker.email}`);
      } else {
        userId = crypto.randomUUID();
        await client.query(
          `INSERT INTO users (id, email, password_hash)
           VALUES ($1, $2, $3)`,
          [userId, worker.email, passwordHash]
        );
        workerUserIds.push({ userId, worker });
        console.log(`   ✅ Worker user created: ${worker.email}`);
      }
    }

    // ============================================
    // 4. CREATE EMPLOYEES (linked to workers)
    // ============================================
    console.log('\n4. Creating employee records...');
    const employeeIds = [];
    for (const { userId, worker } of workerUserIds) {
      // Check if employee exists
      const existing = await client.query(
        'SELECT id FROM employees WHERE email = $1',
        [worker.email]
      );
      
      let employeeId;
      if (existing.rows.length > 0) {
        employeeId = existing.rows[0].id;
        // Update existing employee
        await client.query(
          `UPDATE employees SET 
           name = $1,
           phone = $2,
           role = $3
           WHERE id = $4`,
          [worker.name, worker.phone, worker.role, employeeId]
        );
        employeeIds.push({ employeeId, userId, worker });
        console.log(`   ✅ Employee updated: ${worker.name}`);
      } else {
        employeeId = crypto.randomUUID();
        await client.query(
          `INSERT INTO employees (id, name, email, phone, role)
           VALUES ($1, $2, $3, $4, $5)`,
          [employeeId, worker.name, worker.email, worker.phone, worker.role]
        );
        employeeIds.push({ employeeId, userId, worker });
        console.log(`   ✅ Employee created: ${worker.name}`);
      }
    }

    // ============================================
    // 5. CREATE PROJECTS
    // ============================================
    console.log('\n5. Creating projects...');
    const projectIds = [];
    for (const project of projects) {
      const projectId = crypto.randomUUID();
      
      const existing = await client.query(
        'SELECT id FROM projects WHERE name = $1',
        [project.name]
      );

      let finalProjectId;
      if (existing.rows.length > 0) {
        finalProjectId = existing.rows[0].id;
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
            finalProjectId,
          ]
        );
        projectIds.push(finalProjectId);
        console.log(`   ✅ Project updated: ${project.name}`);
      } else {
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

    // ============================================
    // 6. ASSIGN WORKERS TO SUPERVISORS
    // ============================================
    console.log('\n6. Linking workers to supervisors...');
    let linkedCount = 0;
    
    // Distribute workers among supervisors
    const workersPerSupervisor = Math.ceil(employeeIds.length / supervisorIds.length);
    
    for (let i = 0; i < employeeIds.length; i++) {
      const supervisorIndex = Math.floor(i / workersPerSupervisor) % supervisorIds.length;
      const supervisorId = supervisorIds[supervisorIndex];
      const { employeeId } = employeeIds[i];
      
      try {
        await client.query(
          `INSERT INTO worker_supervisor_relation (worker_id, supervisor_id)
           VALUES ($1, $2)
           ON CONFLICT (worker_id, supervisor_id) DO NOTHING`,
          [employeeId, supervisorId]
        );
        linkedCount++;
      } catch (error) {
        console.log(`   ⚠️  Error linking worker: ${error.message}`);
      }
    }
    console.log(`   ✅ Linked ${linkedCount} workers to supervisors`);

    // ============================================
    // 7. ASSIGN PROJECTS TO SUPERVISORS
    // ============================================
    console.log('\n7. Linking projects to supervisors...');
    let projectLinkedCount = 0;
    
    // Distribute projects among supervisors
    const projectsPerSupervisor = Math.ceil(projectIds.length / supervisorIds.length);
    
    for (let i = 0; i < projectIds.length; i++) {
      const supervisorIndex = Math.floor(i / projectsPerSupervisor) % supervisorIds.length;
      const supervisorId = supervisorIds[supervisorIndex];
      const projectId = projectIds[i];
      
      try {
        await client.query(
          `INSERT INTO supervisor_projects_relation (project_id, supervisor_id)
           VALUES ($1, $2)
           ON CONFLICT (supervisor_id, project_id) DO NOTHING`,
          [projectId, supervisorId]
        );
        projectLinkedCount++;
      } catch (error) {
        console.log(`   ⚠️  Error linking project: ${error.message}`);
      }
    }
    console.log(`   ✅ Linked ${projectLinkedCount} projects to supervisors`);

    // ============================================
    // 8. ASSIGN WORKERS TO PROJECTS
    // ============================================
    console.log('\n8. Assigning workers to projects...');
    let assignedCount = 0;
    
    // Assign workers to projects (each worker to 1-2 projects)
    for (let i = 0; i < employeeIds.length; i++) {
      const { employeeId } = employeeIds[i];
      const projectIndex = i % projectIds.length;
      const projectId = projectIds[projectIndex];
      
      try {
        await client.query(
          `UPDATE employees SET project_id = $1 WHERE id = $2`,
          [projectId, employeeId]
        );
        assignedCount++;
      } catch (error) {
        console.log(`   ⚠️  Error assigning project: ${error.message}`);
      }
    }
    console.log(`   ✅ Assigned ${assignedCount} workers to projects`);

    // ============================================
    // 9. CREATE SAMPLE ATTENDANCE RECORDS
    // ============================================
    console.log('\n9. Creating sample attendance records...');
    let attendanceCount = 0;
    
    // Create attendance for last 7 days for each worker
    const today = new Date();
    for (const { userId, worker } of employeeIds) {
      for (let day = 0; day < 7; day++) {
        const date = new Date(today);
        date.setDate(date.getDate() - day);
        
        // Skip weekends (Saturday = 6, Sunday = 0)
        if (date.getDay() === 0 || date.getDay() === 6) continue;
        
        // Random check-in time between 7 AM and 9 AM
        const checkInHour = 7 + Math.floor(Math.random() * 2);
        const checkInMinute = Math.floor(Math.random() * 60);
        const checkInTime = new Date(date);
        checkInTime.setHours(checkInHour, checkInMinute, 0, 0);
        
        // Random check-out time between 4 PM and 6 PM
        const checkOutHour = 16 + Math.floor(Math.random() * 2);
        const checkOutMinute = Math.floor(Math.random() * 60);
        const checkOutTime = new Date(date);
        checkOutTime.setHours(checkOutHour, checkOutMinute, 0, 0);
        
        const attendanceId = crypto.randomUUID();
        
        try {
          await client.query(
            `INSERT INTO attendance_logs (id, user_id, check_in_time, check_out_time, latitude, longitude)
             VALUES ($1, $2, $3, $4, $5, $6)
             ON CONFLICT DO NOTHING`,
            [
              attendanceId,
              userId,
              checkInTime.toISOString(),
              checkOutTime.toISOString(),
              40.7128 + (Math.random() - 0.5) * 0.01, // NYC area coordinates with variation
              -74.0060 + (Math.random() - 0.5) * 0.01,
            ]
          );
          attendanceCount++;
        } catch (error) {
          // Ignore duplicate errors
        }
      }
    }
    console.log(`   ✅ Created ${attendanceCount} attendance records`);

    // ============================================
    // 10. CREATE SAMPLE TASKS
    // ============================================
    console.log('\n10. Creating sample tasks...');
    let taskCount = 0;
    
    const taskTemplates = [
      { title: 'Install electrical wiring', description: 'Complete electrical installation for floor 3' },
      { title: 'Paint exterior walls', description: 'Apply primer and paint to building exterior' },
      { title: 'Install plumbing fixtures', description: 'Install sinks and toilets in bathrooms' },
      { title: 'Lay foundation concrete', description: 'Pour and level foundation concrete' },
      { title: 'Install windows', description: 'Install all windows for building facade' },
      { title: 'Roofing work', description: 'Complete roofing installation' },
      { title: 'Flooring installation', description: 'Install tiles and hardwood floors' },
      { title: 'HVAC system setup', description: 'Install heating and cooling systems' },
    ];
    
    for (let i = 0; i < employeeIds.length && i < projectIds.length; i++) {
      const { employeeId } = employeeIds[i];
      const projectId = projectIds[i % projectIds.length];
      
      // Find supervisor for this worker
      const supervisorResult = await client.query(
        'SELECT supervisor_id FROM worker_supervisor_relation WHERE worker_id = $1 LIMIT 1',
        [employeeId]
      );
      
      if (supervisorResult.rows.length > 0) {
        const supervisorId = supervisorResult.rows[0].supervisor_id;
        const taskTemplate = taskTemplates[i % taskTemplates.length];
        const taskId = crypto.randomUUID();
        
        // Due date in 1-2 weeks
        const dueDate = new Date();
        dueDate.setDate(dueDate.getDate() + 7 + Math.floor(Math.random() * 7));
        
        const statuses = ['pending', 'in_progress', 'completed'];
        const status = statuses[Math.floor(Math.random() * statuses.length)];
        
        try {
          await client.query(
            `INSERT INTO worker_tasks (id, project_id, worker_id, supervisor_id, title, description, status, due_date)
             VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
            [
              taskId,
              projectId,
              employeeId,
              supervisorId,
              taskTemplate.title,
              taskTemplate.description,
              status,
              dueDate.toISOString().split('T')[0],
            ]
          );
          taskCount++;
        } catch (error) {
          console.log(`   ⚠️  Error creating task: ${error.message}`);
        }
      }
    }
    console.log(`   ✅ Created ${taskCount} tasks`);

    // ============================================
    // 11. CREATE SAMPLE NOTIFICATIONS
    // ============================================
    console.log('\n11. Creating sample notifications...');
    let notificationCount = 0;
    
    for (const supervisorId of supervisorIds) {
      const notificationTypes = [
        { type: 'worker_absent', title: 'Worker Absent', message: 'John Smith did not check in today' },
        { type: 'delayed_task', title: 'Delayed Task', message: 'Task "Install windows" is overdue' },
        { type: 'location_mismatch', title: 'Location Mismatch', message: 'Check-in location does not match project site' },
      ];
      
      // Create 2-3 notifications per supervisor
      for (let i = 0; i < 3; i++) {
        const notificationId = crypto.randomUUID();
        const notification = notificationTypes[i % notificationTypes.length];
        const createdAt = new Date();
        createdAt.setHours(createdAt.getHours() - Math.floor(Math.random() * 24));
        
        try {
          await client.query(
            `INSERT INTO notifications (id, supervisor_id, type, title, message, is_read, created_at)
             VALUES ($1, $2, $3, $4, $5, $6, $7)`,
            [
              notificationId,
              supervisorId,
              notification.type,
              notification.title,
              notification.message,
              Math.random() > 0.5, // Random read/unread
              createdAt.toISOString(),
            ]
          );
          notificationCount++;
        } catch (error) {
          console.log(`   ⚠️  Error creating notification: ${error.message}`);
        }
      }
    }
    console.log(`   ✅ Created ${notificationCount} notifications`);

    await client.query('COMMIT');

    // ============================================
    // SUMMARY
    // ============================================
    console.log('\n🎉 Seed process completed successfully!\n');
    console.log('📊 Summary:');
    console.log(`   ✅ ${adminIds.length} Admin accounts`);
    console.log(`   ✅ ${supervisorIds.length} Supervisor accounts`);
    console.log(`   ✅ ${employeeIds.length} Worker accounts (users + employees)`);
    console.log(`   ✅ ${projectIds.length} Projects`);
    console.log(`   ✅ ${linkedCount} Worker-Supervisor relations`);
    console.log(`   ✅ ${projectLinkedCount} Supervisor-Project relations`);
    console.log(`   ✅ ${assignedCount} Worker-Project assignments`);
    console.log(`   ✅ ${attendanceCount} Attendance records`);
    console.log(`   ✅ ${taskCount} Tasks`);
    console.log(`   ✅ ${notificationCount} Notifications`);
    
    console.log('\n📋 Login Credentials:\n');
    
    console.log('👤 ADMIN PORTAL:');
    admins.forEach(admin => {
      console.log(`   Email: ${admin.email}`);
      console.log(`   Password: ${admin.password}`);
    });
    
    console.log('\n👷 SUPERVISOR APP:');
    supervisors.forEach(supervisor => {
      console.log(`   Email: ${supervisor.email}`);
      console.log(`   Password: ${supervisor.password}`);
    });
    
    console.log('\n👨‍🔧 WORKER ATTENDANCE APP:');
    workers.slice(0, 5).forEach(worker => {
      console.log(`   Email: ${worker.email}`);
      console.log(`   Password: ${worker.password}`);
    });
    console.log(`   ... and ${workers.length - 5} more workers`);
    
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
seedAllData()
  .then(() => {
    console.log('✅ Seed script finished');
    process.exit(0);
  })
  .catch((error) => {
    console.error('❌ Seed script failed:', error);
    process.exit(1);
  });

