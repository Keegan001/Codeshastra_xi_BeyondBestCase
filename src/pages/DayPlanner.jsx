import { useState, useEffect } from 'react'
import { useParams, Link, Navigate, useNavigate } from 'react-router-dom'
import { useSelector } from 'react-redux'
import { getItineraryById, updateItinerary } from '../services/itinerary'
import { searchPlaces, getPlaceById } from '../services/place'

function DayPlanner() {
  const { id, dayId } = useParams()
  const navigate = useNavigate()
  const { isAuthenticated } = useSelector(state => state.auth)
  
  const [itinerary, setItinerary] = useState(null)
  const [day, setDay] = useState(null)
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState(null)
  const [searchQuery, setSearchQuery] = useState('')
  const [searchResults, setSearchResults] = useState([])
  const [isSearching, setIsSearching] = useState(false)
  const [newActivity, setNewActivity] = useState({
    title: '',
    placeId: '',
    placeName: '',
    startTime: '',
    endTime: '',
    notes: '',
    cost: 0
  })
  const [isAddingActivity, setIsAddingActivity] = useState(false)
  const [selectedPlace, setSelectedPlace] = useState(null)
  
  if (!isAuthenticated) {
    return <Navigate to="/login" />
  }
  
  useEffect(() => {
    loadItinerary()
  }, [id, dayId])
  
  function loadItinerary() {
    setIsLoading(true)
    getItineraryById(id)
      .then(data => {
        setItinerary(data)
        const currentDay = data.days.find(d => d.id === dayId)
        if (currentDay) {
          setDay(currentDay)
        } else {
          setError('Day not found in this itinerary')
        }
        setIsLoading(false)
      })
      .catch(err => {
        setError('Failed to load itinerary details')
        setIsLoading(false)
        console.error(err)
      })
  }
  
  function handleSearch(e) {
    e.preventDefault()
    if (!searchQuery.trim()) return
    
    setIsSearching(true)
    searchPlaces(searchQuery)
      .then(results => {
        setSearchResults(results)
        setIsSearching(false)
      })
      .catch(err => {
        setError('Failed to search places')
        setIsSearching(false)
        console.error(err)
      })
  }
  
  function selectPlace(place) {
    setSelectedPlace(place)
    setNewActivity(prev => ({
      ...prev,
      placeId: place.id,
      placeName: place.name,
      title: place.name
    }))
    setSearchResults([])
    setSearchQuery('')
  }
  
  function handleActivityInputChange(e) {
    const { name, value } = e.target
    setNewActivity(prev => ({
      ...prev,
      [name]: name === 'cost' ? parseFloat(value) || 0 : value
    }))
  }
  
  function addActivity(e) {
    e.preventDefault()
    
    // Validate times
    if (newActivity.startTime && newActivity.endTime) {
      const start = new Date(`2000-01-01T${newActivity.startTime}`)
      const end = new Date(`2000-01-01T${newActivity.endTime}`)
      
      if (end < start) {
        setError('End time cannot be before start time')
        return
      }
    }
    
    // Clone the itinerary and update the day's activities
    const updatedItinerary = { ...itinerary }
    const dayIndex = updatedItinerary.days.findIndex(d => d.id === dayId)
    
    if (dayIndex === -1) {
      setError('Day not found')
      return
    }
    
    // Generate a simple ID for the new activity
    const activityId = Date.now().toString()
    const activityWithId = { ...newActivity, id: activityId }
    
    updatedItinerary.days[dayIndex].activities = [
      ...(updatedItinerary.days[dayIndex].activities || []),
      activityWithId
    ]
    
    setIsLoading(true)
    updateItinerary(id, updatedItinerary)
      .then(updated => {
        setItinerary(updated)
        const updatedDay = updated.days.find(d => d.id === dayId)
        setDay(updatedDay)
        // Reset the form
        setNewActivity({
          title: '',
          placeId: '',
          placeName: '',
          startTime: '',
          endTime: '',
          notes: '',
          cost: 0
        })
        setSelectedPlace(null)
        setIsAddingActivity(false)
        setIsLoading(false)
      })
      .catch(err => {
        setError('Failed to add activity')
        setIsLoading(false)
        console.error(err)
      })
  }
  
  function removeActivity(activityId) {
    if (!window.confirm('Are you sure you want to remove this activity?')) return
    
    // Clone the itinerary and update the day's activities
    const updatedItinerary = { ...itinerary }
    const dayIndex = updatedItinerary.days.findIndex(d => d.id === dayId)
    
    if (dayIndex === -1) {
      setError('Day not found')
      return
    }
    
    updatedItinerary.days[dayIndex].activities = updatedItinerary.days[dayIndex].activities.filter(
      activity => activity.id !== activityId
    )
    
    setIsLoading(true)
    updateItinerary(id, updatedItinerary)
      .then(updated => {
        setItinerary(updated)
        const updatedDay = updated.days.find(d => d.id === dayId)
        setDay(updatedDay)
        setIsLoading(false)
      })
      .catch(err => {
        setError('Failed to remove activity')
        setIsLoading(false)
        console.error(err)
      })
  }

  if (isLoading && !day) {
    return (
      <div className="max-w-4xl mx-auto py-8 px-4">
        <div className="text-center py-12">
          <p className="text-gray-600">Loading day details...</p>
        </div>
      </div>
    )
  }

  if (error && !day) {
    return (
      <div className="max-w-4xl mx-auto py-8 px-4">
        <div className="bg-red-100 text-red-700 p-4 rounded-lg mb-6">
          {error}
        </div>
        <div className="text-center">
          <button
            onClick={() => navigate(`/itineraries/${id}`)}
            className="bg-indigo-600 text-white px-6 py-2 rounded-lg hover:bg-indigo-700"
          >
            Back to Itinerary
          </button>
        </div>
      </div>
    )
  }
  
  // Sort activities by start time
  const sortedActivities = day?.activities?.length 
    ? [...day.activities].sort((a, b) => {
        if (!a.startTime) return 1
        if (!b.startTime) return -1
        return a.startTime.localeCompare(b.startTime)
      })
    : []
  
  // Calculate total cost for the day
  const totalCost = sortedActivities.reduce((sum, activity) => sum + (activity.cost || 0), 0)
  
  return (
    <div className="max-w-4xl mx-auto py-8 px-4">
      {error && (
        <div className="bg-red-100 text-red-700 p-4 rounded-lg mb-6">
          {error}
        </div>
      )}
      
      <div className="flex items-center mb-6">
        <Link 
          to={`/itineraries/${id}`} 
          className="text-indigo-600 hover:text-indigo-800 mr-4"
        >
          ← Back to Itinerary
        </Link>
        <h1 className="text-2xl font-bold">
          Day {day?.dayNumber} - {new Date(day?.date).toLocaleDateString('en-US', { weekday: 'long', month: 'long', day: 'numeric' })}
        </h1>
      </div>
      
      <div className="bg-white rounded-lg shadow-md overflow-hidden mb-8">
        <div className="p-6">
          <div className="flex justify-between items-center mb-6">
            <h2 className="text-xl font-bold">Activities</h2>
            <div className="flex items-center">
              <div className="mr-4 text-gray-700">
                Total Cost: <span className="font-medium">${totalCost.toFixed(2)}</span>
              </div>
              <button
                onClick={() => setIsAddingActivity(true)}
                className="bg-indigo-600 text-white px-4 py-2 rounded hover:bg-indigo-700"
                disabled={isAddingActivity}
              >
                Add Activity
              </button>
            </div>
          </div>
          
          {isAddingActivity && (
            <div className="bg-gray-50 p-6 rounded-lg mb-6">
              <h3 className="text-lg font-medium mb-4">Add New Activity</h3>
              
              <div className="mb-4">
                <label className="block text-gray-700 font-medium mb-2">
                  Search for a Place
                </label>
                <form onSubmit={handleSearch} className="flex">
                  <input
                    type="text"
                    value={searchQuery}
                    onChange={e => setSearchQuery(e.target.value)}
                    className="flex-1 px-4 py-2 border rounded-l focus:outline-none focus:ring-2 focus:ring-indigo-500"
                    placeholder="e.g. Eiffel Tower, Central Park, Museum"
                    disabled={isSearching}
                  />
                  <button
                    type="submit"
                    className="bg-indigo-600 text-white px-4 py-2 rounded-r hover:bg-indigo-700 disabled:bg-indigo-300"
                    disabled={isSearching}
                  >
                    {isSearching ? 'Searching...' : 'Search'}
                  </button>
                </form>
                
                {searchResults.length > 0 && (
                  <div className="mt-2 border rounded max-h-48 overflow-y-auto">
                    <ul className="divide-y divide-gray-200">
                      {searchResults.map(place => (
                        <li 
                          key={place.id}
                          className="p-3 hover:bg-gray-100 cursor-pointer"
                          onClick={() => selectPlace(place)}
                        >
                          <div className="font-medium">{place.name}</div>
                          {place.address && <div className="text-sm text-gray-600">{place.address}</div>}
                        </li>
                      ))}
                    </ul>
                  </div>
                )}
                
                {selectedPlace && (
                  <div className="mt-2 p-3 border rounded bg-indigo-50">
                    <div className="font-medium">{selectedPlace.name}</div>
                    {selectedPlace.address && <div className="text-sm">{selectedPlace.address}</div>}
                  </div>
                )}
              </div>
              
              <form onSubmit={addActivity}>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
                  <div>
                    <label 
                      htmlFor="title" 
                      className="block text-gray-700 font-medium mb-2"
                    >
                      Activity Title*
                    </label>
                    <input
                      type="text"
                      id="title"
                      name="title"
                      value={newActivity.title}
                      onChange={handleActivityInputChange}
                      className="w-full px-4 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-indigo-500"
                      required
                    />
                  </div>
                  
                  <div>
                    <label 
                      htmlFor="cost" 
                      className="block text-gray-700 font-medium mb-2"
                    >
                      Estimated Cost ($)
                    </label>
                    <input
                      type="number"
                      id="cost"
                      name="cost"
                      value={newActivity.cost}
                      onChange={handleActivityInputChange}
                      min="0"
                      step="0.01"
                      className="w-full px-4 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-indigo-500"
                    />
                  </div>
                </div>
                
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
                  <div>
                    <label 
                      htmlFor="startTime" 
                      className="block text-gray-700 font-medium mb-2"
                    >
                      Start Time
                    </label>
                    <input
                      type="time"
                      id="startTime"
                      name="startTime"
                      value={newActivity.startTime}
                      onChange={handleActivityInputChange}
                      className="w-full px-4 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-indigo-500"
                    />
                  </div>
                  
                  <div>
                    <label 
                      htmlFor="endTime" 
                      className="block text-gray-700 font-medium mb-2"
                    >
                      End Time
                    </label>
                    <input
                      type="time"
                      id="endTime"
                      name="endTime"
                      value={newActivity.endTime}
                      onChange={handleActivityInputChange}
                      className="w-full px-4 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-indigo-500"
                    />
                  </div>
                </div>
                
                <div className="mb-6">
                  <label 
                    htmlFor="notes" 
                    className="block text-gray-700 font-medium mb-2"
                  >
                    Notes
                  </label>
                  <textarea
                    id="notes"
                    name="notes"
                    value={newActivity.notes}
                    onChange={handleActivityInputChange}
                    rows="3"
                    className="w-full px-4 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-indigo-500"
                  ></textarea>
                </div>
                
                <div className="flex space-x-3">
                  <button
                    type="submit"
                    className="bg-green-600 text-white px-4 py-2 rounded hover:bg-green-700"
                    disabled={isLoading}
                  >
                    {isLoading ? 'Adding...' : 'Add to Itinerary'}
                  </button>
                  <button
                    type="button"
                    onClick={() => {
                      setIsAddingActivity(false)
                      setSelectedPlace(null)
                      setNewActivity({
                        title: '',
                        placeId: '',
                        placeName: '',
                        startTime: '',
                        endTime: '',
                        notes: '',
                        cost: 0
                      })
                    }}
                    className="bg-gray-200 text-gray-800 px-4 py-2 rounded hover:bg-gray-300"
                  >
                    Cancel
                  </button>
                </div>
              </form>
            </div>
          )}
          
          {sortedActivities.length === 0 ? (
            <div className="text-center py-8 bg-gray-50 rounded-lg">
              <h3 className="text-lg font-medium text-gray-700 mb-2">No Activities Planned</h3>
              <p className="text-gray-600 mb-4">
                Start adding activities to plan your day.
              </p>
              <button
                onClick={() => setIsAddingActivity(true)}
                className="bg-indigo-600 text-white px-6 py-2 rounded-lg hover:bg-indigo-700"
                disabled={isAddingActivity}
              >
                Add Your First Activity
              </button>
            </div>
          ) : (
            <div className="bg-white rounded-lg border">
              <ul className="divide-y divide-gray-200">
                {sortedActivities.map((activity, index) => (
                  <li 
                    key={activity.id} 
                    className={`p-4 ${index % 2 === 0 ? 'bg-white' : 'bg-gray-50'}`}
                  >
                    <div className="flex justify-between">
                      <div className="flex-1">
                        <div className="flex items-center">
                          <h3 className="text-lg font-medium">{activity.title}</h3>
                          {activity.cost > 0 && (
                            <span className="ml-3 bg-gray-100 text-gray-800 px-2 py-1 rounded text-sm">
                              ${activity.cost.toFixed(2)}
                            </span>
                          )}
                        </div>
                        
                        {(activity.startTime || activity.endTime) && (
                          <p className="text-gray-600 mt-1">
                            {activity.startTime && formatTime(activity.startTime)}
                            {activity.startTime && activity.endTime && ' - '}
                            {activity.endTime && formatTime(activity.endTime)}
                          </p>
                        )}
                        
                        {activity.placeName && (
                          <p className="text-indigo-600 text-sm mt-1">
                            {activity.placeName}
                          </p>
                        )}
                        
                        {activity.notes && (
                          <p className="text-gray-700 mt-2 text-sm">
                            {activity.notes}
                          </p>
                        )}
                      </div>
                      
                      <div>
                        <button
                          onClick={() => removeActivity(activity.id)}
                          className="text-red-600 hover:text-red-800"
                          title="Remove activity"
                        >
                          <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
                            <path fillRule="evenodd" d="M9 2a1 1 0 00-.894.553L7.382 4H4a1 1 0 000 2v10a2 2 0 002 2h8a2 2 0 002-2V6a1 1 0 100-2h-3.382l-.724-1.447A1 1 0 0011 2H9zM7 8a1 1 0 012 0v6a1 1 0 11-2 0V8zm5-1a1 1 0 00-1 1v6a1 1 0 102 0V8a1 1 0 00-1-1z" clipRule="evenodd" />
                          </svg>
                        </button>
                      </div>
                    </div>
                  </li>
                ))}
              </ul>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}

// Helper function to format time
function formatTime(timeString) {
  try {
    const [hours, minutes] = timeString.split(':')
    const date = new Date()
    date.setHours(parseInt(hours, 10))
    date.setMinutes(parseInt(minutes, 10))
    
    return date.toLocaleTimeString('en-US', { 
      hour: 'numeric',
      minute: '2-digit',
      hour12: true
    })
  } catch (e) {
    return timeString
  }
}

export default DayPlanner 