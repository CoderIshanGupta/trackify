import React from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import { useAuth } from './context/AuthContext';
import Login from './pages/Login';
import Dashboard from './pages/Dashboard';
import UserDetail from './pages/UserDetail';

function ProtectedRoute({ children }) {
    const { user, dbUser, loading } = useAuth();
    if (loading) return <div className="loader-full"><div className="spinner" /></div>;
    if (!user || !dbUser || dbUser.role !== 'admin') return <Navigate to="/login" />;
    return children;
}

export default function App() {
    const { user, dbUser } = useAuth();
    return (
        <Routes>
            <Route path="/login" element={
                user && dbUser?.role === 'admin' ? <Navigate to="/" /> : <Login />
            } />
            <Route path="/" element={<ProtectedRoute><Dashboard /></ProtectedRoute>} />
            <Route path="/users/:uid" element={<ProtectedRoute><UserDetail /></ProtectedRoute>} />
        </Routes>
    );
}
