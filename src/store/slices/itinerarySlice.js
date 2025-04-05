import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';
import * as itineraryService from '../../services/itinerary';

// Initial state
const initialState = {
  itineraries: [],
  currentItinerary: null,
  isLoading: false,
  error: null
};

// Async thunks
export const fetchItineraries = createAsyncThunk(
  'itinerary/fetchAll',
  async (_, { rejectWithValue }) => {
    try {
      return await itineraryService.getItineraries();
    } catch (error) {
      return rejectWithValue(error.response?.data?.message || 'Failed to fetch itineraries');
    }
  }
);

export const fetchItineraryById = createAsyncThunk(
  'itinerary/fetchById',
  async (id, { rejectWithValue }) => {
    try {
      return await itineraryService.getItineraryById(id);
    } catch (error) {
      return rejectWithValue(error.response?.data?.message || 'Failed to fetch itinerary');
    }
  }
);

export const createItinerary = createAsyncThunk(
  'itinerary/create',
  async (formData, { rejectWithValue }) => {
    try {
      return await itineraryService.createItinerary(formData);
    } catch (error) {
      return rejectWithValue(error.response?.data?.message || 'Failed to create itinerary');
    }
  }
);

export const updateItinerary = createAsyncThunk(
  'itinerary/update',
  async ({ id, data }, { rejectWithValue }) => {
    try {
      return await itineraryService.updateItinerary(id, data);
    } catch (error) {
      return rejectWithValue(error.response?.data?.message || 'Failed to update itinerary');
    }
  }
);

export const removeItinerary = createAsyncThunk(
  'itinerary/delete',
  async (id, { rejectWithValue }) => {
    try {
      await itineraryService.deleteItinerary(id);
      return id;
    } catch (error) {
      return rejectWithValue(error.response?.data?.message || 'Failed to delete itinerary');
    }
  }
);

export const addDayToItinerary = createAsyncThunk(
  'itinerary/addDay',
  async ({ itineraryId, dayData }, { rejectWithValue }) => {
    try {
      return await itineraryService.addDayToItinerary(itineraryId, dayData);
    } catch (error) {
      return rejectWithValue(error.response?.data?.message || 'Failed to add day to itinerary');
    }
  }
);

export const addCollaborator = createAsyncThunk(
  'itinerary/addCollaborator',
  async ({ itineraryId, email, role }, { rejectWithValue }) => {
    try {
      return await itineraryService.addCollaboratorToItinerary(itineraryId, email, role);
    } catch (error) {
      return rejectWithValue(error.response?.data?.message || 'Failed to add collaborator to itinerary');
    }
  }
);

export const removeCollaborator = createAsyncThunk(
  'itinerary/removeCollaborator',
  async ({ itineraryId, collaboratorId }, { rejectWithValue }) => {
    try {
      return await itineraryService.removeCollaboratorFromItinerary(itineraryId, collaboratorId);
    } catch (error) {
      return rejectWithValue(error.response?.data?.message || 'Failed to remove collaborator from itinerary');
    }
  }
);

