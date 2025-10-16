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
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  Avatar,
  Card,
  CardContent,
  Fade,
  Grow,
  Tooltip
} from '@mui/material';
import {
  Add as AddIcon,
  Edit as EditIcon,
  Delete as DeleteIcon,
  LocationOn as LocationIcon
} from '@mui/icons-material';
import { styled } from '@mui/material/styles';
import { mosqueService, organizationService } from '../services/firebaseService';
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

const StyledAvatar = styled(Avatar)(({ theme }) => ({
  width: 56,
  height: 56,
  border: '3px solid rgba(0, 105, 92, 0.2)',
  boxShadow: '0 4px 12px rgba(0, 105, 92, 0.2)',
  transition: 'all 0.3s ease',
  '&:hover': {
    transform: 'scale(1.1)',
    boxShadow: '0 6px 20px rgba(0, 105, 92, 0.3)'
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

const StyledFormControl = styled(FormControl)(({ theme }) => ({
  '& .MuiOutlinedInput-root': {
    borderRadius: '12px',
    backgroundColor: 'white',
    transition: 'all 0.3s ease',
    '&:hover': {
      boxShadow: '0 4px 12px rgba(32, 178, 170, 0.15)',
    },
    '&.Mui-focused': {
      boxShadow: '0 4px 20px rgba(32, 178, 170, 0.25)',
      '& .MuiOutlinedInput-notchedOutline': {
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

const LocationButton = styled(Button)(({ theme }) => ({
  height: '56px',
  borderRadius: '12px',
  borderColor: '#20B2AA',
  color: '#20B2AA',
  fontWeight: 600,
  transition: 'all 0.3s ease',
  '&:hover': {
    borderColor: '#1a9999',
    backgroundColor: 'rgba(32, 178, 170, 0.08)',
    boxShadow: '0 4px 12px rgba(32, 178, 170, 0.15)',
    transform: 'translateY(-1px)',
  },
}));

const Mosques = () => {
  const [mosques, setMosques] = useState([]);
  const [organizations, setOrganizations] = useState([]);
  const [open, setOpen] = useState(false);
  const [editingMosque, setEditingMosque] = useState(null);
  const [loading, setLoading] = useState(false);
  const [snackbar, setSnackbar] = useState({ open: false, message: '', severity: 'success' });
  
  // Search, Filter, Sort states
  const [searchValue, setSearchValue] = useState('');
  const [sortBy, setSortBy] = useState('');
  const [sortOrder, setSortOrder] = useState('asc');
  const [filters, setFilters] = useState({
    organizationName: '',
    postalCode: ''
  });
  
  const [formData, setFormData] = useState({
    mosqueName: '',
    mosquePhoto: '',
    organizationId: '',
    organizationName: '',
    fullAddress: '',
    latitude: '',
    longitude: '',
    postalCode: ''
  });

  useEffect(() => {
    fetchMosques();
    fetchOrganizations();
  }, []);

  const fetchMosques = async () => {
    try {
      setLoading(true);
      const data = await mosqueService.getAll();
      setMosques(data);
    } catch (error) {
      showSnackbar('Error fetching mosques', 'error');
    } finally {
      setLoading(false);
    }
  };

  const fetchOrganizations = async () => {
    try {
      const data = await organizationService.getAll();
      setOrganizations(data);
    } catch (error) {
      showSnackbar('Error fetching organizations', 'error');
    }
  };

  const handleOpen = (mosque = null) => {
    if (mosque) {
      setEditingMosque(mosque);
      setFormData({
        mosqueName: mosque.mosqueName || '',
        mosquePhoto: mosque.mosquePhoto || '',
        organizationId: mosque.organizationId || '',
        organizationName: mosque.organizationName || '',
        fullAddress: mosque.fullAddress || '',
        latitude: mosque.latitude || '',
        longitude: mosque.longitude || '',
        postalCode: mosque.postalCode || ''
      });
    } else {
      setEditingMosque(null);
      setFormData({
        mosqueName: '',
        mosquePhoto: '',
        organizationId: '',
        organizationName: '',
        fullAddress: '',
        latitude: '',
        longitude: '',
        postalCode: ''
      });
    }
    setOpen(true);
  };

  const handleClose = () => {
    setOpen(false);
    setEditingMosque(null);
    setFormData({
      mosqueName: '',
      mosquePhoto: '',
      organizationId: '',
      organizationName: '',
      fullAddress: '',
      latitude: '',
      longitude: '',
      postalCode: ''
    });
  };

  const handleOrganizationChange = (orgId) => {
    const selectedOrg = organizations.find(org => org.id === orgId);
    setFormData(prev => ({
      ...prev,
      organizationId: orgId,
      organizationName: selectedOrg ? selectedOrg.organizationName : ''
    }));
  };

  const handleSubmit = async () => {
    try {
      setLoading(true);
      if (editingMosque) {
        await mosqueService.update(editingMosque.id, formData);
        showSnackbar('Mosque updated successfully', 'success');
      } else {
        await mosqueService.create(formData);
        showSnackbar('Mosque created successfully', 'success');
      }
      handleClose();
      fetchMosques();
    } catch (error) {
      showSnackbar('Error saving mosque', 'error');
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async (id) => {
    if (window.confirm('Are you sure you want to delete this mosque?')) {
      try {
        setLoading(true);
        await mosqueService.delete(id);
        showSnackbar('Mosque deleted successfully', 'success');
        fetchMosques();
      } catch (error) {
        showSnackbar('Error deleting mosque', 'error');
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

  const getCurrentLocation = () => {
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          setFormData(prev => ({
            ...prev,
            latitude: position.coords.latitude.toString(),
            longitude: position.coords.longitude.toString()
          }));
          showSnackbar('Location obtained successfully', 'success');
        },
        (error) => {
          showSnackbar('Error getting location', 'error');
        }
      );
    } else {
      showSnackbar('Geolocation is not supported by this browser', 'error');
    }
  };

  // Filter and sort mosques
  const filteredAndSortedMosques = useMemo(() => {
    let filtered = mosques.filter(mosque => {
      // Search filter
      const searchMatch = !searchValue || 
        mosque.mosqueName?.toLowerCase().includes(searchValue.toLowerCase()) ||
        mosque.organizationName?.toLowerCase().includes(searchValue.toLowerCase()) ||
        mosque.fullAddress?.toLowerCase().includes(searchValue.toLowerCase()) ||
        mosque.postalCode?.toLowerCase().includes(searchValue.toLowerCase());

      // Additional filters
      const organizationMatch = !filters.organizationName || mosque.organizationName === filters.organizationName;
      const postalCodeMatch = !filters.postalCode || mosque.postalCode === filters.postalCode;

      return searchMatch && organizationMatch && postalCodeMatch;
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
  }, [mosques, searchValue, sortBy, sortOrder, filters]);

  // Get unique values for filter options
  const filterOptions = useMemo(() => {
    const uniqueOrganizations = [...new Set(mosques.map(mosque => mosque.organizationName).filter(Boolean))];
    const uniquePostalCodes = [...new Set(mosques.map(mosque => mosque.postalCode).filter(Boolean))];

    return {
      organizationName: {
        label: 'Organization',
        values: uniqueOrganizations.map(org => ({ value: org, label: org }))
      },
      postalCode: {
        label: 'Postal Code',
        values: uniquePostalCodes.map(code => ({ value: code, label: code }))
      }
    };
  }, [mosques]);

  const sortOptions = [
    { value: 'mosqueName', label: 'Mosque Name' },
    { value: 'organizationName', label: 'Organization' },
    { value: 'fullAddress', label: 'Address' },
    { value: 'postalCode', label: 'Postal Code' }
  ];

  return (
    <Fade in timeout={800}>
      <Box>
        <HeaderCard>
          <CardContent>
            <Box display="flex" justifyContent="space-between" alignItems="center">
              <Typography variant="h4" sx={{ fontWeight: 'bold', display: 'flex', alignItems: 'center' }}>
                Mosque Management
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
                Add New Mosque
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
          placeholder="Search mosques, organizations, addresses, or postal codes..."
        />

        <StyledTableContainer component={Paper}>
          <Table>
            <StyledTableHead>
              <TableRow>
                <TableCell>Photo</TableCell>
                <TableCell>Mosque Name</TableCell>
                <TableCell>Organization</TableCell>
                <TableCell>Address</TableCell>
                <TableCell>Location</TableCell>
                <TableCell>Postal Code</TableCell>
                <TableCell align="center">Actions</TableCell>
              </TableRow>
            </StyledTableHead>
            <TableBody>
              {filteredAndSortedMosques.map((mosque, index) => (
                <Grow in timeout={600 + index * 100} key={mosque.id}>
                  <StyledTableRow>
                    <TableCell>
                      <StyledAvatar
                        src={mosque.mosquePhoto}
                        alt={mosque.mosqueName}
                        sx={{ backgroundColor: '#00695c' }}
                      >
                        {mosque.mosqueName?.charAt(0)}
                      </StyledAvatar>
                    </TableCell>
                    <TableCell>
                      <Typography variant="body1" sx={{ fontWeight: 600, color: '#00695c' }}>
                        {mosque.mosqueName}
                      </Typography>
                    </TableCell>
                    <TableCell>
                      <Typography variant="body2" sx={{ color: '#666' }}>
                        {mosque.organizationName}
                      </Typography>
                    </TableCell>
                    <TableCell>
                      <Typography variant="body2" sx={{ maxWidth: 200, overflow: 'hidden', textOverflow: 'ellipsis' }}>
                        {mosque.fullAddress}
                      </Typography>
                    </TableCell>
                    <TableCell>
                       {mosque.latitude && mosque.longitude ? (
                         <Tooltip title={`Lat: ${mosque.latitude}, Lng: ${mosque.longitude}`}>
                           <Box display="flex" alignItems="center" sx={{ cursor: 'pointer' }}>
                             <LocationIcon sx={{ color: '#00695c', mr: 1, fontSize: 20 }} />
                             <Typography variant="body2" sx={{ color: '#00695c', fontWeight: 500 }}>
                               {parseFloat(mosque.latitude).toFixed(4)}, {parseFloat(mosque.longitude).toFixed(4)}
                             </Typography>
                           </Box>
                         </Tooltip>
                       ) : (
                         <Typography variant="body2" sx={{ color: '#999' }}>
                           Not set
                         </Typography>
                       )}
                     </TableCell>
                     <TableCell>
                       <Typography variant="body2" sx={{ fontWeight: 500 }}>
                         {mosque.postalCode || 'N/A'}
                       </Typography>
                     </TableCell>
                     <TableCell align="center">
                       <Tooltip title="Edit Mosque">
                         <ActionButton
                           className="edit-btn"
                           onClick={() => handleOpen(mosque)}
                         >
                           <EditIcon />
                         </ActionButton>
                       </Tooltip>
                       <Tooltip title="Delete Mosque">
                         <ActionButton
                           className="delete-btn"
                           onClick={() => handleDelete(mosque.id)}
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
           {editingMosque ? 'Edit Mosque' : 'Add New Mosque'}
         </StyledDialogTitle>
         <StyledDialogContent>
           <FormSection>
             <SectionTitle>Basic Information</SectionTitle>
             <Grid container spacing={3}>
               <Grid item xs={12} sm={6}>
                 <StyledTextField
                   fullWidth
                   label="Mosque Name"
                   value={formData.mosqueName}
                   onChange={(e) => handleInputChange('mosqueName', e.target.value)}
                 />
               </Grid>
               <Grid item xs={12} sm={6}>
                 <StyledTextField
                   fullWidth
                   label="Mosque Photo URL"
                   value={formData.mosquePhoto}
                   onChange={(e) => handleInputChange('mosquePhoto', e.target.value)}
                 />
               </Grid>
               <Grid item xs={12}>
                 <StyledFormControl fullWidth>
                   <InputLabel>Organization</InputLabel>
                   <Select
                     value={formData.organizationId}
                     onChange={(e) => handleOrganizationChange(e.target.value)}
                   >
                     {organizations.map((org) => (
                       <MenuItem key={org.id} value={org.id}>
                         {org.organizationName}
                       </MenuItem>
                     ))}
                   </Select>
                 </StyledFormControl>
               </Grid>
             </Grid>
           </FormSection>

           <FormSection>
             <SectionTitle>Address & Location</SectionTitle>
             <Grid container spacing={3}>
               <Grid item xs={12}>
                 <StyledTextField
                   fullWidth
                   label="Full Address"
                   multiline
                   rows={2}
                   value={formData.fullAddress}
                   onChange={(e) => handleInputChange('fullAddress', e.target.value)}
                 />
               </Grid>
               <Grid item xs={12} sm={4}>
                 <StyledTextField
                   fullWidth
                   label="Latitude"
                   type="number"
                   value={formData.latitude}
                   onChange={(e) => handleInputChange('latitude', e.target.value)}
                 />
               </Grid>
               <Grid item xs={12} sm={4}>
                 <StyledTextField
                   fullWidth
                   label="Longitude"
                   type="number"
                   value={formData.longitude}
                   onChange={(e) => handleInputChange('longitude', e.target.value)}
                 />
               </Grid>
               <Grid item xs={12} sm={4}>
                 <LocationButton
                   fullWidth
                   variant="outlined"
                   startIcon={<LocationIcon />}
                   onClick={getCurrentLocation}
                 >
                   Get Current Location
                 </LocationButton>
               </Grid>
               <Grid item xs={12}>
                 <StyledTextField
                   fullWidth
                   label="Postal Code"
                   value={formData.postalCode}
                   onChange={(e) => handleInputChange('postalCode', e.target.value)}
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
             {loading ? 'Saving...' : editingMosque ? 'Update' : 'Create'}
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

export default Mosques;