const mongoose = require('mongoose');

const userSchema = new mongoose.Schema(
    {
        uid: { type: String, required: true, unique: true }, // Firebase UID
        email: { type: String, required: true },
        name: { type: String },
        photoURL: { type: String },
        role: { type: String, enum: ['user', 'admin'], default: 'user' },
        lastSeen: { type: Date, default: Date.now },
    },
    { timestamps: true }
);

module.exports = mongoose.model('User', userSchema);
