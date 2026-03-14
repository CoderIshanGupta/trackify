const admin = require('../config/firebase');
const User = require('../models/User');

const verifyToken = async (req, res, next) => {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(401).json({ message: 'No token provided' });
    }

    const idToken = authHeader.split('Bearer ')[1];

    try {
        const decoded = await admin.auth().verifyIdToken(idToken);
        // Attach Firebase decoded user to request
        req.user = decoded;

        // Update lastSeen (fire-and-forget, doesn't block the request)
        User.findOneAndUpdate(
            { uid: decoded.uid },
            { lastSeen: new Date() }
        ).catch(() => { });

        next();
    } catch (err) {
        console.error('Token verification failed:', err.message);
        return res.status(401).json({ message: 'Invalid or expired token' });
    }
};

module.exports = verifyToken;
