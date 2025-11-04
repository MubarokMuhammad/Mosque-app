import React, { useState, useEffect } from 'react';
import {
  Grid,
  Card,
  CardContent,
  Typography,
  Box,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Paper,
  Avatar,
  Chip,
  Fade,
  Grow
} from '@mui/material';
import {
  People,
  Business,
  Event,
  Group,
  TrendingUp,
  CalendarToday,
  LocationOn
} from '@mui/icons-material';
import { PieChart, Pie, Cell, BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, LineChart, Line } from 'recharts';
import { styled } from '@mui/material/styles';
import { collection, onSnapshot, query, orderBy } from 'firebase/firestore';
import { db } from '../firebase';

const DashboardContainer = styled(Box)(({ theme }) => ({
  padding: 0,
  background: 'linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%)',
  minHeight: '100vh',
  position: 'relative',
  width: '100%'
}));

const StyledCard = styled(Card)(({ theme }) => ({
  height: '180px',
  minHeight: '180px',
  display: 'flex',
  flexDirection: 'column',
  background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
  color: 'white',
  borderRadius: '20px',
  border: 'none',
  boxShadow: '0 10px 30px rgba(0, 0, 0, 0.1)',
  transition: 'all 0.3s cubic-bezier(0.4, 0, 0.2, 1)',
  overflow: 'hidden',
  position: 'relative',
  '&::before': {
    content: '""',
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    background: 'linear-gradient(135deg, rgba(255, 255, 255, 0.1) 0%, rgba(255, 255, 255, 0.05) 100%)',
    zIndex: 1
  },
  '&:hover': {
    transform: 'translateY(-8px) scale(1.02)',
    boxShadow: '0 20px 40px rgba(0, 0, 0, 0.15)',
  },
}));

const StatCardContent = styled(CardContent)(({ theme }) => ({
  position: 'relative',
  zIndex: 2,
  padding: theme.spacing(3),
  flex: 1,
  display: 'flex',
  flexDirection: 'column',
  justifyContent: 'space-between',
  '&:last-child': {
    paddingBottom: theme.spacing(3),
  }
}));

const ChartCard = styled(Card)(({ theme }) => ({
  borderRadius: '20px',
  boxShadow: '0 10px 30px rgba(0, 0, 0, 0.08)',
  border: '1px solid rgba(255, 255, 255, 0.2)',
  background: 'rgba(255, 255, 255, 0.95)',
  backdropFilter: 'blur(20px)',
  transition: 'all 0.3s ease-in-out',
  '&:hover': {
    transform: 'translateY(-5px)',
    boxShadow: '0 15px 35px rgba(0, 0, 0, 0.12)',
  }
}));

const TableCard = styled(Card)(({ theme }) => ({
  borderRadius: '20px',
  boxShadow: '0 10px 30px rgba(0, 0, 0, 0.08)',
  border: '1px solid rgba(255, 255, 255, 0.2)',
  background: 'rgba(255, 255, 255, 0.95)',
  backdropFilter: 'blur(20px)',
  overflow: 'hidden'
}));

const StyledTableHead = styled(TableHead)(({ theme }) => ({
  background: 'linear-gradient(135deg, #00695c 0%, #00897b 100%)',
  '& .MuiTableCell-head': {
    color: 'white',
    fontWeight: 700,
    fontSize: '0.95rem',
    textTransform: 'uppercase',
    letterSpacing: '0.5px'
  }
}));

const StyledTableRow = styled(TableRow)(({ theme }) => ({
  transition: 'all 0.2s ease-in-out',
  '&:hover': {
    backgroundColor: 'rgba(0, 105, 92, 0.04)',
    transform: 'scale(1.01)',
  },
  '&:nth-of-type(even)': {
    backgroundColor: 'rgba(0, 0, 0, 0.02)',
  }
}));

const StatCard = ({ title, value, icon, color, gradient, delay = 0 }) => (
  <Grow in={true} timeout={800} style={{ transitionDelay: `${delay}ms` }}>
    <StyledCard sx={{ background: gradient }}>
      <StatCardContent>
        <Box display="flex" alignItems="center" justifyContent="space-between">
          <Box sx={{ flex: 1 }}>
            <Typography variant="h2" component="div" fontWeight="800" sx={{ mb: 1, fontSize: '2.5rem' }}>
              {value}
            </Typography>
            <Typography variant="h6" sx={{ opacity: 0.9, fontWeight: 500 }}>
              {title}
            </Typography>
          </Box>
          <Avatar 
            sx={{ 
              width: 80, 
              height: 80, 
              backgroundColor: 'rgba(255, 255, 255, 0.2)',
              backdropFilter: 'blur(10px)'
            }}
          >
            <Box sx={{ fontSize: 40 }}>
              {icon}
            </Box>
          </Avatar>
        </Box>
        <Box sx={{ mt: 2, display: 'flex', alignItems: 'center' }}>
          <TrendingUp sx={{ mr: 1, fontSize: 24 }} />
          <Typography variant="body1" sx={{ opacity: 0.8, fontWeight: 500 }}>
            +12% from last month
          </Typography>
        </Box>
      </StatCardContent>
    </StyledCard>
  </Grow>
);

