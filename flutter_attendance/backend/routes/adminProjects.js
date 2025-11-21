const express = require('express');
const { supabase } = require('../config/supabaseClient');
const adminAuthMiddleware = require('../middleware/adminAuthMiddleware');

const router = express.Router();

// All routes require admin authentication
router.use(adminAuthMiddleware);

// GET /admin/projects - Fetch all projects
router.get('/', async (req, res) => {
  try {
    const { data, error } = await supabase
      .from('projects')
      .select('*')
      .order('created_at', { ascending: false });

    if (error) {
      return res.status(500).json({ message: error.message || 'Failed to fetch projects' });
    }

    return res.json({ projects: data || [] });
  } catch (err) {
    console.error('Get projects error', err);
    return res.status(500).json({ message: 'Error fetching projects' });
  }
});

// POST /admin/projects - Add new project
router.post('/', async (req, res) => {
  try {
    const { name, location, start_date, end_date, description, budget } = req.body;

    if (!name || typeof name !== 'string' || name.trim().length === 0) {
      return res.status(400).json({ message: 'Project name is required' });
    }

    const projectData = {
      name: name.trim(),
      location: location?.trim() || null,
      start_date: start_date || null,
      end_date: end_date || null,
      description: description?.trim() || null,
      budget: budget != null ? (typeof budget === 'string' ? parseFloat(budget) : budget) : null,
    };

    const { data, error } = await supabase
      .from('projects')
      .insert([projectData])
      .select()
      .single();

    if (error) {
      return res.status(400).json({ message: error.message || 'Failed to create project' });
    }

    return res.status(201).json({ project: data, message: 'Project created successfully' });
  } catch (err) {
    console.error('Create project error', err);
    return res.status(500).json({ message: 'Error creating project' });
  }
});

// PUT /admin/projects/:id - Update project by ID
router.put('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { name, location, start_date, end_date, description, budget } = req.body;

    if (!id) {
      return res.status(400).json({ message: 'Project ID is required' });
    }

    const updateData = {};
    if (name !== undefined) {
      if (typeof name !== 'string' || name.trim().length === 0) {
        return res.status(400).json({ message: 'Project name must be a non-empty string' });
      }
      updateData.name = name.trim();
    }
    if (location !== undefined) {
      updateData.location = location?.trim() || null;
    }
    if (start_date !== undefined) {
      updateData.start_date = start_date || null;
    }
    if (end_date !== undefined) {
      updateData.end_date = end_date || null;
    }
    if (description !== undefined) {
      updateData.description = description?.trim() || null;
    }
    if (budget !== undefined) {
      updateData.budget = budget != null ? (typeof budget === 'string' ? parseFloat(budget) : budget) : null;
    }

    if (Object.keys(updateData).length === 0) {
      return res.status(400).json({ message: 'No fields to update' });
    }

    const { data, error } = await supabase
      .from('projects')
      .update(updateData)
      .eq('id', id)
      .select()
      .single();

    if (error) {
      if (error.code === 'PGRST116') {
        return res.status(404).json({ message: 'Project not found' });
      }
      return res.status(400).json({ message: error.message || 'Failed to update project' });
    }

    if (!data) {
      return res.status(404).json({ message: 'Project not found' });
    }

    return res.json({ project: data, message: 'Project updated successfully' });
  } catch (err) {
    console.error('Update project error', err);
    return res.status(500).json({ message: 'Error updating project' });
  }
});

// DELETE /admin/projects/:id - Delete project by ID
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;

    if (!id) {
      return res.status(400).json({ message: 'Project ID is required' });
    }

    const { error } = await supabase
      .from('projects')
      .delete()
      .eq('id', id);

    if (error) {
      return res.status(400).json({ message: error.message || 'Failed to delete project' });
    }

    return res.json({ message: 'Project deleted successfully' });
  } catch (err) {
    console.error('Delete project error', err);
    return res.status(500).json({ message: 'Error deleting project' });
  }
});

module.exports = router;

