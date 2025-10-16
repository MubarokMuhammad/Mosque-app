import React, { useState, useEffect, useMemo, useCallback } from 'react';
import {
  Box,
  Paper,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Typography,
  Card,
  CardContent,
  Grid,
  Chip,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  TextField,
  Button,
  Accordion,
  AccordionSummary,
  AccordionDetails,
  List,
  ListItem,
  ListItemText,
  Divider,
  Avatar,
  Fade,
  Grow,
  Slide,
  Zoom
} from '@mui/material';
import { 
  ExpandMore, 
  Event, 
  People, 
  ThumbUp, 
  LocationOn, 
  Business,
  Category,
  AccessTime,
  Person,
  Email,
  Phone,
  Assessment
} from '@mui/icons-material';
import { styled } from '@mui/material/styles';
import { eventService, mosqueService, organizationService, categoryService, userService } from '../services/firebaseService';
import SearchFilterSort from '../components/SearchFilterSort';

const HeaderCard = styled(Card)(({ theme }) => ({
  background: 'linear-gradient(135deg, #00695c 0%, #00897b 100%)',
  color: 'white',
  borderRadius: '16px',
  boxShadow: '0 8px 32px rgba(0, 105, 92, 0.3)',
  marginBottom: theme.spacing(3)
}));

const StyledCard = styled(Card)(({ theme }) => ({
  borderRadius: '16px',
  boxShadow: '0 4px 20px rgba(0, 105, 92, 0.1)',
  border: '1px solid rgba(0, 105, 92, 0.08)',
  transition: 'all 0.3s cubic-bezier(0.4, 0, 0.2, 1)',
  '&:hover': {
    transform: 'translateY(-4px)',
    boxShadow: '0 8px 32px rgba(0, 105, 92, 0.2)',
    borderColor: 'rgba(0, 105, 92, 0.2)'
  }
}));

const StyledAccordion = styled(Accordion)(({ theme }) => ({
  borderRadius: '12px !important',
  boxShadow: '0 2px 12px rgba(0, 105, 92, 0.08)',
  border: '1px solid rgba(0, 105, 92, 0.08)',
  marginBottom: theme.spacing(2),
  '&:before': {
    display: 'none'
  },
  '&.Mui-expanded': {
    margin: `0 0 ${theme.spacing(2)}px 0`,
    boxShadow: '0 4px 20px rgba(0, 105, 92, 0.15)'
  }
}));

const StyledAccordionSummary = styled(AccordionSummary)(({ theme }) => ({
  backgroundColor: 'rgba(0, 105, 92, 0.04)',
  borderRadius: '12px',
  minHeight: '64px',
  '&.Mui-expanded': {
    borderBottomLeftRadius: 0,
    borderBottomRightRadius: 0
  },
  '& .MuiAccordionSummary-content': {
    alignItems: 'center'
  }
}));

const FilterCard = styled(Card)(({ theme }) => ({
  borderRadius: '16px',
  boxShadow: '0 4px 20px rgba(0, 105, 92, 0.08)',
  border: '1px solid rgba(0, 105, 92, 0.08)',
  marginBottom: theme.spacing(3),
  background: 'linear-gradient(135deg, #ffffff 0%, #f8f9fa 100%)'
}));

