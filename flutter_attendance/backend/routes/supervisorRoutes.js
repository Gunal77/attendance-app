const express = require('express');
const { supabase } = require('../config/supabaseClient');
const supervisorAuthMiddleware = require('../middleware/supervisorAuthMiddleware');
const multer = require('multer');
const { uploadToSupabase } = require('../services/uploadService');

const router = express.Router();

// All routes require supervisor authentication
router.use(supervisorAuthMiddleware);

// GET /supervisor/workers - Get all workers under supervisor
router.get('/workers', async (req, res) => {
  try {
    const supervisorId = req.user.id;

    const { data, error } = await supabase
      .from('worker_supervisor_relation')
      .select(`
        worker_id,
        assigned_at,
        employees:worker_id (
          id,
          name,
          email,
          phone,
          role,
          project_id,
          created_at,
          projects:project_id (
            id,
            name,
            location
          )
        )
      `)
      .eq('supervisor_id', supervisorId)
      .order('assigned_at', { ascending: false });

    if (error) {
      return res.status(500).json({ message: error.message || 'Failed to fetch workers' });
    }

    const workers = (data || [])
      .filter(item => item.employees != null)
      .map(item => ({
        ...item.employees,
        assignedAt: item.assigned_at,
        project: item.employees?.projects || null,
      }));

    return res.json({ workers });
  } catch (err) {
    console.error('Get workers error', err);
    return res.status(500).json({ message: 'Error fetching workers' });
  }
});

// GET /supervisor/workers/:id - Get worker details
router.get('/workers/:id', async (req, res) => {
  try {
    const supervisorId = req.user.id;
    const workerId = req.params.id;

    // Verify worker is under this supervisor
    const { data: relation, error: relationError } = await supabase
      .from('worker_supervisor_relation')
      .select('worker_id')
      .eq('supervisor_id', supervisorId)
      .eq('worker_id', workerId)
      .maybeSingle();

    if (relationError || !relation) {
      return res.status(403).json({ message: 'Worker not found or access denied' });
    }

    const { data: worker, error } = await supabase
      .from('employees')
      .select(`
        *,
        projects:project_id (
          id,
          name,
          location
        )
      `)
      .eq('id', workerId)
      .maybeSingle();

    if (error) {
      return res.status(500).json({ message: error.message || 'Failed to fetch worker' });
    }

    if (!worker) {
      return res.status(404).json({ message: 'Worker not found' });
    }

    return res.json({ worker });
  } catch (err) {
    console.error('Get worker error', err);
    return res.status(500).json({ message: 'Error fetching worker' });
  }
});

// PUT /supervisor/workers/:id - Update worker details
router.put('/workers/:id', async (req, res) => {
  try {
    const supervisorId = req.user.id;
    const workerId = req.params.id;

    // Verify worker is under this supervisor
    const { data: relation, error: relationError } = await supabase
      .from('worker_supervisor_relation')
      .select('worker_id')
      .eq('supervisor_id', supervisorId)
      .eq('worker_id', workerId)
      .maybeSingle();

    if (relationError || !relation) {
      return res.status(403).json({ message: 'Worker not found or access denied' });
    }

    const { name, email, phone, role, project_id } = req.body;
    const updateData = {};

    if (name) updateData.name = name;
    if (email) updateData.email = email;
    if (phone) updateData.phone = phone;
    if (role) updateData.role = role;
    if (project_id !== undefined) updateData.project_id = project_id;

    const { data: worker, error } = await supabase
      .from('employees')
      .update(updateData)
      .eq('id', workerId)
      .select()
      .single();

    if (error) {
      return res.status(500).json({ message: error.message || 'Failed to update worker' });
    }

    return res.json({ worker, message: 'Worker updated successfully' });
  } catch (err) {
    console.error('Update worker error', err);
    return res.status(500).json({ message: 'Error updating worker' });
  }
});

