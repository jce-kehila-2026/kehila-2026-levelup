const admin = require('firebase-admin');

// Initialize with the project ID from .firebaserc
admin.initializeApp({
  projectId: 'levelup-26'
});

const db = admin.firestore();

console.log('Querying users...');
db.collection('users').get()
  .then(snap => {
    console.log(`Found ${snap.docs.length} users:`);
    snap.docs.forEach(doc => {
      const data = doc.data();
      console.log(`ID: ${doc.id} | Name: ${data.name} | Email: ${data.email} | Role: ${data.role} | Archived: ${data.isArchived}`);
    });
    process.exit(0);
  })
  .catch(err => {
    console.error('Error querying users:', err);
    process.exit(1);
  });
