'use client';

import { Project } from '@/lib/api';
import { MapPin, Calendar, ArrowRight } from 'lucide-react';
import Link from 'next/link';

interface ActiveProjectsProps {
  projects: Project[];
}

export default function ActiveProjects({ projects }: ActiveProjectsProps) {
  // Filter active projects (not completed and not on hold)
  const activeProjects = projects
    .filter((project) => {
      // Consider a project active if:
      // 1. No end date, OR
      // 2. End date is in the future
      if (!project.end_date) return true;
      return new Date(project.end_date) > new Date();
    })
    .slice(0, 5); // Show top 5 active projects

  if (activeProjects.length === 0) {
    return null;
  }

  return (
    <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
      <div className="flex items-center justify-between mb-4">
        <h3 className="text-lg font-semibold text-gray-800">Active Projects</h3>
        <Link
          href="/projects"
          className="text-sm text-primary-600 hover:text-primary-700 font-medium flex items-center space-x-1"
        >
          <span>View All Projects</span>
          <ArrowRight className="h-4 w-4" />
        </Link>
      </div>
      <div className="space-y-3">
        {activeProjects.map((project) => (
          <div
            key={project.id}
            className="p-4 border border-gray-200 rounded-lg hover:border-primary-300 hover:shadow-sm transition-all"
          >
            <div className="flex items-start justify-between">
              <div className="flex-1">
                <h4 className="font-semibold text-gray-900 mb-2">
                  {project.name}
                </h4>
                {project.location && (
                  <div className="flex items-center space-x-1 text-sm text-gray-600 mb-1">
                    <MapPin className="h-4 w-4" />
                    <span>{project.location}</span>
                  </div>
                )}
                {project.start_date && (
                  <div className="flex items-center space-x-1 text-sm text-gray-500">
                    <Calendar className="h-4 w-4" />
                    <span>
                      {new Date(project.start_date).toLocaleDateString('en-US', {
                        month: 'short',
                        day: 'numeric',
                        year: 'numeric',
                      })}
                      {project.end_date && (
                        <>
                          {' - '}
                          {new Date(project.end_date).toLocaleDateString('en-US', {
                            month: 'short',
                            day: 'numeric',
                            year: 'numeric',
                          })}
                        </>
                      )}
                    </span>
                  </div>
                )}
              </div>
              <span className="px-3 py-1 text-xs font-semibold bg-green-100 text-green-800 rounded-full whitespace-nowrap ml-4">
                Active
              </span>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

