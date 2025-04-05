import { useState, useEffect } from 'react'
import { Link, Navigate, useNavigate } from 'react-router-dom'
import { useSelector, useDispatch } from 'react-redux'
import { fetchItineraries, removeItinerary } from '../store/slices/itinerarySlice'

function Itineraries() {
  const { isAuthenticated, user } = useSelector(state => state.auth)
  const { itineraries, isLoading, error } = useSelector(state => state.itinerary)
  const dispatch = useDispatch()
  const navigate = useNavigate()
  
  // Redirect if not authenticated
  if (!isAuthenticated) {
    return <Navigate to="/login" />
  }
  
  useEffect(() => {
    // Fetch itineraries when component mounts
    dispatch(fetchItineraries())
  }, [dispatch])
  
  function handleDelete(id) {
    if (window.confirm('Are you sure you want to delete this itinerary?')) {
      dispatch(removeItinerary(id))
    }
  }
  
  // Add a function to check if the user is the owner after handleDelete
  function isUserOwner(itinerary) {
    if (!user || !itinerary) return false;
    
    // Get owner ID from itinerary
    const ownerId = itinerary.owner?._id || itinerary.owner?.id || itinerary.owner;
    
    // Get current user ID
    const userId = user._id || user.id;
    
    // Compare as strings to ensure proper comparison
    return String(ownerId) === String(userId);
  }
  
  // Create a memoized version of the itineraries data to ensure it's always an array
  const itinerariesData = Array.isArray(itineraries?.itineraries) 
    ? itineraries.itineraries 
    : Array.isArray(itineraries) 
      ? itineraries 
      : []
  
  return (
    <div className="max-w-7xl mx-auto py-8 px-4 sm:px-6 lg:px-8">
      <div className="flex justify-between items-center mb-8">
        <h1 className="text-3xl font-bold text-gray-900">My Itineraries</h1>
        <div className="flex space-x-4">
          <Link 
            to="/itineraries/explore" 
            className="bg-indigo-100 text-indigo-700 px-6 py-2 rounded-lg hover:bg-indigo-200 transition-colors"
          >
            Explore Public Itineraries
          </Link>
          <Link 
            to="/itineraries/new" 
            className="bg-indigo-600 text-white px-6 py-2 rounded-lg hover:bg-indigo-700 transition-colors"
          >
            Create New Itinerary
          </Link>
        </div>
      </div>
      
      {error && (
        <div className="bg-red-100 text-red-700 p-4 rounded-lg mb-6">
          {error}
          <button 
            className="ml-2 text-red-500 hover:text-red-700"
            onClick={() => dispatch(fetchItineraries())}
          >
            Try again
          </button>
        </div>
      )}
      
      {isLoading ? (
        <div className="text-center py-12">
          <p className="text-gray-600">Loading your itineraries...</p>
        </div>
      ) : itinerariesData.length === 0 ? (
        <div className="bg-gray-50 rounded-lg p-8 text-center">
          <h3 className="text-xl font-medium text-gray-700 mb-4">No Itineraries Yet</h3>
          <p className="text-gray-600 mb-6">
            You haven't created any itineraries yet. Start planning your next adventure!
          </p>
          <Link 
            to="/itineraries/new" 
            className="bg-indigo-600 text-white px-6 py-2 rounded-lg hover:bg-indigo-700 transition-colors"
          >
            Create Your First Itinerary
          </Link>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {itinerariesData.map(itinerary => (
            <div 
              key={itinerary.id || itinerary._id} 
              className="bg-white rounded-lg shadow-md overflow-hidden hover:shadow-lg transition-shadow"
            >
              {itinerary.coverImage ? (
                <img 
                  src={itinerary.coverImage} 
                  alt={itinerary.title} 
                  className="w-full h-48 object-cover"
                />
              ) : (
                <div className="bg-gradient-to-r from-indigo-500 to-purple-600 w-full h-48 flex items-center justify-center">
                  <span className="text-white text-lg font-medium">{itinerary.title || 'My Itinerary'}</span>
                </div>
              )}
              
              <div className="p-6">
                <div className="flex justify-between items-start mb-2">
                  <h3 className="text-xl font-bold text-gray-900">
                    {itinerary.title}
                  </h3>
                  <div>
                    <span className={`px-2 py-1 text-xs rounded-full ${
                      itinerary.isPrivate 
                        ? 'bg-red-100 text-red-800' 
                        : 'bg-green-100 text-green-800'
                    }`}>
                      {itinerary.isPrivate ? 'Private' : 'Public'}
                    </span>
                    {isUserOwner(itinerary) ? (
                      <span className="ml-2 px-2 py-1 text-xs rounded-full bg-blue-100 text-blue-800">
                        Owner
                      </span>
                    ) : (
                      <span className="ml-2 px-2 py-1 text-xs rounded-full bg-purple-100 text-purple-800">
                        Collaborator
                      </span>
                    )}
                  </div>
                </div>
                <p className="text-gray-600 mb-4">
                  {itinerary.destination?.name || itinerary.destination || 'No destination specified'}
                </p>
                
                <div className="flex justify-between items-center">
                  <p className="text-sm text-gray-500">
                    {new Date(itinerary.dateRange?.start || itinerary.startDate).toLocaleDateString()} - {new Date(itinerary.dateRange?.end || itinerary.endDate).toLocaleDateString()}
                  </p>
                  <span className="text-sm text-indigo-600 font-medium">
                    {itinerary.days?.length || 0} {itinerary.days?.length === 1 ? 'Day' : 'Days'}
                  </span>
                </div>
                
                <div className="flex justify-between mt-6">
                  <Link 
                    to={`/itineraries/${itinerary.id || itinerary._id || itinerary.uuid}`} 
                    className="bg-indigo-100 text-indigo-700 px-4 py-2 rounded hover:bg-indigo-200 transition-colors"
                  >
                    View Details
                  </Link>
                  {isUserOwner(itinerary) && (
                    <button 
                      onClick={() => handleDelete(itinerary.id || itinerary._id || itinerary.uuid)}
                      className="text-red-600 hover:text-red-800"
                    >
                      Delete
                    </button>
                  )}
                </div>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  )
}

export default Itineraries 