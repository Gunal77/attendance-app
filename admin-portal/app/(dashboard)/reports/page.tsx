import { serverAPI } from '@/lib/api-server';
import StatCard from '@/components/StatCard';
import Card from '@/components/Card';
import ProjectReportsTable from '@/components/ProjectReportsTable';
import { FolderKanban, Users as UsersIcon, Clock as ClockIcon, DollarSign } from 'lucide-react';

async function getReportsData() {
  try {
    const [employeesRes, attendanceRes, projectsRes] = await Promise.all([
      serverAPI.employees.getAll(),
      serverAPI.attendance.getAll({ sortBy: 'check_in_time', sortOrder: 'desc' }),
      serverAPI.projects.getAll(),
    ]);

    const workers = employeesRes.employees || [];
    const attendanceRecords = attendanceRes.records || [];
    const projects = projectsRes.projects || [];

    // Calculate statistics
    const activeProjects = projects.filter((p: any) => !p.end_date || new Date(p.end_date) > new Date()).length;
    
    const today = new Date().toISOString().split('T')[0];
    const todayRecords = attendanceRecords.filter((record: any) => {
      const recordDate = new Date(record.check_in_time).toISOString().split('T')[0];
      return recordDate === today;
    });
    const activeToday = new Set(todayRecords.map((r: any) => r.user_id)).size;

    // Calculate total hours for current month
    const currentMonth = new Date().getMonth();
    const currentYear = new Date().getFullYear();
    const monthRecords = attendanceRecords.filter((record: any) => {
      const recordDate = new Date(record.check_in_time);
      return recordDate.getMonth() === currentMonth && recordDate.getFullYear() === currentYear && record.check_out_time;
    });
    
    const totalHours = monthRecords.reduce((sum: number, record: any) => {
      const checkIn = new Date(record.check_in_time);
      const checkOut = new Date(record.check_out_time);
      const diff = checkOut.getTime() - checkIn.getTime();
      const hours = diff / (1000 * 60 * 60);
      return sum + hours;
    }, 0);

    // Calculate previous month hours for trend
    const prevMonth = currentMonth === 0 ? 11 : currentMonth - 1;
    const prevYear = currentMonth === 0 ? currentYear - 1 : currentYear;
    const prevMonthRecords = attendanceRecords.filter((record: any) => {
      const recordDate = new Date(record.check_in_time);
      return recordDate.getMonth() === prevMonth && recordDate.getFullYear() === prevYear && record.check_out_time;
    });
    
    const prevMonthHours = prevMonthRecords.reduce((sum: number, record: any) => {
      const checkIn = new Date(record.check_in_time);
      const checkOut = new Date(record.check_out_time);
      const diff = checkOut.getTime() - checkIn.getTime();
      const hours = diff / (1000 * 60 * 60);
      return sum + hours;
    }, 0);

    const hoursTrend = prevMonthHours > 0 
      ? ((totalHours - prevMonthHours) / prevMonthHours) * 100 
      : 0;

    // Calculate total budget
    let totalBudget = 0;
    let totalSpent = 0;
    projects.forEach((project: any) => {
      if (project.budget) {
        totalBudget += typeof project.budget === 'string' ? parseFloat(project.budget) : project.budget;
      }
      // Estimate spent based on completion if available
      if (project.budget && project.completion) {
        const budget = typeof project.budget === 'string' ? parseFloat(project.budget) : project.budget;
        totalSpent += budget * (project.completion / 100);
      }
    });

    const budgetUtilization = totalBudget > 0 ? (totalSpent / totalBudget) * 100 : 0;

    // Project reports data
    const projectReports = projects.map((project: any) => {
      const projectWorkers = workers.filter((w: any) => w.project_id === project.id);
      const projectRecords = attendanceRecords.filter((r: any) => 
        projectWorkers.some((w: any) => w.id === r.user_id) && r.check_out_time
      );
      
      const projectHours = projectRecords.reduce((sum: number, record: any) => {
        const checkIn = new Date(record.check_in_time);
        const checkOut = new Date(record.check_out_time);
        const diff = checkOut.getTime() - checkIn.getTime();
        return sum + (diff / (1000 * 60 * 60));
      }, 0);

      // Determine status
      let status = 'ACTIVE';
      if (project.end_date && new Date(project.end_date) <= new Date()) {
        status = 'COMPLETED';
      } else if (project.status === 'on_hold' || project.status === 'ON HOLD') {
        status = 'ON HOLD';
      }

      // Calculate completion percentage
      let completion = null;
      if (project.end_date && project.start_date) {
        const start = new Date(project.start_date);
        const end = new Date(project.end_date);
        const now = new Date();
        const totalDuration = end.getTime() - start.getTime();
        const elapsed = now.getTime() - start.getTime();
        if (totalDuration > 0) {
          completion = Math.min(100, Math.max(0, (elapsed / totalDuration) * 100));
        }
      } else if (status === 'COMPLETED') {
        completion = 100;
      }

      // Calculate spent (estimate based on completion or use actual if available)
      let spent = null;
      if (project.budget) {
        const budget = typeof project.budget === 'string' ? parseFloat(project.budget) : project.budget;
        if (completion !== null) {
          spent = budget * (completion / 100);
        } else if (project.spent) {
          spent = typeof project.spent === 'string' ? parseFloat(project.spent) : project.spent;
        }
      }

      return {
        id: project.id,
        name: project.name,
        startDate: project.start_date,
        status,
        workers: projectWorkers.length,
        totalHours: Math.round(projectHours),
        budget: project.budget ? (typeof project.budget === 'string' ? parseFloat(project.budget) : project.budget) : null,
        spent,
        completion: completion ? Math.round(completion) : null,
      };
    });

    return {
      totalProjects: projects.length,
      activeProjects,
      totalWorkers: workers.length,
      activeToday,
      totalHours: Math.round(totalHours),
      hoursTrend,
      totalBudget,
      totalSpent,
      budgetUtilization,
      projectReports,
    };
  } catch (error) {
    console.error('Error fetching reports data:', error);
    return {
      totalProjects: 0,
      activeProjects: 0,
      totalWorkers: 0,
      activeToday: 0,
      totalHours: 0,
      hoursTrend: 0,
      totalBudget: 0,
      totalSpent: 0,
      budgetUtilization: 0,
      projectReports: [],
    };
  }
}

