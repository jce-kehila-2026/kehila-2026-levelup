const { onCall, HttpsError } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");

admin.initializeApp();

const STUDENT_EMAIL_DOMAIN = "@students.levelup-26.local";

exports.createUser = onCall({
  cors: ["http://localhost:53996", "http://localhost:5000", /^http:\/\/localhost(:\d+)?$/, "https://levelup-26.web.app", "https://levelup-26.firebaseapp.com"],
  region: "us-central1",
}, async (request) => {
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
    isArchived: false,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    searchKeywords: name.toLowerCase().split(" ").concat([role]),
  };

  const privateDoc = {};

  if (role === "student") {
    userDoc.username = data.username.toLowerCase();
    userDoc.levelId = data.levelId || null;
    userDoc.studentNumber = data.studentNumber || null;
    userDoc.createdBy = callerUid;

    privateDoc.pinCode = data.pinCode;
  } else {
    userDoc.assignedLevels = data.assignedLevels || [];

    privateDoc.email = email;
    privateDoc.phoneNumber = data.phoneNumber || null;
    privateDoc.address = data.address || null;
  }

  await admin.firestore().collection("users").doc(uid).set(userDoc);
  await admin.firestore().collection("users_private").doc(uid).set(privateDoc);

  if (role === "instructor") {
    try {
      const resetLink = await admin.auth().generatePasswordResetLink(email);

      const transporter = nodemailer.createTransport({
        service: "gmail",
        auth: {
          user: process.env.GMAIL_USER,
          pass: process.env.GMAIL_PASS,
        },
      });

      await transporter.sendMail({
        from: process.env.GMAIL_USER,
        to: email,
        subject: "Welcome to LevelUp — Set Your Password",
        html: `
          <h2>Welcome to LevelUp, ${name}!</h2>
          <p>Your instructor account has been created.</p>
          <p>Click the link below to set your password and access the platform:</p>
          <a href="${resetLink}" style="
            background-color: #6B21A8;
            color: white;
            padding: 12px 24px;
            text-decoration: none;
            border-radius: 8px;
            display: inline-block;
            margin: 16px 0;
          ">Set Your Password</a>
          <p>If the button doesn't work, copy this link: ${resetLink}</p>
          <p>This link expires in 24 hours.</p>
          <br>
          <p>The LevelUp Team</p>
        `,
      });
    } catch (emailError) {
      console.error("Failed to send welcome email:", emailError.message);
      console.error("GMAIL_USER:", process.env.GMAIL_USER ? "SET" : "NOT SET");
      console.error("GMAIL_PASS:", process.env.GMAIL_PASS ? "SET" : "NOT SET");
      // Don't throw — user was created successfully
    }
  }

  return { uid: uid };
});

exports.archiveUser = onCall({
  cors: ["http://localhost:53996", "http://localhost:5000", /^http:\/\/localhost(:\d+)?$/, "https://levelup-26.web.app", "https://levelup-26.firebaseapp.com"],
  region: "us-central1",
}, async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "You must be signed in.");
  }

  const callerDoc = await admin.firestore()
    .collection("users")
    .doc(request.auth.uid)
    .get();
  const callerRole = callerDoc.exists ? callerDoc.data().role : null;

  if (callerRole !== "admin" && callerRole !== "instructor") {
    throw new HttpsError("permission-denied", "Only admins or instructors can archive users.");
  }

  const uid = request.data.uid;
  if (!uid) {
    throw new HttpsError("invalid-argument", "uid is required.");
  }

  const targetDoc = await admin.firestore()
    .collection("users")
    .doc(uid)
    .get();
  const targetRole = targetDoc.exists ? targetDoc.data().role : null;

  if (callerRole === "instructor" && targetRole !== "student") {
    throw new HttpsError("permission-denied", "Instructors can only archive students.");
  }

  await admin.auth().updateUser(uid, { disabled: true });

  await admin.firestore().collection("users").doc(uid).update({
    isArchived: true,
    archivedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  if (targetRole === "instructor") {
    const groupsSnap = await admin.firestore()
      .collection("groups")
      .where("instructorIds", "arrayContains", uid)
      .get();
    const batch = admin.firestore().batch();
    groupsSnap.docs.forEach((doc) => {
      batch.update(doc.ref, {
        instructorIds: admin.firestore.FieldValue.arrayRemove(uid)
      });
    });
    await batch.commit();
  }

  return { success: true };
});

