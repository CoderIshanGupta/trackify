const express = require('express');
const router = express.Router();
const User = require('../models/User');
const Expense = require('../models/Expense');
const Workout = require('../models/Workout');
const MoodLog = require('../models/MoodLog');
const verifyToken = require('../middleware/auth');
const adminOnly = require('../middleware/adminOnly');

// Both middlewares required for all admin routes
router.use(verifyToken, adminOnly);

// GET /api/admin/users — all users with stats
router.get('/users', async (req, res) => {
    try {
        const users = await User.find().sort({ lastSeen: -1 }).lean();

        // Mark active: seen in last 15 minutes
        const fifteenMinutesAgo = new Date(Date.now() - 15 * 60 * 1000);
        const usersWithStatus = users.map((u) => ({
            ...u,
            isActive: u.lastSeen && new Date(u.lastSeen) > fifteenMinutesAgo,
        }));

        res.json({
            total: users.length,
            activeNow: usersWithStatus.filter((u) => u.isActive).length,
            users: usersWithStatus,
        });
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// GET /api/admin/users/:uid — single user with full history
router.get('/users/:uid', async (req, res) => {
    try {
        const user = await User.findOne({ uid: req.params.uid }).lean();
        if (!user) return res.status(404).json({ message: 'User not found' });

        const [expenses, workouts, moodLogs] = await Promise.all([
            Expense.find({ userId: req.params.uid }).sort({ date: -1 }).limit(50),
            Workout.find({ userId: req.params.uid }).sort({ date: -1 }).limit(50),
            MoodLog.find({ userId: req.params.uid }).sort({ date: -1 }).limit(50),
        ]);

        const expenseSummary = await Expense.aggregate([
            { $match: { userId: req.params.uid } },
            { $group: { _id: null, total: { $sum: '$amount' }, count: { $sum: 1 } } },
        ]);

        const workoutSummary = await Workout.aggregate([
            { $match: { userId: req.params.uid } },
            {
                $group: {
                    _id: null,
                    totalMinutes: { $sum: '$durationMinutes' },
                    totalCalories: { $sum: '$caloriesBurned' },
                    count: { $sum: 1 },
                },
            },
        ]);

        res.json({
            user,
            stats: {
                expenses: expenseSummary[0] || { total: 0, count: 0 },
                workouts: workoutSummary[0] || { totalMinutes: 0, totalCalories: 0, count: 0 },
                moodLogs: moodLogs.length,
            },
            recentActivity: {
                expenses,
                workouts,
                moodLogs,
            },
        });
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// PATCH /api/admin/users/:uid/role — promote/demote users
router.patch('/users/:uid/role', async (req, res) => {
    try {
        const { role } = req.body;
        if (!['user', 'admin'].includes(role)) {
            return res.status(400).json({ message: 'role must be "user" or "admin"' });
        }
        const user = await User.findOneAndUpdate(
            { uid: req.params.uid },
            { role },
            { new: true }
        );
        if (!user) return res.status(404).json({ message: 'User not found' });
        res.json({ message: `Role updated to ${role}`, user });
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// GET /api/admin/stats — platform-wide stats
router.get('/stats', async (req, res) => {
    try {
        const fifteenMinutesAgo = new Date(Date.now() - 15 * 60 * 1000);
        const [
            totalUsers,
            activeUsers,
            totalExpenses,
            totalWorkouts,
            totalMoodLogs,
        ] = await Promise.all([
            User.countDocuments(),
            User.countDocuments({ lastSeen: { $gte: fifteenMinutesAgo } }),
            Expense.countDocuments(),
            Workout.countDocuments(),
            MoodLog.countDocuments(),
        ]);

        const totalSpent = await Expense.aggregate([
            { $group: { _id: null, total: { $sum: '$amount' } } },
        ]);

        res.json({
            totalUsers,
            activeUsers,
            totalExpenses,
            totalWorkouts,
            totalMoodLogs,
            platformTotalSpent: totalSpent[0]?.total || 0,
        });
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

module.exports = router;
