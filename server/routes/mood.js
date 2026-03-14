const express = require('express');
const router = express.Router();
const MoodLog = require('../models/MoodLog');
const verifyToken = require('../middleware/auth');
const { getSuggestionsForMood } = require('../utils/moodEngine');

router.use(verifyToken);

// POST /api/mood — log mood + get activity suggestions from server
router.post('/', async (req, res) => {
    try {
        const { mood, note } = req.body;

        const validMoods = ['Happy', 'Sad', 'Anxious', 'Angry', 'Tired', 'Excited', 'Calm', 'Bored'];
        if (!mood || !validMoods.includes(mood)) {
            return res.status(400).json({
                message: `mood is required and must be one of: ${validMoods.join(', ')}`,
            });
        }

        // Generate suggestions server-side
        const suggestedActivities = getSuggestionsForMood(mood);

        const moodLog = await MoodLog.create({
            userId: req.user.uid,
            mood,
            suggestedActivities,
            note: note || '',
        });

        res.status(201).json({
            mood: moodLog.mood,
            suggestedActivities: moodLog.suggestedActivities,
            date: moodLog.date,
            id: moodLog._id,
        });
    } catch (err) {
        res.status(400).json({ message: err.message });
    }
});

// GET /api/mood/history — mood logs for current user
router.get('/history', async (req, res) => {
    try {
        const limit = parseInt(req.query.limit) || 30;
        const logs = await MoodLog.find({ userId: req.user.uid })
            .sort({ date: -1 })
            .limit(limit);
        res.json(logs);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// GET /api/mood/stats — mood frequency breakdown
router.get('/stats', async (req, res) => {
    try {
        const stats = await MoodLog.aggregate([
            { $match: { userId: req.user.uid } },
            {
                $group: {
                    _id: '$mood',
                    count: { $sum: 1 },
                    lastOccurrence: { $max: '$date' },
                },
            },
            { $sort: { count: -1 } },
        ]);
        res.json(stats);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

module.exports = router;
