import React, { createContext, useContext, useState, useEffect } from 'react';
import { initializeApp } from 'firebase/app';
import { getAuth, GoogleAuthProvider, signInWithPopup, signOut, onAuthStateChanged } from 'firebase/auth';
import { firebaseConfig } from '../firebase';
import { adminApi } from '../services/api';

const app = initializeApp(firebaseConfig);
const auth = getAuth(app);
const provider = new GoogleAuthProvider();

const AuthContext = createContext(null);

export function AuthProvider({ children }) {
    const [user, setUser] = useState(null);
    const [dbUser, setDbUser] = useState(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);

    useEffect(() => {
        const unsub = onAuthStateChanged(auth, async (firebaseUser) => {
            if (firebaseUser) {
                try {
                    const token = await firebaseUser.getIdToken();
                    localStorage.setItem('adminToken', token);
                    const res = await adminApi.loginWithGoogle(token);
                    const userData = res.data.user;
                    if (userData.role !== 'admin') {
                        setError('Access denied. Admin only.');
                        await signOut(auth);
                        setUser(null);
                        setDbUser(null);
                    } else {
                        setUser(firebaseUser);
                        setDbUser(userData);
                        setError(null);
                    }
                } catch {
                    setError('Server error. Please try again.');
                }
            } else {
                localStorage.removeItem('adminToken');
                setUser(null);
                setDbUser(null);
            }
            setLoading(false);
        });
        return () => unsub();
    }, []);

    const loginWithGoogle = async () => {
        setError(null);
        setLoading(true);
        try {
            await signInWithPopup(auth, provider);
        } catch (e) {
            setError('Sign-in failed. Try again.');
            setLoading(false);
        }
    };

    const logout = async () => {
        await signOut(auth);
        localStorage.removeItem('adminToken');
    };

    return (
        <AuthContext.Provider value={{ user, dbUser, loading, error, loginWithGoogle, logout }}>
            {children}
        </AuthContext.Provider>
    );
}

export const useAuth = () => useContext(AuthContext);
