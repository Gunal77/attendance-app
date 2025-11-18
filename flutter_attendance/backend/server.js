const express = require('express');
const multer = require('multer');
const env = require('./config/env');
const { initializeDatabase } = require('./config/db');
const authRoutes = require('./routes/authRoutes');
const adminAuthRoutes = require('./routes/adminAuth');
const attendanceRoutes = require('./routes/attendanceRoutes');
const adminProjectsRoutes = require('./routes/adminProjects');
const adminEmployeesRoutes = require('./routes/adminEmployees');

const app = express();

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

app.use('/api/auth', authRoutes);
app.use(['/api/admin/auth', '/admin/auth'], adminAuthRoutes);
app.use('/api/attendance', attendanceRoutes);
app.use(['/api/admin/projects', '/admin/projects'], adminProjectsRoutes);
app.use(['/api/admin/employees', '/admin/employees'], adminEmployeesRoutes);

// Not found handler
app.use((req, res) => {
  res.status(404).json({ message: 'Route not found' });
});

// Centralized error handler
app.use((err, req, res, next) => {
  console.error('Unhandled error', err);

  if (err instanceof multer.MulterError) {
    return res.status(400).json({ message: err.message });
  }

  if (err?.message === 'Only image files are allowed') {
    return res.status(400).json({ message: err.message });
  }

  const status = err.status || 500;
  return res.status(status).json({ message: err.message || 'Internal server error' });
});

const startServer = async () => {
  try {
    await initializeDatabase();
    app.listen(env.port, () => {
      console.log(`Server listening on port ${env.port}`);
    });
  } catch (error) {
    console.error('Failed to start server', error);
    process.exit(1);
  }
};

startServer();

module.exports = app;

