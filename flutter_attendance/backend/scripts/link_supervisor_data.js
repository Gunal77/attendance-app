/**
 * Link existing workers and projects to supervisors
 * 
 * This script links existing workers (employees) and projects to supervisors
 * that were created through the admin portal or other means.
 * 
 * Usage: node scripts/link_supervisor_data.js
 */

const db = require('../config/db');

async function linkSupervisorData() {
  const client = await db.getClient();
  
  try {
    await client.query('BEGIN');
    console.log('🔗 Linking existing data to supervisors...\n');

    // 1. Get all supervisors
    console.log('1. Fetching supervisors...');
    const supervisorsResult = await client.query('SELECT id, name, email FROM supervisors');
    const supervisors = supervisorsResult.rows;
    
    if (supervisors.length === 0) {
      console.log('   ⚠️  No supervisors found. Please create a supervisor first.');
      await client.query('ROLLBACK');
      return;
    }
    
    console.log(`   ✅ Found ${supervisors.length} supervisor(s):`);
    supervisors.forEach(s => console.log(`      - ${s.name} (${s.email})`));

    // 2. Get all workers (employees)
    console.log('\n2. Fetching workers (employees)...');
    const workersResult = await client.query('SELECT id, name, email FROM employees');
    const workers = workersResult.rows;
    
    if (workers.length === 0) {
      console.log('   ⚠️  No workers found. Please create workers first.');
    } else {
      console.log(`   ✅ Found ${workers.length} worker(s)`);
    }

    // 3. Get all projects
    console.log('\n3. Fetching projects...');
    const projectsResult = await client.query('SELECT id, name FROM projects');
    const projects = projectsResult.rows;
    
    if (projects.length === 0) {
      console.log('   ⚠️  No projects found. Please create projects first.');
    } else {
      console.log(`   ✅ Found ${projects.length} project(s)`);
    }

    // 4. Link workers to supervisors
    if (workers.length > 0 && supervisors.length > 0) {
      console.log('\n4. Linking workers to supervisors...');
      let linkedWorkers = 0;
      let skippedWorkers = 0;

      // Distribute workers evenly among supervisors
      const workersPerSupervisor = Math.ceil(workers.length / supervisors.length);

      for (let i = 0; i < workers.length; i++) {
        const worker = workers[i];
        const supervisorIndex = Math.floor(i / workersPerSupervisor) % supervisors.length;
        const supervisor = supervisors[supervisorIndex];

        // Check if relation already exists
        const existingRelation = await client.query(
          'SELECT id FROM worker_supervisor_relation WHERE worker_id = $1 AND supervisor_id = $2',
          [worker.id, supervisor.id]
        );

        if (existingRelation.rows.length > 0) {
          skippedWorkers++;
          continue;
        }

        try {
          await client.query(
            `INSERT INTO worker_supervisor_relation (worker_id, supervisor_id)
             VALUES ($1, $2)
             ON CONFLICT (worker_id, supervisor_id) DO NOTHING`,
            [worker.id, supervisor.id]
          );
          linkedWorkers++;
          console.log(`   ✅ Linked ${worker.name} to ${supervisor.name}`);
        } catch (error) {
          console.log(`   ⚠️  Error linking ${worker.name}: ${error.message}`);
        }
      }

      console.log(`\n   📊 Summary: ${linkedWorkers} workers linked, ${skippedWorkers} already linked`);
    }

    // 5. Link projects to supervisors
    if (projects.length > 0 && supervisors.length > 0) {
      console.log('\n5. Linking projects to supervisors...');
      let linkedProjects = 0;
      let skippedProjects = 0;

      // Distribute projects evenly among supervisors
      const projectsPerSupervisor = Math.ceil(projects.length / supervisors.length);

      for (let i = 0; i < projects.length; i++) {
        const project = projects[i];
        const supervisorIndex = Math.floor(i / projectsPerSupervisor) % supervisors.length;
        const supervisor = supervisors[supervisorIndex];

        // Check if relation already exists
        const existingRelation = await client.query(
          'SELECT id FROM supervisor_projects_relation WHERE project_id = $1 AND supervisor_id = $2',
          [project.id, supervisor.id]
        );

        if (existingRelation.rows.length > 0) {
          skippedProjects++;
          continue;
        }

        try {
          await client.query(
            `INSERT INTO supervisor_projects_relation (project_id, supervisor_id)
             VALUES ($1, $2)
             ON CONFLICT (supervisor_id, project_id) DO NOTHING`,
            [project.id, supervisor.id]
          );
          linkedProjects++;
          console.log(`   ✅ Linked ${project.name} to ${supervisor.name}`);
        } catch (error) {
          console.log(`   ⚠️  Error linking ${project.name}: ${error.message}`);
        }
      }

      console.log(`\n   📊 Summary: ${linkedProjects} projects linked, ${skippedProjects} already linked`);
    }

    // 6. Show summary
    console.log('\n' + '='.repeat(50));
    console.log('✅ Linking completed successfully!');
    console.log('='.repeat(50));
    
    // Show what each supervisor has
    console.log('\n📋 Supervisor Summary:');
    for (const supervisor of supervisors) {
      const workerCount = await client.query(
        'SELECT COUNT(*) FROM worker_supervisor_relation WHERE supervisor_id = $1',
        [supervisor.id]
      );
      const projectCount = await client.query(
        'SELECT COUNT(*) FROM supervisor_projects_relation WHERE supervisor_id = $1',
        [supervisor.id]
      );
      
      console.log(`\n   ${supervisor.name} (${supervisor.email}):`);
      console.log(`      - Workers: ${workerCount.rows[0].count}`);
      console.log(`      - Projects: ${projectCount.rows[0].count}`);
    }

    await client.query('COMMIT');
    console.log('\n✅ All changes committed to database!\n');
    
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('❌ Error linking data:', error);
    throw error;
  } finally {
    client.release();
  }
}

// Run the script
linkSupervisorData()
  .then(() => {
    console.log('🎉 Script completed successfully!');
    process.exit(0);
  })
  .catch((error) => {
    console.error('💥 Script failed:', error);
    process.exit(1);
  });

