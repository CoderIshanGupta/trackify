const mongoose = require('mongoose');

const expenseSchema = new mongoose.Schema(
    {
        userId: { type: String, required: true }, // Firebase UID
        amount: { type: Number, required: true },
        category: {
            type: String,
            enum: ['Food', 'Transport', 'Shopping', 'Health', 'Entertainment', 'Bills', 'Other'],
            default: 'Other',
        },
        note: { type: String, default: '' },
        date: { type: Date, default: Date.now },
    },
    { timestamps: true }
);

module.exports = mongoose.model('Expense', expenseSchema);