// POST /supervisor/workers/:id/assign-project - Assign worker to project
router.post('/workers/:id/assign-project', async (req, res) => {
  try {
    const supervisorId = req.user.id;
    const workerId = req.params.id;
    const { project_id } = req.body;

    if (!project_id) {
      return res.status(400).json({ message: 'project_id is required' });
    }

    // Verify worker is under this supervisor
    const { data: relation, error: relationError } = await supabase
      .from('worker_supervisor_relation')
      .select('worker_id')
      .eq('supervisor_id', supervisorId)
      .eq('worker_id', workerId)
      .maybeSingle();

    if (relationError || !relation) {
      return res.status(403).json({ message: 'Worker not found or access denied' });
    }

    // Verify supervisor has access to this project
    const { data: projectRelation, error: projectRelationError } = await supabase
      .from('supervisor_projects_relation')
      .select('project_id')
      .eq('supervisor_id', supervisorId)
      .eq('project_id', project_id)
      .maybeSingle();

    if (projectRelationError || !projectRelation) {
      return res.status(403).json({ message: 'Project not found or access denied' });
    }

    const { data: worker, error } = await supabase
      .from('employees')
      .update({ project_id })
      .eq('id', workerId)
      .select()
      .single();

    if (error) {
      return res.status(500).json({ message: error.message || 'Failed to assign project' });
    }

    return res.json({ worker, message: 'Worker assigned to project successfully' });
  } catch (err) {
    console.error('Assign project error', err);
    return res.status(500).json({ message: 'Error assigning project' });
  }
});

// DELETE /supervisor/workers/:id/remove-project - Remove worker from project
router.delete('/workers/:id/remove-project', async (req, res) => {
  try {
    const supervisorId = req.user.id;
    const workerId = req.params.id;

    // Verify worker is under this supervisor
    const { data: relation, error: relationError } = await supabase
      .from('worker_supervisor_relation')
      .select('worker_id')
      .eq('supervisor_id', supervisorId)
      .eq('worker_id', workerId)
      .maybeSingle();

    if (relationError || !relation) {
      return res.status(403).json({ message: 'Worker not found or access denied' });
    }

    const { data: worker, error } = await supabase
      .from('employees')
      .update({ project_id: null })
      .eq('id', workerId)
      .select()
      .single();

    if (error) {
      return res.status(500).json({ message: error.message || 'Failed to remove project' });
    }

    return res.json({ worker, message: 'Worker removed from project successfully' });
  } catch (err) {
    console.error('Remove project error', err);
    return res.status(500).json({ message: 'Error removing project' });
  }
});

// GET /supervisor/attendance - Get attendance records
router.get('/attendance', async (req, res) => {
  try {
    const supervisorId = req.user.id;
    const { worker_id, date, month, year, start_date, end_date } = req.query;

    // Get all worker IDs under this supervisor
    const { data: relations, error: relationsError } = await supabase
      .from('worker_supervisor_relation')
      .select(`
        worker_id,
        employees:worker_id (
          email
        )
      `)
      .eq('supervisor_id', supervisorId);

    if (relationsError) {
      return res.status(500).json({ message: 'Failed to fetch workers' });
    }

    const workerEmails = (relations || [])
      .filter(r => r.employees?.email)
      .map(r => r.employees.email);

    if (workerEmails.length === 0) {
      return res.json({ attendance: [] });
    }

    // Get user IDs by email (employees and users share emails)
    const { data: users, error: usersError } = await supabase
      .from('users')
      .select('id')
      .in('email', workerEmails);

    if (usersError || !users || users.length === 0) {
      return res.json({ attendance: [] });
    }

    const userIds = users.map(u => u.id);

    let query = supabase
      .from('attendance_logs')
      .select(`
        *,
        users:user_id (
          id,
          email
        )
      `)
      .in('user_id', userIds);

    if (worker_id) {
      query = query.eq('user_id', worker_id);
    }

    if (date) {
      query = query.gte('check_in_time', `${date}T00:00:00Z`)
        .lt('check_in_time', `${date}T23:59:59Z`);
    } else if (start_date && end_date) {
      query = query.gte('check_in_time', `${start_date}T00:00:00Z`)
        .lte('check_in_time', `${end_date}T23:59:59Z`);
    } else if (month && year) {
      const start = `${year}-${String(month).padStart(2, '0')}-01`;
      const end = `${year}-${String(month).padStart(2, '0')}-31`;
      query = query.gte('check_in_time', `${start}T00:00:00Z`)
        .lte('check_in_time', `${end}T23:59:59Z`);
    }

    query = query.order('check_in_time', { ascending: false });

    const { data: attendance, error } = await query;

    if (error) {
      return res.status(500).json({ message: error.message || 'Failed to fetch attendance' });
    }

    return res.json({ attendance: attendance || [] });
  } catch (err) {
    console.error('Get attendance error', err);
    return res.status(500).json({ message: 'Error fetching attendance' });
  }
});

