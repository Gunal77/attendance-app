/**
 * Seed sample attendance records and notifications for supervisors
 * 
 * Usage: node scripts/seed_attendance_notifications.js
 */

const db = require('../config/db');

async function seedAttendanceAndNotifications() {
  const client = await db.getClient();
  
  try {
    await client.query('BEGIN');
    console.log('🌱 Seeding attendance and notifications...\n');

    // 1. Get supervisors and their workers
    console.log('1. Fetching supervisors and workers...');
    const supervisorsResult = await client.query('SELECT id, name, email FROM supervisors');
    const supervisors = supervisorsResult.rows;
    
    if (supervisors.length === 0) {
      console.log('   ⚠️  No supervisors found.');
      await client.query('ROLLBACK');
      return;
    }

    // Get workers for each supervisor
    // Note: attendance_logs.user_id references users table
    // We need to find users that correspond to employees
    const supervisorWorkers = {};
    for (const supervisor of supervisors) {
      const workersResult = await client.query(
        `SELECT wsr.worker_id, e.email
         FROM worker_supervisor_relation wsr
         JOIN employees e ON e.id = wsr.worker_id
         WHERE wsr.supervisor_id = $1`,
        [supervisor.id]
      );
      
      // Get user IDs by email (employees and users share emails)
      const userIds = [];
      for (const row of workersResult.rows) {
        if (row.email) {
          const userResult = await client.query('SELECT id FROM users WHERE email = $1', [row.email]);
          if (userResult.rows.length > 0) {
            userIds.push(userResult.rows[0].id);
          }
        }
      }
      supervisorWorkers[supervisor.id] = userIds;
    }

    // 2. Create sample attendance records (today and yesterday)
    console.log('\n2. Creating attendance records...');
    const today = new Date();
    today.setHours(8, 0, 0, 0); // 8 AM check-in
    const todayCheckOut = new Date(today);
    todayCheckOut.setHours(17, 0, 0, 0); // 5 PM check-out

    const yesterday = new Date(today);
    yesterday.setDate(yesterday.getDate() - 1);
    yesterday.setHours(8, 30, 0, 0);
    const yesterdayCheckOut = new Date(yesterday);
    yesterdayCheckOut.setHours(16, 30, 0, 0);

    let attendanceCount = 0;
    for (const supervisor of supervisors) {
      const workers = supervisorWorkers[supervisor.id] || [];
      for (let i = 0; i < Math.min(workers.length, 5); i++) {
        const workerId = workers[i];
        
        // Today's attendance
        try {
          const result = await client.query(
            `INSERT INTO attendance_logs (id, user_id, check_in_time, check_out_time, latitude, longitude)
             VALUES (gen_random_uuid(), $1, $2, $3, $4, $5)`,
            [
              workerId,
              today.toISOString(),
              todayCheckOut.toISOString(),
              40.7128 + (Math.random() * 0.01), // Random lat near NYC
              -74.0060 + (Math.random() * 0.01), // Random lng near NYC
            ]
          );
          if (result.rowCount > 0) attendanceCount++;
        } catch (e) {
          console.log(`   ⚠️  Error creating attendance: ${e.message}`);
        }

        // Yesterday's attendance
        try {
          const result = await client.query(
            `INSERT INTO attendance_logs (id, user_id, check_in_time, check_out_time, latitude, longitude)
             VALUES (gen_random_uuid(), $1, $2, $3, $4, $5)`,
            [
              workerId,
              yesterday.toISOString(),
              yesterdayCheckOut.toISOString(),
              40.7128 + (Math.random() * 0.01),
              -74.0060 + (Math.random() * 0.01),
            ]
          );
          if (result.rowCount > 0) attendanceCount++;
        } catch (e) {
          console.log(`   ⚠️  Error creating attendance: ${e.message}`);
        }
      }
    }
    console.log(`   ✅ Created ${attendanceCount} attendance records`);

    // 3. Create sample notifications
    console.log('\n3. Creating notifications...');
    const notificationTypes = [
      { type: 'worker_absent', title: 'Worker Absent', message: 'Worker did not check in today' },
      { type: 'location_mismatch', title: 'Location Mismatch', message: 'Worker checked in from unexpected location' },
      { type: 'delayed_task', title: 'Delayed Task', message: 'Task deadline approaching' },
      { type: 'attendance_override', title: 'Attendance Override', message: 'Manual attendance entry created' },
    ];

    let notificationCount = 0;
    for (const supervisor of supervisors) {
      // Create 2-3 notifications per supervisor
      for (let i = 0; i < 3; i++) {
        const notifType = notificationTypes[i % notificationTypes.length];
        const createdAt = new Date();
        createdAt.setHours(createdAt.getHours() - i); // Stagger times

        try {
          const result = await client.query(
            `INSERT INTO notifications (id, supervisor_id, type, title, message, is_read, created_at)
             VALUES (gen_random_uuid(), $1, $2, $3, $4, $5, $6)`,
            [
              supervisor.id,
              notifType.type,
              notifType.title,
              notifType.message,
              i === 0 ? false : true, // First one unread
              createdAt.toISOString(),
            ]
          );
          if (result.rowCount > 0) notificationCount++;
        } catch (e) {
          console.log(`   ⚠️  Error creating notification: ${e.message}`);
        }
      }
    }
    console.log(`   ✅ Created ${notificationCount} notifications`);

    await client.query('COMMIT');
    console.log('\n✅ Seeding completed successfully!\n');
    
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('❌ Error seeding data:', error);
    throw error;
  } finally {
    client.release();
  }
}

// Run the script
seedAttendanceAndNotifications()
  .then(() => {
    console.log('🎉 Script completed!');
    process.exit(0);
  })
  .catch((error) => {
    console.error('💥 Script failed:', error);
    process.exit(1);
  });

