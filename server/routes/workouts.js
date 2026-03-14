const express = require('express');
const router = express.Router();
const Workout = require('../models/Workout');
const verifyToken = require('../middleware/auth');

router.use(verifyToken);

// GET /api/workouts
router.get('/', async (req, res) => {
    try {
        const workouts = await Workout.find({ userId: req.user.uid }).sort({ date: -1 });
        res.json(workouts);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// GET /api/workouts/summary — total minutes and calories per type
router.get('/summary', async (req, res) => {
    try {
        const summary = await Workout.aggregate([
            { $match: { userId: req.user.uid } },
            {
                $group: {
                    _id: '$type',
                    totalMinutes: { $sum: '$durationMinutes' },
                    totalCalories: { $sum: '$caloriesBurned' },
                    count: { $sum: 1 },
                },
            },
            { $sort: { totalMinutes: -1 } },
        ]);
        const totalMinutes = summary.reduce((acc, w) => acc + w.totalMinutes, 0);
        const totalCalories = summary.reduce((acc, w) => acc + w.totalCalories, 0);
        res.json({ types: summary, totalMinutes, totalCalories });
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// POST /api/workouts
router.post('/', async (req, res) => {
    try {
        const { type, durationMinutes, caloriesBurned, note, date } = req.body;
        if (!durationMinutes || durationMinutes <= 0) {
            return res.status(400).json({ message: 'durationMinutes must be positive' });
        }
        const workout = await Workout.create({
            userId: req.user.uid,
            type: type || 'Other',
            durationMinutes,
            caloriesBurned: caloriesBurned || 0,
            note: note || '',
            date: date ? new Date(date) : new Date(),
        });
        res.status(201).json(workout);
    } catch (err) {
        res.status(400).json({ message: err.message });
    }
});

// PUT /api/workouts/:id
router.put('/:id', async (req, res) => {
    try {
        const workout = await Workout.findOne({ _id: req.params.id, userId: req.user.uid });
        if (!workout) return res.status(404).json({ message: 'Workout not found' });

        const { type, durationMinutes, caloriesBurned, note, date } = req.body;
        if (type !== undefined) workout.type = type;
        if (durationMinutes !== undefined) workout.durationMinutes = durationMinutes;
        if (caloriesBurned !== undefined) workout.caloriesBurned = caloriesBurned;
        if (note !== undefined) workout.note = note;
        if (date !== undefined) workout.date = new Date(date);

        await workout.save();
        res.json(workout);
    } catch (err) {
        res.status(400).json({ message: err.message });
    }
});

// DELETE /api/workouts/:id
router.delete('/:id', async (req, res) => {
    try {
        const workout = await Workout.findOneAndDelete({ _id: req.params.id, userId: req.user.uid });
        if (!workout) return res.status(404).json({ message: 'Workout not found' });
        res.json({ message: 'Workout deleted' });
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

module.exports = router;
