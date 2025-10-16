import React, { useState, useEffect, useMemo } from 'react';
import {
  Box,
  Paper,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Button,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  Typography,
  IconButton,
  Snackbar,
  Alert,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  Chip,
  Grid,
  Avatar,
  Fade,
  Grow,
  Tooltip,
  Card,
  CardContent
} from '@mui/material';
import { Add, Edit, Delete, Person, Phone, Email, People, Cake, LocationOn } from '@mui/icons-material';
import { styled } from '@mui/material/styles';
import { userService } from '../services/firebaseService';
import SearchFilterSort from '../components/SearchFilterSort';

const StyledTableContainer = styled(TableContainer)(({ theme }) => ({
  borderRadius: '16px',
  boxShadow: '0 8px 32px rgba(0, 105, 92, 0.12)',
  background: 'linear-gradient(135deg, #ffffff 0%, #f8f9fa 100%)',
  border: '1px solid rgba(0, 105, 92, 0.08)',
  overflow: 'hidden'
}));

const StyledTableHead = styled(TableHead)(({ theme }) => ({
  background: 'linear-gradient(135deg, #00695c 0%, #00897b 100%)',
  '& .MuiTableCell-head': {
    color: 'white',
    fontWeight: 700,
    fontSize: '0.95rem',
    textTransform: 'uppercase',
    letterSpacing: '0.5px',
    padding: theme.spacing(2),
    borderBottom: 'none'
  }
}));

const StyledTableRow = styled(TableRow)(({ theme }) => ({
  transition: 'all 0.3s cubic-bezier(0.4, 0, 0.2, 1)',
  cursor: 'pointer',
  '&:nth-of-type(odd)': {
    backgroundColor: 'rgba(0, 105, 92, 0.02)'
  },
  '&:hover': {
    backgroundColor: 'rgba(0, 105, 92, 0.08)',
    transform: 'translateY(-2px)',
    boxShadow: '0 4px 20px rgba(0, 105, 92, 0.15)',
    '& .MuiTableCell-root': {
      borderColor: 'rgba(0, 105, 92, 0.2)'
    }
  },
  '& .MuiTableCell-root': {
    borderBottom: '1px solid rgba(0, 105, 92, 0.08)',
    padding: theme.spacing(2),
    fontSize: '0.9rem'
  }
}));

const ActionButton = styled(IconButton)(({ theme }) => ({
  borderRadius: '8px',
  padding: '8px',
  margin: '0 2px',
  transition: 'all 0.3s ease',
  '&.edit-btn': {
    color: '#00695c',
    backgroundColor: 'rgba(0, 105, 92, 0.08)',
    '&:hover': {
      backgroundColor: '#00695c',
      color: 'white',
      transform: 'scale(1.1)'
    }
  },
  '&.delete-btn': {
    color: '#d32f2f',
    backgroundColor: 'rgba(211, 47, 47, 0.08)',
    '&:hover': {
      backgroundColor: '#d32f2f',
      color: 'white',
      transform: 'scale(1.1)'
    }
  }
}));

const HeaderCard = styled(Card)(({ theme }) => ({
  background: 'linear-gradient(135deg, #00695c 0%, #00897b 100%)',
  color: 'white',
  borderRadius: '16px',
  boxShadow: '0 8px 32px rgba(0, 105, 92, 0.3)',
  marginBottom: theme.spacing(3)
}));

const GenderChip = styled(Chip)(({ theme }) => ({
  borderRadius: '12px',
  fontWeight: 600,
  fontSize: '0.75rem',
  height: '28px',
  '&.male': {
    backgroundColor: '#e3f2fd',
    color: '#1976d2',
    border: '1px solid #bbdefb'
  },
  '&.female': {
    backgroundColor: '#fce4ec',
    color: '#c2185b',
    border: '1px solid #f8bbd9'
  }
}));

