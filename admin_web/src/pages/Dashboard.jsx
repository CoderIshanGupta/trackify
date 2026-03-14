import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { adminApi } from '../services/api';

export default function Dashboard() {
    const { dbUser, logout } = useAuth();
    const navigate = useNavigate();
    const [stats, setStats] = useState(null);
    const [users, setUsers] = useState([]);
    const [loading, setLoading] = useState(true);
    const [search, setSearch] = useState('');

    useEffect(() => {
        fetchData();
        const interval = setInterval(fetchData, 30000); // auto-refresh every 30s
        return () => clearInterval(interval);
    }, []);

    const fetchData = async () => {
        try {
            const [statsRes, usersRes] = await Promise.all([
                adminApi.getPlatformStats(),
                adminApi.getUsers(),
            ]);
            setStats(statsRes.data);
            setUsers(usersRes.data.users || []);
        } catch (e) {
            console.error(e);
        } finally {
            setLoading(false);
        }
    };

    const filteredUsers = users.filter(
        (u) =>
            u.name?.toLowerCase().includes(search.toLowerCase()) ||
            u.email?.toLowerCase().includes(search.toLowerCase())
    );

    const handleRoleChange = async (uid, newRole) => {
        await adminApi.updateUserRole(uid, newRole);
        fetchData();
    };

    return (
        <div className="dashboard">
            {/* Sidebar */}
            <aside className="sidebar">
                <div className="sidebar-brand">
                    <span className="logo-icon">⚡</span>
                    <span>Trackify</span>
                </div>
                <nav className="sidebar-nav">
                    <a className="nav-item active">
                        <span>📊</span> Dashboard
                    </a>
                    <a className="nav-item" onClick={() => navigate('/')}>
                        <span>👥</span> Users
                    </a>
                </nav>
                <div className="sidebar-footer">
                    <div className="admin-info">
                        <img
                            src={dbUser?.photoURL || ''}
                            alt=""
                            className="admin-avatar"
                            onError={(e) => (e.target.style.display = 'none')}
                        />
                        <div>
                            <div className="admin-name">{dbUser?.name}</div>
                            <div className="admin-role">Admin</div>
                        </div>
                    </div>
                    <button className="logout-btn" onClick={logout}>
                        Sign Out
                    </button>
                </div>
            </aside>

            {/* Main */}
            <main className="main-content">
                <div className="topbar">
                    <h1 className="page-title">Dashboard</h1>
                    <div className="refresh-info">Auto-refreshes every 30s</div>
                </div>

                {loading ? (
                    <div className="loader-full"><div className="spinner" /></div>
                ) : (
                    <>
                        {/* Stats cards */}
                        <div className="stats-grid">
                            <div className="stat-card yellow">
                                <div className="stat-icon">👥</div>
                                <div className="stat-value">{stats?.totalUsers ?? 0}</div>
                                <div className="stat-label">Total Users</div>
                            </div>
                            <div className="stat-card green">
                                <div className="stat-icon">🟢</div>
                                <div className="stat-value">{stats?.activeUsers ?? 0}</div>
                                <div className="stat-label">Active (last 15 min)</div>
                            </div>
                            <div className="stat-card orange">
                                <div className="stat-icon">💸</div>
                                <div className="stat-value">₹{Math.round(stats?.platformTotalSpent ?? 0).toLocaleString()}</div>
                                <div className="stat-label">Platform Total Spent</div>
                            </div>
                            <div className="stat-card blue">
                                <div className="stat-icon">🏋️</div>
                                <div className="stat-value">{stats?.totalWorkouts ?? 0}</div>
                                <div className="stat-label">Total Workouts</div>
                            </div>
                            <div className="stat-card pink">
                                <div className="stat-icon">😊</div>
                                <div className="stat-value">{stats?.totalMoodLogs ?? 0}</div>
                                <div className="stat-label">Mood Logs</div>
                            </div>
                            <div className="stat-card purple">
                                <div className="stat-icon">🧾</div>
                                <div className="stat-value">{stats?.totalExpenses ?? 0}</div>
                                <div className="stat-label">Total Expenses</div>
                            </div>
                        </div>

                        {/* Users table */}
                        <div className="section-header">
                            <h2>All Users</h2>
                            <input
                                className="search-box"
                                placeholder="🔍 Search by name or email..."
                                value={search}
                                onChange={(e) => setSearch(e.target.value)}
                            />
                        </div>

                        <div className="table-wrap">
                            <table className="users-table">
                                <thead>
                                    <tr>
                                        <th>User</th>
                                        <th>Email</th>
                                        <th>Status</th>
                                        <th>Last Seen</th>
                                        <th>Role</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    {filteredUsers.map((u) => (
                                        <tr key={u.uid} onClick={() => navigate(`/users/${u.uid}`)} className="user-row">
                                            <td>
                                                <div className="user-cell">
                                                    <img
                                                        src={u.photoURL || ''}
                                                        alt=""
                                                        className="user-avatar"
                                                        onError={(e) => (e.target.style.display = 'none')}
                                                    />
                                                    <span>{u.name || 'Unknown'}</span>
                                                </div>
                                            </td>
                                            <td className="text-muted">{u.email}</td>
                                            <td>
                                                <span className={`status-badge ${u.isActive ? 'active' : 'offline'}`}>
                                                    {u.isActive ? '🟢 Active' : '⚫ Offline'}
                                                </span>
                                            </td>
                                            <td className="text-muted">
                                                {u.lastSeen ? new Date(u.lastSeen).toLocaleString() : 'Never'}
                                            </td>
                                            <td>
                                                <span className={`role-badge ${u.role}`}>{u.role}</span>
                                            </td>
                                            <td onClick={(e) => e.stopPropagation()}>
                                                <button
                                                    className={`role-btn ${u.role === 'admin' ? 'demote' : 'promote'}`}
                                                    onClick={() =>
                                                        handleRoleChange(u.uid, u.role === 'admin' ? 'user' : 'admin')
                                                    }
                                                >
                                                    {u.role === 'admin' ? 'Demote' : 'Promote'}
                                                </button>
                                            </td>
                                        </tr>
                                    ))}
                                </tbody>
                            </table>
                            {filteredUsers.length === 0 && (
                                <div className="empty-table">No users found.</div>
                            )}
                        </div>
                    </>
                )}
            </main>
        </div>
    );
}
