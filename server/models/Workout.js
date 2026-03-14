const mongoose = require('mongoose');

const workoutSchema = new mongoose.Schema(
    {
        userId: { type: String, required: true }, // Firebase UID
        type: {
            type: String,
            enum: ['Running', 'Cycling', 'Strength', 'Yoga', 'Swimming', 'Walking', 'HIIT', 'Other'],
            default: 'Other',
        },
        durationMinutes: { type: Number, required: true },
        caloriesBurned: { type: Number, default: 0 },
        note: { type: String, default: '' },
        date: { type: Date, default: Date.now },
    },
    { timestamps: true }
);

module.exports = mongoose.model('Workout', workoutSchema);
