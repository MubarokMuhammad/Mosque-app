import React, { useState } from 'react';
import {
  Box,
  TextField,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  Chip,
  IconButton,
  Paper,
  Grid,
  Typography,
  Collapse,
  Divider,
  InputAdornment
} from '@mui/material';
import {
  Search as SearchIcon,
  FilterList as FilterIcon,
  Sort as SortIcon,
  Clear as ClearIcon,
  ExpandMore as ExpandMoreIcon,
  ExpandLess as ExpandLessIcon
} from '@mui/icons-material';

const SearchFilterSort = ({
  searchValue,
  onSearchChange,
  sortBy,
  onSortChange,
  sortOrder,
  onSortOrderChange,
  filters,
  onFilterChange,
  filterOptions = {},
  sortOptions = [],
  placeholder = "Search...",
  showFilters = true,
  showSort = true
}) => {
  const [filtersExpanded, setFiltersExpanded] = useState(false);
  const [activeFiltersCount, setActiveFiltersCount] = useState(0);

  // Count active filters
  React.useEffect(() => {
    const count = Object.values(filters || {}).filter(value => 
      value && value !== '' && value !== 'all'
    ).length;
    setActiveFiltersCount(count);
  }, [filters]);

  const handleClearAll = () => {
    onSearchChange('');
    if (filters && onFilterChange) {
      const clearedFilters = {};
      Object.keys(filters).forEach(key => {
        clearedFilters[key] = '';
      });
      onFilterChange(clearedFilters);
    }
    if (onSortChange) {
      onSortChange('');
    }
    if (onSortOrderChange) {
      onSortOrderChange('asc');
    }
  };

  const hasActiveFilters = searchValue || activeFiltersCount > 0 || sortBy;

  return (
    <Paper 
      elevation={2} 
      sx={{ 
        p: 3, 
        mb: 3, 
        borderRadius: 2,
        background: 'linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%)',
        border: '1px solid rgba(0,0,0,0.05)'
      }}
    >
      <Grid container spacing={2} alignItems="center">
        {/* Search Field */}
        <Grid item xs={12} md={6}>
          <TextField
            fullWidth
            variant="outlined"
            placeholder={placeholder}
            value={searchValue}
            onChange={(e) => onSearchChange(e.target.value)}
            InputProps={{
              startAdornment: (
                <InputAdornment position="start">
                  <SearchIcon color="action" />
                </InputAdornment>
              ),
              endAdornment: searchValue && (
                <InputAdornment position="end">
                  <IconButton
                    size="small"
                    onClick={() => onSearchChange('')}
                    edge="end"
                  >
                    <ClearIcon />
                  </IconButton>
                </InputAdornment>
              ),
            }}
            sx={{
              '& .MuiOutlinedInput-root': {
                backgroundColor: 'white',
                borderRadius: 2,
                '&:hover': {
                  '& .MuiOutlinedInput-notchedOutline': {
                    borderColor: 'primary.main',
                  },
                },
              },
            }}
          />
        </Grid>

        {/* Sort Controls */}
        {showSort && (
          <Grid item xs={12} md={4}>
            <Grid container spacing={1}>
              <Grid item xs={8}>
                <FormControl fullWidth variant="outlined" size="medium">
                  <InputLabel>Sort By</InputLabel>
                  <Select
                    value={sortBy}
                    onChange={(e) => onSortChange(e.target.value)}
                    label="Sort By"
                    startAdornment={<SortIcon sx={{ mr: 1, color: 'action.active' }} />}
                    sx={{
                      backgroundColor: 'white',
                      borderRadius: 2,
                    }}
                  >
                    <MenuItem value="">
                      <em>None</em>
                    </MenuItem>
                    {sortOptions.map((option) => (
                      <MenuItem key={option.value} value={option.value}>
                        {option.label}
                      </MenuItem>
                    ))}
                  </Select>
                </FormControl>
              </Grid>
              <Grid item xs={4}>
                <FormControl fullWidth variant="outlined" size="medium">
                  <InputLabel>Order</InputLabel>
                  <Select
                    value={sortOrder}
                    onChange={(e) => onSortOrderChange(e.target.value)}
                    label="Order"
                    disabled={!sortBy}
                    sx={{
                      backgroundColor: 'white',
                      borderRadius: 2,
                    }}
                  >
                    <MenuItem value="asc">A-Z</MenuItem>
                    <MenuItem value="desc">Z-A</MenuItem>
                  </Select>
                </FormControl>
              </Grid>
            </Grid>
          </Grid>
        )}

        {/* Filter Toggle and Clear */}
        <Grid item xs={12} md={2}>
          <Box display="flex" gap={1} justifyContent="flex-end">
            {showFilters && (
              <IconButton
                onClick={() => setFiltersExpanded(!filtersExpanded)}
                sx={{
                  backgroundColor: filtersExpanded ? 'primary.main' : 'white',
                  color: filtersExpanded ? 'white' : 'primary.main',
                  border: '1px solid',
                  borderColor: 'primary.main',
                  borderRadius: 2,
                  '&:hover': {
                    backgroundColor: filtersExpanded ? 'primary.dark' : 'primary.light',
                    color: 'white',
                  },
                }}
              >
                <FilterIcon />
                {activeFiltersCount > 0 && (
                  <Chip
                    label={activeFiltersCount}
                    size="small"
                    sx={{
                      ml: 0.5,
                      height: 20,
                      minWidth: 20,
                      backgroundColor: 'error.main',
                      color: 'white',
                      fontSize: '0.75rem',
                    }}
                  />
                )}
                {filtersExpanded ? <ExpandLessIcon /> : <ExpandMoreIcon />}
              </IconButton>
            )}
            
            {hasActiveFilters && (
              <IconButton
                onClick={handleClearAll}
                sx={{
                  backgroundColor: 'error.light',
                  color: 'error.main',
                  border: '1px solid',
                  borderColor: 'error.main',
                  borderRadius: 2,
                  '&:hover': {
                    backgroundColor: 'error.main',
                    color: 'white',
                  },
                }}
              >
                <ClearIcon />
              </IconButton>
            )}
          </Box>
        </Grid>
      </Grid>

      {/* Filters Section */}
      {showFilters && (
        <Collapse in={filtersExpanded}>
          <Divider sx={{ my: 2 }} />
          <Typography variant="h6" gutterBottom sx={{ color: 'primary.main', fontWeight: 600 }}>
            Advanced Filters
          </Typography>
          <Grid container spacing={2}>
            {Object.entries(filterOptions).map(([filterKey, options]) => (
              <Grid item xs={12} sm={6} md={4} key={filterKey}>
                <FormControl fullWidth variant="outlined">
                  <InputLabel>{options.label}</InputLabel>
                  <Select
                    value={filters?.[filterKey] || ''}
                    onChange={(e) => onFilterChange({ 
                      ...filters, 
                      [filterKey]: e.target.value 
                    })}
                    label={options.label}
                    sx={{
                      backgroundColor: 'white',
                      borderRadius: 2,
                    }}
                  >
                    <MenuItem value="">
                      <em>All {options.label}</em>
                    </MenuItem>
                    {options.values.map((option) => (
                      <MenuItem key={option.value} value={option.value}>
                        {option.label}
                      </MenuItem>
                    ))}
                  </Select>
                </FormControl>
              </Grid>
            ))}
          </Grid>
        </Collapse>
      )}

      {/* Active Filters Display */}
      {hasActiveFilters && (
        <Box mt={2}>
          <Typography variant="body2" color="text.secondary" gutterBottom>
            Active Filters:
          </Typography>
          <Box display="flex" flexWrap="wrap" gap={1}>
            {searchValue && (
              <Chip
                label={`Search: "${searchValue}"`}
                onDelete={() => onSearchChange('')}
                color="primary"
                variant="outlined"
                size="small"
              />
            )}
            {sortBy && (
              <Chip
                label={`Sort: ${sortOptions.find(opt => opt.value === sortBy)?.label} (${sortOrder === 'asc' ? 'A-Z' : 'Z-A'})`}
                onDelete={() => {
                  onSortChange('');
                  onSortOrderChange('asc');
                }}
                color="secondary"
                variant="outlined"
                size="small"
              />
            )}
            {filters && Object.entries(filters).map(([key, value]) => {
              if (!value || value === '' || value === 'all') return null;
              const filterOption = filterOptions[key];
              const valueLabel = filterOption?.values.find(opt => opt.value === value)?.label || value;
              return (
                <Chip
                  key={key}
                  label={`${filterOption?.label}: ${valueLabel}`}
                  onDelete={() => onFilterChange({ ...filters, [key]: '' })}
                  color="info"
                  variant="outlined"
                  size="small"
                />
              );
            })}
          </Box>
        </Box>
      )}
    </Paper>
  );
};

export default SearchFilterSort;