import { useState, useEffect } from 'react'
import { Link, Navigate } from 'react-router-dom'
import { useSelector } from 'react-redux'
import { getItineraries, deleteItinerary } from '../services/itinerary'

function Itineraries() {
  const { isAuthenticated } = useSelector(state => state.auth)
  const [itineraries, setItineraries] = useState([])
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState(null)
  
  // Redirect if not authenticated
  if (!isAuthenticated) {
    return <Navigate to="/login" />
  }
  
  useEffect(() => {
    loadItineraries()
  }, [])
  
  function loadItineraries() {
    setIsLoading(true)
    getItineraries()
      .then(data => {
        setItineraries(data)
        setIsLoading(false)
      })
      .catch(err => {
        setError('Failed to load itineraries')
        setIsLoading(false)
        console.error(err)
      })
  }
  
  function handleDelete(id) {
    if (window.confirm('Are you sure you want to delete this itinerary?')) {
      setIsLoading(true)
      deleteItinerary(id)
        .then(() => {
          setItineraries(prev => prev.filter(item => item.id !== id))
          setIsLoading(false)
        })
        .catch(err => {
          setError('Failed to delete itinerary')
          setIsLoading(false)
          console.error(err)
        })
    }
  }
  
  return (
    <div className="py-8">
      <div className="flex justify-between items-center mb-8">
        <h1 className="text-3xl font-bold">My Itineraries</h1>
        <Link 
          to="/itineraries/new" 
          className="bg-indigo-600 text-white px-6 py-2 rounded-lg hover:bg-indigo-700"
        >
          Create New Itinerary
        </Link>
      </div>
      
      {error && (
        <div className="bg-red-100 text-red-700 p-4 rounded-lg mb-6">
          {error}
        </div>
      )}
      
      {isLoading ? (
        <div className="text-center py-12">
          <p className="text-gray-600">Loading itineraries...</p>
        </div>
      ) : itineraries.length === 0 ? (
        <div className="bg-gray-50 rounded-lg p-8 text-center">
          <h3 className="text-xl font-medium text-gray-700 mb-4">No Itineraries Yet</h3>
          <p className="text-gray-600 mb-6">
            You haven't created any itineraries yet. Start planning your next adventure!
          </p>
          <Link 
            to="/itineraries/new" 
            className="bg-indigo-600 text-white px-6 py-2 rounded-lg hover:bg-indigo-700"
          >
            Create Your First Itinerary
          </Link>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {itineraries.map(itinerary => (
            <div 
              key={itinerary.id} 
              className="bg-white rounded-lg shadow-md overflow-hidden"
            >
              {itinerary.coverImage ? (
                <img 
                  src={itinerary.coverImage} 
                  alt={itinerary.title} 
                  className="w-full h-48 object-cover"
                />
              ) : (
                <div className="bg-gray-200 w-full h-48 flex items-center justify-center">
                  <span className="text-gray-500">No Image</span>
                </div>
              )}
              
              <div className="p-6">
                <h3 className="text-xl font-bold mb-2">
                  {itinerary.title}
                </h3>
                <p className="text-gray-600 mb-4">
                  {itinerary.destination}
                </p>
                
                <div className="flex justify-between items-center">
                  <p className="text-sm text-gray-500">
                    {new Date(itinerary.startDate).toLocaleDateString()} - {new Date(itinerary.endDate).toLocaleDateString()}
                  </p>
                  <span className="text-sm text-indigo-600 font-medium">
                    {itinerary.days?.length || 0} {itinerary.days?.length === 1 ? 'Day' : 'Days'}
                  </span>
                </div>
                
                <div className="flex justify-between mt-6">
                  <Link 
                    to={`/itineraries/${itinerary.id}`} 
                    className="bg-indigo-100 text-indigo-700 px-4 py-2 rounded hover:bg-indigo-200"
                  >
                    View Details
                  </Link>
                  <button 
                    onClick={() => handleDelete(itinerary.id)}
                    className="text-red-600 hover:text-red-800"
                  >
                    Delete
                  </button>
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