const Users = () => {
  const [users, setUsers] = useState([]);
  const [open, setOpen] = useState(false);
  const [editingUser, setEditingUser] = useState(null);
  const [snackbar, setSnackbar] = useState({ open: false, message: '', severity: 'success' });
  const [formData, setFormData] = useState({
    name: '',
    gender: '',
    dateOfBirth: '',
    email: '',
    password: '',
    phone: '',
    address: ''
  });

  // Search, filter, and sort state
  const [searchValue, setSearchValue] = useState('');
  const [sortBy, setSortBy] = useState('');
  const [sortOrder, setSortOrder] = useState('asc');
  const [filters, setFilters] = useState({
    gender: '',
    address: ''
  });

  useEffect(() => {
    fetchUsers();
  }, []);

  const fetchUsers = async () => {
    try {
      const data = await userService.getAll();
      setUsers(data);
    } catch (error) {
      console.error('Error fetching users:', error);
    }
  };

  const handleOpen = (user = null) => {
    if (user) {
      setEditingUser(user);
      setFormData({
        name: user.name || '',
        gender: user.gender || '',
        dateOfBirth: user.dateOfBirth || '',
        email: user.email || '',
        password: user.password || '',
        phone: user.phone || '',
        address: user.address || ''
      });
    } else {
      setEditingUser(null);
      setFormData({
        name: '',
        gender: '',
        dateOfBirth: '',
        email: '',
        password: '',
        phone: '',
        address: ''
      });
    }
    setOpen(true);
  };

  const handleClose = () => {
    setOpen(false);
    setEditingUser(null);
  };

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };

  const handleSubmit = async () => {
    try {
      if (editingUser) {
        await userService.update(editingUser.id, formData);
        setSnackbar({ open: true, message: 'User updated successfully!', severity: 'success' });
      } else {
        await userService.create(formData);
        setSnackbar({ open: true, message: 'User created successfully!', severity: 'success' });
      }
      fetchUsers();
      handleClose();
    } catch (error) {
      console.error('Error saving user:', error);
      setSnackbar({ open: true, message: 'Error saving user!', severity: 'error' });
    }
  };

  const handleDelete = async (id) => {
    if (window.confirm('Are you sure you want to delete this user?')) {
      try {
        await userService.delete(id);
        setSnackbar({ open: true, message: 'User deleted successfully!', severity: 'success' });
        fetchUsers();
      } catch (error) {
        console.error('Error deleting user:', error);
        setSnackbar({ open: true, message: 'Error deleting user!', severity: 'error' });
      }
    }
  };

  // const formatDate = (dateString) => {
  //   if (!dateString) return '';
  //   return new Date(dateString).toLocaleDateString();
  // };

  const calculateAge = (dateOfBirth) => {
    if (!dateOfBirth) return '';
    const today = new Date();
    const birthDate = new Date(dateOfBirth);
    let age = today.getFullYear() - birthDate.getFullYear();
    const monthDiff = today.getMonth() - birthDate.getMonth();
    if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
      age--;
    }
    return age;
  };

  // Filter and sort users
  const filteredAndSortedUsers = useMemo(() => {
    let filtered = users.filter(user => {
      // Search filter
      const searchMatch = !searchValue || 
        user.name?.toLowerCase().includes(searchValue.toLowerCase()) ||
        user.email?.toLowerCase().includes(searchValue.toLowerCase()) ||
        user.phone?.toLowerCase().includes(searchValue.toLowerCase()) ||
        user.address?.toLowerCase().includes(searchValue.toLowerCase());

      // Additional filters
      const genderMatch = !filters.gender || user.gender === filters.gender;
      const addressMatch = !filters.address || 
        user.address?.toLowerCase().includes(filters.address.toLowerCase());

      return searchMatch && genderMatch && addressMatch;
    });

    // Sort
    if (sortBy) {
      filtered.sort((a, b) => {
        let aValue = a[sortBy] || '';
        let bValue = b[sortBy] || '';
        
        // Handle special cases for age calculation
        if (sortBy === 'age') {
          aValue = calculateAge(a.dateOfBirth);
          bValue = calculateAge(b.dateOfBirth);
        }
        
        if (typeof aValue === 'string') {
          aValue = aValue.toLowerCase();
          bValue = bValue.toLowerCase();
        }

        if (sortOrder === 'asc') {
          return aValue < bValue ? -1 : aValue > bValue ? 1 : 0;
        } else {
          return aValue > bValue ? -1 : aValue < bValue ? 1 : 0;
        }
      });
    }

    return filtered;
  }, [users, searchValue, sortBy, sortOrder, filters]);

  // Get unique values for filter options
  const filterOptions = useMemo(() => {
    const uniqueGenders = [...new Set(users.map(user => user.gender).filter(Boolean))];
    const uniqueAddresses = [...new Set(users.map(user => user.address).filter(Boolean))];

    return {
      gender: {
        label: 'Gender',
        values: uniqueGenders.map(gender => ({ value: gender, label: gender }))
      },
      address: {
        label: 'Address',
        values: uniqueAddresses.map(address => ({ value: address, label: address }))
      }
    };
  }, [users]);

  const sortOptions = [
    { value: 'name', label: 'Name' },
    { value: 'email', label: 'Email' },
    { value: 'phone', label: 'Phone' },
    { value: 'gender', label: 'Gender' },
    { value: 'age', label: 'Age' },
    { value: 'address', label: 'Address' }
  ];

  return (
    <Fade in={true} timeout={800}>
      <Box sx={{ p: 3 }}>
        <HeaderCard>
          <CardContent sx={{ p: 3 }}>
            <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                <Avatar sx={{ backgroundColor: 'rgba(255, 255, 255, 0.2)', width: 56, height: 56 }}>
                  <People sx={{ fontSize: 28 }} />
                </Avatar>
                <Box>
                  <Typography variant="h4" component="h1" sx={{ fontWeight: 700, mb: 1 }}>
                    User Jamaah Management
                  </Typography>
                  <Typography variant="body1" sx={{ opacity: 0.9 }}>
                    Manage mosque community members and their information
                  </Typography>
                </Box>
              </Box>
              <Button
                variant="contained"
                startIcon={<Add />}
                onClick={() => handleOpen()}
                sx={{ 
                  backgroundColor: 'rgba(255, 255, 255, 0.15)',
                  backdropFilter: 'blur(10px)',
                  border: '1px solid rgba(255, 255, 255, 0.2)',
                  borderRadius: '12px',
                  px: 3,
                  py: 1.5,
                  fontWeight: 600,
                  textTransform: 'none',
                  fontSize: '1rem',
                  '&:hover': {
                    backgroundColor: 'rgba(255, 255, 255, 0.25)',
                    transform: 'translateY(-2px)',
                    boxShadow: '0 8px 25px rgba(0, 0, 0, 0.2)'
                  }
                }}
              >
                Add New User
              </Button>
            </Box>
          </CardContent>
        </HeaderCard>

        <SearchFilterSort
          searchValue={searchValue}
          onSearchChange={setSearchValue}
          sortBy={sortBy}
          sortOrder={sortOrder}
          onSortChange={setSortBy}
          onSortOrderChange={setSortOrder}
          filters={filters}
          onFiltersChange={setFilters}
          filterOptions={filterOptions}
          sortOptions={sortOptions}
          placeholder="Search users by name, email, phone, or address..."
        />

        <StyledTableContainer component={Paper}>
          <Table>
            <StyledTableHead>
              <TableRow>
                <TableCell>User Profile</TableCell>
                <TableCell>Personal Info</TableCell>
                <TableCell>Contact Details</TableCell>
                <TableCell>Address</TableCell>
                <TableCell align="center">Actions</TableCell>
              </TableRow>
            </StyledTableHead>
            <TableBody>
              {filteredAndSortedUsers.map((user, index) => (
                <Grow
                  key={user.id}
                  in={true}
                  timeout={600}
                  style={{ transitionDelay: `${index * 100}ms` }}
                >
                  <StyledTableRow>
                    <TableCell>
                      <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                        <Avatar 
                          sx={{ 
                            backgroundColor: user.gender === 'Male' ? '#1976d2' : '#c2185b',
                            width: 45,
                            height: 45,
                            fontSize: '1.2rem',
                            fontWeight: 600
                          }}
                        >
                          {user.name ? user.name.charAt(0).toUpperCase() : 'U'}
                        </Avatar>
                        <Box>
                          <Typography variant="subtitle1" sx={{ fontWeight: 600, color: '#00695c' }}>
                            {user.name}
                          </Typography>
                          <GenderChip 
                            label={user.gender} 
                            size="small"
                            className={user.gender?.toLowerCase()}
                          />
                        </Box>
                      </Box>
                    </TableCell>
                    <TableCell>
                      <Box>
                        <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 1 }}>
                          <Cake sx={{ fontSize: 16, color: '#00695c' }} />
                          <Typography variant="body2" sx={{ fontWeight: 600 }}>
                            {calculateAge(user.dateOfBirth)} years old
                          </Typography>
                        </Box>
                        <Typography variant="body2" sx={{ color: 'text.secondary' }}>
                          Born: {user.dateOfBirth ? new Date(user.dateOfBirth).toLocaleDateString() : 'N/A'}
                        </Typography>
                      </Box>
                    </TableCell>
                    <TableCell>
                      <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1 }}>
                        <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                          <Email sx={{ fontSize: 16, color: '#00695c' }} />
                          <Typography variant="body2" sx={{ fontWeight: 500 }}>
                            {user.email}
                          </Typography>
                        </Box>
                        <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                          <Phone sx={{ fontSize: 16, color: '#00695c' }} />
                          <Typography variant="body2" sx={{ color: 'text.secondary' }}>
                            {user.phone}
                          </Typography>
                        </Box>
                      </Box>
                    </TableCell>
                    <TableCell>
                      <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                        <LocationOn sx={{ fontSize: 16, color: '#00695c' }} />
                        <Typography 
                          variant="body2" 
                          sx={{ 
                            maxWidth: 200, 
                            overflow: 'hidden', 
                            textOverflow: 'ellipsis',
                            whiteSpace: 'nowrap'
                          }}
                        >
                          {user.address || 'No address provided'}
                        </Typography>
                      </Box>
                    </TableCell>
                    <TableCell align="center">
                      <Box sx={{ display: 'flex', justifyContent: 'center', gap: 1 }}>
                        <Tooltip title="Edit User" arrow>
                          <ActionButton
                            className="edit-btn"
                            onClick={() => handleOpen(user)}
                            size="small"
                          >
                            <Edit sx={{ fontSize: 18 }} />
                          </ActionButton>
                        </Tooltip>
                        <Tooltip title="Delete User" arrow>
                          <ActionButton
                            className="delete-btn"
                            onClick={() => handleDelete(user.id)}
                            size="small"
                          >
                            <Delete sx={{ fontSize: 18 }} />
                          </ActionButton>
                        </Tooltip>
                      </Box>
                    </TableCell>
                  </StyledTableRow>
                </Grow>
              ))}
            </TableBody>
          </Table>
        </StyledTableContainer>

      {/* Enhanced Add/Edit User Dialog */}
      <StyledDialog 
        open={open} 
        onClose={handleClose} 
        maxWidth="md" 
        fullWidth
        TransitionComponent={Fade}
        transitionDuration={400}
      >
        <StyledDialogTitle>
          <Person />
          {editingUser ? 'Edit User' : 'Add New User'}
        </StyledDialogTitle>
        <StyledDialogContent>
          <Fade in={open} timeout={600} style={{ transitionDelay: '200ms' }}>
            <Box>
              <FormSection>
                <SectionTitle>
                  <Person sx={{ fontSize: 20 }} />
                  Personal Information
                </SectionTitle>
                <Grid container spacing={3}>
                  <Grid item xs={12} md={6}>
                    <StyledTextField
                      fullWidth
                      label="Full Name"
                      name="name"
                      value={formData.name}
                      onChange={handleInputChange}
                      placeholder="Enter full name"
                      required
                    />
                  </Grid>
                  <Grid item xs={12} md={6}>
                    <StyledFormControl fullWidth required>
                      <InputLabel>Gender</InputLabel>
                      <Select
                        name="gender"
                        value={formData.gender}
                        onChange={handleInputChange}
                        label="Gender"
                      >
                        <MenuItem value="Male">Male</MenuItem>
                        <MenuItem value="Female">Female</MenuItem>
                      </Select>
                    </StyledFormControl>
                  </Grid>
                  <Grid item xs={12} md={6}>
                    <StyledTextField
                      fullWidth
                      label="Date of Birth"
                      name="dateOfBirth"
                      type="date"
                      value={formData.dateOfBirth}
                      onChange={handleInputChange}
                      InputLabelProps={{ shrink: true }}
                      required
                    />
                  </Grid>
                </Grid>
              </FormSection>

              <FormSection>
                <SectionTitle>
                  <Email sx={{ fontSize: 20 }} />
                  Contact Information
                </SectionTitle>
                <Grid container spacing={3}>
                  <Grid item xs={12} md={6}>
                    <StyledTextField
                      fullWidth
                      label="Email Address"
                      name="email"
                      type="email"
                      value={formData.email}
                      onChange={handleInputChange}
                      placeholder="Enter email address"
                      required
                    />
                  </Grid>
                  <Grid item xs={12} md={6}>
                    <StyledTextField
                      fullWidth
                      label="Phone Number"
                      name="phone"
                      value={formData.phone}
                      onChange={handleInputChange}
                      placeholder="Enter phone number"
                      required
                    />
                  </Grid>
                  <Grid item xs={12}>
                    <StyledTextField
                      fullWidth
                      label="Address"
                      name="address"
                      value={formData.address}
                      onChange={handleInputChange}
                      multiline
                      rows={3}
                      placeholder="Enter full address"
                      required
                    />
                  </Grid>
                </Grid>
              </FormSection>

              <FormSection>
                <SectionTitle>
                  <Person sx={{ fontSize: 20 }} />
                  Account Security
                </SectionTitle>
                <Grid container spacing={3}>
                  <Grid item xs={12}>
                    <StyledTextField
                      fullWidth
                      label="Password"
                      name="password"
                      type="password"
                      value={formData.password}
                      onChange={handleInputChange}
                      placeholder="Enter secure password"
                      required
                    />
                  </Grid>
                </Grid>
              </FormSection>
            </Box>
          </Fade>
        </StyledDialogContent>
        <StyledDialogActions>
          <DialogActionButton 
            className="secondary"
            onClick={handleClose}
          >
            Cancel
          </DialogActionButton>
          <DialogActionButton 
            className="primary"
            onClick={handleSubmit}
            startIcon={editingUser ? <Edit /> : <Add />}
          >
            {editingUser ? 'Update User' : 'Create User'}
          </DialogActionButton>
        </StyledDialogActions>
      </StyledDialog>

      <Snackbar
        open={snackbar.open}
        autoHideDuration={6000}
        onClose={() => setSnackbar({ ...snackbar, open: false })}
      >
        <Alert severity={snackbar.severity} onClose={() => setSnackbar({ ...snackbar, open: false })}>
          {snackbar.message}
        </Alert>
      </Snackbar>
    </Box>
    </Fade>
  );
};

