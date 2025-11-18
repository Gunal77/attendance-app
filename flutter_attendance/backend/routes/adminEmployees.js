const express = require('express');
const { supabase } = require('../config/supabaseClient');
const adminAuthMiddleware = require('../middleware/adminAuthMiddleware');

const router = express.Router();

// All routes require admin authentication
router.use(adminAuthMiddleware);

// GET /admin/employees - Fetch all employees (with project info if available)
router.get('/', async (req, res) => {
  try {
    const { data, error } = await supabase
      .from('employees')
      .select(`
        *,
        projects (
          id,
          name,
          location
        )
      `)
      .order('created_at', { ascending: false });

    if (error) {
      return res.status(500).json({ message: error.message || 'Failed to fetch employees' });
    }

    return res.json({ employees: data || [] });
  } catch (err) {
    console.error('Get employees error', err);
    return res.status(500).json({ message: 'Error fetching employees' });
  }
});

// POST /admin/employees - Add new employee
router.post('/', async (req, res) => {
  try {
    const { name, email, phone, role, project_id } = req.body;

    if (!name || typeof name !== 'string' || name.trim().length === 0) {
      return res.status(400).json({ message: 'Employee name is required' });
    }

    // Validate email format if provided
    if (email && (!email.includes('@') || email.trim().length === 0)) {
      return res.status(400).json({ message: 'Invalid email format' });
    }

    // If project_id is provided, verify it exists
    if (project_id) {
      const { data: project, error: projectError } = await supabase
        .from('projects')
        .select('id')
        .eq('id', project_id)
        .single();

      if (projectError || !project) {
        return res.status(400).json({ message: 'Invalid project ID' });
      }
    }

    const employeeData = {
      name: name.trim(),
      email: email?.trim() || null,
      phone: phone?.trim() || null,
      role: role?.trim() || null,
      project_id: project_id || null,
    };

    const { data, error } = await supabase
      .from('employees')
      .insert([employeeData])
      .select(`
        *,
        projects (
          id,
          name,
          location
        )
      `)
      .single();

    if (error) {
      if (error.code === '23505') {
        return res.status(409).json({ message: 'Employee with this email already exists' });
      }
      return res.status(400).json({ message: error.message || 'Failed to create employee' });
    }

    return res.status(201).json({ employee: data, message: 'Employee created successfully' });
  } catch (err) {
    console.error('Create employee error', err);
    return res.status(500).json({ message: 'Error creating employee' });
  }
});

// PUT /admin/employees/:id - Update employee by ID
router.put('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { name, email, phone, role, project_id } = req.body;

    if (!id) {
      return res.status(400).json({ message: 'Employee ID is required' });
    }

    const updateData = {};
    if (name !== undefined) {
      if (typeof name !== 'string' || name.trim().length === 0) {
        return res.status(400).json({ message: 'Employee name must be a non-empty string' });
      }
      updateData.name = name.trim();
    }
    if (email !== undefined) {
      if (email && (!email.includes('@') || email.trim().length === 0)) {
        return res.status(400).json({ message: 'Invalid email format' });
      }
      updateData.email = email?.trim() || null;
    }
    if (phone !== undefined) {
      updateData.phone = phone?.trim() || null;
    }
    if (role !== undefined) {
      updateData.role = role?.trim() || null;
    }
    if (project_id !== undefined) {
      // If project_id is provided, verify it exists
      if (project_id) {
        const { data: project, error: projectError } = await supabase
          .from('projects')
          .select('id')
          .eq('id', project_id)
          .single();

        if (projectError || !project) {
          return res.status(400).json({ message: 'Invalid project ID' });
        }
      }
      updateData.project_id = project_id || null;
    }

    if (Object.keys(updateData).length === 0) {
      return res.status(400).json({ message: 'No fields to update' });
    }

    const { data, error } = await supabase
      .from('employees')
      .update(updateData)
      .eq('id', id)
      .select(`
        *,
        projects (
          id,
          name,
          location
        )
      `)
      .single();

    if (error) {
      if (error.code === 'PGRST116') {
        return res.status(404).json({ message: 'Employee not found' });
      }
      if (error.code === '23505') {
        return res.status(409).json({ message: 'Employee with this email already exists' });
      }
      return res.status(400).json({ message: error.message || 'Failed to update employee' });
    }

    if (!data) {
      return res.status(404).json({ message: 'Employee not found' });
    }

    return res.json({ employee: data, message: 'Employee updated successfully' });
  } catch (err) {
    console.error('Update employee error', err);
    return res.status(500).json({ message: 'Error updating employee' });
  }
});

// DELETE /admin/employees/:id - Delete employee by ID
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;

    if (!id) {
      return res.status(400).json({ message: 'Employee ID is required' });
    }

    const { error } = await supabase
      .from('employees')
      .delete()
      .eq('id', id);

    if (error) {
      return res.status(400).json({ message: error.message || 'Failed to delete employee' });
    }

    return res.json({ message: 'Employee deleted successfully' });
  } catch (err) {
    console.error('Delete employee error', err);
    return res.status(500).json({ message: 'Error deleting employee' });
  }
});

module.exports = router;

