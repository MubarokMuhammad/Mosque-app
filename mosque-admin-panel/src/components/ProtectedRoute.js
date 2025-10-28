import React from 'react';
import { Navigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';

const ProtectedRoute = ({ children }) => {
  const { currentUser, loading } = useAuth();
  
  if (loading) {
    return <div>Loading...</div>; // You can replace this with a proper loading component
  }
  
  if (!currentUser) {
    return <Navigate to="/" replace />;
  }
  
  return children;
};

export default ProtectedRoute;