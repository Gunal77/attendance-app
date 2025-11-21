'use client';

import { useState, useEffect } from 'react';
import { useParams, useRouter } from 'next/navigation';
import { employeesAPI, attendanceAPI, Employee, AttendanceRecord } from '@/lib/api';
import Card from '@/components/Card';
import Table from '@/components/Table';
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
} from 'recharts';
import { ArrowLeft, Mail, Phone, Briefcase, Calendar } from 'lucide-react';

export default function WorkerDetailsPage() {
  const params = useParams();
  const router = useRouter();
  const workerId = params.id as string;

  const [worker, setWorker] = useState<Employee | null>(null);
  const [attendanceRecords, setAttendanceRecords] = useState<AttendanceRecord[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    if (workerId) {
      fetchWorkerDetails();
      fetchAttendanceHistory();
    }
  }, [workerId]);

  const fetchWorkerDetails = async () => {
    try {
      setLoading(true);
      // Since backend doesn't have GET /:id, fetch all and filter
      const response = await employeesAPI.getAll();
      const workers = response.employees || [];
      const foundWorker = workers.find((w: Employee) => w.id === workerId);
      
      if (foundWorker) {
        setWorker(foundWorker);
      } else {
        setError('Worker not found');
      }
    } catch (err: any) {
      console.error('Error fetching worker:', err);
      const errorMessage = err.response?.data?.message || err.message || 'Failed to fetch worker details';
      setError(errorMessage);
    } finally {
      setLoading(false);
    }
  };

  const fetchAttendanceHistory = async () => {
    try {
      // First get worker to get their email for filtering
      const workerResponse = await employeesAPI.getById(workerId);
      const worker = workerResponse.employee;
      
      if (worker?.email) {
        const response = await attendanceAPI.getAll({
          user: worker.email,
          sortBy: 'check_in_time',
          sortOrder: 'desc',
        });
        // Filter by user_id on client side as well to ensure accuracy
        const filtered = (response.records || []).filter(
          (record: AttendanceRecord) => record.user_id === workerId
        );
        setAttendanceRecords(filtered);
      } else {
        // If no email, fetch all and filter by user_id
        const response = await attendanceAPI.getAll({
          sortBy: 'check_in_time',
          sortOrder: 'desc',
        });
        const filtered = (response.records || []).filter(
          (record: AttendanceRecord) => record.user_id === workerId
        );
        setAttendanceRecords(filtered);
      }
    } catch (err: any) {
      console.error('Error fetching attendance:', err);
    } finally {
      setLoading(false);
    }
  };

  // Process data for chart (check-ins per month)
  const getChartData = () => {
    const monthlyData: { [key: string]: number } = {};
    
    attendanceRecords.forEach((record) => {
      const date = new Date(record.check_in_time);
      const monthKey = `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}`;
      monthlyData[monthKey] = (monthlyData[monthKey] || 0) + 1;
    });

    return Object.entries(monthlyData)
      .map(([month, count]) => ({
        month: new Date(month + '-01').toLocaleDateString('en-US', {
          month: 'short',
          year: 'numeric',
        }),
        checkIns: count,
      }))
      .sort((a, b) => {
        const dateA = new Date(a.month);
        const dateB = new Date(b.month);
        return dateA.getTime() - dateB.getTime();
      });
  };

  const chartData = getChartData();

  const attendanceColumns = [
    {
      key: 'check_in_time',
      header: 'Check In',
      render: (item: AttendanceRecord) =>
        new Date(item.check_in_time).toLocaleString(),
    },
    {
      key: 'check_out_time',
      header: 'Check Out',
      render: (item: AttendanceRecord) =>
        item.check_out_time
          ? new Date(item.check_out_time).toLocaleString()
          : <span className="text-gray-400">Not checked out</span>,
    },
    {
      key: 'duration',
      header: 'Duration',
      render: (item: AttendanceRecord) => {
        if (!item.check_out_time) return <span className="text-gray-400">-</span>;
        const checkIn = new Date(item.check_in_time);
        const checkOut = new Date(item.check_out_time);
        const diff = checkOut.getTime() - checkIn.getTime();
        const hours = Math.floor(diff / (1000 * 60 * 60));
        const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
        return `${hours}h ${minutes}m`;
      },
    },
    {
      key: 'status',
      header: 'Status',
      render: (item: AttendanceRecord) => (
        <span
          className={`px-2 py-1 text-xs font-medium rounded-full ${
            item.check_out_time
              ? 'bg-green-100 text-green-800'
              : 'bg-yellow-100 text-yellow-800'
          }`}
        >
          {item.check_out_time ? 'Completed' : 'Active'}
        </span>
      ),
    },
  ];

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-gray-500">Loading worker details...</div>
      </div>
    );
  }

  if (error && !worker) {
    return (
      <div className="space-y-4">
        <button
          onClick={() => router.push('/workers')}
          className="flex items-center space-x-2 text-primary-600 hover:text-primary-700"
        >
          <ArrowLeft className="h-5 w-5" />
          <span>Back to Workers</span>
        </button>
        <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded">
          {error || 'Worker not found'}
        </div>
      </div>
    );
  }

  if (!worker && !loading) {
    return (
      <div className="space-y-4">
        <button
          onClick={() => router.push('/workers')}
          className="flex items-center space-x-2 text-primary-600 hover:text-primary-700"
        >
          <ArrowLeft className="h-5 w-5" />
          <span>Back to Workers</span>
        </button>
        <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded">
          Worker not found
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center space-x-4">
        <button
          onClick={() => router.back()}
          className="flex items-center space-x-2 text-primary-600 hover:text-primary-700"
        >
          <ArrowLeft className="h-5 w-5" />
          <span>Back</span>
        </button>
        <div>
          <h1 className="text-2xl font-bold text-gray-800">{worker.name}</h1>
          <p className="text-gray-600 mt-1">Worker Details</p>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <Card title="Worker Information">
          <div className="space-y-4">
            <div className="flex items-start space-x-3">
              <Mail className="h-5 w-5 text-gray-400 mt-0.5" />
              <div>
                <p className="text-sm text-gray-600">Email</p>
                <p className="text-gray-900 font-medium">
                  {worker.email || 'N/A'}
                </p>
              </div>
            </div>
            {worker.phone && (
              <div className="flex items-start space-x-3">
                <Phone className="h-5 w-5 text-gray-400 mt-0.5" />
                <div>
                  <p className="text-sm text-gray-600">Phone</p>
                  <p className="text-gray-900 font-medium">{worker.phone}</p>
                </div>
              </div>
            )}
            {worker.role && (
              <div className="flex items-start space-x-3">
                <Briefcase className="h-5 w-5 text-gray-400 mt-0.5" />
                <div>
                  <p className="text-sm text-gray-600">Department</p>
                  <p className="text-gray-900 font-medium">{worker.role}</p>
                </div>
              </div>
            )}
            <div className="flex items-start space-x-3">
              <Calendar className="h-5 w-5 text-gray-400 mt-0.5" />
              <div>
                <p className="text-sm text-gray-600">Joined Date</p>
                <p className="text-gray-900 font-medium">
                  {new Date(worker.created_at).toLocaleDateString()}
                </p>
              </div>
            </div>
            {worker.projects && (
              <div className="flex items-start space-x-3">
                <Briefcase className="h-5 w-5 text-gray-400 mt-0.5" />
                <div>
                  <p className="text-sm text-gray-600">Project</p>
                  <p className="text-gray-900 font-medium">
                    {worker.projects.name}
                  </p>
                </div>
              </div>
            )}
          </div>
        </Card>

        <Card title="Attendance Statistics">
          <div className="space-y-4">
            <div>
              <p className="text-sm text-gray-600">Total Records</p>
              <p className="text-2xl font-bold text-gray-900">
                {attendanceRecords.length}
              </p>
            </div>
            <div>
              <p className="text-sm text-gray-600">Completed Sessions</p>
              <p className="text-2xl font-bold text-green-600">
                {
                  attendanceRecords.filter((r) => r.check_out_time).length
                }
              </p>
            </div>
            <div>
              <p className="text-sm text-gray-600">Active Sessions</p>
              <p className="text-2xl font-bold text-yellow-600">
                {
                  attendanceRecords.filter((r) => !r.check_out_time).length
                }
              </p>
            </div>
          </div>
        </Card>
      </div>

      {chartData.length > 0 && (
        <Card title="Check-ins per Month">
          <ResponsiveContainer width="100%" height={300}>
            <BarChart data={chartData}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="month" />
              <YAxis />
              <Tooltip />
              <Legend />
              <Bar dataKey="checkIns" fill="#0ea5e9" />
            </BarChart>
          </ResponsiveContainer>
        </Card>
      )}

      <Card title="Attendance History">
        <Table
          columns={attendanceColumns}
          data={attendanceRecords}
          keyExtractor={(item) => item.id}
          emptyMessage="No attendance records found"
        />
      </Card>
    </div>
  );
}
