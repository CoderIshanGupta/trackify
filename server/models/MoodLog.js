const mongoose = require('mongoose');

const moodLogSchema = new mongoose.Schema(
    {
        userId: { type: String, required: true }, // Firebase UID
        mood: {
            type: String,
            enum: ['Happy', 'Sad', 'Anxious', 'Angry', 'Tired', 'Excited', 'Calm', 'Bored'],
            required: true,
        },
        suggestedActivities: [{ type: String }],
        note: { type: String, default: '' },
        date: { type: Date, default: Date.now },
    },
    { timestamps: true }
);

module.exports = mongoose.model('MoodLog', moodLogSchema);