// POST /supervisor/attendance/override - Manual attendance override
router.post('/attendance/override', async (req, res) => {
  try {
    const supervisorId = req.user.id;
    const { worker_id, date, check_in_time, check_out_time, reason } = req.body;

    if (!worker_id || !date) {
      return res.status(400).json({ message: 'worker_id and date are required' });
    }

    // Verify worker is under this supervisor
    const { data: relation, error: relationError } = await supabase
      .from('worker_supervisor_relation')
      .select('worker_id')
      .eq('supervisor_id', supervisorId)
      .eq('worker_id', worker_id)
      .maybeSingle();

    if (relationError || !relation) {
      return res.status(403).json({ message: 'Worker not found or access denied' });
    }

    const overrideData = {
      worker_id,
      supervisor_id: supervisorId,
      date,
      check_in_time: check_in_time || null,
      check_out_time: check_out_time || null,
      reason: reason || null,
    };

    const { data: override, error } = await supabase
      .from('attendance_override')
      .upsert(overrideData, { onConflict: 'worker_id,date' })
      .select()
      .single();

    if (error) {
      return res.status(500).json({ message: error.message || 'Failed to override attendance' });
    }

    // Create notification
    await supabase.from('notifications').insert({
      supervisor_id: supervisorId,
      type: 'attendance_override',
      title: 'Attendance Override',
      message: `Manual attendance entry created for ${date}`,
      related_entity_type: 'attendance',
      related_entity_id: override.id,
    });

    return res.json({ override, message: 'Attendance override created successfully' });
  } catch (err) {
    console.error('Attendance override error', err);
    return res.status(500).json({ message: 'Error overriding attendance' });
  }
});

// GET /supervisor/projects - Get assigned projects
router.get('/projects', async (req, res) => {
  try {
    const supervisorId = req.user.id;

    const { data, error } = await supabase
      .from('supervisor_projects_relation')
      .select(`
        project_id,
        assigned_at,
        projects:project_id (
          id,
          name,
          location,
          start_date,
          end_date,
          description,
          budget,
          created_at
        )
      `)
      .eq('supervisor_id', supervisorId)
      .order('assigned_at', { ascending: false });

    if (error) {
      return res.status(500).json({ message: error.message || 'Failed to fetch projects' });
    }

    const projects = (data || []).map(item => ({
      ...item.projects,
      assignedAt: item.assigned_at,
    }));

    return res.json({ projects });
  } catch (err) {
    console.error('Get projects error', err);
    return res.status(500).json({ message: 'Error fetching projects' });
  }
});

// GET /supervisor/projects/:id - Get project details
router.get('/projects/:id', async (req, res) => {
  try {
    const supervisorId = req.user.id;
    const projectId = req.params.id;

    // Verify supervisor has access to this project
    const { data: relation, error: relationError } = await supabase
      .from('supervisor_projects_relation')
      .select('project_id')
      .eq('supervisor_id', supervisorId)
      .eq('project_id', projectId)
      .maybeSingle();

    if (relationError || !relation) {
      return res.status(403).json({ message: 'Project not found or access denied' });
    }

    const { data: project, error } = await supabase
      .from('projects')
      .select('*')
      .eq('id', projectId)
      .maybeSingle();

    if (error) {
      return res.status(500).json({ message: error.message || 'Failed to fetch project' });
    }

    if (!project) {
      return res.status(404).json({ message: 'Project not found' });
    }

    return res.json({ project });
  } catch (err) {
    console.error('Get project error', err);
    return res.status(500).json({ message: 'Error fetching project' });
  }
});

// GET /supervisor/projects/:id/tasks - Get tasks for a project
router.get('/projects/:id/tasks', async (req, res) => {
  try {
    const supervisorId = req.user.id;
    const projectId = req.params.id;

    // Verify supervisor has access to this project
    const { data: relation, error: relationError } = await supabase
      .from('supervisor_projects_relation')
      .select('project_id')
      .eq('supervisor_id', supervisorId)
      .eq('project_id', projectId)
      .maybeSingle();

    if (relationError || !relation) {
      return res.status(403).json({ message: 'Project not found or access denied' });
    }

    const { data: tasks, error } = await supabase
      .from('worker_tasks')
      .select(`
        *,
        employees:worker_id (
          id,
          name,
          email
        )
      `)
      .eq('project_id', projectId)
      .eq('supervisor_id', supervisorId)
      .order('created_at', { ascending: false });

    if (error) {
      return res.status(500).json({ message: error.message || 'Failed to fetch tasks' });
    }

    return res.json({ tasks: tasks || [] });
  } catch (err) {
    console.error('Get tasks error', err);
    return res.status(500).json({ message: 'Error fetching tasks' });
  }
});

