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
  orderBy,
  onSnapshot
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
    
    // Add default ordering - use submittedAt for organization verification, createdAt for others
    const orderField = collectionName === 'mosqueapp_verify_organization' ? 'submittedAt' : 'createdAt';
    q = query(q, orderBy(orderField, 'desc'));
    
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
  getRecent: () => getDocuments('mosqueapp_events').then(events => events.slice(0, 5)),
  // Avoid composite index requirement by not using default getDocuments orderBy
  getByOrganization: async (organizationId) => {
    try {
      const q = query(
        collection(db, 'mosqueapp_events'),
        where('organizationId', '==', organizationId)
      );
      const snap = await getDocs(q);
      return snap.docs.map(d => ({ id: d.id, ...d.data() }));
    } catch (error) {
      console.error('Error fetching events by organization:', error);
      throw error;
    }
  },
  // Real-time subscription by organizationId
  subscribeByOrganization: (organizationId, callback) => {
    const q = query(
      collection(db, 'mosqueapp_events'),
      where('organizationId', '==', organizationId)
    );
    const unsub = onSnapshot(q, (snap) => {
      const docs = snap.docs.map(d => ({ id: d.id, ...d.data() }));
      callback(docs);
    }, (error) => {
      console.error('Event subscription error:', error);
    });
    return unsub;
  },
  // Real-time subscription by organization details
  subscribeByOrganizationDetails: (organizationName, organizationAddress, callback) => {
    console.log('🔍 Querying events with organizationName:', organizationName, 'organizationAddress:', organizationAddress);
    console.log('🔍 Expected Firebase data structure: organization.organizationName and organization.address');
    
    // Query by both organizationName and organizationAddress
    const q = query(
      collection(db, 'mosqueapp_events'),
      where('organization.organizationName', '==', organizationName),
      where('organization.address', '==', organizationAddress)
    );
    
    const unsub = onSnapshot(q, (snap) => {
      const docs = snap.docs.map(d => ({ id: d.id, ...d.data() }));
      console.log('📅 Events received for', organizationName, 'at', organizationAddress, 'Count:', docs.length);
      console.log('📅 Events data:', docs);
      
      // Debug: Log the organization structure of each event
      docs.forEach((doc, index) => {
        console.log(`📅 Event ${index + 1} organization structure:`, doc.organization);
      });
      
      callback(docs);
    }, (error) => {
      console.error('Event subscription by details error:', error);
      console.error('Error code:', error.code);
      console.error('Error message:', error.message);
      
      // If composite index error occurs, fallback to organizationName only
      if (error.code === 'failed-precondition') {
        console.log('🔄 Falling back to organizationName only query for events due to composite index requirement');
        const fallbackQ = query(
          collection(db, 'mosqueapp_events'),
          where('organization.organizationName', '==', organizationName)
        );
        const fallbackUnsub = onSnapshot(fallbackQ, (snap) => {
          // Filter by organizationAddress in memory
          const allDocs = snap.docs.map(d => ({ id: d.id, ...d.data() }));
          console.log('📅 All events found by organizationName:', allDocs.length);
          
          // Debug: Log all organization structures before filtering
          allDocs.forEach((doc, index) => {
            console.log(`📅 Fallback Event ${index + 1} organization:`, doc.organization);
            console.log(`📅 Comparing address: "${doc.organization?.address}" === "${organizationAddress}"`);
          });
          
          const docs = allDocs.filter(doc => doc.organization?.address === organizationAddress);
          console.log('📅 Fallback events received for', organizationName, 'Count:', docs.length);
          callback(docs);
        });
        return fallbackUnsub;
      }
    });
    return unsub;
  }
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

