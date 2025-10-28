import React, { useState } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import {
  AppBar,
  Box,
  CssBaseline,
  Drawer,
  IconButton,
  List,
  ListItem,
  ListItemButton,
  ListItemIcon,
  ListItemText,
  Toolbar,
  Typography,
  Button,
  Avatar,
  Divider,
  Chip,
  Fade,
  Slide
} from '@mui/material';
import {
  Menu as MenuIcon,
  Dashboard,
  Business,
  Mosque,
  Event,
  People,
  Category,
  Assessment,
  Logout,
  AccountCircle,
  Notifications,
  Settings,
  CloudUpload,
  VerifiedUser
} from '@mui/icons-material';
import { styled } from '@mui/material/styles';

const drawerWidth = 280;

const StyledAppBar = styled(AppBar)(({ theme }) => ({
  background: 'linear-gradient(135deg, #00695c 0%, #00897b 100%)',
  zIndex: theme.zIndex.drawer + 1,
  boxShadow: '0 4px 20px rgba(0, 105, 92, 0.3)',
  backdropFilter: 'blur(20px)',
}));

const StyledDrawer = styled(Drawer)(({ theme }) => ({
  width: drawerWidth,
  flexShrink: 0,
  '& .MuiDrawer-paper': {
    width: drawerWidth,
    boxSizing: 'border-box',
    background: 'linear-gradient(180deg, #ffffff 0%, #f8f9fa 100%)',
    borderRight: 'none',
    boxShadow: '4px 0 20px rgba(0, 0, 0, 0.08)',
    overflow: 'hidden'
  },
}));

const LogoContainer = styled(Box)(({ theme }) => ({
  padding: theme.spacing(3),
  background: 'linear-gradient(135deg, #00695c 0%, #00897b 100%)',
  color: 'white',
  textAlign: 'center',
  position: 'relative',
  '&::after': {
    content: '""',
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    height: '4px',
    background: 'linear-gradient(90deg, #26a69a 0%, #4db6ac 100%)'
  }
}));

const StyledListItemButton = styled(ListItemButton)(({ theme }) => ({
  margin: theme.spacing(0.5, 2),
  borderRadius: '12px',
  transition: 'all 0.3s cubic-bezier(0.4, 0, 0.2, 1)',
  position: 'relative',
  overflow: 'hidden',
  '&::before': {
    content: '""',
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    background: 'linear-gradient(135deg, #00695c 0%, #00897b 100%)',
    opacity: 0,
    transition: 'opacity 0.3s ease',
    zIndex: 0
  },
  '&.Mui-selected': {
    backgroundColor: 'transparent',
    '&::before': {
      opacity: 1
    },
    '& .MuiListItemIcon-root': {
      color: 'white',
      transform: 'scale(1.1)',
      zIndex: 1
    },
    '& .MuiListItemText-primary': {
      color: 'white',
      fontWeight: 700,
      zIndex: 1
    },
    '&:hover': {
      backgroundColor: 'transparent',
      '&::before': {
        opacity: 0.9
      }
    }
  },
  '&:hover': {
    backgroundColor: 'rgba(0, 105, 92, 0.08)',
    transform: 'translateX(8px)',
    '& .MuiListItemIcon-root': {
      transform: 'scale(1.1)',
      color: '#00695c'
    }
  },
  '& .MuiListItemIcon-root': {
    minWidth: 48,
    transition: 'all 0.3s ease',
    position: 'relative',
    zIndex: 1
  },
  '& .MuiListItemText-primary': {
    fontWeight: 600,
    fontSize: '0.95rem',
    position: 'relative',
    zIndex: 1
  }
}));

const ProfileSection = styled(Box)(({ theme }) => ({
  padding: theme.spacing(3),
  background: 'linear-gradient(135deg, rgba(0, 105, 92, 0.05) 0%, rgba(0, 137, 123, 0.1) 100%)',
  margin: theme.spacing(2),
  borderRadius: '16px',
  border: '1px solid rgba(0, 105, 92, 0.1)',
  textAlign: 'center'
}));

const menuItems = [
  { text: 'Dashboard', icon: <Dashboard />, path: '/dashboard', badge: null },
  { text: 'Mosques', icon: <Business />, path: '/organizations', badge: null },
  // { text: 'Mosques', icon: <Mosque />, path: '/mosques', badge: '45' },
  { text: 'Events', icon: <Event />, path: '/events', badge: null },
  { text: 'Users', icon: <People />, path: '/users', badge: null },
  { text: 'Verify Organization', icon: <VerifiedUser />, path: '/verify-organization', badge: null },
  { text: 'Categories', icon: <Category />, path: '/categories', badge: null },
  { text: 'Reports', icon: <Assessment />, path: '/reports', badge: null },
];