// Format currency in millions
function formatCurrency(value: number): string {
  if (value >= 1000000) {
    return `$${(value / 1000000).toFixed(1)}M`;
  } else if (value >= 1000) {
    return `$${(value / 1000).toFixed(1)}K`;
  }
  return `$${value.toLocaleString()}`;
}

export default async function ReportsPage() {
  const { 
    totalProjects, 
    activeProjects, 
    totalWorkers, 
    activeToday, 
    totalHours, 
    hoursTrend,
    totalBudget,
    budgetUtilization,
    projectReports 
  } = await getReportsData();

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-gray-800">Reports & Analytics</h1>
        <p className="text-gray-600 mt-1">Comprehensive project, attendance, and performance reports</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <StatCard
          title="Total Projects"
          value={totalProjects}
          subtitle={`${activeProjects} Active`}
          icon={<FolderKanban className="h-6 w-6 text-blue-600" />}
        />
        <StatCard
          title="Total Workers"
          value={totalWorkers}
          subtitle={`${activeToday} Active Today`}
          icon={<UsersIcon className="h-6 w-6 text-green-600" />}
        />
        <StatCard
          title="Total Hours (Month)"
          value={totalHours.toLocaleString()}
          subtitle={hoursTrend !== 0 ? (
            <span className={hoursTrend > 0 ? 'text-green-600' : 'text-red-600'}>
              {hoursTrend > 0 ? '+' : ''}{hoursTrend.toFixed(1)}% vs last month
            </span>
          ) : undefined}
          icon={<ClockIcon className="h-6 w-6 text-orange-600" />}
        />
        <StatCard
          title="Total Budget"
          value={totalBudget > 0 ? formatCurrency(totalBudget) : '$0'}
          subtitle={totalBudget > 0 ? `${budgetUtilization.toFixed(1)}% utilized` : undefined}
          icon={<DollarSign className="h-6 w-6 text-red-600" />}
        />
      </div>

      <Card title="Project Reports">
        <ProjectReportsTable data={projectReports} />
      </Card>
    </div>
  );
}
