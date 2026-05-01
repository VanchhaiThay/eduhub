const { Pool } = require('pg');
const admin = require('firebase-admin');
const bcrypt = require('bcrypt');
const fs = require('fs');
require('dotenv').config();

// Initialize Firebase Admin SDK
// Make sure you have firebase-service-key.json in the backend folder
const serviceAccountPath = process.env.FIREBASE_SERVICE_KEY || './firebase-service-key.json';

if (!fs.existsSync(serviceAccountPath)) {
  console.error('❌ Error: firebase-service-key.json not found!');
  console.error('Please download your Firebase service account key and save it as firebase-service-key.json');
  process.exit(1);
}

const serviceAccount = require(serviceAccountPath);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: serviceAccount.project_id,
});

// PostgreSQL Connection Pool
const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'eduUsers',
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'VaKS83CA',
});

async function syncFirebaseUsersToPgSQL() {
  try {
    console.log('Starting Firebase to PostgreSQL sync...');

    // Get all users from Firestore
    const usersCollection = admin.firestore().collection('users');
    const snapshot = await usersCollection.get();

    if (snapshot.empty) {
      console.log('No users found in Firestore');
      return;
    }

    let insertedCount = 0;
    let skippedCount = 0;

    // Iterate through all users
    for (const doc of snapshot.docs) {
      const userData = doc.data();
      const firebaseUid = doc.id;

      try {
        // Generate a hash for the password (use a placeholder if not available)
        const tempPassword = userData.password || 'temp-firebase-user-' + firebaseUid;
        const hashedPassword = await bcrypt.hash(tempPassword, 10);

        // Insert user into PostgreSQL
        const query = `
          INSERT INTO "eduUsers" (firebase_uid, first_name, last_name, email, password, role, created_at)
          VALUES ($1, $2, $3, $4, $5, $6, NOW())
          ON CONFLICT (email) DO UPDATE SET
            firebase_uid = EXCLUDED.firebase_uid,
            first_name = EXCLUDED.first_name,
            last_name = EXCLUDED.last_name,
            role = EXCLUDED.role
          RETURNING id;
        `;

        const values = [
          firebaseUid,
          userData.firstName || 'N/A',
          userData.lastName || 'N/A',
          userData.email,
          hashedPassword,
          userData.role || 'student'
        ];

        const result = await pool.query(query, values);
        insertedCount++;
        console.log(`✅ Synced user: ${userData.email} (ID: ${result.rows[0].id})`);
      } catch (error) {
        if (error.message.includes('duplicate key')) {
          skippedCount++;
          console.log(`⏭️  Skipped (already exists): ${userData.email}`);
        } else {
          console.error(`❌ Error syncing user ${userData.email}:`, error.message);
        }
      }
    }

    console.log(`\n✅ Sync complete!`);
    console.log(`📊 Summary:`);
    console.log(`   - Inserted: ${insertedCount}`);
    console.log(`   - Skipped: ${skippedCount}`);
    console.log(`   - Total: ${snapshot.size}`);
  } catch (error) {
    console.error('Sync error:', error.message);
  } finally {
    await pool.end();
    process.exit(0);
  }
}

syncFirebaseUsersToPgSQL();