const Layout = ({ children }) => {
  const [mobileOpen, setMobileOpen] = useState(false);
  const navigate = useNavigate();
  const location = useLocation();
  const { logout } = useAuth();

  const handleDrawerToggle = () => {
    setMobileOpen(!mobileOpen);
  };

  const handleLogout = () => {
    logout();
    navigate('/');
  };

  const drawer = (
    <Box sx={{ height: '100%', display: 'flex', flexDirection: 'column' }}>
      <Box sx={{ flexGrow: 1, px: 1, pt: '70px' }}>
        <List sx={{ pt: 2 }}>
          {menuItems.map((item, index) => (
            <Slide 
              key={item.text} 
              direction="right" 
              in={true} 
              timeout={600} 
              style={{ transitionDelay: `${index * 100}ms` }}
            >
              <ListItem disablePadding>
                <StyledListItemButton
                  onClick={() => navigate(item.path)}
                  selected={location.pathname === item.path}
                >
                  <ListItemIcon>
                    {item.icon}
                  </ListItemIcon>
                  <ListItemText primary={item.text} />
                  {item.badge && (
                    <Chip
                      label={item.badge}
                      size="small"
                      sx={{
                        height: 20,
                        fontSize: '0.7rem',
                        backgroundColor: location.pathname === item.path ? 'rgba(255, 255, 255, 0.2)' : '#00695c',
                        color: 'white',
                        fontWeight: 600
                      }}
                    />
                  )}
                </StyledListItemButton>
              </ListItem>
            </Slide>
          ))}
        </List>
      </Box>

      <Divider sx={{ mx: 2, backgroundColor: 'rgba(0, 105, 92, 0.1)' }} />
      
      <Box sx={{ p: 2 }}>
        <StyledListItemButton onClick={() => navigate('/settings')}>
          <ListItemIcon>
            <Settings />
          </ListItemIcon>
          <ListItemText primary="Settings" />
        </StyledListItemButton>
      </Box>
    </Box>
  );

  return (
    <Box sx={{ display: 'flex' }}>
      <CssBaseline />
      <StyledAppBar position="fixed">
        <Toolbar sx={{ minHeight: '70px !important' }}>
          <IconButton
            color="inherit"
            aria-label="open drawer"
            edge="start"
            onClick={handleDrawerToggle}
            sx={{ 
              mr: 2, 
              display: { sm: 'none' },
              '&:hover': {
                backgroundColor: 'rgba(255, 255, 255, 0.1)'
              }
            }}
          >
            <MenuIcon />
          </IconButton>
          
          <Typography variant="h5" noWrap component="div" sx={{ flexGrow: 1, fontWeight: 700, color: '#fff' }}>
            Mosque Management System
          </Typography>
          
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
            <IconButton 
              color="inherit"
              sx={{
                color: '#fff',
                '&:hover': {
                  backgroundColor: 'rgba(255, 255, 255, 0.1)'
                }
              }}
            >
              <Notifications />
            </IconButton>
            
            <Button
              color="inherit"
              onClick={handleLogout}
              startIcon={<Logout />}
              sx={{
                color: '#fff',
                borderRadius: '12px',
                textTransform: 'none',
                fontWeight: 600,
                px: 3,
                py: 1,
                backgroundColor: 'rgba(255, 255, 255, 0.1)',
                backdropFilter: 'blur(10px)',
                border: '1px solid rgba(255, 255, 255, 0.2)',
                transition: 'all 0.3s ease',
                '&:hover': {
                  backgroundColor: 'rgba(255, 255, 255, 0.2)',
                  transform: 'translateY(-2px)',
                  boxShadow: '0 8px 20px rgba(0, 0, 0, 0.2)'
                }
              }}
            >
              Logout
            </Button>
          </Box>
        </Toolbar>
      </StyledAppBar>
      
      <Box
        component="nav"
        sx={{ width: { sm: drawerWidth }, flexShrink: { sm: 0 } }}
      >
        <StyledDrawer
          variant="temporary"
          open={mobileOpen}
          onClose={handleDrawerToggle}
          ModalProps={{
            keepMounted: true,
          }}
          sx={{
            display: { xs: 'block', sm: 'none' },
          }}
        >
          {drawer}
        </StyledDrawer>
        <StyledDrawer
          variant="permanent"
          sx={{
            display: { xs: 'none', sm: 'block' },
          }}
          open
        >
          {drawer}
        </StyledDrawer>
      </Box>
      
      <Box
        component="main"
        sx={{
          flexGrow: 1,
          width: { sm: `calc(100% - ${drawerWidth}px)` },
          minHeight: '100vh',
          background: 'linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%)',
          position: 'relative'
        }}
      >
        <Toolbar sx={{ minHeight: '70px !important' }} />
        <Fade in={true} timeout={800}>
          <Box sx={{ p: 3 }}>
            {children}
          </Box>
        </Fade>
      </Box>
    </Box>
  );
};

export default Layout;