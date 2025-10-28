import React, { useState } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { useNavigate } from 'react-router-dom';
import {
  Container,
  Paper,
  TextField,
  Button,
  Typography,
  Box,
  Alert,
  Avatar,
  Fade,
  Slide
} from '@mui/material';
import { styled } from '@mui/material/styles';
import { AccountCircle, Lock } from '@mui/icons-material';

const LoginContainer = styled(Container)(({ theme }) => ({
  minHeight: '100vh',
  display: 'flex',
  alignItems: 'center',
  justifyContent: 'center',
  background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
  position: 'relative',
  '&::before': {
    content: '""',
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    background: 'linear-gradient(135deg, rgba(0, 105, 92, 0.8) 0%, rgba(0, 150, 136, 0.6) 100%)',
    zIndex: 1
  }
}));

const StyledPaper = styled(Paper)(({ theme }) => ({
  padding: theme.spacing(5),
  display: 'flex',
  flexDirection: 'column',
  alignItems: 'center',
  maxWidth: 450,
  width: '100%',
  backgroundColor: 'rgba(255, 255, 255, 0.95)',
  backdropFilter: 'blur(20px)',
  boxShadow: '0 20px 40px rgba(0, 0, 0, 0.15), 0 0 0 1px rgba(255, 255, 255, 0.1)',
  borderRadius: '24px',
  border: '1px solid rgba(255, 255, 255, 0.2)',
  position: 'relative',
  zIndex: 2,
  transition: 'all 0.3s ease-in-out',
  '&:hover': {
    transform: 'translateY(-5px)',
    boxShadow: '0 25px 50px rgba(0, 0, 0, 0.2), 0 0 0 1px rgba(255, 255, 255, 0.15)',
  }
}));

const LoginButton = styled(Button)(({ theme }) => ({
  background: 'linear-gradient(135deg, #00695c 0%, #00897b 100%)',
  color: 'white',
  padding: theme.spacing(1.8),
  marginTop: theme.spacing(3),
  borderRadius: '12px',
  fontSize: '1.1rem',
  fontWeight: 600,
  textTransform: 'none',
  boxShadow: '0 8px 20px rgba(0, 105, 92, 0.3)',
  transition: 'all 0.3s ease-in-out',
  '&:hover': {
    background: 'linear-gradient(135deg, #004d40 0%, #00695c 100%)',
    transform: 'translateY(-2px)',
    boxShadow: '0 12px 25px rgba(0, 105, 92, 0.4)',
  },
  '&:active': {
    transform: 'translateY(0px)',
  }
}));

const StyledTextField = styled(TextField)(({ theme }) => ({
  '& .MuiOutlinedInput-root': {
    borderRadius: '12px',
    backgroundColor: 'rgba(255, 255, 255, 0.8)',
    transition: 'all 0.3s ease-in-out',
    '&:hover': {
      backgroundColor: 'rgba(255, 255, 255, 0.9)',
    },
    '&.Mui-focused': {
      backgroundColor: 'rgba(255, 255, 255, 1)',
      '& fieldset': {
        borderColor: '#00695c',
        borderWidth: '2px',
      },
    },
  },
  '& .MuiInputLabel-root.Mui-focused': {
    color: '#00695c',
    fontWeight: 600,
  },
  '& .MuiOutlinedInput-input': {
    padding: theme.spacing(1.5),
  }
}));

const LogoAvatar = styled(Avatar)(({ theme }) => ({
  width: 80,
  height: 80,
  background: 'linear-gradient(135deg, #00695c 0%, #00897b 100%)',
  marginBottom: theme.spacing(2),
  boxShadow: '0 8px 20px rgba(0, 105, 92, 0.3)',
}));

const Login = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const { login } = useAuth();
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    try {
      setError('');
      setLoading(true);
      
      // Use Firebase Authentication instead of mock login
      await login(email, password);
      navigate('/dashboard');
    } catch (error) {
      console.error('Login error:', error);
      
      // More specific error messages based on Firebase error codes
      let errorMessage = 'Failed to log in. Please check your credentials.';
      
      if (error.code === 'auth/user-not-found') {
        errorMessage = 'No user found with this email address.';
      } else if (error.code === 'auth/wrong-password') {
        errorMessage = 'Incorrect password.';
      } else if (error.code === 'auth/invalid-email') {
        errorMessage = 'Invalid email address format.';
      } else if (error.code === 'auth/user-disabled') {
        errorMessage = 'This account has been disabled.';
      } else if (error.code === 'auth/too-many-requests') {
        errorMessage = 'Too many failed login attempts. Please try again later.';
      } else if (error.code === 'auth/network-request-failed') {
        errorMessage = 'Network error. Please check your internet connection.';
      }
      
      setError(errorMessage);
    } finally {
      setLoading(false);
    }
  };

  return (
    <LoginContainer component="main" maxWidth={false}>
      <Fade in={true} timeout={800}>
        <StyledPaper elevation={0}>
          <Slide direction="down" in={true} timeout={600}>
            <LogoAvatar>
              <AccountCircle sx={{ fontSize: 40 }} />
            </LogoAvatar>
          </Slide>
          
          <Slide direction="up" in={true} timeout={800}>
            <Typography 
              component="h1" 
              variant="h4" 
              sx={{ 
                background: 'linear-gradient(135deg, #00695c 0%, #00897b 100%)',
                backgroundClip: 'text',
                WebkitBackgroundClip: 'text',
                WebkitTextFillColor: 'transparent',
                fontWeight: 700, 
                mb: 1,
                textAlign: 'center'
              }}
            >
              Mosque Admin Panel
            </Typography>
          </Slide>
          
          <Typography 
            variant="body1" 
            sx={{ 
              color: 'rgba(0, 0, 0, 0.6)', 
              mb: 4, 
              textAlign: 'center',
              fontWeight: 500
            }}
          >
            Manage your mosque community with ease
          </Typography>
          
          {error && (
            <Fade in={!!error}>
              <Alert 
                severity="error" 
                sx={{ 
                  width: '100%', 
                  mb: 3,
                  borderRadius: '12px',
                  backgroundColor: 'rgba(244, 67, 54, 0.1)',
                  border: '1px solid rgba(244, 67, 54, 0.2)'
                }}
              >
                {error}
              </Alert>
            </Fade>
          )}
          
          <Box component="form" onSubmit={handleSubmit} sx={{ width: '100%' }}>
            <StyledTextField
              margin="normal"
              required
              fullWidth
              id="email"
              label="Email Address"
              name="email"
              autoComplete="email"
              autoFocus
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              InputProps={{
                startAdornment: (
                  <Box sx={{ mr: 1, color: '#00695c' }}>
                    <AccountCircle />
                  </Box>
                ),
              }}
            />
            <StyledTextField
              margin="normal"
              required
              fullWidth
              name="password"
              label="Password"
              type="password"
              id="password"
              autoComplete="current-password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              InputProps={{
                startAdornment: (
                  <Box sx={{ mr: 1, color: '#00695c' }}>
                    <Lock />
                  </Box>
                ),
              }}
            />
            <LoginButton
              type="submit"
              fullWidth
              variant="contained"
              disabled={loading}
            >
              {loading ? 'Signing In...' : 'Sign In to Dashboard'}
            </LoginButton>
          </Box>
          
          
        </StyledPaper>
      </Fade>
    </LoginContainer>
  );
};

export default Login;