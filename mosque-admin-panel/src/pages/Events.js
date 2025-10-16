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
  Card,
  CardContent,
  List,
  ListItem,
  ListItemText,
  ListItemSecondaryAction,
  Checkbox,
  Avatar,
  Fade,
  Grow,
  Tooltip,
  Badge
} from '@mui/material';
import { Add, Edit, Delete, Person, AccessTime, LocationOn, Event as EventIcon, Group } from '@mui/icons-material';
import { styled } from '@mui/material/styles';
import { eventService, mosqueService, organizationService, categoryService, userService } from '../services/firebaseService';
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

const StyledChip = styled(Chip)(({ theme }) => ({
  borderRadius: '12px',
  fontWeight: 600,
  fontSize: '0.75rem',
  height: '28px',
  '&.type-online': {
    backgroundColor: '#e3f2fd',
    color: '#1976d2',
    border: '1px solid #bbdefb'
  },
  '&.type-physical': {
    backgroundColor: '#f3e5f5',
    color: '#7b1fa2',
    border: '1px solid #ce93d8'
  },
  '&.type-hybrid': {
    backgroundColor: '#fff3e0',
    color: '#f57c00',
    border: '1px solid #ffcc02'
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
  },
  '&.attendance-btn': {
    color: '#1976d2',
    backgroundColor: 'rgba(25, 118, 210, 0.08)',
    '&:hover': {
      backgroundColor: '#1976d2',
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

const Events = () => {
  const [events, setEvents] = useState([]);
  const [mosques, setMosques] = useState([]);
  const [organizations, setOrganizations] = useState([]);
  const [categories, setCategories] = useState([]);
  const [users, setUsers] = useState([]);
  const [open, setOpen] = useState(false);
  const [attendanceOpen, setAttendanceOpen] = useState(false);
  const [editingEvent, setEditingEvent] = useState(null);
  const [snackbar, setSnackbar] = useState({ open: false, message: '', severity: 'success' });
  
  // Search, Filter, Sort states
  const [searchValue, setSearchValue] = useState('');
  const [sortBy, setSortBy] = useState('');
  const [sortOrder, setSortOrder] = useState('asc');
  const [filters, setFilters] = useState({
    type: '',
    categoryId: '',
    mosqueId: ''
  });
  
  const [formData, setFormData] = useState({
    name: '',
    mosqueId: '',
    organizationId: '',
    attendanceList: [],
    type: '',
    categoryId: '',
    date: '',
    startTime: '',
    endTime: '',
    notes: ''
  });

  useEffect(() => {
    fetchEvents();
    fetchMosques();
    fetchOrganizations();
    fetchCategories();
    fetchUsers();
  }, []);

  const fetchEvents = async () => {
    try {
      const data = await eventService.getAll();
      setEvents(data);
    } catch (error) {
      console.error('Error fetching events:', error);
    }
  };

  const fetchMosques = async () => {
    try {
      const data = await mosqueService.getAll();
      setMosques(data);
    } catch (error) {
      console.error('Error fetching mosques:', error);
    }
  };

  const fetchOrganizations = async () => {
    try {
      const data = await organizationService.getAll();
      setOrganizations(data);
    } catch (error) {
      console.error('Error fetching organizations:', error);
    }
  };

  const fetchCategories = async () => {
    try {
      const data = await categoryService.getAll();
      setCategories(data);
    } catch (error) {
      console.error('Error fetching categories:', error);
    }
  };

  const fetchUsers = async () => {
    try {
      const data = await userService.getAll();
      setUsers(data);
    } catch (error) {
      console.error('Error fetching users:', error);
    }
  };

  const handleOpen = (event = null) => {
    if (event) {
      setEditingEvent(event);
      setFormData({
        name: event.name || '',
        mosqueId: event.mosqueId || '',
        organizationId: event.organizationId || '',
        attendanceList: event.attendanceList || [],
        type: event.type || '',
        categoryId: event.categoryId || '',
        date: event.date || '',
        startTime: event.startTime || '',
        endTime: event.endTime || '',
        notes: event.notes || ''
      });
    } else {
      setEditingEvent(null);
      setFormData({
        name: '',
        mosqueId: '',
        organizationId: '',
        attendanceList: [],
        type: '',
        categoryId: '',
        date: '',
        startTime: '',
        endTime: '',
        notes: ''
      });
    }
    setOpen(true);
  };

  const handleClose = () => {
    setOpen(false);
    setEditingEvent(null);
  };

  const handleAttendanceOpen = () => {
    setAttendanceOpen(true);
  };

  const handleAttendanceClose = () => {
    setAttendanceOpen(false);
  };

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };

  const handleAttendanceToggle = (userId) => {
    setFormData(prev => ({
      ...prev,
      attendanceList: prev.attendanceList.includes(userId)
        ? prev.attendanceList.filter(id => id !== userId)
        : [...prev.attendanceList, userId]
    }));
  };

  const handleSubmit = async () => {
    try {
      if (editingEvent) {
        await eventService.update(editingEvent.id, formData);
        setSnackbar({ open: true, message: 'Event updated successfully!', severity: 'success' });
      } else {
        await eventService.create(formData);
        setSnackbar({ open: true, message: 'Event created successfully!', severity: 'success' });
      }
      fetchEvents();
      handleClose();
    } catch (error) {
      console.error('Error saving event:', error);
      setSnackbar({ open: true, message: 'Error saving event!', severity: 'error' });
    }
  };

  const handleDelete = async (id) => {
    if (window.confirm('Are you sure you want to delete this event?')) {
      try {
        await eventService.delete(id);
        setSnackbar({ open: true, message: 'Event deleted successfully!', severity: 'success' });
        fetchEvents();
      } catch (error) {
        console.error('Error deleting event:', error);
        setSnackbar({ open: true, message: 'Error deleting event!', severity: 'error' });
      }
    }
  };

  const getMosqueName = (mosqueId) => {
    const mosque = mosques.find(m => m.id === mosqueId);
    return mosque ? mosque.name : 'Unknown Mosque';
  };

  const getOrganizationName = (organizationId) => {
    const organization = organizations.find(o => o.id === organizationId);
    return organization ? organization.name : 'Unknown Organization';
  };

  const getCategoryName = (categoryId) => {
    const category = categories.find(c => c.id === categoryId);
    return category ? category.name : 'Unknown Category';
  };

  const getUserName = (userId) => {
    const user = users.find(u => u.id === userId);
    return user ? user.name : 'Unknown User';
  };

  const formatDate = (dateString) => {
    if (!dateString) return '';
    return new Date(dateString).toLocaleDateString();
  };

  const formatTime = (timeString) => {
    if (!timeString) return '';
    return timeString;
  };

  // Filter and sort events
  const filteredAndSortedEvents = useMemo(() => {
    let filtered = events.filter(event => {
      // Search filter
      const searchMatch = !searchValue || 
        event.name?.toLowerCase().includes(searchValue.toLowerCase()) ||
        event.notes?.toLowerCase().includes(searchValue.toLowerCase()) ||
        getMosqueName(event.mosqueId)?.toLowerCase().includes(searchValue.toLowerCase()) ||
        getOrganizationName(event.organizationId)?.toLowerCase().includes(searchValue.toLowerCase()) ||
        getCategoryName(event.categoryId)?.toLowerCase().includes(searchValue.toLowerCase());

      // Additional filters
      const typeMatch = !filters.type || event.type === filters.type;
      const categoryMatch = !filters.categoryId || event.categoryId === filters.categoryId;
      const mosqueMatch = !filters.mosqueId || event.mosqueId === filters.mosqueId;

      return searchMatch && typeMatch && categoryMatch && mosqueMatch;
    });

    // Sort
    if (sortBy) {
      filtered.sort((a, b) => {
        let aValue = a[sortBy] || '';
        let bValue = b[sortBy] || '';
        
        // Handle special cases for related data
        if (sortBy === 'mosqueName') {
          aValue = getMosqueName(a.mosqueId) || '';
          bValue = getMosqueName(b.mosqueId) || '';
        } else if (sortBy === 'categoryName') {
          aValue = getCategoryName(a.categoryId) || '';
          bValue = getCategoryName(b.categoryId) || '';
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
  }, [events, searchValue, sortBy, sortOrder, filters, mosques, categories]);

  // Get unique values for filter options
  const filterOptions = useMemo(() => {
    const uniqueTypes = [...new Set(events.map(event => event.type).filter(Boolean))];
    const uniqueCategories = categories.filter(cat => 
      events.some(event => event.categoryId === cat.id)
    );
    const uniqueMosques = mosques.filter(mosque => 
      events.some(event => event.mosqueId === mosque.id)
    );

    return {
      type: {
        label: 'Event Type',
        values: uniqueTypes.map(type => ({ value: type, label: type }))
      },
      categoryId: {
        label: 'Category',
        values: uniqueCategories.map(cat => ({ value: cat.id, label: cat.categoryName }))
      },
      mosqueId: {
        label: 'Mosque',
        values: uniqueMosques.map(mosque => ({ value: mosque.id, label: mosque.mosqueName }))
      }
    };
  }, [events, categories, mosques]);

  const sortOptions = [
    { value: 'name', label: 'Event Name' },
    { value: 'date', label: 'Date' },
    { value: 'startTime', label: 'Start Time' },
    { value: 'type', label: 'Type' },
    { value: 'mosqueName', label: 'Mosque' },
    { value: 'categoryName', label: 'Category' }
  ];

  return (
    <Fade in={true} timeout={800}>
      <Box sx={{ p: 3 }}>
        <HeaderCard>
          <CardContent sx={{ p: 3 }}>
            <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                <Avatar sx={{ backgroundColor: 'rgba(255, 255, 255, 0.2)', width: 56, height: 56 }}>
                  <EventIcon sx={{ fontSize: 28 }} />
                </Avatar>
                <Box>
                  <Typography variant="h4" component="h1" sx={{ fontWeight: 700, mb: 1 }}>
                    Events Management
                  </Typography>
                  <Typography variant="body1" sx={{ opacity: 0.9 }}>
                    Manage mosque events, schedules, and attendance
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
                Add New Event
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
          placeholder="Search events by name, description, mosque, organization, or category..."
        />

        <StyledTableContainer component={Paper}>
          <Table>
            <StyledTableHead>
              <TableRow>
                <TableCell>Event Details</TableCell>
                <TableCell>Location & Organization</TableCell>
                <TableCell>Type & Category</TableCell>
                <TableCell>Schedule</TableCell>
                <TableCell>Attendance</TableCell>
                <TableCell align="center">Actions</TableCell>
              </TableRow>
            </StyledTableHead>
            <TableBody>
              {filteredAndSortedEvents.map((event, index) => (
                <Grow
                  key={event.id}
                  in={true}
                  timeout={600}
                  style={{ transitionDelay: `${index * 100}ms` }}
                >
                  <StyledTableRow>
                    <TableCell>
                      <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                        <Avatar sx={{ backgroundColor: '#00695c', width: 40, height: 40 }}>
                          <EventIcon />
                        </Avatar>
                        <Box>
                          <Typography variant="subtitle1" sx={{ fontWeight: 600, color: '#00695c' }}>
                            {event.name}
                          </Typography>
                          <Typography variant="body2" sx={{ color: 'text.secondary', mt: 0.5 }}>
                            {event.notes ? event.notes.substring(0, 50) + '...' : 'No description'}
                          </Typography>
                        </Box>
                      </Box>
                    </TableCell>
                    <TableCell>
                      <Box>
                        <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 1 }}>
                          <LocationOn sx={{ fontSize: 16, color: '#00695c' }} />
                          <Typography variant="body2" sx={{ fontWeight: 600 }}>
                            {getMosqueName(event.mosqueId)}
                          </Typography>
                        </Box>
                        <Typography variant="body2" sx={{ color: 'text.secondary' }}>
                          {getOrganizationName(event.organizationId)}
                        </Typography>
                      </Box>
                    </TableCell>
                    <TableCell>
                      <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1 }}>
                        <StyledChip 
                          label={event.type} 
                          size="small"
                          className={`type-${event.type.toLowerCase()}`}
                        />
                        <Chip 
                          label={getCategoryName(event.categoryId)}
                          size="small"
                          variant="outlined"
                          sx={{ 
                            borderColor: '#00695c',
                            color: '#00695c',
                            fontWeight: 600
                          }}
                        />
                      </Box>
                    </TableCell>
                    <TableCell>
                      <Box>
                        <Typography variant="body2" sx={{ fontWeight: 600, mb: 0.5 }}>
                          {formatDate(event.date)}
                        </Typography>
                        <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                          <AccessTime sx={{ fontSize: 14, color: '#00695c' }} />
                          <Typography variant="body2" sx={{ color: 'text.secondary' }}>
                            {formatTime(event.startTime)} - {formatTime(event.endTime)}
                          </Typography>
                        </Box>
                      </Box>
                    </TableCell>
                    <TableCell>
                      <Badge 
                        badgeContent={event.attendanceList ? event.attendanceList.length : 0}
                        color="primary"
                        sx={{
                          '& .MuiBadge-badge': {
                            backgroundColor: '#00695c',
                            color: 'white',
                            fontWeight: 600
                          }
                        }}
                      >
                        <Avatar sx={{ backgroundColor: 'rgba(0, 105, 92, 0.1)', color: '#00695c', width: 36, height: 36 }}>
                          <Group sx={{ fontSize: 18 }} />
                        </Avatar>
                      </Badge>
                    </TableCell>
                    <TableCell align="center">
                      <Box sx={{ display: 'flex', justifyContent: 'center', gap: 1 }}>
                        <Tooltip title="Edit Event" arrow>
                          <ActionButton
                            className="edit-btn"
                            onClick={() => handleOpen(event)}
                            size="small"
                          >
                            <Edit sx={{ fontSize: 18 }} />
                          </ActionButton>
                        </Tooltip>
                        <Tooltip title="Manage Attendance" arrow>
                          <ActionButton
                            className="attendance-btn"
                            onClick={() => handleAttendanceOpen(event)}
                            size="small"
                          >
                            <Person sx={{ fontSize: 18 }} />
                          </ActionButton>
                        </Tooltip>
                        <Tooltip title="Delete Event" arrow>
                          <ActionButton
                            className="delete-btn"
                            onClick={() => handleDelete(event.id)}
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

      {/* Add/Edit Event Dialog */}
      <StyledDialog 
        open={open} 
        onClose={handleClose} 
        maxWidth="md" 
        fullWidth
        TransitionComponent={Fade}
        transitionDuration={400}
      >
        <StyledDialogTitle>
          <EventIcon />
          {editingEvent ? 'Edit Event' : 'Add New Event'}
        </StyledDialogTitle>
        <StyledDialogContent>
          <Fade in={open} timeout={600} style={{ transitionDelay: '200ms' }}>
            <Box>
              <FormSection>
                <SectionTitle>
                  <EventIcon sx={{ fontSize: 20 }} />
                  Event Information
                </SectionTitle>
                <Grid container spacing={3}>
                  <Grid item xs={12}>
                    <StyledTextField
                      fullWidth
                      label="Event Name"
                      name="name"
                      value={formData.name}
                      onChange={handleInputChange}
                      placeholder="Enter event name"
                    />
                  </Grid>
                  <Grid item xs={12}>
                    <StyledTextField
                      fullWidth
                      label="Event Description"
                      name="notes"
                      value={formData.notes}
                      onChange={handleInputChange}
                      multiline
                      rows={3}
                      placeholder="Enter event description"
                    />
                  </Grid>
                </Grid>
              </FormSection>

              <FormSection>
                <SectionTitle>
                  <LocationOn sx={{ fontSize: 20 }} />
                  Location & Organization
                </SectionTitle>
                <Grid container spacing={3}>
                  <Grid item xs={12} md={6}>
                    <StyledFormControl fullWidth>
                      <InputLabel>Mosque Location</InputLabel>
                      <Select
                        name="mosqueId"
                        value={formData.mosqueId}
                        onChange={handleInputChange}
                        label="Mosque Location"
                      >
                        {mosques.map((mosque) => (
                          <MenuItem key={mosque.id} value={mosque.id}>
                            {mosque.name}
                          </MenuItem>
                        ))}
                      </Select>
                    </StyledFormControl>
                  </Grid>
                  <Grid item xs={12} md={6}>
                    <StyledFormControl fullWidth>
                      <InputLabel>Organizing Organization</InputLabel>
                      <Select
                        name="organizationId"
                        value={formData.organizationId}
                        onChange={handleInputChange}
                        label="Organizing Organization"
                      >
                        {organizations.map((org) => (
                          <MenuItem key={org.id} value={org.id}>
                            {org.name}
                          </MenuItem>
                        ))}
                      </Select>
                    </StyledFormControl>
                  </Grid>
                </Grid>
              </FormSection>

              <FormSection>
                <SectionTitle>
                  <EventIcon sx={{ fontSize: 20 }} />
                  Event Details
                </SectionTitle>
                <Grid container spacing={3}>
                  <Grid item xs={12} md={6}>
                    <StyledFormControl fullWidth>
                      <InputLabel>Event Type</InputLabel>
                      <Select
                        name="type"
                        value={formData.type}
                        onChange={handleInputChange}
                        label="Event Type"
                      >
                        <MenuItem value="Online">Online</MenuItem>
                        <MenuItem value="Physical">Physical</MenuItem>
                        <MenuItem value="Hybrid">Hybrid</MenuItem>
                      </Select>
                    </StyledFormControl>
                  </Grid>
                  <Grid item xs={12} md={6}>
                    <StyledFormControl fullWidth>
                      <InputLabel>Category</InputLabel>
                      <Select
                        name="categoryId"
                        value={formData.categoryId}
                        onChange={handleInputChange}
                        label="Category"
                      >
                        {categories.map((category) => (
                          <MenuItem key={category.id} value={category.id}>
                            {category.name}
                          </MenuItem>
                        ))}
                      </Select>
                    </StyledFormControl>
                  </Grid>
                </Grid>
              </FormSection>

              <FormSection>
                <SectionTitle>
                  <AccessTime sx={{ fontSize: 20 }} />
                  Schedule
                </SectionTitle>
                <Grid container spacing={3}>
                  <Grid item xs={12} md={4}>
                    <StyledTextField
                      fullWidth
                      label="Event Date"
                      name="date"
                      type="date"
                      value={formData.date}
                      onChange={handleInputChange}
                      InputLabelProps={{
                        shrink: true,
                      }}
                    />
                  </Grid>
                  <Grid item xs={12} md={4}>
                    <StyledTextField
                      fullWidth
                      label="Start Time"
                      name="startTime"
                      type="time"
                      value={formData.startTime}
                      onChange={handleInputChange}
                      InputLabelProps={{
                        shrink: true,
                      }}
                    />
                  </Grid>
                  <Grid item xs={12} md={4}>
                    <StyledTextField
                      fullWidth
                      label="End Time"
                      name="endTime"
                      type="time"
                      value={formData.endTime}
                      onChange={handleInputChange}
                      InputLabelProps={{
                        shrink: true,
                      }}
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
            startIcon={editingEvent ? <Edit /> : <Add />}
          >
            {editingEvent ? 'Update Event' : 'Create Event'}
          </DialogActionButton>
        </StyledDialogActions>
      </StyledDialog>

      {/* Attendance Management Dialog */}
      <Dialog open={attendanceOpen} onClose={handleAttendanceClose} maxWidth="sm" fullWidth>
        <DialogTitle sx={{ backgroundColor: '#00695c', color: 'white' }}>
          Manage Attendance
        </DialogTitle>
        <DialogContent>
          <List>
            {users.map((user) => (
              <ListItem key={user.id} dense>
                <Checkbox
                  checked={formData.attendanceList.includes(user.id)}
                  onChange={() => handleAttendanceToggle(user.id)}
                  sx={{ color: '#00695c' }}
                />
                <ListItemText 
                  primary={user.name}
                  secondary={user.email}
                />
              </ListItem>
            ))}
          </List>
        </DialogContent>
        <DialogActions>
          <Button onClick={handleAttendanceClose}>Done</Button>
        </DialogActions>
      </Dialog>

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

export default Events;
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
