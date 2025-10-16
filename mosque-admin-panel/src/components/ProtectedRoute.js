import React from 'react';
import { Navigate } from 'react-router-dom';

const ProtectedRoute = ({ children }) => {
  const adminUser = localStorage.getItem('adminUser');
  
  if (!adminUser) {
    return <Navigate to="/" replace />;
  }
  
  return children;
};

export default ProtectedRoute;