// POST /supervisor/projects/:id/tasks - Create task
router.post('/projects/:id/tasks', async (req, res) => {
  try {
    const supervisorId = req.user.id;
    const projectId = req.params.id;
    const { worker_id, title, description, due_date } = req.body;

    if (!worker_id || !title) {
      return res.status(400).json({ message: 'worker_id and title are required' });
    }

    // Verify supervisor has access to this project
    const { data: projectRelation, error: projectRelationError } = await supabase
      .from('supervisor_projects_relation')
      .select('project_id')
      .eq('supervisor_id', supervisorId)
      .eq('project_id', projectId)
      .maybeSingle();

    if (projectRelationError || !projectRelation) {
      return res.status(403).json({ message: 'Project not found or access denied' });
    }

    // Verify worker is under this supervisor
    const { data: workerRelation, error: workerRelationError } = await supabase
      .from('worker_supervisor_relation')
      .select('worker_id')
      .eq('supervisor_id', supervisorId)
      .eq('worker_id', worker_id)
      .maybeSingle();

    if (workerRelationError || !workerRelation) {
      return res.status(403).json({ message: 'Worker not found or access denied' });
    }

    const taskData = {
      project_id: projectId,
      worker_id,
      supervisor_id: supervisorId,
      title,
      description: description || null,
      due_date: due_date || null,
      status: 'pending',
    };

    const { data: task, error } = await supabase
      .from('worker_tasks')
      .insert(taskData)
      .select()
      .single();

    if (error) {
      return res.status(500).json({ message: error.message || 'Failed to create task' });
    }

    return res.json({ task, message: 'Task created successfully' });
  } catch (err) {
    console.error('Create task error', err);
    return res.status(500).json({ message: 'Error creating task' });
  }
});

// PUT /supervisor/tasks/:id - Update task
router.put('/tasks/:id', async (req, res) => {
  try {
    const supervisorId = req.user.id;
    const taskId = req.params.id;
    const { title, description, status, due_date } = req.body;

    // Verify task belongs to this supervisor
    const { data: existingTask, error: fetchError } = await supabase
      .from('worker_tasks')
      .select('id, status')
      .eq('id', taskId)
      .eq('supervisor_id', supervisorId)
      .maybeSingle();

    if (fetchError || !existingTask) {
      return res.status(403).json({ message: 'Task not found or access denied' });
    }

    const updateData = {};
    if (title) updateData.title = title;
    if (description !== undefined) updateData.description = description;
    if (status) {
      updateData.status = status;
      if (status === 'completed') {
        updateData.completed_at = new Date().toISOString();
      }
    }
    if (due_date !== undefined) updateData.due_date = due_date;
    updateData.updated_at = new Date().toISOString();

    const { data: task, error } = await supabase
      .from('worker_tasks')
      .update(updateData)
      .eq('id', taskId)
      .select()
      .single();

    if (error) {
      return res.status(500).json({ message: error.message || 'Failed to update task' });
    }

    return res.json({ task, message: 'Task updated successfully' });
  } catch (err) {
    console.error('Update task error', err);
    return res.status(500).json({ message: 'Error updating task' });
  }
});

// POST /supervisor/projects/:id/progress - Update project progress
const upload = multer({ storage: multer.memoryStorage() });