const Reports = () => {
  const [events, setEvents] = useState([]);
  const [mosques, setMosques] = useState([]);
  const [organizations, setOrganizations] = useState([]);
  const [categories, setCategories] = useState([]);
  const [users, setUsers] = useState([]);
  const [filteredEvents, setFilteredEvents] = useState([]);
  const [filters, setFilters] = useState({
    mosqueId: '',
    organizationId: '',
    categoryId: '',
    dateFrom: '',
    dateTo: ''
  });

  // Search, filter, and sort state for SearchFilterSort component
  const [searchValue, setSearchValue] = useState('');
  const [sortBy, setSortBy] = useState('');
  const [sortOrder, setSortOrder] = useState('asc');
  const [additionalFilters, setAdditionalFilters] = useState({
    type: '',
    status: ''
  });

  const applyFilters = useCallback(() => {
    let filtered = [...events];

    if (filters.mosqueId) {
      filtered = filtered.filter(event => event.mosqueId === filters.mosqueId);
    }

    if (filters.organizationId) {
      filtered = filtered.filter(event => event.organizationId === filters.organizationId);
    }

    if (filters.categoryId) {
      filtered = filtered.filter(event => event.categoryId === filters.categoryId);
    }

    if (filters.dateFrom) {
      filtered = filtered.filter(event => new Date(event.date) >= new Date(filters.dateFrom));
    }

    if (filters.dateTo) {
      filtered = filtered.filter(event => new Date(event.date) <= new Date(filters.dateTo));
    }

    // Sort by date (newest first)
    filtered.sort((a, b) => new Date(b.date) - new Date(a.date));

    setFilteredEvents(filtered);
  }, [events, filters]);

  useEffect(() => {
    fetchAllData();
  }, []);

  useEffect(() => {
    applyFilters();
  }, [events, filters, applyFilters]);

  const fetchAllData = async () => {
    try {
      const [eventsData, mosquesData, organizationsData, categoriesData, usersData] = await Promise.all([
        eventService.getAll(),
        mosqueService.getAll(),
        organizationService.getAll(),
        categoryService.getAll(),
        userService.getAll()
      ]);

      setEvents(eventsData);
      setMosques(mosquesData);
      setOrganizations(organizationsData);
      setCategories(categoriesData);
      setUsers(usersData);
    } catch (error) {
      console.error('Error fetching data:', error);
    }
  };

  const handleFilterChange = (e) => {
    const { name, value } = e.target;
    setFilters(prev => ({
      ...prev,
      [name]: value
    }));
  };

  const clearFilters = () => {
    setFilters({
      mosqueId: '',
      organizationId: '',
      categoryId: '',
      dateFrom: '',
      dateTo: ''
    });
  };

  const getMosqueName = (mosqueId) => {
    const mosque = mosques.find(m => m.id === mosqueId);
    return mosque ? mosque.name : 'Unknown Mosque';
  };

  const getMosqueDetails = (mosqueId) => {
    return mosques.find(m => m.id === mosqueId);
  };

  const getOrganizationName = (organizationId) => {
    const organization = organizations.find(o => o.id === organizationId);
    return organization ? organization.name : 'Unknown Organization';
  };

  const getOrganizationDetails = (organizationId) => {
    return organizations.find(o => o.id === organizationId);
  };

  const getCategoryName = (categoryId) => {
    const category = categories.find(c => c.id === categoryId);
    return category ? category.name : 'Unknown Category';
  };

  const getUserDetails = (userId) => {
    return users.find(u => u.id === userId);
  };

  const formatDate = (dateString) => {
    if (!dateString) return '';
    return new Date(dateString).toLocaleDateString('en-US', {
      weekday: 'long',
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    });
  };

  const formatTime = (timeString) => {
    if (!timeString) return '';
    return timeString;
  };

  const getTotalAttendance = () => {
    return filteredEvents.reduce((total, event) => {
      return total + (event.attendanceList ? event.attendanceList.length : 0);
    }, 0);
  };

  const getTotalLikes = () => {
    // Simulate likes data (in real app, this would come from Firebase)
    return filteredEvents.reduce((total, event) => {
      return total + Math.floor(Math.random() * 50) + 10; // Random likes for demo
    }, 0);
  };

  const getEventLikes = (eventId) => {
    // Simulate likes for individual events
    return Math.floor(Math.random() * 50) + 10;
  };

  // Enhanced filter and sort for SearchFilterSort component
  const finalFilteredAndSortedEvents = useMemo(() => {
    let filtered = [...filteredEvents]; // Start with existing filtered events

    // Apply search filter
    if (searchValue) {
      filtered = filtered.filter(event => 
        event.name?.toLowerCase().includes(searchValue.toLowerCase()) ||
        event.notes?.toLowerCase().includes(searchValue.toLowerCase()) ||
        getMosqueName(event.mosqueId)?.toLowerCase().includes(searchValue.toLowerCase()) ||
        getOrganizationName(event.organizationId)?.toLowerCase().includes(searchValue.toLowerCase()) ||
        getCategoryName(event.categoryId)?.toLowerCase().includes(searchValue.toLowerCase())
      );
    }

    // Apply additional filters
    if (additionalFilters.type) {
      filtered = filtered.filter(event => event.type === additionalFilters.type);
    }

    if (additionalFilters.status) {
      const now = new Date();
      filtered = filtered.filter(event => {
        const eventDate = new Date(event.date);
        if (additionalFilters.status === 'upcoming') {
          return eventDate > now;
        } else if (additionalFilters.status === 'past') {
          return eventDate < now;
        } else if (additionalFilters.status === 'today') {
          return eventDate.toDateString() === now.toDateString();
        }
        return true;
      });
    }

    // Apply sorting
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
        } else if (sortBy === 'organizationName') {
          aValue = getOrganizationName(a.organizationId) || '';
          bValue = getOrganizationName(b.organizationId) || '';
        } else if (sortBy === 'attendance') {
          aValue = a.attendanceList ? a.attendanceList.length : 0;
          bValue = b.attendanceList ? b.attendanceList.length : 0;
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
  }, [filteredEvents, searchValue, sortBy, sortOrder, additionalFilters, mosques, categories, organizations, getCategoryName, getMosqueName, getOrganizationName]);

  // Get unique values for filter options
  const filterOptions = useMemo(() => {
    const uniqueTypes = [...new Set(events.map(event => event.type).filter(Boolean))];
    
    return {
      type: {
        label: 'Event Type',
        values: uniqueTypes.map(type => ({ value: type, label: type }))
      },
      status: {
        label: 'Event Status',
        values: [
          { value: 'upcoming', label: 'Upcoming' },
          { value: 'past', label: 'Past' },
          { value: 'today', label: 'Today' }
        ]
      }
    };
  }, [events]);

  const sortOptions = [
    { value: 'name', label: 'Event Name' },
    { value: 'date', label: 'Date' },
    { value: 'startTime', label: 'Start Time' },
    { value: 'type', label: 'Type' },
    { value: 'mosqueName', label: 'Mosque' },
    { value: 'categoryName', label: 'Category' },
    { value: 'organizationName', label: 'Organization' },
    { value: 'attendance', label: 'Attendance' }
  ];

  return (
    <Fade in timeout={800}>
      <Box sx={{ p: 3 }}>
        <HeaderCard>
          <CardContent sx={{ p: 3 }}>
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
              <Avatar sx={{ backgroundColor: 'rgba(255, 255, 255, 0.2)', width: 56, height: 56 }}>
                <Assessment sx={{ fontSize: 28 }} />
              </Avatar>
              <Box>
                <Typography variant="h4" component="h1" sx={{ fontWeight: 700, mb: 1 }}>
                  Event Reports & Analytics
                </Typography>
                <Typography variant="body1" sx={{ opacity: 0.9 }}>
                  Comprehensive insights and statistics for mosque events
                </Typography>
              </Box>
            </Box>
          </CardContent>
        </HeaderCard>

        {/* Summary Cards */}
        <Grid container spacing={3} sx={{ mb: 4 }}>
          <Grid item xs={12} md={3}>
            <Zoom in timeout={600} style={{ transitionDelay: '100ms' }}>
              <StyledCard sx={{ backgroundColor: '#e0f2f1' }}>
                <CardContent>
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                    <Avatar sx={{ backgroundColor: '#00695c', width: 48, height: 48 }}>
                      <Event sx={{ fontSize: 24 }} />
                    </Avatar>
                    <Box>
                      <Typography variant="h4" sx={{ color: '#00695c', fontWeight: 'bold' }}>
                        {filteredEvents.length}
                      </Typography>
                      <Typography variant="body2" color="text.secondary">
                        Total Events
                      </Typography>
                    </Box>
                  </Box>
                </CardContent>
              </StyledCard>
            </Zoom>
          </Grid>
          <Grid item xs={12} md={3}>
            <Zoom in timeout={600} style={{ transitionDelay: '200ms' }}>
              <StyledCard sx={{ backgroundColor: '#e3f2fd' }}>
                <CardContent>
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                    <Avatar sx={{ backgroundColor: '#1976d2', width: 48, height: 48 }}>
                      <People sx={{ fontSize: 24 }} />
                    </Avatar>
                    <Box>
                      <Typography variant="h4" sx={{ color: '#1976d2', fontWeight: 'bold' }}>
                        {getTotalAttendance()}
                      </Typography>
                      <Typography variant="body2" color="text.secondary">
                        Total Attendance
                      </Typography>
                    </Box>
                  </Box>
                </CardContent>
              </StyledCard>
            </Zoom>
          </Grid>
          <Grid item xs={12} md={3}>
            <Zoom in timeout={600} style={{ transitionDelay: '300ms' }}>
              <StyledCard sx={{ backgroundColor: '#fce4ec' }}>
                <CardContent>
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                    <Avatar sx={{ backgroundColor: '#e91e63', width: 48, height: 48 }}>
                      <ThumbUp sx={{ fontSize: 24 }} />
                    </Avatar>
                    <Box>
                      <Typography variant="h4" sx={{ color: '#e91e63', fontWeight: 'bold' }}>
                        {getTotalLikes()}
                      </Typography>
                      <Typography variant="body2" color="text.secondary">
                        Total Likes
                      </Typography>
                    </Box>
                  </Box>
                </CardContent>
              </StyledCard>
            </Zoom>
          </Grid>
          <Grid item xs={12} md={3}>
            <Zoom in timeout={600} style={{ transitionDelay: '400ms' }}>
              <StyledCard sx={{ backgroundColor: '#fff3e0' }}>
                <CardContent>
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                    <Avatar sx={{ backgroundColor: '#ff9800', width: 48, height: 48 }}>
                      <LocationOn sx={{ fontSize: 24 }} />
                    </Avatar>
                    <Box>
                      <Typography variant="h4" sx={{ color: '#ff9800', fontWeight: 'bold' }}>
                        {mosques.length}
                      </Typography>
                      <Typography variant="body2" color="text.secondary">
                        Active Mosques
                      </Typography>
                    </Box>
                  </Box>
                </CardContent>
              </StyledCard>
            </Zoom>
          </Grid>
        </Grid>

        {/* Filters */}
        <Slide in timeout={800} direction="up">
          <FilterCard>
            <CardContent sx={{ p: 3 }}>
              <Typography variant="h6" sx={{ color: '#00695c', mb: 2, fontWeight: 600 }}>
                Filter Events
              </Typography>
        <Grid container spacing={2}>
          <Grid item xs={12} md={2.4}>
            <FormControl fullWidth>
              <InputLabel>Mosque</InputLabel>
              <Select
                name="mosqueId"
                value={filters.mosqueId}
                onChange={handleFilterChange}
                label="Mosque"
              >
                <MenuItem value="">All Mosques</MenuItem>
                {mosques.map((mosque) => (
                  <MenuItem key={mosque.id} value={mosque.id}>
                    {mosque.name}
                  </MenuItem>
                ))}
              </Select>
            </FormControl>
          </Grid>
          <Grid item xs={12} md={2.4}>
            <FormControl fullWidth>
              <InputLabel>Organization</InputLabel>
              <Select
                name="organizationId"
                value={filters.organizationId}
                onChange={handleFilterChange}
                label="Organization"
              >
                <MenuItem value="">All Organizations</MenuItem>
                {organizations.map((org) => (
                  <MenuItem key={org.id} value={org.id}>
                    {org.name}
                  </MenuItem>
                ))}
              </Select>
            </FormControl>
          </Grid>
          <Grid item xs={12} md={2.4}>
            <FormControl fullWidth>
              <InputLabel>Category</InputLabel>
              <Select
                name="categoryId"
                value={filters.categoryId}
                onChange={handleFilterChange}
                label="Category"
              >
                <MenuItem value="">All Categories</MenuItem>
                {categories.map((category) => (
                  <MenuItem key={category.id} value={category.id}>
                    {category.name}
                  </MenuItem>
                ))}
              </Select>
            </FormControl>
          </Grid>
          <Grid item xs={12} md={2.4}>
            <TextField
              fullWidth
              label="From Date"
              name="dateFrom"
              type="date"
              value={filters.dateFrom}
              onChange={handleFilterChange}
              InputLabelProps={{ shrink: true }}
            />
          </Grid>
          <Grid item xs={12} md={2.4}>
            <TextField
              fullWidth
              label="To Date"
              name="dateTo"
              type="date"
              value={filters.dateTo}
              onChange={handleFilterChange}
              InputLabelProps={{ shrink: true }}
            />
          </Grid>
        </Grid>
        <Box sx={{ mt: 2 }}>
          <Button
            variant="outlined"
            onClick={clearFilters}
            sx={{ color: '#00695c', borderColor: '#00695c' }}
          >
            Clear Filters
          </Button>
        </Box>
            </CardContent>
          </FilterCard>
        </Slide>

        <SearchFilterSort
          searchValue={searchValue}
          onSearchChange={setSearchValue}
          sortBy={sortBy}
          sortOrder={sortOrder}
          onSortChange={setSortBy}
          onSortOrderChange={setSortOrder}
          filters={additionalFilters}
          onFiltersChange={setAdditionalFilters}
          filterOptions={filterOptions}
          sortOptions={sortOptions}
          placeholder="Search events by name, description, mosque, organization, or category..."
        />

        {/* Detailed Event List */}
        <Grow in timeout={1000}>
          <StyledCard>
            <Box sx={{ p: 2, backgroundColor: '#00695c', color: 'white', borderRadius: '16px 16px 0 0' }}>
              <Typography variant="h6" sx={{ fontWeight: 600 }}>
                Detailed Event Reports ({finalFilteredAndSortedEvents.length} events)
              </Typography>
            </Box>
            <Box sx={{ p: 2 }}>
              {finalFilteredAndSortedEvents.map((event, index) => {
                const mosque = getMosqueDetails(event.mosqueId);
                const organization = getOrganizationDetails(event.organizationId);
                const eventLikes = getEventLikes(event.id);
                
                return (
                  <Grow
                    key={event.id}
                    in={true}
                    timeout={600}
                    style={{ transitionDelay: `${index * 100}ms` }}
                  >
                    <StyledAccordion>
                      <StyledAccordionSummary expandIcon={<ExpandMore />}>
                        <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, width: '100%' }}>
                          <Event sx={{ color: '#00695c' }} />
                          <Box sx={{ flexGrow: 1 }}>
                            <Typography variant="h6" sx={{ color: '#00695c' }}>
                              {event.name}
                            </Typography>
                            <Typography variant="body2" color="text.secondary">
                              {formatDate(event.date)} • {getMosqueName(event.mosqueId)}
                            </Typography>
                          </Box>
                          <Box sx={{ display: 'flex', gap: 2 }}>
                            <Chip
                              icon={<People />}
                              label={`${event.attendanceList ? event.attendanceList.length : 0} attendees`}
                              size="small"
                              color="primary"
                            />
                            <Chip
                              icon={<ThumbUp />}
                              label={`${eventLikes} likes`}
                              size="small"
                              color="secondary"
                            />
                          </Box>
                        </Box>
                      </StyledAccordionSummary>
                      <AccordionDetails>
                  <Grid container spacing={3}>
                    {/* Event Details */}
                    <Grid item xs={12} md={6}>
                      <Typography variant="h6" sx={{ color: '#00695c', mb: 2 }}>
                        Event Details
                      </Typography>
                      <List dense>
                        <ListItem>
                          <Category sx={{ mr: 2, color: '#00695c' }} />
                          <ListItemText
                            primary="Category"
                            secondary={getCategoryName(event.categoryId)}
                          />
                        </ListItem>
                        <ListItem>
                          <Event sx={{ mr: 2, color: '#00695c' }} />
                          <ListItemText
                            primary="Type"
                            secondary={event.type}
                          />
                        </ListItem>
                        <ListItem>
                          <AccessTime sx={{ mr: 2, color: '#00695c' }} />
                          <ListItemText
                            primary="Time"
                            secondary={`${formatTime(event.startTime)} - ${formatTime(event.endTime)}`}
                          />
                        </ListItem>
                        {event.notes && (
                          <ListItem>
                            <ListItemText
                              primary="Notes"
                              secondary={event.notes}
                            />
                          </ListItem>
                        )}
                      </List>
                    </Grid>

                    {/* Location & Organization */}
                    <Grid item xs={12} md={6}>
                      <Typography variant="h6" sx={{ color: '#00695c', mb: 2 }}>
                        Location & Organization
                      </Typography>
                      <List dense>
                        <ListItem>
                          <LocationOn sx={{ mr: 2, color: '#00695c' }} />
                          <ListItemText
                            primary="Mosque"
                            secondary={mosque ? `${mosque.name} - ${mosque.address}` : 'Unknown'}
                          />
                        </ListItem>
                        <ListItem>
                          <Business sx={{ mr: 2, color: '#00695c' }} />
                          <ListItemText
                            primary="Organizing Organization"
                            secondary={organization ? `${organization.name} - ${organization.leader}` : 'Unknown'}
                          />
                        </ListItem>
                        {organization && (
                          <>
                            <ListItem>
                              <Email sx={{ mr: 2, color: '#00695c' }} />
                              <ListItemText
                                primary="Contact Email"
                                secondary={organization.email}
                              />
                            </ListItem>
                            <ListItem>
                              <Phone sx={{ mr: 2, color: '#00695c' }} />
                              <ListItemText
                                primary="Contact Phone"
                                secondary={organization.phone}
                              />
                            </ListItem>
                          </>
                        )}
                      </List>
                    </Grid>

                    {/* Attendance List */}
                    {event.attendanceList && event.attendanceList.length > 0 && (
                      <Grid item xs={12}>
                        <Divider sx={{ my: 2 }} />
                        <Typography variant="h6" sx={{ color: '#00695c', mb: 2 }}>
                          Attendance List ({event.attendanceList.length} attendees)
                        </Typography>
                        <Grid container spacing={2}>
                          {event.attendanceList.map((userId) => {
                            const user = getUserDetails(userId);
                            return user ? (
                              <Grid item xs={12} sm={6} md={4} key={userId}>
                                <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, p: 1, border: '1px solid #e0e0e0', borderRadius: 1 }}>
                                  <Avatar sx={{ bgcolor: '#00695c' }}>
                                    <Person />
                                  </Avatar>
                                  <Box>
                                    <Typography variant="body2" fontWeight="bold">
                                      {user.name}
                                    </Typography>
                                    <Typography variant="caption" color="text.secondary">
                                      {user.email}
                                    </Typography>
                                  </Box>
                                </Box>
                              </Grid>
                            ) : null;
                          })}
                        </Grid>
                      </Grid>
                    )}
                  </Grid>
                        </AccordionDetails>
                      </StyledAccordion>
                    </Grow>
                  );
                })}
                
                {filteredEvents.length === 0 && (
                  <Box sx={{ textAlign: 'center', py: 4 }}>
                    <Typography variant="h6" color="text.secondary">
                      No events found matching the selected filters.
                    </Typography>
                  </Box>
                )}
              </Box>
            </StyledCard>
          </Grow>
        </Box>
      </Fade>
    );
  };

export default Reports;