const User = require('../models/User');

const adminOnly = async (req, res, next) => {
    try {
        const user = await User.findOne({ uid: req.user.uid });
        if (!user || user.role !== 'admin') {
            return res.status(403).json({ message: 'Admin access required' });
        }
        req.dbUser = user;
        next();
    } catch (err) {
        return res.status(500).json({ message: 'Server error' });
    }
};

module.exports = adminOnly;
