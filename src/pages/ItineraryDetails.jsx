import { useState, useEffect } from 'react'
import { useParams, Link, Navigate, useNavigate } from 'react-router-dom'
import { useSelector, useDispatch } from 'react-redux'
import { fetchItineraryById, updateItinerary, removeItinerary, addDayToItinerary, clearError } from '../store/slices/itinerarySlice'
import { differenceInDays, addDays, format, parseISO } from 'date-fns'
import GroupItineraryMembers from '../components/GroupItineraryMembers'
import ItineraryMap from '../components/ItineraryMap'
import axios from 'axios'
import { toast } from 'react-hot-toast'
import BudgetManager from '../components/BudgetManager'
import api from '../services/api'
axios.defaults.timeout = 100000;

function ItineraryDetails() {
  // Move all hooks to the top
  const { id } = useParams()
  const navigate = useNavigate()
  const dispatch = useDispatch()
  const { isAuthenticated, user, token } = useSelector(state => state.auth)
  const { currentItinerary: itinerary, isLoading, error } = useSelector(state => state.itinerary)
  
  const [localError, setLocalError] = useState(null)
  const [isEditing, setIsEditing] = useState(false)
  const [editData, setEditData] = useState({
    title: '',
    destination: '',
    description: '',
    startDate: '',
    endDate: '',
    isPrivate: false
  })

  const [showMap, setShowMap] = useState(false);
  const [mapLocations, setMapLocations] = useState([]);
  const [budgetUpdated, setBudgetUpdated] = useState(false);
  const [isAILoading, setIsAILoading] = useState(false); // Renamed local loading state

  // Fetch itinerary data when ID changes or on first load
  useEffect(() => {
    console.log('Fetching itinerary with ID:', id);
    dispatch(fetchItineraryById(id));
    
    // Clear the current itinerary when component unmounts
    return () => {
      dispatch(clearError());
    };
  }, [id, dispatch])

  // Update form data when itinerary is loaded
  useEffect(() => {
    console.log('Current itinerary data:', itinerary);
    if (itinerary) {
      // Handle different data formats from the API
      const destinationName = 
        typeof itinerary.destination === 'object' ? 
          itinerary.destination.name : 
          (typeof itinerary.destination === 'string' ? itinerary.destination : '');
      
      // Handle date formats - might be in nested dateRange or directly on the itinerary
      let startDate = '';
      let endDate = '';
      
      if (itinerary.dateRange) {
        startDate = itinerary.dateRange.start;
        endDate = itinerary.dateRange.end;
      } else {
        startDate = itinerary.startDate;
        endDate = itinerary.endDate;
      }
      
      // Format dates for input fields (YYYY-MM-DD)
      if (startDate) {
        const parsedStartDate = typeof startDate === 'string' ? parseISO(startDate) : new Date(startDate);
        startDate = format(parsedStartDate, 'yyyy-MM-dd');
      }
      
      if (endDate) {
        const parsedEndDate = typeof endDate === 'string' ? parseISO(endDate) : new Date(endDate);
        endDate = format(parsedEndDate, 'yyyy-MM-dd');
      }
      
      setEditData({
        title: itinerary.title || '',
        destination: destinationName,
        description: itinerary.description || '',
        startDate,
        endDate,
        isPrivate: itinerary.isPrivate || false
      });
    }
  }, [itinerary])

  // Update map locations when itinerary data is loaded
  useEffect(() => {
    if (itinerary && itinerary.routeLocations && itinerary.routeLocations.length > 0) {
      // Transform routeLocations to the format expected by ItineraryMap
      const locations = itinerary.routeLocations.map(loc => ({
        name: loc.name,
        description: loc.description,
        placeId: loc.placeId || `place-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`, // Generate a placeholder ID if missing
        lat: loc.location.coordinates ? loc.location.coordinates[1] : 0, // Convert from MongoDB format (lng, lat) to (lat, lng)
        lng: loc.location.coordinates ? loc.location.coordinates[0] : 0
      }));
      setMapLocations(locations);
    } else {
      setMapLocations([]);
    }
  }, [itinerary]);

  // Helper function to check if the current user is the owner
  const isUserOwner = () => {
    if (!itinerary || !itinerary.owner || !user) return false;
    
    // Convert IDs to strings for comparison
    const ownerId = itinerary.owner._id?.toString() || itinerary.owner.id?.toString() || itinerary.owner.toString();
    const userId = user._id?.toString() || user.id?.toString();
    
    return ownerId === userId;
  };

  // Helper function to check if the current user is the owner or editor
  const isUserOwnerOrEditor = () => {
    if (!itinerary || !user) return false;
    
    // Convert IDs to strings for comparison
    const ownerId = itinerary.owner._id?.toString() || itinerary.owner.id?.toString() || itinerary.owner.toString();
    const userId = user._id?.toString() || user.id?.toString();
    
    // Check if user is owner
    const isOwner = ownerId === userId;
    
    // Check if user is an editor collaborator
    const isEditorCollaborator = itinerary.collaborators?.some(
      c => {
        const collaboratorId = c.user._id?.toString() || c.user.id?.toString() || c.user.toString();
        return collaboratorId === userId && c.role === 'editor';
      }
    );
    
    return isOwner || isEditorCollaborator;
  };

  function handleEditChange(e) {
    const { name, value, type, checked } = e.target
    setEditData(prev => ({
      ...prev,
      [name]: type === 'checkbox' ? checked : value
    }))
  }

  function handleSave() {
    // Validate dates
    const start = new Date(editData.startDate)
    const end = new Date(editData.endDate)
    
    if (end < start) {
      dispatch(clearError())
      setLocalError('End date cannot be before start date')
      return
    }

    dispatch(updateItinerary({ id, data: editData }))
      .unwrap()
      .then(() => {
        setIsEditing(false)
        setLocalError(null)
      })
      .catch(err => {
        console.error(err)
        setLocalError('Failed to update itinerary')
      })
      window.location.reload()
  }

  function handleDelete() {
    if (window.confirm('Are you sure you want to delete this itinerary? This action cannot be undone.')) {
      dispatch(removeItinerary(id))
        .unwrap()
        .then(() => {
          navigate('/itineraries')
        })
        .catch(err => {
          console.error(err)
          setLocalError('Failed to delete itinerary')
        })
    }
  }

  function handleAddDay() {
    // Calculate the next day number
    const nextDayNum = itinerary.days ? itinerary.days.length + 1 : 1
    
    // Get the start date from the appropriate property
    let startDate;
    if (itinerary.dateRange && itinerary.dateRange.start) {
      startDate = new Date(itinerary.dateRange.start);
    } else if (itinerary.startDate) {
      startDate = new Date(itinerary.startDate);
    } else {
      startDate = new Date();
    }
    
    // Calculate date for the new day based on start date + day number
    const dayDate = addDays(startDate, nextDayNum - 1)
    
    const newDay = {
      dayNumber: nextDayNum,
      date: format(dayDate, 'yyyy-MM-dd'),
      activities: []
    }
    
    dispatch(addDayToItinerary({ itineraryId: id, dayData: newDay }))
      .unwrap()
      .then(() => {
        setLocalError(null);
      })
      .catch(err => {
        console.error('Failed to add day:', err);
        setLocalError('Failed to add day to itinerary');
      });
  }

  function generateInitialDays() {
    console.log("Generate days function called - starting");
    if (!itinerary) {
      console.log("No itinerary found, returning");
      setLocalError('No itinerary found. Please try again.');
      return;
    }
    
    // Get dates from appropriate properties
    let startDate, endDate;
    if (itinerary.dateRange) {
      startDate = new Date(itinerary.dateRange.start);
      endDate = new Date(itinerary.dateRange.end);
    } else {
      startDate = new Date(itinerary.startDate);
      endDate = new Date(itinerary.endDate);
    }
    
    // Format dates for API request
    const formattedStartDate = format(startDate, 'yyyy-MM-dd');
    const formattedEndDate = format(endDate, 'yyyy-MM-dd');
    
    // Prepare API request data according to the sample input in endpoint.md
    const requestData = {
      source: itinerary.source || itinerary.startLocation || "Borivali", // Default if not available
      destination: itinerary.destination?.name || itinerary.destination || "India Gate", // Handle both object and string
      activities_to_attend: itinerary.activities || itinerary.points_of_interest || [],
      date_range: [formattedStartDate, formattedEndDate],
      budget: itinerary.budget || "25000 INR", // Default if not available
      numberofpeople: itinerary.participants?.length || itinerary.numberOfPeople || 2 // Default if not available
    };

    console.log("API request data:", requestData);
    
    setLocalError(null);
    
    // Show local loading message
    const loadingMessage = "Generating itinerary days with AI...";
    setLocalError(loadingMessage);
    
    // Define the AI service URL
    const AI_SERVICE_URL = 'http://localhost:8000/api/ai';
    
    console.log("Making API call to generate itinerary using axios");
    // Make API call to generate itinerary using the api instance with auth headers and increased timeout
    api.post(`${AI_SERVICE_URL}/generate-itinerary`, requestData, {
      timeout: 60000 // Increase timeout to 60 seconds
    })
      .then(response => {
        console.log("API response received:", response.status);
        return response.data;
      })
      .then(data => {
        console.log('AI generated itinerary:', data);
        
        // Clear loading message if it's still the same
        if (localError === loadingMessage) {
          setLocalError(null);
        }
        
        // Check if the response has the expected structure
        if (data && data.itinerary && data.itinerary.day_wise_plan) {
          // Send the AI response to our backend for processing
          console.log("Sending AI response to backend for processing...");
          // Use api instance instead of axios directly to ensure auth headers are sent
          return api.post(
            `/itineraries/${id}/process-ai-itinerary`,
            { itineraryData: data },
            { timeout: 60000 } // Increase timeout to 60 seconds
          );
        } else {
          throw new Error('Invalid AI response format');
        }
      })
      .then(response => {
        console.log('Backend processing complete:', response.data);
        
        // Refresh the itinerary data to show the new days
        return dispatch(fetchItineraryById(id)).unwrap();
      })
      .then(() => {
        toast.success('Days successfully generated!');
      })
      .catch(error => {
        console.error('Error generating days:', error);
        setLocalError('Failed to generate days. Please try again.');
        toast.error('Failed to generate days');
      });
  }

  function handleSaveRoute() {
    // Save the updated route locations to the itinerary
    if (mapLocations.length > 0) {
      dispatch(updateItinerary({ 
        id, 
        data: { 
          locations: mapLocations 
        } 
      }))
      .unwrap()
      .then(() => {
        setLocalError(null);
        console.log('Route locations saved successfully');
      })
      .catch(err => {
        console.error('Failed to save route:', err);
        setLocalError('Failed to save route locations');
      });
    }
  }

  // Add this function to handle toggling the privacy status
  function handleTogglePrivacy() {
    if (!isUserOwnerOrEditor()) return;
    
    const newPrivacyValue = !editData.isPrivate;
    
    dispatch(updateItinerary({ 
      id, 
      data: { 
        isPrivate: newPrivacyValue 
      } 
    }))
    .unwrap()
    .then(() => {
      setEditData(prev => ({
        ...prev,
        isPrivate: newPrivacyValue
      }));
      setLocalError(null);
    })
    .catch(err => {
      console.error('Failed to update privacy setting:', err);
      setLocalError('Failed to update privacy setting');
    });
  }

  // Get displayed dates in the correct format
  const getFormattedDate = (dateStr) => {
    if (!dateStr) return '';
    try {
      const date = typeof dateStr === 'string' ? new Date(dateStr) : dateStr;
      return date.toLocaleDateString();
    } catch (e) {
      console.error('Error formatting date:', e);
      return dateStr;
    }
  };
  
  const displayStartDate = itinerary?.dateRange?.start || itinerary?.startDate || '';
  const displayEndDate = itinerary?.dateRange?.end || itinerary?.endDate || '';
  const formattedStartDate = getFormattedDate(displayStartDate);
  const formattedEndDate = getFormattedDate(displayEndDate);
  const destinationName = 
    typeof itinerary?.destination === 'object' ? 
      itinerary.destination.name : 
      (typeof itinerary?.destination === 'string' ? itinerary.destination : '');

  // Handler for budget updates
  const handleBudgetUpdate = (updatedBudget) => {
    console.log('Budget updated:', updatedBudget);
    setBudgetUpdated(true);
    
    // Fetch the latest itinerary data after budget update
    dispatch(fetchItineraryById(id))
      .unwrap()
      .then(() => {
        console.log('Itinerary refreshed after budget update');
      })
      .catch(err => {
        console.error('Failed to refresh itinerary:', err);
      });
  };

  // Conditional returns moved after all function definitions
  // Redirect if not authenticated
  if (!isAuthenticated) {
    return <Navigate to="/login" />
  }
  
  // Display loading state
  if (isLoading && !itinerary) {
    return (
      <div className="max-w-4xl mx-auto py-8 px-4">
        <div className="text-center py-12">
          <p className="text-gray-600">Loading itinerary details...</p>
        </div>
      </div>
    );
  }

  // Display error state
  if ((error || localError) && !itinerary) {
    return (
      <div className="max-w-4xl mx-auto py-8 px-4">
        <div className="bg-red-100 text-red-700 p-4 rounded-lg mb-6">
          {error || localError}
        </div>
        <div className="text-center">
          <button
            onClick={() => navigate('/itineraries')}
            className="bg-indigo-600 text-white px-6 py-2 rounded-lg hover:bg-indigo-700"
          >
            Back to Itineraries
          </button>
        </div>
      </div>
    );
  }

  // Handle case where itinerary is not found
  if (!isLoading && !itinerary) {
    return (
      <div className="max-w-4xl mx-auto py-8 px-4">
        <div className="bg-yellow-100 text-yellow-700 p-4 rounded-lg mb-6">
          Itinerary not found or you don't have access to it.
        </div>
        <div className="text-center">
          <button
            onClick={() => navigate('/itineraries')}
            className="bg-indigo-600 text-white px-6 py-2 rounded-lg hover:bg-indigo-700"
          >
            Back to Itineraries
          </button>
        </div>
      </div>
    );
  }

  // Main JSX return - moved to after all conditional returns
  return (
    <div className="max-w-6xl mx-auto py-8 px-4 relative">
      {(error || localError) && (
        <div className="bg-red-100 text-red-700 p-4 rounded-lg mb-6">
          {error || localError}
        </div>
      )}
      
      <div className="flex flex-col md:flex-row justify-between items-start md:items-center mb-6 gap-4">
        <div className="flex items-center">
          <Link to="/itineraries" className="mr-4 text-[#56288A] hover:text-[#864BD8] flex items-center">
            <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5 mr-1" viewBox="0 0 20 20" fill="currentColor">
              <path fillRule="evenodd" d="M9.707 16.707a1 1 0 01-1.414 0l-6-6a1 1 0 010-1.414l6-6a1 1 0 011.414 1.414L5.414 9H17a1 1 0 110 2H5.414l4.293 4.293a1 1 0 010 1.414z" clipRule="evenodd" />
            </svg>
            Back to Itineraries
          </Link>
          <div>
            {isEditing ? (
              <input
                type="text"
                name="title"
                value={editData.title}
                onChange={handleEditChange}
                className="text-3xl font-bold border-b-2 border-[#56288A] focus:outline-none"
                disabled={isAILoading}
              />
            ) : (
              <h1 className="text-3xl font-bold">{itinerary?.title}</h1>
            )}
            
            {/* Privacy Indicator */}
            <div className="flex items-center mt-2">
              <span className={`px-2 py-1 text-xs rounded-full ${
                editData.isPrivate 
                  ? 'bg-red-100 text-red-800' 
                  : 'bg-green-100 text-green-800'
              }`}>
                {editData.isPrivate ? 'Private' : 'Public'}
              </span>
              
              {isUserOwnerOrEditor() && !isEditing && (
                <button 
                  onClick={handleTogglePrivacy}
                  className="ml-2 text-sm text-[#56288A] hover:text-[#864BD8]"
                >
                  {editData.isPrivate ? 'Make Public' : 'Make Private'}
                </button>
              )}
            </div>
          </div>
        </div>
        <div className="flex space-x-2">
          {isEditing ? (
            <>
              <button
                onClick={handleSave}
                className="bg-[#56288A] text-white px-4 py-2 rounded-lg hover:bg-[#864BD8] disabled:bg-[#56288A]/60 flex items-center"
                disabled={isAILoading}
              >
                <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5 mr-1" viewBox="0 0 20 20" fill="currentColor">
                  <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
                </svg>
                Save
              </button>
              <button
                onClick={() => setIsEditing(false)}
                className="bg-gray-200 text-gray-800 px-4 py-2 rounded-lg hover:bg-gray-300 disabled:bg-gray-100 flex items-center"
                disabled={isAILoading}
              >
                <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5 mr-1" viewBox="0 0 20 20" fill="currentColor">
                  <path fillRule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clipRule="evenodd" />
                </svg>
                Cancel
              </button>
            </>
          ) : (
            <>
              <button
                onClick={() => setIsEditing(true)}
                className="bg-[#56288A] text-white px-4 py-2 rounded-lg hover:bg-[#864BD8] flex items-center"
              >
                <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5 mr-1" viewBox="0 0 20 20" fill="currentColor">
                  <path d="M13.586 3.586a2 2 0 112.828 2.828l-.793.793-2.828-2.828.793-.793zM11.379 5.793L3 14.172V17h2.828l8.38-8.379-2.83-2.828z" />
                </svg>
                Edit
              </button>
              <button
                onClick={handleDelete}
                className="bg-red-600 text-white px-4 py-2 rounded-lg hover:bg-red-700 flex items-center"
              >
                <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5 mr-1" viewBox="0 0 20 20" fill="currentColor">
                  <path fillRule="evenodd" d="M9 2a1 1 0 00-.894.553L7.382 4H4a1 1 0 000 2v10a2 2 0 002 2h8a2 2 0 002-2V6a1 1 0 100-2h-3.382l-.724-1.447A1 1 0 0011 2H9zM7 8a1 1 0 012 0v6a1 1 0 11-2 0V8zm5-1a1 1 0 00-1 1v6a1 1 0 102 0V8a1 1 0 00-1-1z" clipRule="evenodd" />
                </svg>
                Delete
              </button>
            </>
          )}
        </div>
      </div>
      
      <div className="bg-white rounded-lg shadow-md overflow-hidden mb-8">
        <div className="p-6">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
            <div>
              <h3 className="text-gray-600 text-sm font-medium uppercase tracking-wider mb-2">Destination</h3>
              {isEditing ? (
                <input
                  type="text"
                  name="destination"
                  value={editData.destination}
                  onChange={handleEditChange}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#56288A]"
                  disabled={isAILoading}
                />
              ) : (
                <p className="text-lg font-medium">{destinationName}</p>
              )}
            </div>
            
            <div>
              <h3 className="text-gray-600 text-sm font-medium uppercase tracking-wider mb-2">Dates</h3>
              {isEditing ? (
                <div className="flex space-x-2">
                  <input
                    type="date"
                    name="startDate"
                    value={editData.startDate}
                    onChange={handleEditChange}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#56288A]"
                    disabled={isAILoading}
                  />
                  <span className="flex items-center">to</span>
                  <input
                    type="date"
                    name="endDate"
                    value={editData.endDate}
                    onChange={handleEditChange}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#56288A]"
                    disabled={isAILoading}
                  />
                </div>
              ) : (
                <p className="text-lg font-medium">
                  {formattedStartDate} - {formattedEndDate}
                </p>
              )}
            </div>
          </div>
          
          <div className="mb-6">
            <h3 className="text-gray-600 text-sm font-medium uppercase tracking-wider mb-2">Description</h3>
            {isEditing ? (
              <textarea
                name="description"
                value={editData.description}
                onChange={handleEditChange}
                rows="3"
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#56288A]"
                disabled={isAILoading}
              ></textarea>
            ) : (
              <p className="text-gray-700 leading-relaxed">{itinerary?.description || 'No description provided.'}</p>
            )}
          </div>
          
          {isEditing && (
            <div className="mb-6">
              <div className="flex items-center">
                <input
                  type="checkbox"
                  id="isPrivate"
                  name="isPrivate"
                  checked={editData.isPrivate}
                  onChange={handleEditChange}
                  className="h-4 w-4 text-[#56288A] focus:ring-[#56288A] border-gray-300 rounded"
                  disabled={isAILoading}
                />
                <label 
                  htmlFor="isPrivate" 
                  className="ml-2 text-gray-700"
                >
                  Private itinerary
                </label>
              </div>
            </div>
          )}
        </div>
      </div>
      
      <div className="mb-6">
        <button
          type="button"
          onClick={() => setShowMap(!showMap)}
          className="flex items-center bg-white px-4 py-2 rounded-lg shadow-sm border border-gray-200 text-[#56288A] hover:text-[#864BD8] hover:bg-gray-50 transition-colors"
        >
          <svg 
            xmlns="http://www.w3.org/2000/svg" 
            className="h-5 w-5 mr-2" 
            fill="none" 
            viewBox="0 0 24 24" 
            stroke="currentColor"
          >
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 20l-5.447-2.724A1 1 0 013 16.382V5.618a1 1 0 011.447-.894L9 7m0 13l6-3m-6 3V7m6 10l4.553 2.276A1 1 0 0021 18.382V7.618a1 1 0 00-.553-.894L15 4m0 13V4m0 0L9 7" />
          </svg>
          {showMap ? "Hide Route Map" : "Show Route Map"} 
          <svg 
            xmlns="http://www.w3.org/2000/svg" 
            className={`h-5 w-5 ml-1 transition-transform ${showMap ? 'transform rotate-180' : ''}`} 
            fill="none" 
            viewBox="0 0 24 24" 
            stroke="currentColor"
          >
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
          </svg>
        </button>
      </div>
      
      {showMap && (
        <div className="bg-white rounded-lg shadow-md p-6 mb-8">
          <div className="flex justify-between items-center mb-4">
            <h2 className="text-xl font-bold text-gray-800 flex items-center">
              <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5 mr-2 text-[#56288A]" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
              </svg>
              Itinerary Route
            </h2>
            {isUserOwnerOrEditor() && (
              <button
                onClick={handleSaveRoute}
                className="bg-[#56288A] text-white px-4 py-2 rounded-lg hover:bg-[#864BD8] flex items-center"
              >
                <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 7H5a2 2 0 00-2 2v9a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-3m-1 4l-3 3m0 0l-3-3m3 3V4" />
                </svg>
                Save Route
              </button>
            )}
          </div>
          
          <ItineraryMap 
            locations={mapLocations} 
            setLocations={setMapLocations} 
            readOnly={!isUserOwnerOrEditor()}
            onSaveLocations={isUserOwnerOrEditor() ? handleSaveRoute : null}
          />
        </div>
      )}
      
      {/* Add BudgetManager component */}
      {itinerary && (
        <div className="mb-8">
          <div className="bg-white rounded-lg shadow-md overflow-hidden">
            <div className="border-b border-gray-200 px-6 py-4">
              <h2 className="text-xl font-bold text-gray-800 flex items-center">
                <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5 mr-2 text-[#56288A]" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                Budget Management
              </h2>
            </div>
            <div className="p-6">
              <BudgetManager 
                itineraryId={id} 
                budget={itinerary.budget}
                onUpdate={handleBudgetUpdate}
                isEditorRole={isUserOwnerOrEditor()}
              />
            </div>
          </div>
        </div>
      )}
      
      {/* Add Group Members section below the itinerary details and above the daily plan */}
      {itinerary && (
        <div className="mb-8">
          <div className="bg-white rounded-lg shadow-md overflow-hidden">
            <div className="border-b border-gray-200 px-6 py-4">
              <h2 className="text-xl font-bold text-gray-800 flex items-center">
                <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5 mr-2 text-[#56288A]" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" />
                </svg>
                Trip Members
              </h2>
            </div>
            <div className="p-6">
              <GroupItineraryMembers 
                itinerary={itinerary} 
                isOwner={isUserOwnerOrEditor()}
              />
            </div>
          </div>
        </div>
      )}
      
      <div className="mb-6">
        <div className="flex justify-between items-center">
          <h2 className="text-2xl font-bold text-gray-800 flex items-center">
            <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6 mr-2 text-[#56288A]" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
            </svg>
            Daily Plan
          </h2>
          <div className="flex space-x-2">
            <button
              onClick={generateInitialDays}
              className="bg-[#56288A] text-white px-4 py-2 rounded-lg hover:bg-[#864BD8] disabled:bg-[#56288A]/60 flex items-center"
              disabled={isAILoading}
            >
              <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 10V3L4 14h7v7l9-11h-7z" />
              </svg>
              Generate with AI
            </button>
            <button
              onClick={handleAddDay}
              className="bg-gray-200 text-gray-800 px-4 py-2 rounded-lg hover:bg-gray-300 disabled:bg-gray-100 flex items-center"
              disabled={isAILoading}
            >
              <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
              </svg>
              Add Day
            </button>
          </div>
        </div>
      </div>
      
      {(!itinerary?.days || itinerary.days.length === 0) ? (
        <div className="bg-white rounded-lg shadow-md p-8 text-center mb-8">
          <div className="inline-block p-4 bg-gray-100 rounded-full mb-4">
            <svg xmlns="http://www.w3.org/2000/svg" className="h-12 w-12 text-[#56288A]" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
            </svg>
          </div>
          <h3 className="text-xl font-medium text-gray-800 mb-4">No Days Added Yet</h3>
          <p className="text-gray-600 mb-6 max-w-md mx-auto">
            Start planning your trip by generating days with AI or adding them manually to your itinerary.
          </p>
          <div className="flex justify-center space-x-3">
            <button
              onClick={generateInitialDays}
              className="bg-[#56288A] text-white px-6 py-2 rounded-lg hover:bg-[#864BD8] flex items-center"
            >
              <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 10V3L4 14h7v7l9-11h-7z" />
              </svg>
              Generate with AI
            </button>
            <button
              onClick={handleAddDay}
              className="bg-gray-200 text-gray-800 px-6 py-2 rounded-lg hover:bg-gray-300 flex items-center"
            >
              <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
              </svg>
              Add Day
            </button>
          </div>
        </div>
      ) : (
        <div className="bg-white rounded-lg shadow-md overflow-hidden mb-8">
          <ul className="divide-y divide-gray-200">
            {itinerary.days.map(day => (
              <li key={day.id} className="group hover:bg-gray-50 transition-colors">
                <Link 
                  to={`/itineraries/${id}/days/${day.id}`}
                  className="block p-6"
                >
                  <div className="flex justify-between items-center">
                    <div>
                      <h3 className="text-lg font-medium text-gray-800 group-hover:text-[#56288A]">Day {day.dayNumber}</h3>
                      <p className="text-gray-600">
                        {new Date(day.date).toLocaleDateString('en-US', { weekday: 'long', month: 'long', day: 'numeric' })}
                      </p>
                    </div>
                    <div className="flex items-center">
                      <span className="flex items-center text-gray-600 mr-2">
                        <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5 mr-1 text-[#56288A]" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 10h16M4 14h16M4 18h16" />
                        </svg>
                        {day.activities?.length || 0} Activities
                      </span>
                      <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5 text-gray-400 group-hover:text-[#56288A] transition-colors" viewBox="0 0 20 20" fill="currentColor">
                        <path fillRule="evenodd" d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z" clipRule="evenodd" />
                      </svg>
                    </div>
                  </div>
                </Link>
              </li>
            ))}
          </ul>
        </div>
      )}
    </div>
  )
}

export default ItineraryDetails 