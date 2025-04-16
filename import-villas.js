const { initializeApp, applicationDefault } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const fs = require('fs');

// Initialize Firebase Admin SDK with default credentials
initializeApp({
  credential: applicationDefault(),
});

const db = getFirestore();

// Read villa data from JSON file
const villas = JSON.parse(fs.readFileSync('villa_collection.json', 'utf8'));

async function importVillas() {
  const batch = db.batch();

  for (const villa of villas) {
    const docRef = db.collection('villas').doc(villa.id); // use 'id' as document ID
    batch.set(docRef, villa);
  }

  await batch.commit();
  console.log('✅ Villas imported successfully to Firestore');
}

importVillas().catch(console.error);
