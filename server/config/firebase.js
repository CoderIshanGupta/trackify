const admin = require('firebase-admin');
const path = require('path');
const fs = require('fs');

const serviceAccountPath = path.resolve(process.env.FIREBASE_SERVICE_ACCOUNT_PATH || './firebase-service-account.json');

if (!fs.existsSync(serviceAccountPath)) {
    console.warn(
        `⚠️  Firebase service account not found at: ${serviceAccountPath}\n` +
        `   Download it from Firebase Console → Project Settings → Service Accounts\n` +
        `   and save as server/firebase-service-account.json\n` +
        `   Auth will NOT work until this file is present.`
    );
    // Initialize with no credential so app still boots in dev
    if (!admin.apps.length) {
        admin.initializeApp();
    }
} else {
    const serviceAccount = require(serviceAccountPath);
    if (!admin.apps.length) {
        admin.initializeApp({
            credential: admin.credential.cert(serviceAccount),
        });
        console.log('✅ Firebase Admin SDK initialized');
    }
}

module.exports = admin;
