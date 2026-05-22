const { onCall, HttpsError } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");

admin.initializeApp();

const STUDENT_EMAIL_DOMAIN = "@students.levelup-26.local";

exports.createUser = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "You must be signed in.");
  }

  const callerUid = request.auth.uid;
  const callerDoc = await admin.firestore().collection("users").doc(callerUid).get();
  const callerRole = callerDoc.exists ? callerDoc.data().role : null;

  const role = request.data.role;

  if (role === "instructor") {
    if (callerRole !== "admin") {
      throw new HttpsError("permission-denied", "Only admins can create instructors.");
    }
  } else if (role === "student") {
    if (callerRole !== "admin" && callerRole !== "instructor") {
      throw new HttpsError("permission-denied", "Only admins or instructors can create students.");
    }
  } else {
    throw new HttpsError("invalid-argument", "role must be 'instructor' or 'student'.");
  }

  const data = request.data;
  const name = data.name;
  if (!name) {
    throw new HttpsError("invalid-argument", "name is required.");
  }

  let email;
  let password;
  if (role === "student") {
    const username = data.username;
    const pin = data.pinCode;
    if (!username || !pin) {
      throw new HttpsError("invalid-argument", "Students need username and pinCode.");
    }
    email = username.toLowerCase() + STUDENT_EMAIL_DOMAIN;
    password = pin;
  } else {
    email = (data.email || "").trim().toLowerCase();
    if (!email) {
      throw new HttpsError("invalid-argument", "Instructors need an email.");
    }
    password = Math.random().toString(36).slice(-10) + "A1!";
  }

  let userRecord;
  try {
    userRecord = await admin.auth().createUser({
      email: email,
      password: password,
      displayName: name,
    });
  } catch (err) {
    if (err.code === "auth/email-already-exists") {
      throw new HttpsError("already-exists", "That username or email is already taken.");
    }
    throw new HttpsError("internal", "Failed to create account: " + err.message);
  }

  const uid = userRecord.uid;
  const userDoc = {
    name: name,
    role: role,
    userNumber: data.userNumber || null,
    searchKeywords: name.toLowerCase().split(" ").concat([role]),
  };

  if (role === "student") {
    userDoc.username = data.username.toLowerCase();
    userDoc.pinCode = data.pinCode;
    userDoc.levelId = data.levelId || null;
    userDoc.studentNumber = data.studentNumber || null;
  } else {
    userDoc.email = email;
    userDoc.phoneNumber = data.phoneNumber || null;
    userDoc.address = data.address || null;
    userDoc.assignedLevels = data.assignedLevels || [];
  }

  await admin.firestore().collection("users").doc(uid).set(userDoc);

  return { uid: uid };
});