exports.restoreUser = onCall({
  cors: ["http://localhost:53996", "http://localhost:5000", /^http:\/\/localhost(:\d+)?$/, "https://levelup-26.web.app", "https://levelup-26.firebaseapp.com"],
  region: "us-central1",
}, async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "You must be signed in.");
  }

  const callerDoc = await admin.firestore()
    .collection("users")
    .doc(request.auth.uid)
    .get();
  const callerRole = callerDoc.exists ? callerDoc.data().role : null;

  if (callerRole !== "admin") {
    throw new HttpsError("permission-denied", "Only admins can restore users.");
  }

  const uid = request.data.uid;
  if (!uid) {
    throw new HttpsError("invalid-argument", "uid is required.");
  }

  await admin.auth().updateUser(uid, { disabled: false });

  await admin.firestore().collection("users").doc(uid).update({
    isArchived: false,
    archivedAt: admin.firestore.FieldValue.delete(),
  });

  return { success: true };
});

exports.resetStudentPin = onCall({ cors: true, region: "us-central1" }, async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "You must be signed in.");
  }

  const callerDoc = await admin.firestore()
    .collection("users")
    .doc(request.auth.uid)
    .get();
  const callerRole = callerDoc.exists ? callerDoc.data().role : null;

  if (callerRole !== "admin" && callerRole !== "instructor") {
    throw new HttpsError("permission-denied", "Only admins or instructors can reset PINs.");
  }

  const { studentId, newPin } = request.data;
  if (!studentId || !newPin) {
    throw new HttpsError("invalid-argument", "studentId and newPin are required.");
  }
  if (!/^\d{6}$/.test(newPin)) {
    throw new HttpsError("invalid-argument", "PIN must be exactly 6 digits.");
  }

  const studentDoc = await admin.firestore()
    .collection("users")
    .doc(studentId)
    .get();

  if (!studentDoc.exists) {
    throw new HttpsError("not-found", "Student not found.");
  }

  await admin.auth().updateUser(studentId, { password: newPin });

  await admin.firestore().collection("users_private").doc(studentId).set({
    pinCode: newPin,
  }, { merge: true });

  return { success: true };
});

exports.resendWelcomeEmail = onCall({ cors: true, region: "us-central1" }, async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "You must be signed in.");
  }

  const callerDoc = await admin.firestore()
    .collection("users")
    .doc(request.auth.uid)
    .get();
  const callerRole = callerDoc.exists ? callerDoc.data().role : null;

  if (callerRole !== "admin") {
    throw new HttpsError("permission-denied", "Only admins can resend welcome emails.");
  }

  const { instructorId } = request.data;
  if (!instructorId) {
    throw new HttpsError("invalid-argument", "instructorId is required.");
  }

  const instructorDoc = await admin.firestore()
    .collection("users")
    .doc(instructorId)
    .get();

  if (!instructorDoc.exists) {
    throw new HttpsError("not-found", "Instructor not found.");
  }

  const name = instructorDoc.data().name;

  const privateDoc = await admin.firestore()
    .collection("users_private")
    .doc(instructorId)
    .get();

  if (!privateDoc.exists) {
    throw new HttpsError("not-found", "Instructor private details not found.");
  }

  const email = privateDoc.data().email;
  const resetLink = await admin.auth().generatePasswordResetLink(email);

  const transporter = nodemailer.createTransport({
    service: "gmail",
    auth: {
      user: process.env.GMAIL_USER,
      pass: process.env.GMAIL_PASS,
    },
  });

  await transporter.sendMail({
    from: process.env.GMAIL_USER,
    to: email,
    subject: "LevelUp — Password Reset Link",
    html: `
      <h2>Hello ${name},</h2>
      <p>Here is your new password reset link:</p>
      <a href="${resetLink}" style="
        background-color: #6B21A8;
        color: white;
        padding: 12px 24px;
        text-decoration: none;
        border-radius: 8px;
        display: inline-block;
        margin: 16px 0;
      ">Set Your Password</a>
      <p>If the button does not work, copy this link: ${resetLink}</p>
      <p>This link expires in 24 hours.</p>
      <br>
      <p>The LevelUp Team</p>
    `,
  });

  return { success: true };
});

