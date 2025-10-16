import React, { useState, useEffect, useMemo } from 'react';
import {
  Box,
  Typography,
  Button,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Paper,
  IconButton,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  Grid,
  Alert,
  Snackbar,
  Card,
  CardContent,
  Fade,
  Grow,
  Tooltip,
  Avatar
} from '@mui/material';
import {
  Add as AddIcon,
  Edit as EditIcon,
  Delete as DeleteIcon,
  Business as BusinessIcon,
  Person as PersonIcon,
  Email as EmailIcon,
  Phone as PhoneIcon,
  LocationCity as OfficeIcon
} from '@mui/icons-material';
import { styled } from '@mui/material/styles';
import { organizationService } from '../services/firebaseService';
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

const InfoBox = styled(Box)(({ theme }) => ({
  display: 'flex',
  alignItems: 'center',
  gap: theme.spacing(1),
  padding: theme.spacing(0.5),
  borderRadius: '8px',
  transition: 'all 0.3s ease',
  '&:hover': {
    backgroundColor: 'rgba(0, 105, 92, 0.05)'
  }
}));

const StyledDialog = styled(Dialog)(({ theme }) => ({
  '& .MuiDialog-paper': {
    borderRadius: '16px',
    boxShadow: '0 20px 40px rgba(0, 0, 0, 0.1)',
    overflow: 'hidden',
  },
}));

const StyledDialogTitle = styled(DialogTitle)(({ theme }) => ({
  background: 'linear-gradient(135deg, #20B2AA 0%, #1a9999 100%)',
  color: 'white',
  padding: '24px',
  fontSize: '1.5rem',
  fontWeight: 600,
  textAlign: 'center',
  position: 'relative',
  '&::after': {
    content: '""',
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    height: '4px',
    background: 'linear-gradient(90deg, rgba(255,255,255,0.3) 0%, rgba(255,255,255,0.1) 100%)',
  },
}));

const StyledDialogContent = styled(DialogContent)(({ theme }) => ({
  padding: '32px 24px',
  backgroundColor: '#fafafa',
}));

const StyledTextField = styled(TextField)(({ theme }) => ({
  '& .MuiOutlinedInput-root': {
    borderRadius: '12px',
    backgroundColor: 'white',
    transition: 'all 0.3s ease',
    '&:hover': {
      boxShadow: '0 4px 12px rgba(32, 178, 170, 0.15)',
    },
    '&.Mui-focused': {
      boxShadow: '0 4px 20px rgba(32, 178, 170, 0.25)',
      '& fieldset': {
        borderColor: '#20B2AA',
        borderWidth: '2px',
      },
    },
  },
  '& .MuiInputLabel-root.Mui-focused': {
    color: '#20B2AA',
    fontWeight: 600,
  },
}));

const FormSection = styled(Box)(({ theme }) => ({
  marginBottom: '24px',
  padding: '20px',
  backgroundColor: 'white',
  borderRadius: '12px',
  boxShadow: '0 2px 8px rgba(0, 0, 0, 0.05)',
  border: '1px solid #e0e0e0',
}));

const SectionTitle = styled(Typography)(({ theme }) => ({
  fontSize: '1.1rem',
  fontWeight: 600,
  color: '#20B2AA',
  marginBottom: '16px',
  display: 'flex',
  alignItems: 'center',
  '&::before': {
    content: '""',
    width: '4px',
    height: '20px',
    backgroundColor: '#20B2AA',
    marginRight: '12px',
    borderRadius: '2px',
  },
}));

const StyledDialogActions = styled(DialogActions)(({ theme }) => ({
  padding: '24px',
  backgroundColor: '#f5f5f5',
  borderTop: '1px solid #e0e0e0',
  gap: '12px',
}));

const DialogActionButton = styled(Button)(({ theme }) => ({
  borderRadius: '8px',
  padding: '10px 24px',
  fontWeight: 600,
  textTransform: 'none',
  minWidth: '100px',
  transition: 'all 0.3s ease',
  '&.MuiButton-contained': {
    background: 'linear-gradient(135deg, #20B2AA 0%, #1a9999 100%)',
    boxShadow: '0 4px 12px rgba(32, 178, 170, 0.3)',
    '&:hover': {
      background: 'linear-gradient(135deg, #1a9999 0%, #158a8a 100%)',
      boxShadow: '0 6px 20px rgba(32, 178, 170, 0.4)',
      transform: 'translateY(-2px)',
    },
  },
  '&.MuiButton-text': {
    color: '#666',
    '&:hover': {
      backgroundColor: 'rgba(0, 0, 0, 0.04)',
    },
  },
}));

