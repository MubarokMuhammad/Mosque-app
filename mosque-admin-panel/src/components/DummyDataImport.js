import React, { useState } from 'react';
import {
  Box,
  Card,
  CardContent,
  Typography,
  Button,
  Grid,
  Alert,
  LinearProgress,
  Chip,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  List,
  ListItem,
  ListItemText,
  ListItemIcon
} from '@mui/material';
import {
  CloudUpload,
  CheckCircle,
  Error,
  Info,
  Business,
  Mosque,
  Category,
  People,
  Event,
  Assessment
} from '@mui/icons-material';
import {
  dummyOrganizations,
  dummyMosques,
  dummyCategories,
  dummyUsers,
  dummyEvents,
  dummyReports
} from '../data/dummyData';
import {
  organizationService,
  mosqueService,
  categoryService,
  userService,
  eventService,
  reportService
} from '../services/firebaseService';

const DummyDataImport = () => {
  const [importing, setImporting] = useState(false);
  const [importStatus, setImportStatus] = useState({});
  const [showDialog, setShowDialog] = useState(false);
  const [importResults, setImportResults] = useState(null);

  const modules = [
    {
      name: 'Organizations',
      icon: <Business />,
      data: dummyOrganizations,
      service: organizationService,
      count: dummyOrganizations.length
    },
    {
      name: 'Mosques',
      icon: <Mosque />,
      data: dummyMosques,
      service: mosqueService,
      count: dummyMosques.length
    },
    {
      name: 'Categories',
      icon: <Category />,
      data: dummyCategories,
      service: categoryService,
      count: dummyCategories.length
    },
    {
      name: 'Users',
      icon: <People />,
      data: dummyUsers,
      service: userService,
      count: dummyUsers.length
    },
    {
      name: 'Events',
      icon: <Event />,
      data: dummyEvents,
      service: eventService,
      count: dummyEvents.length
    },
    {
      name: 'Reports',
      icon: <Assessment />,
      data: dummyReports,
      service: reportService,
      count: dummyReports.length
    }
  ];

  const handleImportAll = async () => {
    setImporting(true);
    setImportStatus({});
    const results = {
      success: [],
      failed: [],
      total: 0
    };

    try {
      for (const module of modules) {
        setImportStatus(prev => ({
          ...prev,
          [module.name]: { status: 'importing', progress: 0 }
        }));

        try {
          let successCount = 0;
          let failedCount = 0;

          for (let i = 0; i < module.data.length; i++) {
            try {
              await module.service.create(module.data[i]);
              successCount++;
            } catch (error) {
              console.error(`Error importing ${module.name} item ${i}:`, error);
              failedCount++;
            }

            const progress = ((i + 1) / module.data.length) * 100;
            setImportStatus(prev => ({
              ...prev,
              [module.name]: { status: 'importing', progress }
            }));
          }

          setImportStatus(prev => ({
            ...prev,
            [module.name]: { 
              status: failedCount === 0 ? 'success' : 'partial', 
              progress: 100,
              success: successCount,
              failed: failedCount
            }
          }));

          results.success.push({
            module: module.name,
            count: successCount,
            failed: failedCount
          });
          results.total += successCount;

        } catch (error) {
          console.error(`Error importing ${module.name}:`, error);
          setImportStatus(prev => ({
            ...prev,
            [module.name]: { status: 'error', progress: 0, error: error.message }
          }));

          results.failed.push({
            module: module.name,
            error: error.message
          });
        }
      }

      setImportResults(results);
      setShowDialog(true);

    } catch (error) {
      console.error('Import error:', error);
    } finally {
      setImporting(false);
    }
  };

  const getStatusColor = (status) => {
    switch (status) {
      case 'success': return 'success';
      case 'partial': return 'warning';
      case 'error': return 'error';
      case 'importing': return 'info';
      default: return 'default';
    }
  };

  const getStatusIcon = (status) => {
    switch (status) {
      case 'success': return <CheckCircle />;
      case 'partial': return <Info />;
      case 'error': return <Error />;
      case 'importing': return <CloudUpload />;
      default: return null;
    }
  };

  return (
    <Box sx={{ p: 3 }}>
      <Typography variant="h4" gutterBottom>
        Import Data Dummy
      </Typography>
      
      <Alert severity="info" sx={{ mb: 3 }}>
        Fitur ini akan mengimpor data dummy ke Firebase Firestore. Pastikan Anda telah mengkonfigurasi Firebase dengan benar.
      </Alert>

      <Card sx={{ mb: 3 }}>
        <CardContent>
          <Typography variant="h6" gutterBottom>
            Data yang Akan Diimpor
          </Typography>
          <Grid container spacing={2}>
            {modules.map((module) => (
              <Grid item xs={12} sm={6} md={4} key={module.name}>
                <Box
                  sx={{
                    display: 'flex',
                    alignItems: 'center',
                    p: 2,
                    border: '1px solid #e0e0e0',
                    borderRadius: 1,
                    backgroundColor: importStatus[module.name]?.status === 'success' ? '#e8f5e8' : 
                                   importStatus[module.name]?.status === 'error' ? '#ffebee' : 'transparent'
                  }}
                >
                  <Box sx={{ mr: 2, color: 'primary.main' }}>
                    {module.icon}
                  </Box>
                  <Box sx={{ flexGrow: 1 }}>
                    <Typography variant="subtitle2">
                      {module.name}
                    </Typography>
                    <Typography variant="body2" color="text.secondary">
                      {module.count} items
                    </Typography>
                    {importStatus[module.name] && (
                      <Box sx={{ mt: 1 }}>
                        <Chip
                          size="small"
                          icon={getStatusIcon(importStatus[module.name].status)}
                          label={
                            importStatus[module.name].status === 'importing' 
                              ? `${Math.round(importStatus[module.name].progress)}%`
                              : importStatus[module.name].status === 'success'
                              ? `${importStatus[module.name].success} berhasil`
                              : importStatus[module.name].status === 'partial'
                              ? `${importStatus[module.name].success}/${importStatus[module.name].success + importStatus[module.name].failed}`
                              : 'Error'
                          }
                          color={getStatusColor(importStatus[module.name].status)}
                        />
                        {importStatus[module.name].status === 'importing' && (
                          <LinearProgress
                            variant="determinate"
                            value={importStatus[module.name].progress}
                            sx={{ mt: 1 }}
                          />
                        )}
                      </Box>
                    )}
                  </Box>
                </Box>
              </Grid>
            ))}
          </Grid>
        </CardContent>
      </Card>

      <Box sx={{ textAlign: 'center' }}>
        <Button
          variant="contained"
          size="large"
          startIcon={<CloudUpload />}
          onClick={handleImportAll}
          disabled={importing}
          sx={{ minWidth: 200 }}
        >
          {importing ? 'Mengimpor Data...' : 'Import Semua Data'}
        </Button>
      </Box>

      {/* Results Dialog */}
      <Dialog open={showDialog} onClose={() => setShowDialog(false)} maxWidth="md" fullWidth>
        <DialogTitle>Hasil Import Data</DialogTitle>
        <DialogContent>
          {importResults && (
            <Box>
              <Alert severity="success" sx={{ mb: 2 }}>
                Total {importResults.total} data berhasil diimpor!
              </Alert>
              
              <Typography variant="h6" gutterBottom>
                Detail Import:
              </Typography>
              
              <List>
                {importResults.success.map((item, index) => (
                  <ListItem key={index}>
                    <ListItemIcon>
                      <CheckCircle color="success" />
                    </ListItemIcon>
                    <ListItemText
                      primary={item.module}
                      secondary={`${item.count} data berhasil diimpor${item.failed > 0 ? `, ${item.failed} gagal` : ''}`}
                    />
                  </ListItem>
                ))}
                
                {importResults.failed.map((item, index) => (
                  <ListItem key={index}>
                    <ListItemIcon>
                      <Error color="error" />
                    </ListItemIcon>
                    <ListItemText
                      primary={item.module}
                      secondary={`Error: ${item.error}`}
                    />
                  </ListItem>
                ))}
              </List>
            </Box>
          )}
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setShowDialog(false)}>
            Tutup
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};

export default DummyDataImport;