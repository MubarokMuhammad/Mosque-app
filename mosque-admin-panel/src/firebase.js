// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";
import { getFirestore } from "firebase/firestore";
import { getAuth } from "firebase/auth";

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
  apiKey: "REMOVED_SECRET",
  authDomain: "REMOVED_SECRET.firebaseapp.com",
  projectId: "REMOVED_SECRET",
  storageBucket: "REMOVED_SECRET.firebasestorage.app",
  messagingSenderId: "REMOVED_SECRET",
  appId: "1:REMOVED_SECRET:web:8cc05a667d5246d4e4f5ee",
  measurementId: "G-8FHB5WTGDZ"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);
const db = getFirestore(app);
const auth = getAuth(app);

export { db, auth, analytics };
export default app;