export default Users;

// Add new styled components for dialog enhancement
const StyledDialog = styled(Dialog)(({ theme }) => ({
  '& .MuiDialog-paper': {
    borderRadius: 16,
    boxShadow: '0 24px 48px rgba(0, 0, 0, 0.15)',
    overflow: 'visible',
  },
}));

const StyledDialogTitle = styled(DialogTitle)(({ theme }) => ({
  background: 'linear-gradient(135deg, #00695c 0%, #00897b 100%)',
  color: 'white',
  padding: '24px 32px',
  position: 'relative',
  '&::after': {
    content: '""',
    position: 'absolute',
    bottom: -10,
    left: '50%',
    transform: 'translateX(-50%)',
    width: 0,
    height: 0,
    borderLeft: '10px solid transparent',
    borderRight: '10px solid transparent',
    borderTop: '10px solid #00695c',
  },
  '& .MuiTypography-root': {
    fontSize: '1.5rem',
    fontWeight: 600,
    display: 'flex',
    alignItems: 'center',
    gap: 2,
  },
}));

const StyledDialogContent = styled(DialogContent)(({ theme }) => ({
  padding: '32px',
  backgroundColor: '#fafafa',
}));

const StyledTextField = styled(TextField)(({ theme }) => ({
  '& .MuiOutlinedInput-root': {
    borderRadius: 12,
    backgroundColor: 'white',
    transition: 'all 0.3s ease',
    '&:hover': {
      boxShadow: '0 4px 12px rgba(0, 105, 92, 0.1)',
    },
    '&.Mui-focused': {
      boxShadow: '0 4px 20px rgba(0, 105, 92, 0.2)',
      '& fieldset': {
        borderColor: '#00695c',
        borderWidth: 2,
      },
    },
  },
  '& .MuiInputLabel-root': {
    fontWeight: 500,
    '&.Mui-focused': {
      color: '#00695c',
    },
  },
}));

