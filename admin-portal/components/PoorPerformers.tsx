'use client';

import { Employee, AttendanceRecord } from '@/lib/api';
import { AlertTriangle } from 'lucide-react';

interface PoorPerformer {
  worker: Employee;
  issues: string[];
  attendance: number;
  priority: 'HIGH' | 'MEDIUM';
}

interface PoorPerformersProps {
  workers: Employee[];
  attendanceRecords: AttendanceRecord[];
}

export default function PoorPerformers({ workers, attendanceRecords }: PoorPerformersProps) {
  const today = new Date().toISOString().split('T')[0];
  const todayStart = new Date(today + 'T00:00:00');
  const todayEnd = new Date(today + 'T23:59:59');
  
  // Expected check-in time (e.g., 7:00 AM)
  const expectedCheckInHour = 7;
  const expectedCheckInMinute = 0;

  // Calculate poor performers
  const poorPerformers: PoorPerformer[] = [];

  workers.forEach((worker) => {
    const workerRecords = attendanceRecords.filter(
      (r) => r.user_id === worker.id
    );

    const issues: string[] = [];
    let lateCount = 0;
    let absentCount = 0;
    let presentDays = 0;

    // Check today's attendance
    const todayRecord = workerRecords.find((r) => {
      const recordDate = new Date(r.check_in_time).toISOString().split('T')[0];
      return recordDate === today;
    });

    if (!todayRecord) {
      absentCount++;
      issues.push('Absent today');
    } else {
      const checkInTime = new Date(todayRecord.check_in_time);
      const expectedTime = new Date(todayStart);
      expectedTime.setHours(expectedCheckInHour, expectedCheckInMinute, 0, 0);

      if (checkInTime > expectedTime) {
        lateCount++;
        const hours = checkInTime.getHours();
        const minutes = checkInTime.getMinutes();
        const ampm = hours >= 12 ? 'PM' : 'AM';
        const displayHours = hours % 12 || 12;
        issues.push(`Late check-in today (${displayHours}:${String(minutes).padStart(2, '0')} ${ampm})`);
      }
    }

    // Calculate weekly stats (last 7 days)
    const weekAgo = new Date();
    weekAgo.setDate(weekAgo.getDate() - 7);
    const weekRecords = workerRecords.filter(
      (r) => new Date(r.check_in_time) >= weekAgo
    );

    let weekLateCount = 0;
    weekRecords.forEach((record) => {
      const checkInTime = new Date(record.check_in_time);
      const expectedTime = new Date(checkInTime);
      expectedTime.setHours(expectedCheckInHour, expectedCheckInMinute, 0, 0);
      expectedTime.setDate(checkInTime.getDate());

      if (checkInTime > expectedTime) {
        weekLateCount++;
      }
    });

    // Count absences this week
    const weekAbsentCount = 7 - weekRecords.length;
    const weekAbsentDays = weekAbsentCount > 0 ? weekAbsentCount : 0;

    if (weekLateCount > 0) {
      issues.push(`${weekLateCount} late arrival${weekLateCount > 1 ? 's' : ''} this week`);
    }
    if (weekAbsentDays > 0) {
      issues.push(`${weekAbsentDays} absence${weekAbsentDays > 1 ? 's' : ''} this week`);
    }

    // Calculate attendance percentage (last 30 days)
    const monthAgo = new Date();
    monthAgo.setDate(monthAgo.getDate() - 30);
    const monthRecords = workerRecords.filter(
      (r) => new Date(r.check_in_time) >= monthAgo
    );

    const uniqueDays = new Set(
      monthRecords.map((r) => r.check_in_time.split('T')[0])
    );
    presentDays = uniqueDays.size;
    const totalDays = 30;
    const attendance = Math.round((presentDays / totalDays) * 100);

    // Determine priority
    let priority: 'HIGH' | 'MEDIUM' = 'MEDIUM';
    if (attendance < 80 || absentCount > 0 || weekLateCount >= 3 || weekAbsentDays >= 2) {
      priority = 'HIGH';
    } else if (weekLateCount >= 1 || attendance < 85) {
      priority = 'MEDIUM';
    }

    // Only include if there are issues or low attendance
    if (issues.length > 0 || attendance < 90) {
      poorPerformers.push({
        worker,
        issues,
        attendance,
        priority,
      });
    }
  });

  // Sort by priority (HIGH first) and attendance (lowest first)
  poorPerformers.sort((a, b) => {
    if (a.priority !== b.priority) {
      return a.priority === 'HIGH' ? -1 : 1;
    }
    return a.attendance - b.attendance;
  });

  if (poorPerformers.length === 0) {
    return null;
  }

  return (
    <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
      <div className="flex items-center space-x-2 mb-4">
        <AlertTriangle className="h-5 w-5 text-yellow-600" />
        <h3 className="text-lg font-semibold text-gray-800">
          Poor Performers - Attention Required
        </h3>
      </div>
      <div className="space-y-3">
        {poorPerformers.slice(0, 5).map((performer) => (
          <div
            key={performer.worker.id}
            className={`p-4 rounded-lg border ${
              performer.priority === 'HIGH'
                ? 'bg-red-50 border-red-200'
                : 'bg-yellow-50 border-yellow-200'
            }`}
          >
            <div className="flex items-start justify-between">
              <div className="flex-1">
                <div className="flex items-center space-x-2 mb-2">
                  <AlertTriangle
                    className={`h-4 w-4 ${
                      performer.priority === 'HIGH'
                        ? 'text-red-600'
                        : 'text-yellow-600'
                    }`}
                  />
                  <h4 className="font-semibold text-gray-900">
                    {performer.worker.name}
                  </h4>
                </div>
                <div className="space-y-1">
                  {performer.issues.map((issue, idx) => (
                    <p
                      key={idx}
                      className="text-sm text-gray-700"
                    >
                      {issue}
                    </p>
                  ))}
                  <p className="text-sm font-medium text-gray-700">
                    Attendance: {performer.attendance}%
                  </p>
                </div>
              </div>
              <span
                className={`px-3 py-1 text-xs font-semibold rounded-full ${
                  performer.priority === 'HIGH'
                    ? 'bg-red-200 text-red-800'
                    : 'bg-yellow-200 text-yellow-800'
                }`}
              >
                {performer.priority}
              </span>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