exports.deleteUserPermanently = onCall({
  cors: ["http://localhost:53996", "http://localhost:5000", /^http:\/\/localhost(:\d+)?$/, "https://levelup-26.web.app", "https://levelup-26.firebaseapp.com"],
  region: "us-central1",
}, async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "You must be signed in.");
  }

  const callerDoc = await admin.firestore()
    .collection("users")
    .doc(request.auth.uid)
    .get();
  const callerRole = callerDoc.exists ? callerDoc.data().role : null;

  if (callerRole !== "admin") {
    throw new HttpsError("permission-denied", "Only admins can permanently delete users.");
  }

  const uid = request.data.uid;
  if (!uid) {
    throw new HttpsError("invalid-argument", "uid is required.");
  }

  // Delete from Firebase Auth
  try {
    await admin.auth().deleteUser(uid);
  } catch (err) {
    if (err.code !== "auth/user-not-found") {
      throw new HttpsError("internal", "Failed to delete Auth account: " + err.message);
    }
  }

  // Delete from Firestore
  await admin.firestore().collection("users").doc(uid).delete();
  await admin.firestore().collection("users_private").doc(uid).delete();

  return { success: true };
});

exports.convertPptxToPdf = onCall({
  cors: ["http://localhost:53996", "http://localhost:5000", /^http:\/\/localhost(:\d+)?$/, "https://levelup-26.web.app", "https://levelup-26.firebaseapp.com"],
  region: "us-central1",
  memory: "2GiB",
  timeoutSeconds: 300,
}, async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "You must be signed in.");
  }

  const storagePath = request.data.storagePath;
  if (!storagePath) {
    throw new HttpsError("invalid-argument", "storagePath is required.");
  }

  const fs = require("fs");
  const path = require("path");
  const os = require("os");
  const { convertDocument } = require("@matbee/libreoffice-converter");

  const bucket = admin.storage().bucket();
  const file = bucket.file(storagePath);

  const [exists] = await file.exists();
  if (!exists) {
    throw new HttpsError("not-found", "PPTX file not found in Storage.");
  }

  const tempDir = os.tmpdir();
  const filename = path.basename(storagePath);
  const tempPptxPath = path.join(tempDir, filename);

  try {
    // Download PPTX
    await file.download({ destination: tempPptxPath });

    // Read bytes
    const pptxBuffer = fs.readFileSync(tempPptxPath);

    // Convert to PDF
    const result = await convertDocument(pptxBuffer, { outputFormat: "pdf" });
    const pdfBuffer = result.data;

    // Upload PDF back to Storage
    const baseNameWithoutExt = path.basename(storagePath, path.extname(storagePath));
    const pdfStoragePath = `materials/converted_pdfs/${baseNameWithoutExt}.pdf`;

    const pdfFile = bucket.file(pdfStoragePath);
    await pdfFile.save(pdfBuffer, {
      metadata: {
        contentType: "application/pdf",
      },
    });

    // Clean up local temp file
    fs.unlinkSync(tempPptxPath);

    return { pdfPath: pdfStoragePath };
  } catch (error) {
    console.error("PPTX to PDF conversion failed:", error);
    if (fs.existsSync(tempPptxPath)) {
      fs.unlinkSync(tempPptxPath);
    }
    throw new HttpsError("internal", "Failed to convert PPTX: " + error.message);
  }
});