export const announcementService = {
  create: (data) => createDocument('mosqueapp_announcements', data),
  getAll: () => getDocuments('mosqueapp_announcements'),
  getById: (id) => getDocument('mosqueapp_announcements', id),
  update: (id, data) => updateDocument('mosqueapp_announcements', id, data),
  delete: (id) => deleteDocument('mosqueapp_announcements', id),
  // Avoid composite index requirement by not using default getDocuments orderBy
  getByOrganization: async (organizationId) => {
    try {
      const q = query(
        collection(db, 'mosqueapp_announcements'),
        where('organizationId', '==', organizationId)
      );
      const snap = await getDocs(q);
      return snap.docs.map(d => ({ id: d.id, ...d.data() }));
    } catch (error) {
      console.error('Error fetching announcements by organization:', error);
      throw error;
    }
  },
  // Real-time subscription
  subscribeByOrganization: (organizationId, callback) => {
    console.log('🔍 Subscribing to announcements for organizationId:', organizationId);
    const q = query(
      collection(db, 'mosqueapp_announcements'),
      where('organizationId', '==', organizationId)
    );
    const unsub = onSnapshot(q, (snap) => {
      const docs = snap.docs.map(d => ({ id: d.id, ...d.data() }));
      console.log('📢 Announcements received for organizationId:', organizationId, 'Count:', docs.length);
      console.log('📢 Announcements data:', docs);
      callback(docs);
    }, (error) => {
      console.error('Announcement subscription error:', error);
    });
    return unsub;
  },
  // Real-time subscription by organization details
  subscribeByOrganizationDetails: (organizationName, organizationAddress, callback) => {
    console.log('🔍 Querying announcements with organizationName:', organizationName, 'organizationAddress:', organizationAddress);
    
    // Query by both organizationName and organizationAddress
    const q = query(
      collection(db, 'mosqueapp_announcements'),
      where('organizationName', '==', organizationName),
      where('organizationAddress', '==', organizationAddress)
    );
    
    const unsub = onSnapshot(q, (snap) => {
      const docs = snap.docs.map(d => ({ id: d.id, ...d.data() }));
      console.log('📢 Announcements received for', organizationName, 'at', organizationAddress, 'Count:', docs.length);
      console.log('📢 Announcements data:', docs);
      callback(docs);
    }, (error) => {
      console.error('Announcement subscription by details error:', error);
      // If composite index error occurs, fallback to organizationName only
      if (error.code === 'failed-precondition') {
        console.log('🔄 Falling back to organizationName only query due to composite index requirement');
        const fallbackQ = query(
          collection(db, 'mosqueapp_announcements'),
          where('organizationName', '==', organizationName)
        );
        const fallbackUnsub = onSnapshot(fallbackQ, (snap) => {
          // Filter by organizationAddress in memory
          const docs = snap.docs
            .map(d => ({ id: d.id, ...d.data() }))
            .filter(doc => doc.organizationAddress === organizationAddress);
          console.log('📢 Fallback announcements received for', organizationName, 'Count:', docs.length);
          callback(docs);
        });
        return fallbackUnsub;
      }
    });
    return unsub;
  }
};

// Organization Verification Service
export const organizationVerificationService = {
  getAll: () => getDocuments('mosqueapp_verify_organization'),
  updateStatus: (id, status) => updateDocument('mosqueapp_verify_organization', id, { 
    verifyStatus: status,
    updatedAt: new Date()
  }),
  delete: async (id) => {
    try {
      // Ambil dokumen verifikasi terlebih dahulu untuk mendapatkan organizationId dan userId
      const verification = await getDocument('mosqueapp_verify_organization', id);

      const orgId = verification.organizationId;
      const userId = verification.userId 
        || verification?.userDetails?.uid 
        || verification?.userDetails?.id 
        || verification?.userDetails?.userId;

      // Jika ada organizationId, hapus organisasi terkait
      if (orgId) {
        try {
          await organizationService.delete(orgId);
        } catch (orgErr) {
          console.error('Error deleting organization document:', orgErr);
          // Lanjutkan proses meski gagal menghapus organisasi
        }
      }

      // Kembalikan status userType menjadi 'regular' dan bersihkan organizationId pada user
      if (userId) {
        try {
          await updateDocument('mosqueapp_users', userId, {
            userType: 'regular',
            organizationId: null,
            updatedAt: new Date()
          });
        } catch (userErr) {
          console.error('Error updating user to regular:', userErr);
          // Lanjutkan proses meski gagal mengupdate user
        }
      }

      // Terakhir, hapus dokumen verifikasi
      await deleteDocument('mosqueapp_verify_organization', id);
      return true;
    } catch (error) {
      console.error('Error deleting organization verification with cascading effects:', error);
      throw error;
    }
  },
  
  // Accept organization verification, create organization doc, and update user type
  accept: async (id, userId) => {
    try {
      // Fetch verification data
      const verification = await getDocument('mosqueapp_verify_organization', id);

      // Compose organization data: include ALL verification fields and normalized keys
      const orgData = {
        ...verification,
        name: verification.organizationName || verification.name || '',
        description: verification.organizationDescription || verification.description || '',
        email: verification.contactEmail || '',
        phone: verification.contactPhone || verification.phone || '',
        address: verification.address || '',
        adminIds: [userId],
        memberIds: [],
        isVerified: true,
        isActive: true,
        verificationId: id,
        submittedAt: verification.submittedAt || null,
      };

      // Create organization document with full data
      const orgId = await organizationService.create(orgData);

      // Update verification status and link to created organization
      await updateDocument('mosqueapp_verify_organization', id, {
        verifyStatus: 'accepted',
        organizationId: orgId,
        updatedAt: new Date()
      });

      // Update user type and link to organization
      await updateDocument('mosqueapp_users', userId, {
        userType: 'Organization',
        organizationId: orgId,
        updatedAt: new Date()
      });

      return true;
    } catch (error) {
      console.error('Error accepting organization verification:', error);
      throw error;
    }
  },
  
  decline: (id) => updateDocument('mosqueapp_verify_organization', id, { 
    verifyStatus: 'declined',
    updatedAt: new Date()
  })
};