const Dashboard = () => {
  const [stats, setStats] = useState({
    totalUsers: 0,
    totalMosques: 0,
    totalEvents: 0,
    totalCommunityUsers: 0
  });

  const [events, setEvents] = useState([]);
  const [attendCounts, setAttendCounts] = useState({});
  const [recentEvents, setRecentEvents] = useState([]);
  const [monthlyUsersData, setMonthlyUsersData] = useState([]);
  const [monthlyEventsData, setMonthlyEventsData] = useState([]);

  const toDate = (value) => {
    try {
      if (!value) return null;
      if (value instanceof Date) return value;
      if (typeof value === 'string') {
        const d = new Date(value);
        return isNaN(d.getTime()) ? null : d;
      }
      if (value?.toDate) return value.toDate();
      if (value?.seconds) return new Date(value.seconds * 1000);
      return null;
    } catch {
      return null;
    }
  };

  const normalizeEventDate = (ev) => {
    return (
      toDate(ev?.eventDate) ||
      toDate(ev?.date) ||
      toDate(ev?.startDate) ||
      toDate(ev?.createdAt) ||
      new Date(0)
    );
  };

  const computeStatus = (date) => {
    if (!date) return 'Upcoming';
    const now = new Date();
    const sameDay = date.toDateString() === now.toDateString();
    if (date < now && !sameDay) return 'Completed';
    if (sameDay) return 'Ongoing';
    return 'Upcoming';
  };

  const monthName = (idx) => ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][idx];

  const buildMonthlyData = (docs) => {
    const now = new Date();
    const buckets = [];
    for (let i = 5; i >= 0; i--) {
      const d = new Date(now.getFullYear(), now.getMonth() - i, 1);
      buckets.push({ key: `${d.getFullYear()}-${d.getMonth()}`, month: monthName(d.getMonth()), users: 0 });
    }
    docs.forEach(u => {
      const d = toDate(u.createdAt);
      if (!d) return;
      const key = `${d.getFullYear()}-${d.getMonth()}`;
      const bucket = buckets.find(b => b.key === key);
      if (bucket) bucket.users += 1;
    });
    // compute growth vs previous
    return buckets.map((b, idx) => ({
      month: b.month,
      users: b.users,
      growth: idx === 0 ? 0 : (b.users - buckets[idx - 1].users)
    }));
  };

  const computeEventsDistribution = (evs) => {
    const categories = {
      'Prayer Events': { match: ['prayer','salat','shalat','jummah','jumat'], color: '#00695c', value: 0 },
      'Educational': { match: ['education','study','class','quran','lecture','talim'], color: '#00897b', value: 0 },
      'Community': { match: ['community','meeting','social','gathering'], color: '#26a69a', value: 0 },
      'Charity': { match: ['charity','donation','fundraiser','zakat','sadaqah'], color: '#4db6ac', value: 0 },
      'Others': { match: [], color: '#80cbc4', value: 0 }
    };
    evs.forEach(e => {
      const raw = String(e.category || e.type || '').toLowerCase();
      let placed = false;
      Object.keys(categories).forEach(label => {
        if (!placed && categories[label].match.some(m => raw.includes(m))) {
          categories[label].value += 1; placed = true;
        }
      });
      if (!placed) categories['Others'].value += 1;
    });
    return Object.entries(categories).map(([name, obj]) => ({ name, value: obj.value, color: obj.color }));
  };

  useEffect(() => {
    // Users
    const unsubUsers = onSnapshot(collection(db, 'mosqueapp_users'), (snap) => {
      const users = snap.docs.map(d => ({ id: d.id, ...d.data() }));
      const communityCount = users.filter(u => {
        const role = String(u.role || u.userRole || u.type || '').toLowerCase();
        return role.includes('community') || role.includes('member') || u.isCommunity === true;
      }).length;
      setStats(prev => ({
        ...prev,
        totalUsers: users.length,
        totalCommunityUsers: communityCount
      }));
      setMonthlyUsersData(buildMonthlyData(users));
    });

    // Organizations (assumed as mosques count per request)
    const unsubOrgs = onSnapshot(collection(db, 'mosqueapp_organizations'), (snap) => {
      const orgs = snap.docs.map(d => ({ id: d.id, ...d.data() }));
      setStats(prev => ({ ...prev, totalMosques: orgs.length }));
    });

    // Events
    const unsubEvents = onSnapshot(query(collection(db, 'mosqueapp_events'), orderBy('createdAt', 'desc')), (snap) => {
      const evs = snap.docs.map(d => ({ id: d.id, ...d.data() }));
      setStats(prev => ({ ...prev, totalEvents: evs.length }));
      setEvents(evs);
      setMonthlyEventsData(computeEventsDistribution(evs));
    });

    // Attendance
    const unsubAttend = onSnapshot(collection(db, 'mosqueapp_events_attend'), (snap) => {
      const counts = {};
      snap.docs.forEach(d => {
        const a = d.data();
        const eventId = a.eventId || a.eventID || a.event?.id;
        if (!eventId) return;
        counts[eventId] = (counts[eventId] || 0) + 1;
      });
      setAttendCounts(counts);
    });

    return () => {
      unsubUsers();
      unsubOrgs();
      unsubEvents();
      unsubAttend();
    };
  }, []);

  useEffect(() => {
    // Build recent events list when events or attendance counts change
    const sorted = [...events].sort((a, b) => normalizeEventDate(b) - normalizeEventDate(a));
    const list = sorted.slice(0, 5).map(ev => {
      const d = normalizeEventDate(ev);
      return {
        id: ev.id,
        name: ev.title || ev.name || 'Event',
        mosque: ev.mosqueName || ev.organization?.organizationName || ev.organizationName || ev.location || 'Unknown',
        date: d ? d.toISOString().split('T')[0] : '',
        attendees: attendCounts[ev.id] || 0,
        status: ev.status || computeStatus(d)
      };
    });
    setRecentEvents(list);
  }, [events, attendCounts]);

  const getStatusColor = (status) => {
    switch (status) {
      case 'Completed': return '#4caf50';
      case 'Ongoing': return '#ff9800';
      case 'Upcoming': return '#2196f3';
      default: return '#757575';
    }
  };

  return (
    <DashboardContainer>
      <Fade in={true} timeout={600}>
        <Typography 
          variant="h3" 
          gutterBottom 
          sx={{ 
            background: 'linear-gradient(135deg, #00695c 0%, #00897b 100%)',
            backgroundClip: 'text',
            WebkitBackgroundClip: 'text',
            WebkitTextFillColor: 'transparent',
            fontWeight: 800, 
            mb: 4,
            textAlign: 'center',
            px: 1,
            pt: 2
          }}
        >
          Dashboard Overview
        </Typography>
      </Fade>

      {/* Statistics Cards */}
      <Box sx={{ width: '100%', px: 0, mb: 3, display: 'flex' }}>
        <Box sx={{ width: '25%', pr: 3 }}>
          <StatCard
            title="Total Users"
            value={stats.totalUsers.toLocaleString()}
            icon={<People />}
            gradient="linear-gradient(135deg, #667eea 0%, #764ba2 100%)"
            delay={0}
          />
        </Box>
        <Box sx={{ width: '25%', px: 3 }}>
          <StatCard
            title="Total Mosques"
            value={stats.totalMosques}
            icon={<Business />}
            gradient="linear-gradient(135deg, #f093fb 0%, #f5576c 100%)"
            delay={100}
          />
        </Box>
        <Box sx={{ width: '25%', px: 3 }}>
          <StatCard
            title="Total Events"
            value={stats.totalEvents}
            icon={<Event />}
            gradient="linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)"
            delay={200}
          />
        </Box>
        <Box sx={{ width: '25%', pl: 3 }}>
          <StatCard
            title="Community Users"
            value={stats.totalCommunityUsers.toLocaleString()}
            icon={<Group />}
            gradient="linear-gradient(135deg, #43e97b 0%, #38f9d7 100%)"
            delay={300}
          />
        </Box>
      </Box>

      {/* Charts */}
      <Box sx={{ width: '100%', px: 0, mb: 3, display: 'flex', gap: 7 }}>
        <Box sx={{ width: '50%' }}>
          <Fade in={true} timeout={800} style={{ transitionDelay: '400ms' }}>
            <ChartCard sx={{ height: 450 }}>
              <CardContent sx={{ p: 2 }}>
                <Box display="flex" alignItems="center" mb={3}>
                  <Avatar sx={{ bgcolor: '#00695c', mr: 2 }}>
                    <CalendarToday />
                  </Avatar>
                  <Typography variant="h5" sx={{ color: '#00695c', fontWeight: 700 }}>
                    Events Distribution
                  </Typography>
                </Box>
                <ResponsiveContainer width="100%" height={320}>
                  <PieChart>
                    <Pie
                      data={monthlyEventsData}
                      cx="50%"
                      cy="50%"
                      labelLine={false}
                      label={({ name, percent }) => `${name} ${(percent * 100).toFixed(0)}%`}
                      outerRadius={100}
                      fill="#8884d8"
                      dataKey="value"
                    >
                      {monthlyEventsData.map((entry, index) => (
                        <Cell key={`cell-${index}`} fill={entry.color} />
                      ))}
                    </Pie>
                    <Tooltip 
                      contentStyle={{
                        backgroundColor: 'rgba(255, 255, 255, 0.95)',
                        border: 'none',
                        borderRadius: '12px',
                        boxShadow: '0 8px 20px rgba(0, 0, 0, 0.1)'
                      }}
                    />
                  </PieChart>
                </ResponsiveContainer>
              </CardContent>
            </ChartCard>
          </Fade>
        </Box>
        
        <Box sx={{ width: '50%' }}>
          <Fade in={true} timeout={800} style={{ transitionDelay: '500ms' }}>
            <ChartCard sx={{ height: 450 }}>
              <CardContent sx={{ p: 2 }}>
                <Box display="flex" alignItems="center" mb={3}>
                  <Avatar sx={{ bgcolor: '#00695c', mr: 2 }}>
                    <TrendingUp />
                  </Avatar>
                  <Typography variant="h5" sx={{ color: '#00695c', fontWeight: 700 }}>
                    User Growth Trend
                  </Typography>
                </Box>
                <ResponsiveContainer width="100%" height={320}>
                  <LineChart data={monthlyUsersData}>
                    <CartesianGrid strokeDasharray="3 3" stroke="rgba(0, 0, 0, 0.1)" />
                    <XAxis 
                      dataKey="month" 
                      axisLine={false}
                      tickLine={false}
                      tick={{ fill: '#666', fontSize: 12 }}
                    />
                    <YAxis 
                      axisLine={false}
                      tickLine={false}
                      tick={{ fill: '#666', fontSize: 12 }}
                    />
                    <Tooltip 
                      contentStyle={{
                        backgroundColor: 'rgba(255, 255, 255, 0.95)',
                        border: 'none',
                        borderRadius: '12px',
                        boxShadow: '0 8px 20px rgba(0, 0, 0, 0.1)'
                      }}
                    />
                    <Line 
                      type="monotone" 
                      dataKey="users" 
                      stroke="#00695c" 
                      strokeWidth={3}
                      dot={{ fill: '#00695c', strokeWidth: 2, r: 6 }}
                      activeDot={{ r: 8, stroke: '#00695c', strokeWidth: 2 }}
                    />
                  </LineChart>
                </ResponsiveContainer>
              </CardContent>
            </ChartCard>
          </Fade>
        </Box>
      </Box>

      {/* Recent Events Table */}
      <Box sx={{ px: 1, mb: 3 }}>
        <Fade in={true} timeout={800} style={{ transitionDelay: '600ms' }}>
          <TableCard>
          <CardContent sx={{ p: 0 }}>
            <Box sx={{ p: 2, pb: 1 }}>
              <Box display="flex" alignItems="center">
                <Avatar sx={{ bgcolor: '#00695c', mr: 2 }}>
                  <LocationOn />
                </Avatar>
                <Typography variant="h5" sx={{ color: '#00695c', fontWeight: 700 }}>
                  Recent Events
                </Typography>
              </Box>
            </Box>
            <TableContainer>
              <Table>
                <StyledTableHead>
                  <TableRow>
                    <TableCell>Event Name</TableCell>
                    <TableCell>Mosque Location</TableCell>
                    <TableCell>Date</TableCell>
                    <TableCell>Attendees</TableCell>
                    <TableCell>Status</TableCell>
                  </TableRow>
                </StyledTableHead>
                <TableBody>
                  {recentEvents.map((event) => (
                    <StyledTableRow key={event.id}>
                      <TableCell>
                        <Typography variant="body1" fontWeight={600}>
                          {event.name}
                        </Typography>
                      </TableCell>
                      <TableCell>
                        <Box display="flex" alignItems="center">
                          <LocationOn sx={{ mr: 1, color: '#00695c', fontSize: 18 }} />
                          {event.mosque}
                        </Box>
                      </TableCell>
                      <TableCell>
                        <Box display="flex" alignItems="center">
                          <CalendarToday sx={{ mr: 1, color: '#666', fontSize: 16 }} />
                          {event.date ? new Date(event.date).toLocaleDateString() : ''}
                        </Box>
                      </TableCell>
                      <TableCell>
                        <Typography variant="body2" fontWeight={600}>
                          {event.attendees} people
                        </Typography>
                      </TableCell>
                      <TableCell>
                        <Chip
                          label={event.status}
                          size="small"
                          sx={{
                            backgroundColor: getStatusColor(event.status),
                            color: 'white',
                            fontWeight: 600,
                            borderRadius: '8px'
                          }}
                        />
                      </TableCell>
                    </StyledTableRow>
                  ))}
                </TableBody>
              </Table>
            </TableContainer>
          </CardContent>
        </TableCard>
      </Fade>
      </Box>
    </DashboardContainer>
  );
};

export default Dashboard;