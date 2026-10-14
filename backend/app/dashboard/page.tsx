'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';
import { Camera, Search, Plus, FileText, Trash2, Eye } from 'lucide-react';

interface Scan {
  id: string;
  originalText: string;
  detectedLanguage: string;
  summary: string;
  createdAt: string;
}

export default function Dashboard() {
  const [scans, setScans] = useState<Scan[]>([]);
  const [searchQuery, setSearchQuery] = useState('');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchScans();
  }, []);

  const fetchScans = async () => {
    try {
      const response = await fetch('/api/scans');
      if (response.ok) {
        const data = await response.json();
        setScans(data.scans || []);
      }
    } catch (error) {
      console.error('Failed to fetch scans:', error);
    } finally {
      setLoading(false);
    }
  };

  const filteredScans = scans.filter(scan =>
    scan.originalText.toLowerCase().includes(searchQuery.toLowerCase()) ||
    scan.summary.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const deleteScan = async (id: string) => {
    if (!confirm('Are you sure you want to delete this scan?')) return;
    
    try {
      const response = await fetch(`/api/scans/${id}`, {
        method: 'DELETE',
      });
      if (response.ok) {
        setScans(scans.filter(scan => scan.id !== id));
      }
    } catch (error) {
      console.error('Failed to delete scan:', error);
    }
  };

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Navigation */}
      <nav className="bg-white shadow-sm">
        <div className="container mx-auto px-6 py-4">
          <div className="flex items-center justify-between">
            <Link href="/" className="flex items-center space-x-2">
              <Camera className="h-8 w-8 text-primary-600" />
              <span className="text-2xl font-bold text-gray-900">LifeLens AI</span>
            </Link>
            <div className="flex items-center space-x-4">
              <Link href="/scanner" className="text-gray-600 hover:text-gray-900 transition">
                Scanner
              </Link>
              <span className="text-gray-600">Dashboard</span>
            </div>
          </div>
        </div>
      </nav>

      <div className="container mx-auto px-6 py-8">
        {/* Header */}
        <div className="flex flex-col md:flex-row md:items-center md:justify-between mb-8">
          <div>
            <h1 className="text-3xl font-bold text-gray-900 mb-2">Dashboard</h1>
            <p className="text-gray-600">Manage your scanned documents</p>
          </div>
          <Link
            href="/scanner"
            className="mt-4 md:mt-0 bg-primary-600 text-white px-6 py-3 rounded-lg hover:bg-primary-700 transition flex items-center gap-2"
          >
            <Plus className="h-5 w-5" />
            New Scan
          </Link>
        </div>

        {/* Stats */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
          <StatCard title="Total Scans" value={scans.length} />
          <StatCard title="This Week" value={0} />
          <StatCard title="This Month" value={0} />
        </div>

        {/* Search */}
        <div className="mb-6">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
            <input
              type="text"
              placeholder="Search scans..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
            />
          </div>
        </div>

        {/* Scans List */}
        {loading ? (
          <div className="text-center py-12">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600 mx-auto"></div>
            <p className="mt-4 text-gray-600">Loading scans...</p>
          </div>
        ) : filteredScans.length === 0 ? (
          <div className="text-center py-12 bg-white rounded-lg shadow">
            <FileText className="h-16 w-16 text-gray-300 mx-auto mb-4" />
            <h3 className="text-xl font-semibold text-gray-900 mb-2">No scans yet</h3>
            <p className="text-gray-600 mb-4">Start by scanning your first document</p>
            <Link
              href="/scanner"
              className="bg-primary-600 text-white px-6 py-3 rounded-lg hover:bg-primary-700 transition inline-flex items-center gap-2"
            >
              <Camera className="h-5 w-5" />
              Start Scanning
            </Link>
          </div>
        ) : (
          <div className="grid gap-4">
            {filteredScans.map((scan) => (
              <div key={scan.id} className="bg-white p-6 rounded-lg shadow hover:shadow-md transition">
                <div className="flex items-start justify-between">
                  <div className="flex-1">
                    <div className="flex items-center gap-2 mb-2">
                      <span className="text-sm text-primary-600 font-medium">
                        {scan.detectedLanguage}
                      </span>
                      <span className="text-sm text-gray-500">
                        {new Date(scan.createdAt).toLocaleDateString()}
                      </span>
                    </div>
                    <p className="text-gray-900 font-medium mb-2 line-clamp-2">
                      {scan.summary || scan.originalText.substring(0, 100)}...
                    </p>
                    <p className="text-gray-600 text-sm line-clamp-2">
                      {scan.originalText.substring(0, 150)}...
                    </p>
                  </div>
                  <div className="flex items-center gap-2 ml-4">
                    <button
                      onClick={() => deleteScan(scan.id)}
                      className="p-2 text-red-600 hover:bg-red-50 rounded-lg transition"
                      title="Delete"
                    >
                      <Trash2 className="h-5 w-5" />
                    </button>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}

function StatCard({ title, value }: { title: string; value: number }) {
  return (
    <div className="bg-white p-6 rounded-lg shadow">
      <h3 className="text-gray-600 text-sm font-medium mb-1">{title}</h3>
      <p className="text-3xl font-bold text-gray-900">{value}</p>
    </div>
  );
}