const StyledFormControl = styled(FormControl)(({ theme }) => ({
  '& .MuiOutlinedInput-root': {
    borderRadius: 12,
    backgroundColor: 'white',
    transition: 'all 0.3s ease',
    '&:hover': {
      boxShadow: '0 4px 12px rgba(0, 105, 92, 0.1)',
    },
    '&.Mui-focused': {
      boxShadow: '0 4px 20px rgba(0, 105, 92, 0.2)',
      '& fieldset': {
        borderColor: '#00695c',
        borderWidth: 2,
      },
    },
  },
  '& .MuiInputLabel-root': {
    fontWeight: 500,
    '&.Mui-focused': {
      color: '#00695c',
    },
  },
}));

const FormSection = styled(Box)(({ theme }) => ({
  backgroundColor: 'white',
  borderRadius: 16,
  padding: '24px',
  marginBottom: '24px',
  boxShadow: '0 2px 8px rgba(0, 0, 0, 0.05)',
  border: '1px solid #e0e0e0',
}));

const SectionTitle = styled(Typography)(({ theme }) => ({
  fontSize: '1.1rem',
  fontWeight: 600,
  color: '#00695c',
  marginBottom: '16px',
  display: 'flex',
  alignItems: 'center',
  gap: 1,
}));

const StyledDialogActions = styled(DialogActions)(({ theme }) => ({
  padding: '24px 32px',
  backgroundColor: '#f5f5f5',
  borderTop: '1px solid #e0e0e0',
  gap: 2,
}));

const DialogActionButton = styled(Button)(({ theme }) => ({
  borderRadius: 12,
  padding: '12px 24px',
  fontWeight: 600,
  textTransform: 'none',
  fontSize: '1rem',
  transition: 'all 0.3s ease',
  '&.primary': {
    background: 'linear-gradient(135deg, #00695c 0%, #00897b 100%)',
    color: 'white',
    '&:hover': {
      background: 'linear-gradient(135deg, #004d40 0%, #00695c 100%)',
      transform: 'translateY(-2px)',
      boxShadow: '0 8px 20px rgba(0, 105, 92, 0.3)',
    },
  },
  '&.secondary': {
    backgroundColor: 'white',
    color: '#666',
    border: '2px solid #e0e0e0',
    '&:hover': {
      backgroundColor: '#f5f5f5',
      borderColor: '#00695c',
      color: '#00695c',
    },
  },
}));