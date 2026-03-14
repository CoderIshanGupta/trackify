const express = require('express');
const router = express.Router();
const Expense = require('../models/Expense');
const verifyToken = require('../middleware/auth');

// All routes require auth
router.use(verifyToken);

// GET /api/expenses — list all expenses for current user
router.get('/', async (req, res) => {
    try {
        const expenses = await Expense.find({ userId: req.user.uid })
            .sort({ date: -1 });
        res.json(expenses);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// GET /api/expenses/summary — totals per category
router.get('/summary', async (req, res) => {
    try {
        const summary = await Expense.aggregate([
            { $match: { userId: req.user.uid } },
            {
                $group: {
                    _id: '$category',
                    total: { $sum: '$amount' },
                    count: { $sum: 1 },
                },
            },
            { $sort: { total: -1 } },
        ]);
        const totalSpent = summary.reduce((acc, cat) => acc + cat.total, 0);
        res.json({ categories: summary, totalSpent });
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// POST /api/expenses — add new expense
router.post('/', async (req, res) => {
    try {
        const { amount, category, note, date } = req.body;
        if (!amount || amount <= 0) {
            return res.status(400).json({ message: 'Amount must be positive' });
        }
        const expense = await Expense.create({
            userId: req.user.uid,
            amount,
            category: category || 'Other',
            note: note || '',
            date: date ? new Date(date) : new Date(),
        });
        res.status(201).json(expense);
    } catch (err) {
        res.status(400).json({ message: err.message });
    }
});

// PUT /api/expenses/:id — update expense
router.put('/:id', async (req, res) => {
    try {
        const expense = await Expense.findOne({ _id: req.params.id, userId: req.user.uid });
        if (!expense) return res.status(404).json({ message: 'Expense not found' });

        const { amount, category, note, date } = req.body;
        if (amount !== undefined) expense.amount = amount;
        if (category !== undefined) expense.category = category;
        if (note !== undefined) expense.note = note;
        if (date !== undefined) expense.date = new Date(date);

        await expense.save();
        res.json(expense);
    } catch (err) {
        res.status(400).json({ message: err.message });
    }
});

// DELETE /api/expenses/:id — delete expense
router.delete('/:id', async (req, res) => {
    try {
        const expense = await Expense.findOneAndDelete({ _id: req.params.id, userId: req.user.uid });
        if (!expense) return res.status(404).json({ message: 'Expense not found' });
        res.json({ message: 'Expense deleted' });
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

module.exports = router;
