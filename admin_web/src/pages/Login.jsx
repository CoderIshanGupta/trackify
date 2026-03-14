import React from 'react';
import { useAuth } from '../context/AuthContext';

export default function Login() {
    const { loginWithGoogle, loading, error } = useAuth();

    return (
        <div className="login-page">
            <div className="login-blob blob-1" />
            <div className="login-blob blob-2" />

            <div className="login-card">
                <div className="login-logo">
                    <span className="logo-icon">⚡</span>
                </div>
                <h1 className="login-title">Trackify Admin</h1>
                <p className="login-subtitle">Administrator access only</p>

                {error && (
                    <div className="error-banner">
                        <span>⚠️</span> {error}
                    </div>
                )}

                <button
                    className="google-btn"
                    onClick={loginWithGoogle}
                    disabled={loading}
                >
                    {loading ? (
                        <div className="spinner-sm" />
                    ) : (
                        <>
                            <img
                                src="https://www.google.com/favicon.ico"
                                alt="Google"
                                width={20}
                                height={20}
                            />
                            Continue with Google
                        </>
                    )}
                </button>

                <p className="login-note">
                    Only accounts with <strong>admin</strong> role can access this panel.
                </p>
            </div>
        </div>
    );
}