// Itinerary slice
const itinerarySlice = createSlice({
  name: 'itinerary',
  initialState,
  reducers: {
    clearError: (state) => {
      state.error = null;
    },
    clearCurrentItinerary: (state) => {
      state.currentItinerary = null;
    }
  },
  extraReducers: (builder) => {
    builder
      // Fetch all itineraries
      .addCase(fetchItineraries.pending, (state) => {
        state.isLoading = true;
        state.error = null;
      })
      .addCase(fetchItineraries.fulfilled, (state, action) => {
        state.isLoading = false;
        
        // Handle different response formats
        const payload = action.payload;
        
        if (payload && payload.itineraries) {
          // Format: { itineraries: [...] }
          state.itineraries = payload.itineraries;
        } else if (payload && payload.data && payload.data.itineraries) {
          // Format: { status, message, data: { itineraries: [...] } }
          state.itineraries = payload.data.itineraries;
        } else if (Array.isArray(payload)) {
          // Format: direct array of itineraries
          state.itineraries = payload;
        } else {
          // Default case
          state.itineraries = payload;
        }
      })
      .addCase(fetchItineraries.rejected, (state, action) => {
        state.isLoading = false;
        state.error = action.payload;
      })
      
      // Fetch itinerary by ID
      .addCase(fetchItineraryById.pending, (state) => {
        state.isLoading = true;
        state.error = null;
      })
      .addCase(fetchItineraryById.fulfilled, (state, action) => {
        state.isLoading = false;
        state.currentItinerary = action.payload;
      })
      .addCase(fetchItineraryById.rejected, (state, action) => {
        state.isLoading = false;
        state.error = action.payload;
      })
      
      // Create itinerary
      .addCase(createItinerary.pending, (state) => {
        state.isLoading = true;
        state.error = null;
      })
      .addCase(createItinerary.fulfilled, (state, action) => {
        state.isLoading = false;
        state.itineraries.push(action.payload);
      })
      .addCase(createItinerary.rejected, (state, action) => {
        state.isLoading = false;
        state.error = action.payload;
      })
      
      // Update itinerary
      .addCase(updateItinerary.pending, (state) => {
        state.isLoading = true;
        state.error = null;
      })
      .addCase(updateItinerary.fulfilled, (state, action) => {
        state.isLoading = false;
        const index = state.itineraries.findIndex(item => item.id === action.payload.id);
        if (index !== -1) {
          state.itineraries[index] = action.payload;
        }
        if (state.currentItinerary && state.currentItinerary.id === action.payload.id) {
          state.currentItinerary = action.payload;
        }
      })
      .addCase(updateItinerary.rejected, (state, action) => {
        state.isLoading = false;
        state.error = action.payload;
      })
      
      // Delete itinerary
      .addCase(removeItinerary.pending, (state) => {
        state.isLoading = true;
        state.error = null;
      })
      .addCase(removeItinerary.fulfilled, (state, action) => {
        state.isLoading = false;
        state.itineraries = state.itineraries.filter(item => item.id !== action.payload);
        if (state.currentItinerary && state.currentItinerary.id === action.payload) {
          state.currentItinerary = null;
        }
      })
      .addCase(removeItinerary.rejected, (state, action) => {
        state.isLoading = false;
        state.error = action.payload;
      })
      
      // Add day to itinerary
      .addCase(addDayToItinerary.pending, (state) => {
        state.isLoading = true;
        state.error = null;
      })
      .addCase(addDayToItinerary.fulfilled, (state, action) => {
        state.isLoading = false;
        state.currentItinerary = action.payload;
        const index = state.itineraries.findIndex(item => item.id === action.payload.id);
        if (index !== -1) {
          state.itineraries[index] = action.payload;
        }
      })
      .addCase(addDayToItinerary.rejected, (state, action) => {
        state.isLoading = false;
        state.error = action.payload;
      })
      
      // Add collaborator to itinerary
      .addCase(addCollaborator.pending, (state) => {
        state.isLoading = true;
        state.error = null;
      })
      .addCase(addCollaborator.fulfilled, (state, action) => {
        state.isLoading = false;
        state.currentItinerary = action.payload;
        // Update the itinerary in the list if it exists
        const index = state.itineraries.findIndex(item => 
          item.id === action.payload.id || item._id === action.payload._id
        );
        if (index !== -1) {
          state.itineraries[index] = action.payload;
        }
      })
      .addCase(addCollaborator.rejected, (state, action) => {
        state.isLoading = false;
        state.error = action.payload;
      })
      
      // Remove collaborator from itinerary
      .addCase(removeCollaborator.pending, (state) => {
        state.isLoading = true;
        state.error = null;
      })
      .addCase(removeCollaborator.fulfilled, (state, action) => {
        state.isLoading = false;
        state.currentItinerary = action.payload;
        // Update the itinerary in the list if it exists
        const index = state.itineraries.findIndex(item => 
          item.id === action.payload.id || item._id === action.payload._id
        );
        if (index !== -1) {
          state.itineraries[index] = action.payload;
        }
      })
      .addCase(removeCollaborator.rejected, (state, action) => {
        state.isLoading = false;
        state.error = action.payload;
      })
  }
});

export const { clearError, clearCurrentItinerary } = itinerarySlice.actions;
export default itinerarySlice.reducer; 