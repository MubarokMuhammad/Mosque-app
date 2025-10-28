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
  Typography,
  Snackbar,
  Alert,
  Chip,
  Grid,
  Avatar,
  Fade,
  Grow,
  Tooltip,
  Card,
  CardContent,
  Divider
} from '@mui/material';
import { 
  CheckCircle, 
  Cancel, 
  Delete, 
  Visibility, 
  Business, 
  Email, 
  Phone, 
  LocationOn,
  Person,
  Description,
  Schedule
} from '@mui/icons-material';
import { styled } from '@mui/material/styles';
import { organizationVerificationService } from '../services/firebaseService';
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
    fontWeight: 600,
    fontSize: '0.95rem',
    textTransform: 'uppercase',
    letterSpacing: '0.5px'
  }
}));

const StyledTableRow = styled(TableRow)(({ theme }) => ({
  '&:nth-of-type(odd)': {
    backgroundColor: 'rgba(0, 105, 92, 0.02)'
  },
  '&:hover': {
    backgroundColor: 'rgba(0, 105, 92, 0.08)',
    transform: 'translateY(-1px)',
    boxShadow: '0 4px 12px rgba(0, 105, 92, 0.15)'
  },
  transition: 'all 0.2s ease-in-out'
}));

const ActionButton = styled(Button)(({ theme, variant }) => ({
  minWidth: '36px',
  height: '36px',
  borderRadius: '8px',
  margin: '0 2px',
  ...(variant === 'accept' && {
    backgroundColor: '#4caf50',
    color: 'white',
    '&:hover': {
      backgroundColor: '#45a049'
    }
  }),
  ...(variant === 'decline' && {
    backgroundColor: '#f44336',
    color: 'white',
    '&:hover': {
      backgroundColor: '#da190b'
    }
  }),
  ...(variant === 'delete' && {
    backgroundColor: '#ff9800',
    color: 'white',
    '&:hover': {
      backgroundColor: '#f57c00'
    }
  })
}));

const StatusChip = styled(Chip)(({ status }) => ({
  fontWeight: 600,
  textTransform: 'capitalize',
  ...(status === 'pending' && {
    backgroundColor: '#fff3cd',
    color: '#856404',
    border: '1px solid #ffeaa7'
  }),
  ...(status === 'accepted' && {
    backgroundColor: '#d4edda',
    color: '#155724',
    border: '1px solid #c3e6cb'
  }),
  ...(status === 'declined' && {
    backgroundColor: '#f8d7da',
    color: '#721c24',
    border: '1px solid #f5c6cb'
  })
}));

