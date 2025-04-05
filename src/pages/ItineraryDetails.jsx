import { useState, useEffect } from 'react'
import { useParams, Link, Navigate, useNavigate } from 'react-router-dom'
import { useSelector, useDispatch } from 'react-redux'
import { fetchItineraryById, updateItinerary, removeItinerary, addDayToItinerary, clearError } from '../store/slices/itinerarySlice'
import { differenceInDays, addDays, format, parseISO } from 'date-fns'

function ItineraryDetails() {
  const { id } = useParams()
  const navigate = useNavigate()
  const dispatch = useDispatch()
  const { isAuthenticated } = useSelector(state => state.auth)
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

  // Redirect if not authenticated
  if (!isAuthenticated) {
    return <Navigate to="/login" />
  }

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
    if (!itinerary) return;
    
    // Get dates from appropriate properties
    let startDate, endDate;
    if (itinerary.dateRange) {
      startDate = new Date(itinerary.dateRange.start);
      endDate = new Date(itinerary.dateRange.end);
    } else {
      startDate = new Date(itinerary.startDate);
      endDate = new Date(itinerary.endDate);
    }
    
    const dayCount = differenceInDays(endDate, startDate) + 1;
    
    // Check if we need to create days (if none exist yet)
    if (!itinerary.days || itinerary.days.length === 0) {
      const promises = [];
      
      for (let i = 0; i < dayCount; i++) {
        const dayDate = addDays(startDate, i);
        const newDay = {
          dayNumber: i + 1,
          date: format(dayDate, 'yyyy-MM-dd'),
          activities: []
        };
        
        promises.push(dispatch(addDayToItinerary({ itineraryId: id, dayData: newDay })).unwrap());
      }
      
      Promise.all(promises)
        .then(() => dispatch(fetchItineraryById(id)))
        .catch(err => {
          console.error('Failed to generate days', err);
          setLocalError('Failed to generate days for this itinerary');
        });
    }
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

  return (
    <div className="max-w-4xl mx-auto py-8 px-4">
      {(error || localError) && (
        <div className="bg-red-100 text-red-700 p-4 rounded-lg mb-6">
          {error || localError}
        </div>
      )}
      
      <div className="flex justify-between items-center mb-6">
        <div className="flex items-center">
          <Link to="/itineraries" className="mr-4 text-indigo-600 hover:text-indigo-800">
            ← Back to Itineraries
          </Link>
          <div>
            {isEditing ? (
              <input
                type="text"
                name="title"
                value={editData.title}
                onChange={handleEditChange}
                className="text-3xl font-bold border-b-2 border-indigo-500 focus:outline-none"
                disabled={isLoading}
              />
            ) : (
              <h1 className="text-3xl font-bold">{itinerary?.title}</h1>
            )}
          </div>
        </div>
        <div className="flex space-x-2">
          {isEditing ? (
            <>
              <button
                onClick={handleSave}
                className="bg-green-600 text-white px-4 py-2 rounded hover:bg-green-700 disabled:bg-green-300"
                disabled={isLoading}
              >
                Save
              </button>
              <button
                onClick={() => setIsEditing(false)}
                className="bg-gray-200 text-gray-800 px-4 py-2 rounded hover:bg-gray-300 disabled:bg-gray-100"
                disabled={isLoading}
              >
                Cancel
              </button>
            </>
          ) : (
            <>
              <button
                onClick={() => setIsEditing(true)}
                className="bg-indigo-600 text-white px-4 py-2 rounded hover:bg-indigo-700"
              >
                Edit
              </button>
              <button
                onClick={handleDelete}
                className="bg-red-600 text-white px-4 py-2 rounded hover:bg-red-700"
              >
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
              <h3 className="text-gray-600 text-sm mb-1">Destination</h3>
              {isEditing ? (
                <input
                  type="text"
                  name="destination"
                  value={editData.destination}
                  onChange={handleEditChange}
                  className="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-indigo-500"
                  disabled={isLoading}
                />
              ) : (
                <p className="text-lg font-medium">{destinationName}</p>
              )}
            </div>
            
            <div>
              <h3 className="text-gray-600 text-sm mb-1">Dates</h3>
              {isEditing ? (
                <div className="flex space-x-2">
                  <input
                    type="date"
                    name="startDate"
                    value={editData.startDate}
                    onChange={handleEditChange}
                    className="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-indigo-500"
                    disabled={isLoading}
                  />
                  <span className="flex items-center">to</span>
                  <input
                    type="date"
                    name="endDate"
                    value={editData.endDate}
                    onChange={handleEditChange}
                    className="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-indigo-500"
                    disabled={isLoading}
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
            <h3 className="text-gray-600 text-sm mb-1">Description</h3>
            {isEditing ? (
              <textarea
                name="description"
                value={editData.description}
                onChange={handleEditChange}
                rows="3"
                className="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-indigo-500"
                disabled={isLoading}
              ></textarea>
            ) : (
              <p className="text-gray-700">{itinerary?.description || 'No description provided.'}</p>
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
                  className="h-4 w-4 text-indigo-600 focus:ring-indigo-500 border-gray-300 rounded"
                  disabled={isLoading}
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
      
      <div className="mb-4 flex justify-between items-center">
        <h2 className="text-2xl font-bold">Daily Plan</h2>
        <div className="flex space-x-2">
          <button
            onClick={generateInitialDays}
            className="bg-indigo-100 text-indigo-700 px-4 py-2 rounded hover:bg-indigo-200"
            disabled={isLoading || (itinerary?.days && itinerary.days.length > 0)}
          >
            Generate Days
          </button>
          <button
            onClick={handleAddDay}
            className="bg-indigo-600 text-white px-4 py-2 rounded hover:bg-indigo-700"
            disabled={isLoading}
          >
            Add Day
          </button>
        </div>
      </div>
      
      {(!itinerary?.days || itinerary.days.length === 0) ? (
        <div className="bg-gray-50 rounded-lg p-8 text-center">
          <h3 className="text-xl font-medium text-gray-700 mb-4">No Days Added Yet</h3>
          <p className="text-gray-600 mb-6">
            Start planning your trip by generating or adding days to your itinerary.
          </p>
          <button
            onClick={generateInitialDays}
            className="bg-indigo-600 text-white px-6 py-2 rounded-lg hover:bg-indigo-700"
          >
            Generate Days Based on Dates
          </button>
        </div>
      ) : (
        <div className="bg-white rounded-lg shadow-md overflow-hidden">
          <ul className="divide-y divide-gray-200">
            {itinerary.days.map(day => (
              <li key={day.id} className="hover:bg-gray-50">
                <Link 
                  to={`/itineraries/${id}/days/${day.id}`}
                  className="block p-6"
                >
                  <div className="flex justify-between items-center">
                    <div>
                      <h3 className="text-lg font-medium">Day {day.dayNumber}</h3>
                      <p className="text-gray-600">
                        {new Date(day.date).toLocaleDateString('en-US', { weekday: 'long', month: 'long', day: 'numeric' })}
                      </p>
                    </div>
                    <div className="flex items-center">
                      <span className="text-gray-600 mr-2">
                        {day.activities?.length || 0} Activities
                      </span>
                      <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5 text-gray-400" viewBox="0 0 20 20" fill="currentColor">
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