import { 
  collection, 
  addDoc, 
  getDocs, 
  doc, 
  getDoc, 
  updateDoc, 
  deleteDoc,
  query,
  where,
  orderBy
} from 'firebase/firestore';
import { db } from '../firebase';

// Generic CRUD operations
export const createDocument = async (collectionName, data) => {
  try {
    const docRef = await addDoc(collection(db, collectionName), {
      ...data,
      createdAt: new Date(),
      updatedAt: new Date()
    });
    return docRef.id;
  } catch (error) {
    console.error('Error creating document:', error);
    throw error;
  }
};

export const getDocuments = async (collectionName, filters = []) => {
  try {
    let q = collection(db, collectionName);
    
    // Apply filters if provided
    filters.forEach(filter => {
      if (filter.field && filter.operator && filter.value) {
        q = query(q, where(filter.field, filter.operator, filter.value));
      }
    });
    
    // Add default ordering by createdAt
    q = query(q, orderBy('createdAt', 'desc'));
    
    const querySnapshot = await getDocs(q);
    const documents = [];
    querySnapshot.forEach((doc) => {
      documents.push({ id: doc.id, ...doc.data() });
    });
    return documents;
  } catch (error) {
    console.error('Error getting documents:', error);
    throw error;
  }
};

export const getDocument = async (collectionName, id) => {
  try {
    const docRef = doc(db, collectionName, id);
    const docSnap = await getDoc(docRef);
    
    if (docSnap.exists()) {
      return { id: docSnap.id, ...docSnap.data() };
    } else {
      throw new Error('Document not found');
    }
  } catch (error) {
    console.error('Error getting document:', error);
    throw error;
  }
};

export const updateDocument = async (collectionName, id, data) => {
  try {
    const docRef = doc(db, collectionName, id);
    await updateDoc(docRef, {
      ...data,
      updatedAt: new Date()
    });
    return true;
  } catch (error) {
    console.error('Error updating document:', error);
    throw error;
  }
};

export const deleteDocument = async (collectionName, id) => {
  try {
    const docRef = doc(db, collectionName, id);
    await deleteDoc(docRef);
    return true;
  } catch (error) {
    console.error('Error deleting document:', error);
    throw error;
  }
};

// Specific service functions for each module
export const organizationService = {
  create: (data) => createDocument('mosqueapp_organizations', data),
  getAll: () => getDocuments('mosqueapp_organizations'),
  getById: (id) => getDocument('mosqueapp_organizations', id),
  update: (id, data) => updateDocument('mosqueapp_organizations', id, data),
  delete: (id) => deleteDocument('mosqueapp_organizations', id)
};

export const mosqueService = {
  create: (data) => createDocument('mosqueapp_mosques', data),
  getAll: () => getDocuments('mosqueapp_mosques'),
  getById: (id) => getDocument('mosqueapp_mosques', id),
  update: (id, data) => updateDocument('mosqueapp_mosques', id, data),
  delete: (id) => deleteDocument('mosqueapp_mosques', id)
};

export const eventService = {
  create: (data) => createDocument('mosqueapp_events', data),
  getAll: () => getDocuments('mosqueapp_events'),
  getById: (id) => getDocument('mosqueapp_events', id),
  update: (id, data) => updateDocument('mosqueapp_events', id, data),
  delete: (id) => deleteDocument('mosqueapp_events', id),
  getRecent: () => getDocuments('mosqueapp_events').then(events => events.slice(0, 5))
};

export const userService = {
  create: (data) => createDocument('mosqueapp_users', data),
  getAll: () => getDocuments('mosqueapp_users'),
  getById: (id) => getDocument('mosqueapp_users', id),
  update: (id, data) => updateDocument('mosqueapp_users', id, data),
  delete: (id) => deleteDocument('mosqueapp_users', id)
};

export const categoryService = {
  create: (data) => createDocument('mosqueapp_categories', data),
  getAll: () => getDocuments('mosqueapp_categories'),
  getById: (id) => getDocument('mosqueapp_categories', id),
  update: (id, data) => updateDocument('mosqueapp_categories', id, data),
  delete: (id) => deleteDocument('mosqueapp_categories', id)
};

export const reportService = {
  create: (data) => createDocument('mosqueapp_reports', data),
  getAll: () => getDocuments('mosqueapp_reports'),
  getById: (id) => getDocument('mosqueapp_reports', id),
  update: (id, data) => updateDocument('mosqueapp_reports', id, data),
  delete: (id) => deleteDocument('mosqueapp_reports', id)
};