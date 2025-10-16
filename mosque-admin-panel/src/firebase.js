// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";
import { getFirestore } from "firebase/firestore";
import { getAuth } from "firebase/auth";

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
  apiKey: "REMOVED_SECRET",
  authDomain: "mubarok-tester.firebaseapp.com",
  databaseURL: "https://mubarok-tester-default-rtdb.firebaseio.com",
  projectId: "mubarok-tester",
  storageBucket: "mubarok-tester.firebasestorage.app",
  messagingSenderId: "185848472146",
  appId: "1:185848472146:web:a3913a5c05141021a9f58b",
  measurementId: "G-JJ7BKXT5NQ"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);
const db = getFirestore(app);
const auth = getAuth(app);

export { db, auth, analytics };
export default app;