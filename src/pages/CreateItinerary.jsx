import { useState } from 'react'
import { useNavigate, Navigate } from 'react-router-dom'
import { useSelector, useDispatch } from 'react-redux'
import { createItinerary, clearError } from '../store/slices/itinerarySlice'
import ItineraryMap from '../components/ItineraryMap'

function CreateItinerary() {
  const { isAuthenticated } = useSelector(state => state.auth)
  const { isLoading, error: reduxError } = useSelector(state => state.itinerary)
  const dispatch = useDispatch()
  const navigate = useNavigate()
  
  const [formData, setFormData] = useState({
    title: '',
    destination: '',
    startDate: '',
    endDate: '',
    description: '',
    isPrivate: false
  })
  
  const [locations, setLocations] = useState([])
  const [localError, setLocalError] = useState(null)
  const [showMap, setShowMap] = useState(false)
  
  // Combine local and Redux errors
  const error = localError || reduxError
  
  // Redirect if not authenticated
  if (!isAuthenticated) {
    return <Navigate to="/login" />
  }
  
  function handleChange(e) {
    const { name, value, type, checked } = e.target
    setFormData(prev => ({
      ...prev,
      [name]: type === 'checkbox' ? checked : value
    }))
    
    if (localError) setLocalError(null)
    if (reduxError) dispatch(clearError())
  }
  
  function handleSubmit(e) {
    e.preventDefault()
    
    // Validate dates
    const start = new Date(formData.startDate)
    const end = new Date(formData.endDate)
    
    if (end < start) {
      // Set a local validation error
      dispatch(clearError())
      setLocalError('End date cannot be before start date')
      return
    }
    
    setLocalError(null)
    
    // Prepare the data to send, including the map locations if available
    const dataToSend = {
      ...formData,
      locations: locations.length > 0 ? locations : undefined
    }
    
    dispatch(createItinerary(dataToSend))
      .unwrap()
      .then(itinerary => {
        console.log('Received itinerary from Redux:', itinerary);
        
        // After our service layer transformations, we should have the actual itinerary object
        // Navigate using the itinerary's ID (_id for MongoDB)
        if (itinerary && (itinerary._id || itinerary.id)) {
          const itineraryId = itinerary._id || itinerary.id;
          navigate(`/itineraries/${itineraryId}`);
        } else {
          // If we can't find an ID, just go back to the itineraries list
          console.warn('Created itinerary but no ID found:', itinerary);
          navigate('/itineraries');
        }
      })
      .catch(err => {
        console.error('Error creating itinerary:', err)
        // Handle API errors
        if (typeof err === 'string') {
          setLocalError(err)
        } else if (err && err.message) {
          setLocalError(err.message);
        } else {
          setLocalError('Failed to create itinerary. Please try again.');
        }
      })
  }
  
  // Note: If in dev mode with mock data, show a warning
  const isDevelopmentWithMock = import.meta.env.DEV && window.itineraryServiceOffline
  
  return (
    <div className="max-w-7xl mx-auto py-8 px-4">
      <h1 className="text-3xl font-bold mb-8">Create New Itinerary</h1>
      
      {isDevelopmentWithMock && (
        <div className="bg-blue-100 text-blue-700 p-4 rounded-lg mb-6">
          <p className="font-medium">Development Mode: Using Mock Data</p>
          <p className="text-sm mt-1">Backend API is unavailable. Your changes will be stored temporarily in browser memory.</p>
        </div>
      )}
      
      {error && (
        <div className="bg-red-100 text-red-700 p-4 rounded-lg mb-6">
          {error}
        </div>
      )}
      
      <div className="bg-white rounded-lg shadow-md p-8 mb-8">
        <form onSubmit={handleSubmit}>
          <div className="mb-4">
            <label 
              htmlFor="title" 
              className="block text-gray-700 font-medium mb-2"
            >
              Itinerary Title*
            </label>
            <input
              type="text"
              id="title"
              name="title"
              value={formData.title}
              onChange={handleChange}
              className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
              required
              disabled={isLoading}
            />
          </div>
          
          <div className="mb-4">
            <label 
              htmlFor="destination" 
              className="block text-gray-700 font-medium mb-2"
            >
              Destination*
            </label>
            <input
              type="text"
              id="destination"
              name="destination"
              value={formData.destination}
              onChange={handleChange}
              className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
              required
              disabled={isLoading}
            />
          </div>
          
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
            <div>
              <label 
                htmlFor="startDate" 
                className="block text-gray-700 font-medium mb-2"
              >
                Start Date*
              </label>
              <input
                type="date"
                id="startDate"
                name="startDate"
                value={formData.startDate}
                onChange={handleChange}
                className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
                required
                disabled={isLoading}
              />
            </div>
            
            <div>
              <label 
                htmlFor="endDate" 
                className="block text-gray-700 font-medium mb-2"
              >
                End Date*
              </label>
              <input
                type="date"
                id="endDate"
                name="endDate"
                value={formData.endDate}
                onChange={handleChange}
                className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
                required
                disabled={isLoading}
              />
            </div>
          </div>
          
          <div className="mb-4">
            <label 
              htmlFor="description" 
              className="block text-gray-700 font-medium mb-2"
            >
              Description
            </label>
            <textarea
              id="description"
              name="description"
              value={formData.description}
              onChange={handleChange}
              rows="4"
              className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
              disabled={isLoading}
            ></textarea>
          </div>
          
          <div className="mb-6">
            <div className="flex items-center">
              <input
                type="checkbox"
                id="isPrivate"
                name="isPrivate"
                checked={formData.isPrivate}
                onChange={handleChange}
                className="h-4 w-4 text-indigo-600 focus:ring-indigo-500 border-gray-300 rounded"
                disabled={isLoading}
              />
              <label 
                htmlFor="isPrivate" 
                className="ml-2 block text-gray-700"
              >
                Make this itinerary private
              </label>
            </div>
            <p className="text-sm text-gray-500 mt-1">
              Private itineraries can only be viewed by people you share them with.
            </p>
          </div>
          
          <div className="mb-6">
            <button
              type="button"
              onClick={() => setShowMap(!showMap)}
              className="text-indigo-600 hover:text-indigo-800 flex items-center"
            >
              {showMap ? "Hide Map" : "Plan Route on Map"} 
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
          
          <div className="flex space-x-4">
            <button
              type="submit"
              className="bg-indigo-600 text-white px-6 py-2 rounded hover:bg-indigo-700 disabled:bg-indigo-300"
              disabled={isLoading}
            >
              {isLoading ? 'Creating...' : 'Create Itinerary'}
            </button>
            <button
              type="button"
              onClick={() => navigate('/itineraries')}
              className="bg-gray-200 text-gray-800 px-6 py-2 rounded hover:bg-gray-300 disabled:bg-gray-100"
              disabled={isLoading}
            >
              Cancel
            </button>
          </div>
        </form>
      </div>
      
      {showMap && (
        <div className="bg-white rounded-lg shadow-md p-6 mb-8">
          <h2 className="text-xl font-bold mb-4">Route Planning</h2>
          <p className="text-gray-600 mb-6">
            Add locations to your itinerary using the map below. You can search for places and build a route 
            of all the places you want to visit.
          </p>
          
          <ItineraryMap 
            locations={locations} 
            setLocations={setLocations} 
          />
        </div>
      )}
    </div>
  )
}

export default CreateItinerary