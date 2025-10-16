import React, { useState, useEffect } from 'react';
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
  Alert,
  Snackbar,
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
  Category as CategoryIcon
} from '@mui/icons-material';
import { styled } from '@mui/material/styles';
import { categoryService } from '../services/firebaseService';

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

const Categories = () => {
  const [categories, setCategories] = useState([]);
  const [open, setOpen] = useState(false);
  const [editingCategory, setEditingCategory] = useState(null);
  const [loading, setLoading] = useState(false);
  const [snackbar, setSnackbar] = useState({ open: false, message: '', severity: 'success' });
  const [formData, setFormData] = useState({
    name: ''
  });

  useEffect(() => {
    fetchCategories();
  }, []);

  const fetchCategories = async () => {
    try {
      setLoading(true);
      const data = await categoryService.getAll();
      setCategories(data);
    } catch (error) {
      showSnackbar('Error fetching categories', 'error');
    } finally {
      setLoading(false);
    }
  };

  const handleOpen = (category = null) => {
    if (category) {
      setEditingCategory(category);
      setFormData({
        name: category.name || ''
      });
    } else {
      setEditingCategory(null);
      setFormData({
        name: ''
      });
    }
    setOpen(true);
  };

  const handleClose = () => {
    setOpen(false);
    setEditingCategory(null);
    setFormData({
      name: ''
    });
  };

  const handleSubmit = async () => {
    try {
      setLoading(true);
      if (editingCategory) {
        await categoryService.update(editingCategory.id, formData);
        showSnackbar('Category updated successfully', 'success');
      } else {
        await categoryService.create(formData);
        showSnackbar('Category created successfully', 'success');
      }
      handleClose();
      fetchCategories();
    } catch (error) {
      showSnackbar('Error saving category', 'error');
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async (id) => {
    if (window.confirm('Are you sure you want to delete this category?')) {
      try {
        setLoading(true);
        await categoryService.delete(id);
        showSnackbar('Category deleted successfully', 'success');
        fetchCategories();
      } catch (error) {
        showSnackbar('Error deleting category', 'error');
      } finally {
        setLoading(false);
      }
    }
  };

  const showSnackbar = (message, severity) => {
    setSnackbar({ open: true, message, severity });
  };

  return (
    <Fade in timeout={800}>
      <Box>
        <HeaderCard>
          <CardContent>
            <Box display="flex" justifyContent="space-between" alignItems="center">
              <Typography variant="h4" sx={{ fontWeight: 'bold', display: 'flex', alignItems: 'center' }}>
                <CategoryIcon sx={{ mr: 2, fontSize: 32 }} />
                Category Management
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
                Add New Category
              </Button>
            </Box>
          </CardContent>
        </HeaderCard>

        <StyledTableContainer component={Paper}>
          <Table>
            <StyledTableHead>
              <TableRow>
                <TableCell>Category Name</TableCell>
                <TableCell align="center">Actions</TableCell>
              </TableRow>
            </StyledTableHead>
            <TableBody>
              {categories.map((category, index) => (
                <Grow
                  key={category.id}
                  in={true}
                  timeout={600}
                  style={{ transitionDelay: `${index * 100}ms` }}
                >
                  <StyledTableRow>
                    <TableCell>
                      <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                        <CategoryIcon sx={{ color: '#00695c', fontSize: 24 }} />
                        <Typography variant="body1" sx={{ fontWeight: 600 }}>
                          {category.name}
                        </Typography>
                      </Box>
                    </TableCell>
                    <TableCell align="center">
                      <Tooltip title="Edit Category" arrow>
                        <ActionButton
                          className="edit-btn"
                          onClick={() => handleOpen(category)}
                        >
                          <EditIcon />
                        </ActionButton>
                      </Tooltip>
                      <Tooltip title="Delete Category" arrow>
                        <ActionButton
                          className="delete-btn"
                          onClick={() => handleDelete(category.id)}
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

        <Dialog open={open} onClose={handleClose} maxWidth="sm" fullWidth>
          <DialogTitle sx={{ backgroundColor: '#20B2AA', color: 'white' }}>
            {editingCategory ? 'Edit Category' : 'Add New Category'}
          </DialogTitle>
          <DialogContent sx={{ mt: 2 }}>
            <TextField
              fullWidth
              label="Category Name"
              value={formData.name}
              onChange={(e) => setFormData({ ...formData, name: e.target.value })}
              sx={{
                '& .MuiOutlinedInput-root': {
                  '&.Mui-focused fieldset': { borderColor: '#20B2AA' }
                },
                '& .MuiInputLabel-root.Mui-focused': { color: '#20B2AA' }
              }}
            />
          </DialogContent>
          <DialogActions sx={{ p: 2 }}>
            <Button onClick={handleClose}>Cancel</Button>
            <Button
              onClick={handleSubmit}
              variant="contained"
              disabled={loading}
              sx={{
                backgroundColor: '#20B2AA',
                '&:hover': { backgroundColor: '#1a9999' }
              }}
            >
              {loading ? 'Saving...' : editingCategory ? 'Update' : 'Create'}
            </Button>
          </DialogActions>
        </Dialog>

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

export default Categories;