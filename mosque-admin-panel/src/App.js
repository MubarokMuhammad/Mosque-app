import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { ThemeProvider, createTheme } from '@mui/material/styles';
import CssBaseline from '@mui/material/CssBaseline';
import { Box } from '@mui/material';
import { styled } from '@mui/material/styles';

// Context
import { AuthProvider } from './contexts/AuthContext';

// Components
import Login from './components/Login';
import Layout from './components/Layout';
import ProtectedRoute from './components/ProtectedRoute';

// Pages
import Dashboard from './pages/Dashboard';
import Organizations from './pages/Organizations';
import Mosques from './pages/Mosques';
import Categories from './pages/Categories';
import Events from './pages/Events';
import Users from './pages/Users';
import Reports from './pages/Reports';
import VerifyOrganization from './pages/VerifyOrganization';
import DummyDataImport from './components/DummyDataImport';

// Create theme with enhanced transitions
const theme = createTheme({
  palette: {
    primary: {
      main: '#20B2AA',
    },
    secondary: {
      main: '#ffffff',
    },
    background: {
      default: '#f5f5f5',
    },
  },
  typography: {
    fontFamily: '"Roboto", "Helvetica", "Arial", sans-serif',
  },
  transitions: {
    duration: {
      shortest: 150,
      shorter: 200,
      short: 250,
      standard: 300,
      complex: 375,
      enteringScreen: 225,
      leavingScreen: 195,
    },
    easing: {
      easeInOut: 'cubic-bezier(0.4, 0, 0.2, 1)',
      easeOut: 'cubic-bezier(0.0, 0, 0.2, 1)',
      easeIn: 'cubic-bezier(0.4, 0, 1, 1)',
      sharp: 'cubic-bezier(0.4, 0, 0.6, 1)',
    },
  },
  components: {
    MuiButton: {
      styleOverrides: {
        root: {
          transition: 'all 0.3s cubic-bezier(0.4, 0, 0.2, 1)',
          '&:hover': {
            transform: 'translateY(-2px)',
            boxShadow: '0 4px 12px rgba(0, 0, 0, 0.15)',
          },
        },
      },
    },
    MuiCard: {
      styleOverrides: {
        root: {
          transition: 'all 0.3s cubic-bezier(0.4, 0, 0.2, 1)',
          '&:hover': {
            transform: 'translateY(-4px)',
            boxShadow: '0 8px 25px rgba(0, 0, 0, 0.15)',
          },
        },
      },
    },
    MuiPaper: {
      styleOverrides: {
        root: {
          transition: 'box-shadow 0.3s cubic-bezier(0.4, 0, 0.2, 1)',
        },
      },
    },
  },
});

// Animated page wrapper
const AnimatedPageWrapper = styled(Box)(({ theme }) => ({
  animation: 'fadeInUp 0.6s cubic-bezier(0.4, 0, 0.2, 1)',
  '@keyframes fadeInUp': {
    '0%': {
      opacity: 0,
      transform: 'translateY(30px)',
    },
    '100%': {
      opacity: 1,
      transform: 'translateY(0)',
    },
  },
}));

function App() {
  return (
    <AuthProvider>
      <ThemeProvider theme={theme}>
        <CssBaseline />
        <Router>
        <Routes>
          <Route path="/" element={<Login />} />
          <Route
            path="/dashboard"
            element={
              <ProtectedRoute>
                <Layout>
                  <AnimatedPageWrapper>
                    <Dashboard />
                  </AnimatedPageWrapper>
                </Layout>
              </ProtectedRoute>
            }
          />
          <Route
            path="/organizations"
            element={
              <ProtectedRoute>
                <Layout>
                  <AnimatedPageWrapper>
                    <Organizations />
                  </AnimatedPageWrapper>
                </Layout>
              </ProtectedRoute>
            }
          />
          <Route
            path="/mosques"
            element={
              <ProtectedRoute>
                <Layout>
                  <AnimatedPageWrapper>
                    <Mosques />
                  </AnimatedPageWrapper>
                </Layout>
              </ProtectedRoute>
            }
          />
          <Route
            path="/categories"
            element={
              <ProtectedRoute>
                <Layout>
                  <AnimatedPageWrapper>
                    <Categories />
                  </AnimatedPageWrapper>
                </Layout>
              </ProtectedRoute>
            }
          />
          <Route
            path="/events"
            element={
              <ProtectedRoute>
                <Layout>
                  <AnimatedPageWrapper>
                    <Events />
                  </AnimatedPageWrapper>
                </Layout>
              </ProtectedRoute>
            }
          />
          <Route
            path="/users"
            element={
              <ProtectedRoute>
                <Layout>
                  <AnimatedPageWrapper>
                    <Users />
                  </AnimatedPageWrapper>
                </Layout>
              </ProtectedRoute>
            }
          />
          <Route
            path="/verify-organization"
            element={
              <ProtectedRoute>
                <Layout>
                  <AnimatedPageWrapper>
                    <VerifyOrganization />
                  </AnimatedPageWrapper>
                </Layout>
              </ProtectedRoute>
            }
          />
          <Route
            path="/reports"
            element={
              <ProtectedRoute>
                <Layout>
                  <AnimatedPageWrapper>
                    <Reports />
                  </AnimatedPageWrapper>
                </Layout>
              </ProtectedRoute>
            }
          />
          <Route
            path="/dummy-import"
            element={
              <ProtectedRoute>
                <Layout>
                  <AnimatedPageWrapper>
                    <DummyDataImport />
                  </AnimatedPageWrapper>
                </Layout>
              </ProtectedRoute>
            }
          />
        </Routes>
        </Router>
      </ThemeProvider>
    </AuthProvider>
  );
}

export default App;