router.post('/projects/:id/progress', upload.array('photos', 10), async (req, res) => {
  try {
    const supervisorId = req.user.id;
    const projectId = req.params.id;
    const { progress_percentage, notes } = req.body;

    if (progress_percentage === undefined) {
      return res.status(400).json({ message: 'progress_percentage is required' });
    }

    // Verify supervisor has access to this project
    const { data: relation, error: relationError } = await supabase
      .from('supervisor_projects_relation')
      .select('project_id')
      .eq('supervisor_id', supervisorId)
      .eq('project_id', projectId)
      .maybeSingle();

    if (relationError || !relation) {
      return res.status(403).json({ message: 'Project not found or access denied' });
    }

    // Upload photos if any
    const photoUrls = [];
    if (req.files && req.files.length > 0) {
      for (const file of req.files) {
        const photoUrl = await uploadToSupabase(file, 'project-progress');
        if (photoUrl) photoUrls.push(photoUrl);
      }
    }

    const progressData = {
      project_id: projectId,
      supervisor_id: supervisorId,
      progress_percentage: parseInt(progress_percentage),
      notes: notes || null,
      photo_urls: photoUrls.length > 0 ? photoUrls : null,
    };

    const { data: progress, error } = await supabase
      .from('project_progress')
      .insert(progressData)
      .select()
      .single();

    if (error) {
      return res.status(500).json({ message: error.message || 'Failed to update progress' });
    }

    return res.json({ progress, message: 'Project progress updated successfully' });
  } catch (err) {
    console.error('Update progress error', err);
    return res.status(500).json({ message: 'Error updating progress' });
  }
});

// GET /supervisor/dashboard - Get dashboard stats
router.get('/dashboard', async (req, res) => {
  try {
    const supervisorId = req.user.id;

    // Get total workers
    const { count: totalWorkers } = await supabase
      .from('worker_supervisor_relation')
      .select('*', { count: 'exact', head: true })
      .eq('supervisor_id', supervisorId);

    // Get total projects
    const { count: totalProjects } = await supabase
      .from('supervisor_projects_relation')
      .select('*', { count: 'exact', head: true })
      .eq('supervisor_id', supervisorId);

    // Get today's attendance
    const today = new Date().toISOString().split('T')[0];
    const { data: workerRelations } = await supabase
      .from('worker_supervisor_relation')
      .select('worker_id')
      .eq('supervisor_id', supervisorId);

    const workerIds = (workerRelations || []).map(r => r.worker_id);
    let presentToday = 0;
    if (workerIds.length > 0) {
      const { count } = await supabase
        .from('attendance_logs')
        .select('*', { count: 'exact', head: true })
        .in('user_id', workerIds)
        .gte('check_in_time', `${today}T00:00:00Z`)
        .lt('check_in_time', `${today}T23:59:59Z`);
      presentToday = count || 0;
    }

    // Get pending tasks
    const { count: pendingTasks } = await supabase
      .from('worker_tasks')
      .select('*', { count: 'exact', head: true })
      .eq('supervisor_id', supervisorId)
      .in('status', ['pending', 'in_progress']);

    return res.json({
      totalWorkers: totalWorkers || 0,
      totalProjects: totalProjects || 0,
      presentToday: presentToday || 0,
      pendingTasks: pendingTasks || 0,
    });
  } catch (err) {
    console.error('Get dashboard error', err);
    return res.status(500).json({ message: 'Error fetching dashboard data' });
  }
});

// GET /supervisor/notifications - Get notifications
router.get('/notifications', async (req, res) => {
  try {
    const supervisorId = req.user.id;
    const { is_read, limit = 50 } = req.query;

    let query = supabase
      .from('notifications')
      .select('*')
      .eq('supervisor_id', supervisorId)
      .order('created_at', { ascending: false })
      .limit(parseInt(limit));

    if (is_read !== undefined) {
      query = query.eq('is_read', is_read === 'true');
    }

    const { data: notifications, error } = await query;

    if (error) {
      return res.status(500).json({ message: error.message || 'Failed to fetch notifications' });
    }

    return res.json({ notifications: notifications || [] });
  } catch (err) {
    console.error('Get notifications error', err);
    return res.status(500).json({ message: 'Error fetching notifications' });
  }
});

// PUT /supervisor/notifications/:id/read - Mark notification as read
router.put('/notifications/:id/read', async (req, res) => {
  try {
    const supervisorId = req.user.id;
    const notificationId = req.params.id;

    const { data: notification, error } = await supabase
      .from('notifications')
      .update({ is_read: true })
      .eq('id', notificationId)
      .eq('supervisor_id', supervisorId)
      .select()
      .single();

    if (error) {
      return res.status(500).json({ message: error.message || 'Failed to update notification' });
    }

    if (!notification) {
      return res.status(404).json({ message: 'Notification not found' });
    }

    return res.json({ notification, message: 'Notification marked as read' });
  } catch (err) {
    console.error('Update notification error', err);
    return res.status(500).json({ message: 'Error updating notification' });
  }
});

module.exports = router;