const VerifyOrganization = () => {
  const [verifications, setVerifications] = useState([]);
  const [loading, setLoading] = useState(true);
  const [selectedVerification, setSelectedVerification] = useState(null);
  const [viewDialogOpen, setViewDialogOpen] = useState(false);
  const [confirmDialogOpen, setConfirmDialogOpen] = useState(false);
  const [actionType, setActionType] = useState('');
  const [snackbar, setSnackbar] = useState({
    open: false,
    message: '',
    severity: 'success'
  });

  const [searchTerm, setSearchTerm] = useState('');
  const [filterStatus, setFilterStatus] = useState('all');
  const [sortBy, setSortBy] = useState('submittedAt');
  const [sortOrder, setSortOrder] = useState('desc');

  const fetchVerifications = async () => {
    try {
      setLoading(true);
      const data = await organizationVerificationService.getAll();
      setVerifications(data);
    } catch (error) {
      console.error('Error fetching verifications:', error);
      showSnackbar('Error fetching organization verifications', 'error');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchVerifications();
  }, []);

  const filteredAndSortedVerifications = useMemo(() => {
    let filtered = verifications.filter(verification => {
      const matchesSearch = 
        verification.organizationName?.toLowerCase().includes(searchTerm.toLowerCase()) ||
        verification.contactEmail?.toLowerCase().includes(searchTerm.toLowerCase()) ||
        verification.contactPerson?.toLowerCase().includes(searchTerm.toLowerCase());
      
      const matchesFilter = filterStatus === 'all' || verification.verifyStatus === filterStatus;
      
      return matchesSearch && matchesFilter;
    });

    filtered.sort((a, b) => {
      let aValue = a[sortBy];
      let bValue = b[sortBy];
      
      if (sortBy === 'submittedAt' || sortBy === 'updatedAt') {
        aValue = new Date(aValue?.seconds ? aValue.seconds * 1000 : aValue);
        bValue = new Date(bValue?.seconds ? bValue.seconds * 1000 : bValue);
      }
      
      if (sortOrder === 'asc') {
        return aValue > bValue ? 1 : -1;
      } else {
        return aValue < bValue ? 1 : -1;
      }
    });

    return filtered;
  }, [verifications, searchTerm, filterStatus, sortBy, sortOrder]);

  const showSnackbar = (message, severity = 'success') => {
    setSnackbar({
      open: true,
      message,
      severity
    });
  };

  const handleViewDetails = (verification) => {
    setSelectedVerification(verification);
    setViewDialogOpen(true);
  };

  const handleAction = (verification, action) => {
    setSelectedVerification(verification);
    setActionType(action);
    setConfirmDialogOpen(true);
  };

  const executeAction = async () => {
    try {
      const { id, userId } = selectedVerification;
      
      switch (actionType) {
        case 'accept':
          await organizationVerificationService.accept(id, userId);
          showSnackbar('Organization verification accepted successfully');
          break;
        case 'decline':
          await organizationVerificationService.decline(id);
          showSnackbar('Organization verification declined');
          break;
        case 'delete':
          await organizationVerificationService.delete(id);
          showSnackbar('Organization verification deleted');
          break;
        default:
          break;
      }
      
      setConfirmDialogOpen(false);
      fetchVerifications();
    } catch (error) {
      console.error(`Error ${actionType}ing verification:`, error);
      showSnackbar(`Error ${actionType}ing verification`, 'error');
    }
  };

  const formatDate = (timestamp) => {
    if (!timestamp) return 'N/A';
    const date = timestamp.seconds ? new Date(timestamp.seconds * 1000) : new Date(timestamp);
    return date.toLocaleDateString() + ' ' + date.toLocaleTimeString();
  };

  const getActionButtons = (verification) => {
    const { verifyStatus } = verification;
    
    return (
      <Box sx={{ display: 'flex', gap: 0.5 }}>
        <Tooltip title="View Details">
          <ActionButton
            size="small"
            onClick={() => handleViewDetails(verification)}
          >
            <Visibility fontSize="small" />
          </ActionButton>
        </Tooltip>
        
        {verifyStatus === 'pending' && (
          <>
            <Tooltip title="Accept">
              <ActionButton
                variant="accept"
                size="small"
                onClick={() => handleAction(verification, 'accept')}
              >
                <CheckCircle fontSize="small" />
              </ActionButton>
            </Tooltip>
            
            <Tooltip title="Decline">
              <ActionButton
                variant="decline"
                size="small"
                onClick={() => handleAction(verification, 'decline')}
              >
                <Cancel fontSize="small" />
              </ActionButton>
            </Tooltip>
          </>
        )}
        
        <Tooltip title="Delete">
          <ActionButton
            variant="delete"
            size="small"
            onClick={() => handleAction(verification, 'delete')}
          >
            <Delete fontSize="small" />
          </ActionButton>
        </Tooltip>
      </Box>
    );
  };

  return (
    <Box sx={{ p: 3 }}>
      <Typography variant="h4" sx={{ mb: 3, fontWeight: 600, color: '#00695c' }}>
        Organization Verifications
      </Typography>

      <SearchFilterSort
        searchValue={searchTerm}
        onSearchChange={setSearchTerm}
        placeholder="Search organizations..."
        filters={{ status: filterStatus }}
        onFilterChange={(newFilters) => setFilterStatus(newFilters.status || 'all')}
        filterOptions={{
          status: {
            label: 'Status',
            values: [
              { value: 'all', label: 'All Status' },
              { value: 'pending', label: 'Pending' },
              { value: 'accepted', label: 'Accepted' },
              { value: 'declined', label: 'Declined' }
            ]
          }
        }}
        sortBy={sortBy}
        onSortChange={setSortBy}
        sortOptions={[
          { value: 'createdAt', label: 'Date Created' },
          { value: 'organizationName', label: 'Organization Name' },
          { value: 'verifyStatus', label: 'Status' }
        ]}
        sortOrder={sortOrder}
        onSortOrderChange={setSortOrder}
      />

      <Fade in={!loading}>
        <StyledTableContainer component={Paper}>
          <Table>
            <StyledTableHead>
              <TableRow>
                <TableCell>Organization</TableCell>
                <TableCell>Contact Person</TableCell>
                <TableCell>Email</TableCell>
                <TableCell>Phone</TableCell>
                <TableCell>Status</TableCell>
                <TableCell>Date Submitted</TableCell>
                <TableCell align="center">Actions</TableCell>
              </TableRow>
            </StyledTableHead>
            <TableBody>
              {filteredAndSortedVerifications.map((verification) => (
                <Grow
                  key={verification.id}
                  in={true}
                  timeout={300}
                >
                  <StyledTableRow>
                    <TableCell>
                      <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                        <Avatar sx={{ bgcolor: '#00695c' }}>
                          <Business />
                        </Avatar>
                        <Box>
                          <Typography variant="subtitle2" fontWeight={600}>
                            {verification.organizationName || 'N/A'}
                          </Typography>
                        </Box>
                      </Box>
                    </TableCell>
                    <TableCell>
                      <Typography variant="body2">
                        {verification.userDetails.name || 'N/A'}
                      </Typography>
                    </TableCell>
                    <TableCell>
                      <Typography variant="body2">
                        {verification.contactEmail || 'N/A'}
                      </Typography>
                    </TableCell>
                    <TableCell>
                      <Typography variant="body2">
                        {verification.contactPhone || 'N/A'}
                      </Typography>
                    </TableCell>
                    <TableCell>
                      <StatusChip
                        label={verification.verifyStatus || 'pending'}
                        status={verification.verifyStatus || 'pending'}
                        size="small"
                      />
                    </TableCell>
                    <TableCell>
                      <Typography variant="body2">
                        {formatDate(verification.submittedAt)}
                      </Typography>
                    </TableCell>
                    <TableCell align="center">
                      {getActionButtons(verification)}
                    </TableCell>
                  </StyledTableRow>
                </Grow>
              ))}
              {filteredAndSortedVerifications.length === 0 && (
                <TableRow>
                  <TableCell colSpan={7} align="center" sx={{ py: 4 }}>
                    <Typography variant="body1" color="text.secondary">
                      No organization verifications found
                    </Typography>
                  </TableCell>
                </TableRow>
              )}
            </TableBody>
          </Table>
        </StyledTableContainer>
      </Fade>

      {/* View Details Dialog */}
      <Dialog
        open={viewDialogOpen}
        onClose={() => setViewDialogOpen(false)}
        maxWidth="md"
        fullWidth
      >
        <DialogTitle>
          <Typography variant="h6" sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
            <Business color="primary" />
            Organization Details
          </Typography>
        </DialogTitle>
        <DialogContent>
          {selectedVerification && (
            <Grid container spacing={3} sx={{ mt: 1 }}>
              <Grid item xs={12} md={6}>
                <Card variant="outlined">
                  <CardContent>
                    <Typography variant="h6" gutterBottom color="primary">
                      Organization Information
                    </Typography>
                    <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
                      <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                        <Business fontSize="small" color="action" />
                        <Typography variant="body2">
                          <strong>Name:</strong> {selectedVerification.organizationName || 'N/A'}
                        </Typography>
                      </Box>
                      <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                        <LocationOn fontSize="small" color="action" />
                        <Typography variant="body2">
                          <strong>Address:</strong> {selectedVerification.address || 'N/A'}
                        </Typography>
                      </Box>
                    </Box>
                  </CardContent>
                </Card>
              </Grid>
              
              <Grid item xs={12} md={6}>
                <Card variant="outlined">
                  <CardContent>
                    <Typography variant="h6" gutterBottom color="primary">
                      Contact Information
                    </Typography>
                    <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
                      <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                        <Person fontSize="small" color="action" />
                        <Typography variant="body2">
                          <strong>Contact Person:</strong> {selectedVerification.userDetails.name || 'N/A'}
                        </Typography>
                      </Box>
                      <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                        <Email fontSize="small" color="action" />
                        <Typography variant="body2">
                          <strong>Email:</strong> {selectedVerification.contactEmail || 'N/A'}
                        </Typography>
                      </Box>
                      <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                        <Phone fontSize="small" color="action" />
                        <Typography variant="body2">
                          <strong>Phone:</strong> {selectedVerification.contactPhone || 'N/A'}
                        </Typography>
                      </Box>
                    </Box>
                  </CardContent>
                </Card>
              </Grid>
              
              <Grid item xs={12}>
                <Card variant="outlined">
                  <CardContent>
                    <Typography variant="h6" gutterBottom color="primary">
                      Additional Details
                    </Typography>
                    <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
                      <Typography variant="body2">
                        <strong>Description:</strong> {selectedVerification.organizationDescription || 'No description provided'}
                      </Typography>
                      <Divider />
                      <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                        <Schedule fontSize="small" color="action" />
                        <Typography variant="body2">
                          <strong>Submitted:</strong> {formatDate(selectedVerification.submittedAt)}
                        </Typography>
                      </Box>
                      <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                        <StatusChip
                          label={selectedVerification.verifyStatus || 'pending'}
                          status={selectedVerification.verifyStatus || 'pending'}
                          size="small"
                        />
                      </Box>
                    </Box>
                  </CardContent>
                </Card>
              </Grid>
            </Grid>
          )}
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setViewDialogOpen(false)}>Close</Button>
        </DialogActions>
      </Dialog>

      {/* Confirmation Dialog */}
      <Dialog
        open={confirmDialogOpen}
        onClose={() => setConfirmDialogOpen(false)}
      >
        <DialogTitle>
          Confirm {actionType?.charAt(0).toUpperCase() + actionType?.slice(1)}
        </DialogTitle>
        <DialogContent>
          <Typography>
            Are you sure you want to {actionType} this organization verification for{' '}
            <strong>{selectedVerification?.organizationName}</strong>?
          </Typography>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setConfirmDialogOpen(false)}>Cancel</Button>
          <Button
            onClick={executeAction}
            variant="contained"
            color={actionType === 'delete' ? 'error' : 'primary'}
          >
            {actionType?.charAt(0).toUpperCase() + actionType?.slice(1)}
          </Button>
        </DialogActions>
      </Dialog>

      {/* Snackbar */}
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
  );
};

export default VerifyOrganization;