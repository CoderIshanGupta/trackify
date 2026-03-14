/**
 * Mood → Activity Suggestions Engine (server-side rule-based system)
 * Maps each mood to a curated list of recommended activities.
 */

const moodActivities = {
    Happy: [
        '🏃 Go for a run to celebrate your energy',
        '🎉 Catch up with a friend or plan a fun outing',
        '📸 Take photos and document your happy moments',
        '🎵 Create a positive playlist and dance it out',
        '🌳 Go for a nature walk and enjoy the day',
    ],
    Sad: [
        '🧘 Practice a 10-minute guided meditation',
        '📔 Journal your thoughts and feelings',
        '🎵 Listen to calming or uplifting music',
        '🚶 Take a gentle walk outdoors for fresh air',
        '📞 Call or message someone you trust',
        '🛁 Take a warm bath and rest',
    ],
    Anxious: [
        '🧘 Try box-breathing: inhale 4s, hold 4s, exhale 4s',
        '🚶 Go for a slow walk — physical movement reduces anxiety',
        '📔 Write down your worries to get them out of your head',
        '🎵 Put on ambient or lo-fi music',
        '🧩 Do a simple puzzle or coloring to occupy your mind',
        '🫖 Make herbal tea and sit quietly for 10 minutes',
    ],
    Angry: [
        '🥊 High-intensity workout to channel the energy',
        '🏃 Run or sprint until the tension releases',
        '🧘 Practice deep breathing for 5 minutes',
        '📔 Write about what triggered your anger (privately)',
        '🌊 Find a quiet place: sit and focus on 5 things you can see',
    ],
    Tired: [
        '💤 Take a 20-minute power nap — no longer!',
        '🚶 A light walk can boost energy more than sitting',
        '💧 Drink a large glass of water — dehydration causes fatigue',
        '🍎 Eat a light healthy snack (banana, nuts)',
        '🧘 Try a gentle yoga stretch for 10 minutes',
    ],
    Excited: [
        '🏋️ Channelize excitement into a workout session',
        '🎯 Set a new goal and write your action plan',
        '📚 Start that course or project you\'ve been delaying',
        '🎉 Share your excitement — inspire someone else',
        '🧗 Try something new and adventurous today',
    ],
    Calm: [
        '📚 Read a book or article you\'ve been saving',
        '🎨 Do something creative: draw, write, or craft',
        '🧘 Perfect time for a longer meditation session',
        '🌿 Tend to plants or go for a peaceful walk',
        '🍳 Cook a healthy meal you\'ve been wanting to try',
    ],
    Bored: [
        '📱 Learn a new skill (YouTube, Duolingo, etc.)',
        '🚴 Go for a bike ride or explore a new area',
        '🎮 Play a mentally stimulating game or puzzle',
        '🧹 Declutter and organize one area of your home',
        '🤝 Volunteer for a local community activity',
        '📞 Reconnect with an old friend',
    ],
};

/**
 * Returns 3 random activity suggestions for the given mood.
 * @param {string} mood - One of the mood enum values
 * @returns {string[]} Array of 3 activity suggestions
 */
const getSuggestionsForMood = (mood) => {
    const activities = moodActivities[mood] || moodActivities['Calm'];
    // Shuffle and return top 3
    const shuffled = [...activities].sort(() => Math.random() - 0.5);
    return shuffled.slice(0, 3);
};

module.exports = { getSuggestionsForMood, moodActivities };
