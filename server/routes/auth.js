const express = require('express');
const router = express.Router();
const User = require('../models/User');
const admin = require('../config/firebase');

/**
 * POST /api/auth/google
 * Verifies a Firebase ID Token, upserts user in MongoDB, returns user profile.
 * This is the only auth endpoint — no password auth.
 */
router.post('/google', async (req, res) => {
    const { idToken } = req.body;

    if (!idToken) {
        return res.status(400).json({ message: 'idToken is required' });
    }

    try {
        // Verify the token with Firebase Admin SDK
        const decoded = await admin.auth().verifyIdToken(idToken);

        const { uid, email, name, picture } = decoded;

        // Upsert: create user if they don't exist, update info if they do
        const user = await User.findOneAndUpdate(
            { uid },
            {
                uid,
                email,
                name: name || email.split('@')[0],
                photoURL: picture || '',
                lastSeen: new Date(),
            },
            { new: true, upsert: true, runValidators: false }
        );

        return res.status(200).json({
            message: 'Authenticated successfully',
            user: {
                uid: user.uid,
                email: user.email,
                name: user.name,
                photoURL: user.photoURL,
                role: user.role,
                lastSeen: user.lastSeen,
            },
        });
    } catch (err) {
        console.error('Google auth error:', err.message);
        return res.status(401).json({ message: 'Invalid Firebase token' });
    }
});

module.exports = router;
