import React, { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { adminApi } from '../services/api';

export default function UserDetail() {
    const { uid } = useParams();
    const navigate = useNavigate();
    const [data, setData] = useState(null);
    const [loading, setLoading] = useState(true);
    const [tab, setTab] = useState('expenses');

    useEffect(() => {
        adminApi.getUserDetail(uid).then((res) => {
            setData(res.data);
            setLoading(false);
        }).catch(() => setLoading(false));
    }, [uid]);

    if (loading) return <div className="loader-full"><div className="spinner" /></div>;
    if (!data) return <div className="error-full">User not found.</div>;

    const { user, stats, recentActivity } = data;

    return (
        <div className="detail-page">
            <button className="back-btn" onClick={() => navigate('/')}>← Back</button>

            <div className="user-header">
                <img src={user.photoURL || ''} alt="" className="user-avatar-lg"
                    onError={(e) => (e.target.style.display = 'none')} />
                <div>
                    <h1>{user.name}</h1>
                    <p className="text-muted">{user.email}</p>
                    <span className={`role-badge ${user.role}`}>{user.role}</span>
                    <span className={`status-badge ml ${user.isActive ? 'active' : 'offline'}`}>
                        {user.isActive ? '🟢 Active Now' : '⚫ Offline'}
                    </span>
                </div>
            </div>

            {/* Summary stats */}
            <div className="stats-grid sm">
                <div className="stat-card yellow">
                    <div className="stat-value">₹{Math.round(stats.expenses?.total || 0).toLocaleString()}</div>
                    <div className="stat-label">{stats.expenses?.count || 0} Expenses</div>
                </div>
                <div className="stat-card orange">
                    <div className="stat-value">{stats.workouts?.totalMinutes || 0} min</div>
                    <div className="stat-label">{stats.workouts?.count || 0} Workouts · {stats.workouts?.totalCalories || 0} kcal</div>
                </div>
                <div className="stat-card pink">
                    <div className="stat-value">{stats.moodLogs}</div>
                    <div className="stat-label">Mood Logs</div>
                </div>
            </div>

            {/* Tabs */}
            <div className="tabs">
                {['expenses', 'workouts', 'mood'].map((t) => (
                    <button
                        key={t}
                        className={`tab-btn ${tab === t ? 'active' : ''}`}
                        onClick={() => setTab(t)}
                    >
                        {t.charAt(0).toUpperCase() + t.slice(1)}
                    </button>
                ))}
            </div>

            {/* Tab content */}
            {tab === 'expenses' && (
                <div className="activity-list">
                    {recentActivity.expenses.length === 0 ? (
                        <p className="text-muted">No expenses.</p>
                    ) : (
                        recentActivity.expenses.map((e) => (
                            <div key={e._id} className="activity-item">
                                <span className="activity-badge yellow">{e.category}</span>
                                <span>₹{e.amount}</span>
                                {e.note && <span className="text-muted small">{e.note}</span>}
                                <span className="text-muted small ml-auto">{new Date(e.date).toLocaleDateString()}</span>
                            </div>
                        ))
                    )}
                </div>
            )}

            {tab === 'workouts' && (
                <div className="activity-list">
                    {recentActivity.workouts.length === 0 ? (
                        <p className="text-muted">No workouts.</p>
                    ) : (
                        recentActivity.workouts.map((w) => (
                            <div key={w._id} className="activity-item">
                                <span className="activity-badge orange">{w.type}</span>
                                <span>{w.durationMinutes} min</span>
                                <span className="text-muted small">{w.caloriesBurned} kcal</span>
                                <span className="text-muted small ml-auto">{new Date(w.date).toLocaleDateString()}</span>
                            </div>
                        ))
                    )}
                </div>
            )}

            {tab === 'mood' && (
                <div className="activity-list">
                    {recentActivity.moodLogs.length === 0 ? (
                        <p className="text-muted">No mood logs.</p>
                    ) : (
                        recentActivity.moodLogs.map((m) => (
                            <div key={m._id} className="activity-item column">
                                <div className="activity-row">
                                    <span className="activity-badge pink">{m.mood}</span>
                                    <span className="text-muted small ml-auto">{new Date(m.date).toLocaleDateString()}</span>
                                </div>
                                <div className="suggestions-mini">
                                    {(m.suggestedActivities || []).map((s, i) => (
                                        <span key={i} className="suggestion-chip">{s}</span>
                                    ))}
                                </div>
                            </div>
                        ))
                    )}
                </div>
            )}
        </div>
    );
}