const Organizations = () => {
  const [organizations, setOrganizations] = useState([]);
  const [open, setOpen] = useState(false);
  const [editingOrg, setEditingOrg] = useState(null);
  const [loading, setLoading] = useState(false);
  const [snackbar, setSnackbar] = useState({ open: false, message: '', severity: 'success' });
  
  // Search, Filter, Sort states
  const [searchValue, setSearchValue] = useState('');
  const [sortBy, setSortBy] = useState('');
  const [sortOrder, setSortOrder] = useState('asc');
  const [filters, setFilters] = useState({
    leader: '',
    office: ''
  });
  
  const [formData, setFormData] = useState({
    organizationName: '',
    leader: '',
    email: '',
    password: '',
    phoneNumber: '',
    office: ''
  });

  useEffect(() => {
    fetchOrganizations();
  }, []);

  const fetchOrganizations = async () => {
    try {
      setLoading(true);
      const data = await organizationService.getAll();
      setOrganizations(data);
    } catch (error) {
      showSnackbar('Error fetching organizations', 'error');
    } finally {
      setLoading(false);
    }
  };

  const handleOpen = (org = null) => {
    if (org) {
      setEditingOrg(org);
      setFormData({
        organizationName: org.organizationName || '',
        leader: org.leader || '',
        email: org.email || '',
        password: org.password || '',
        phoneNumber: org.phoneNumber || '',
        office: org.office || ''
      });
    } else {
      setEditingOrg(null);
      setFormData({
        organizationName: '',
        leader: '',
        email: '',
        password: '',
        phoneNumber: '',
        office: ''
      });
    }
    setOpen(true);
  };

  const handleClose = () => {
    setOpen(false);
    setEditingOrg(null);
    setFormData({
      organizationName: '',
      leader: '',
      email: '',
      password: '',
      phoneNumber: '',
      office: ''
    });
  };

  const handleSubmit = async () => {
    try {
      setLoading(true);
      if (editingOrg) {
        await organizationService.update(editingOrg.id, formData);
        showSnackbar('Organization updated successfully', 'success');
      } else {
        await organizationService.create(formData);
        showSnackbar('Organization created successfully', 'success');
      }
      handleClose();
      fetchOrganizations();
    } catch (error) {
      showSnackbar('Error saving organization', 'error');
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async (id) => {
    if (window.confirm('Are you sure you want to delete this organization?')) {
      try {
        setLoading(true);
        await organizationService.delete(id);
        showSnackbar('Organization deleted successfully', 'success');
        fetchOrganizations();
      } catch (error) {
        showSnackbar('Error deleting organization', 'error');
      } finally {
        setLoading(false);
      }
    }
  };

  const showSnackbar = (message, severity) => {
    setSnackbar({ open: true, message, severity });
  };

  const handleInputChange = (field, value) => {
    setFormData(prev => ({
      ...prev,
      [field]: value
    }));
  };

  // Filter and sort organizations
  const filteredAndSortedOrganizations = useMemo(() => {
    let filtered = organizations.filter(org => {
      // Search filter
      const searchMatch = !searchValue || 
        org.organizationName?.toLowerCase().includes(searchValue.toLowerCase()) ||
        org.leader?.toLowerCase().includes(searchValue.toLowerCase()) ||
        org.email?.toLowerCase().includes(searchValue.toLowerCase()) ||
        org.office?.toLowerCase().includes(searchValue.toLowerCase());

      // Additional filters
      const leaderMatch = !filters.leader || org.leader === filters.leader;
      const officeMatch = !filters.office || org.office === filters.office;

      return searchMatch && leaderMatch && officeMatch;
    });

    // Sort
    if (sortBy) {
      filtered.sort((a, b) => {
        let aValue = a[sortBy] || '';
        let bValue = b[sortBy] || '';
        
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
  }, [organizations, searchValue, sortBy, sortOrder, filters]);

  // Get unique values for filter options
  const filterOptions = useMemo(() => {
    const uniqueLeaders = [...new Set(organizations.map(org => org.leader).filter(Boolean))];
    const uniqueOffices = [...new Set(organizations.map(org => org.office).filter(Boolean))];

    return {
      leader: {
        label: 'Leader',
        values: uniqueLeaders.map(leader => ({ value: leader, label: leader }))
      },
      office: {
        label: 'Office Location',
        values: uniqueOffices.map(office => ({ value: office, label: office }))
      }
    };
  }, [organizations]);

  const sortOptions = [
    { value: 'organizationName', label: 'Organization Name' },
    { value: 'leader', label: 'Leader' },
    { value: 'email', label: 'Email' },
    { value: 'office', label: 'Office Location' }
  ];

  return (
    <Fade in timeout={800}>
      <Box>
        <HeaderCard>
          <CardContent>
            <Box display="flex" justifyContent="space-between" alignItems="center">
              <Typography variant="h4" sx={{ fontWeight: 'bold', display: 'flex', alignItems: 'center' }}>
                <BusinessIcon sx={{ mr: 2, fontSize: 32 }} />
                Organization Management
              </Typography>
              <Button
                variant="contained"
                startIcon={<AddIcon />}
                onClick={() => handleOpen()}
                sx={{
                  backgroundColor: 'rgba(255, 255, 255, 0.2)',
                  color: 'white',
                  borderRadius: '12px',
                  padding: '12px 24px',
                  fontWeight: 600,
                  backdropFilter: 'blur(10px)',
                  border: '1px solid rgba(255, 255, 255, 0.3)',
                  '&:hover': {
                    backgroundColor: 'rgba(255, 255, 255, 0.3)',
                    transform: 'translateY(-2px)',
                    boxShadow: '0 8px 25px rgba(0, 0, 0, 0.2)'
                  }
                }}
              >
                Add New Organization
              </Button>
            </Box>
          </CardContent>
        </HeaderCard>

        <SearchFilterSort
          searchValue={searchValue}
          onSearchChange={setSearchValue}
          sortBy={sortBy}
          onSortChange={setSortBy}
          sortOrder={sortOrder}
          onSortOrderChange={setSortOrder}
          filters={filters}
          onFilterChange={setFilters}
          filterOptions={filterOptions}
          sortOptions={sortOptions}
          placeholder="Search organizations, leaders, emails, or offices..."
        />

        <StyledTableContainer component={Paper}>
          <Table>
            <StyledTableHead>
              <TableRow>
                <TableCell>Organization</TableCell>
                <TableCell>Leader</TableCell>
                <TableCell>Contact</TableCell>
                <TableCell>Office</TableCell>
                <TableCell align="center">Actions</TableCell>
              </TableRow>
            </StyledTableHead>
            <TableBody>
              {filteredAndSortedOrganizations.map((org, index) => (
                <Grow in timeout={600 + index * 100} key={org.id}>
                  <StyledTableRow>
                    <TableCell>
                      <InfoBox>
                        <Avatar sx={{ backgroundColor: '#00695c', width: 40, height: 40 }}>
                          <BusinessIcon />
                        </Avatar>
                        <Box>
                          <Typography variant="body1" sx={{ fontWeight: 600, color: '#00695c' }}>
                            {org.organizationName}
                          </Typography>
                        </Box>
                      </InfoBox>
                    </TableCell>
                    <TableCell>
                      <InfoBox>
                        <PersonIcon sx={{ color: '#00695c', fontSize: 20 }} />
                        <Typography variant="body2" sx={{ fontWeight: 500 }}>
                          {org.leader}
                        </Typography>
                      </InfoBox>
                    </TableCell>
                    <TableCell>
                      <Box>
                        <InfoBox sx={{ mb: 0.5 }}>
                          <EmailIcon sx={{ color: '#00695c', fontSize: 18 }} />
                          <Typography variant="body2" sx={{ fontSize: '0.85rem' }}>
                            {org.email}
                          </Typography>
                        </InfoBox>
                        <InfoBox>
                          <PhoneIcon sx={{ color: '#00695c', fontSize: 18 }} />
                          <Typography variant="body2" sx={{ fontSize: '0.85rem' }}>
                            {org.phoneNumber}
                          </Typography>
                        </InfoBox>
                      </Box>
                    </TableCell>
                    <TableCell>
                      <InfoBox>
                        <OfficeIcon sx={{ color: '#00695c', fontSize: 20 }} />
                        <Typography variant="body2" sx={{ fontWeight: 500 }}>
                          {org.office}
                        </Typography>
                      </InfoBox>
                    </TableCell>
                    <TableCell align="center">
                      <Tooltip title="Edit Organization">
                        <ActionButton
                          className="edit-btn"
                          onClick={() => handleOpen(org)}
                        >
                          <EditIcon />
                        </ActionButton>
                      </Tooltip>
                      <Tooltip title="Delete Organization">
                        <ActionButton
                          className="delete-btn"
                          onClick={() => handleDelete(org.id)}
                        >
                          <DeleteIcon />
                        </ActionButton>
                      </Tooltip>
                    </TableCell>
                  </StyledTableRow>
                </Grow>
              ))}
            </TableBody>
          </Table>
        </StyledTableContainer>

      <StyledDialog open={open} onClose={handleClose} maxWidth="md" fullWidth>
        <StyledDialogTitle>
          {editingOrg ? 'Edit Organization' : 'Add New Organization'}
        </StyledDialogTitle>
        <StyledDialogContent>
          <FormSection>
            <SectionTitle>Basic Information</SectionTitle>
            <Grid container spacing={3}>
              <Grid item xs={12} sm={6}>
                <StyledTextField
                  fullWidth
                  label="Organization Name"
                  value={formData.organizationName}
                  onChange={(e) => handleInputChange('organizationName', e.target.value)}
                />
              </Grid>
              <Grid item xs={12} sm={6}>
                <StyledTextField
                  fullWidth
                  label="Leader"
                  value={formData.leader}
                  onChange={(e) => handleInputChange('leader', e.target.value)}
                />
              </Grid>
            </Grid>
          </FormSection>

          <FormSection>
            <SectionTitle>Contact Information</SectionTitle>
            <Grid container spacing={3}>
              <Grid item xs={12} sm={6}>
                <StyledTextField
                  fullWidth
                  label="Email"
                  type="email"
                  value={formData.email}
                  onChange={(e) => handleInputChange('email', e.target.value)}
                />
              </Grid>
              <Grid item xs={12} sm={6}>
                <StyledTextField
                  fullWidth
                  label="Phone Number"
                  value={formData.phoneNumber}
                  onChange={(e) => handleInputChange('phoneNumber', e.target.value)}
                />
              </Grid>
            </Grid>
          </FormSection>

          <FormSection>
            <SectionTitle>Account Security</SectionTitle>
            <Grid container spacing={3}>
              <Grid item xs={12} sm={6}>
                <StyledTextField
                  fullWidth
                  label="Password"
                  type="password"
                  value={formData.password}
                  onChange={(e) => handleInputChange('password', e.target.value)}
                />
              </Grid>
              <Grid item xs={12} sm={6}>
                <StyledTextField
                  fullWidth
                  label="Office"
                  value={formData.office}
                  onChange={(e) => handleInputChange('office', e.target.value)}
                />
              </Grid>
            </Grid>
          </FormSection>
        </StyledDialogContent>
        <StyledDialogActions>
          <DialogActionButton onClick={handleClose}>
            Cancel
          </DialogActionButton>
          <DialogActionButton
            onClick={handleSubmit}
            variant="contained"
            disabled={loading}
          >
            {loading ? 'Saving...' : editingOrg ? 'Update' : 'Create'}
          </DialogActionButton>
        </StyledDialogActions>
      </StyledDialog>

      <Snackbar
        open={snackbar.open}
        autoHideDuration={6000}
        onClose={() => setSnackbar({ ...snackbar, open: false })}
      >
        <Alert
          onClose={() => setSnackbar({ ...snackbar, open: false })}
          severity={snackbar.severity}
          sx={{ width: '100%' }}
        >
          {snackbar.message}
        </Alert>
      </Snackbar>
    </Box>
  </Fade>
  );
};

export default Organizations;