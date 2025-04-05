import { useState } from 'react'
import { useNavigate, Navigate } from 'react-router-dom'
import { useSelector, useDispatch } from 'react-redux'
import { createItinerary, clearError } from '../store/slices/itinerarySlice'
import ItineraryMap from '../components/ItineraryMap'
import { itineraryService } from '../services';

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
  
  // AI generation related state
  const [showAIForm, setShowAIForm] = useState(false)
  const [isGenerating, setIsGenerating] = useState(false)
  const [isSaving, setIsSaving] = useState(false)
  const [aiFormData, setAiFormData] = useState({
    source: '',
    destination: '',
    activities_to_attend: '',
    budget: '',
    numberofpeople: 2
  })
  const [generatedItinerary, setGeneratedItinerary] = useState(null)
  
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
  
  function handleAIFormChange(e) {
    const { name, value, type } = e.target
    
    if (name === 'activities_to_attend') {
      // Handle activities as a comma-separated string that will be converted to array
      setAiFormData(prev => ({
        ...prev,
        [name]: value
      }))
    } else if (name === 'numberofpeople') {
      // Ensure number of people is a number
      setAiFormData(prev => ({
        ...prev,
        [name]: parseInt(value, 10) || 2
      }))
    } else {
      setAiFormData(prev => ({
        ...prev,
        [name]: value
      }))
    }
    
    if (localError) setLocalError(null)
    if (reduxError) dispatch(clearError())
  }
  
  async function handleGenerateItinerary(e) {
    e.preventDefault()
    
    setIsGenerating(true)
    setLocalError(null)
    
    try {
      // Validate that date range is provided
      if (!formData.startDate || !formData.endDate) {
        setLocalError('Please select both start and end dates for your trip')
        setIsGenerating(false)
        return
      }
      
      // Validate dates
      const startDate = new Date(formData.startDate)
      const endDate = new Date(formData.endDate)
      
      if (isNaN(startDate.getTime()) || isNaN(endDate.getTime())) {
        setLocalError('Please enter valid start and end dates')
        setIsGenerating(false)
        return
      }
      
      if (endDate < startDate) {
        setLocalError('End date cannot be before start date')
        setIsGenerating(false)
        return
      }
      
      // Prepare the data for the API
      const activitiesArray = aiFormData.activities_to_attend
        .split(',')
        .map(activity => activity.trim())
        .filter(activity => activity.length > 0)
      
      const dateRange = [formData.startDate, formData.endDate]
      
      const aiRequestData = {
        source: aiFormData.source,
        destination: aiFormData.destination,
        activities_to_attend: activitiesArray,
        date_range: dateRange,
        budget: aiFormData.budget,
        numberofpeople: aiFormData.numberofpeople
      }
      
      console.log('Generating itinerary with data:', aiRequestData)
      
      // Call the AI service
      const response = await itineraryService.generateAIItinerary(aiRequestData)
      
      console.log('Generated itinerary:', response)
      
      // Handle different response formats
      let itineraryData
      
      if (response.itinerary) {
        // Direct itinerary object in the response
        itineraryData = response.itinerary
      } else if (response.data && response.data.itinerary) {
        // Nested within data property
        itineraryData = response.data.itinerary
      } else {
        // Unexpected format - try to find anything that looks like an itinerary
        itineraryData = response.day_wise_plan ? response : null
      }
      
      if (itineraryData) {
        // Store the generated itinerary
        setGeneratedItinerary(itineraryData)
        
        // Update the form with data from the generated itinerary
        setFormData(prev => ({
          ...prev,
          title: `Trip to ${aiFormData.destination}`,
          destination: aiFormData.destination,
          description: `Generated itinerary to ${aiFormData.destination} with activities: ${activitiesArray.join(', ')}`
        }))
      } else {
        setLocalError('Failed to generate itinerary. Please try again or create one manually.')
      }
    } catch (error) {
      console.error('Error generating itinerary:', error)
      setLocalError('Error generating itinerary: ' + (error.message || 'Unknown error'))
    } finally {
      setIsGenerating(false)
    }
  }
  
  async function handleSaveGeneratedItinerary() {
    if (!generatedItinerary) return;
    
    setIsSaving(true);
    setLocalError(null);
    
    try {
      // Prepare the form data with information from the generated itinerary
      const itineraryFormData = {
        ...formData,
        title: formData.title || `Trip to ${aiFormData.destination}`,
        destination: formData.destination || aiFormData.destination,
        description: formData.description || `Generated itinerary to ${aiFormData.destination} with a budget of ${aiFormData.budget}`
      };
      
      console.log('Saving generated itinerary with form data:', itineraryFormData);
      
      // Call the service to save the itinerary
      const savedItinerary = await itineraryService.saveGeneratedItinerary(generatedItinerary, itineraryFormData);
      
      console.log('Saved generated itinerary:', savedItinerary);
      
      // Navigate to the saved itinerary details page
      if (savedItinerary && (savedItinerary._id || savedItinerary.id)) {
        const itineraryId = savedItinerary._id || savedItinerary.id;
        navigate(`/itineraries/${itineraryId}`);
      } else {
        // If we can't find an ID, just go back to the itineraries list
        console.warn('Created itinerary but no ID found:', savedItinerary);
        navigate('/itineraries');
      }
    } catch (error) {
      console.error('Error saving generated itinerary:', error);
      setLocalError('Error saving itinerary: ' + (error.message || 'Unknown error'));
      setIsSaving(false);
    }
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
      
      <div className="mb-6">
        <button
          type="button"
          onClick={() => setShowAIForm(!showAIForm)}
          className="bg-purple-600 hover:bg-purple-700 text-white px-4 py-2 rounded-lg flex items-center"
        >
          {showAIForm ? "Hide AI Generator" : "Generate with AI"} 
          <svg 
            xmlns="http://www.w3.org/2000/svg" 
            className={`h-5 w-5 ml-2 transition-transform ${showAIForm ? 'transform rotate-180' : ''}`} 
            fill="none" 
            viewBox="0 0 24 24" 
            stroke="currentColor"
          >
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
          </svg>
        </button>
      </div>
      
      {showAIForm && (
        <div className="bg-white rounded-lg shadow-md p-8 mb-8">
          <h2 className="text-xl font-semibold mb-4">AI Itinerary Generator</h2>
          <p className="text-gray-600 mb-4">Fill in the details below to generate a complete itinerary with AI.</p>
          
          <form onSubmit={handleGenerateItinerary}>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
              <div>
                <label 
                  htmlFor="source" 
                  className="block text-gray-700 font-medium mb-2"
                >
                  Source Location*
                </label>
                <input
                  type="text"
                  id="source"
                  name="source"
                  value={aiFormData.source}
                  onChange={handleAIFormChange}
                  className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
                  required
                  disabled={isGenerating}
                  placeholder="e.g., Mumbai"
                />
              </div>
              
              <div>
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
                  value={aiFormData.destination}
                  onChange={handleAIFormChange}
                  className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
                  required
                  disabled={isGenerating}
                  placeholder="e.g., Delhi"
                />
              </div>
            </div>
            
            <div className="mb-4">
              <label 
                htmlFor="activities_to_attend" 
                className="block text-gray-700 font-medium mb-2"
              >
                Activities/Places to Visit (comma-separated)*
              </label>
              <textarea
                id="activities_to_attend"
                name="activities_to_attend"
                value={aiFormData.activities_to_attend}
                onChange={handleAIFormChange}
                rows="3"
                className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
                required
                disabled={isGenerating}
                placeholder="e.g., Red Fort, India Gate, Jama Masjid"
              ></textarea>
            </div>
            
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
              <div>
                <label 
                  htmlFor="budget" 
                  className="block text-gray-700 font-medium mb-2"
                >
                  Budget*
                </label>
                <input
                  type="text"
                  id="budget"
                  name="budget"
                  value={aiFormData.budget}
                  onChange={handleAIFormChange}
                  className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
                  required
                  disabled={isGenerating}
                  placeholder="e.g., 25000 INR"
                />
              </div>
              
              <div>
                <label 
                  htmlFor="numberofpeople" 
                  className="block text-gray-700 font-medium mb-2"
                >
                  Number of People*
                </label>
                <input
                  type="number"
                  id="numberofpeople"
                  name="numberofpeople"
                  value={aiFormData.numberofpeople}
                  onChange={handleAIFormChange}
                  className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
                  required
                  min="1"
                  disabled={isGenerating}
                />
              </div>
            </div>
            
            <div className="mt-6">
              <button
                type="submit"
                className="bg-purple-600 hover:bg-purple-700 text-white px-6 py-2 rounded-lg font-medium flex items-center"
                disabled={isGenerating}
              >
                {isGenerating ? (
                  <>
                    <svg className="animate-spin -ml-1 mr-3 h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                      <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                      <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                    </svg>
                    Generating...
                  </>
                ) : "Generate Itinerary"}
              </button>
            </div>
          </form>
          
          {generatedItinerary && (
            <div className="mt-8 border-t pt-6">
              <h3 className="text-lg font-semibold mb-4">Generated Itinerary</h3>
              
              <div className="mb-6">
                <button
                  type="button"
                  onClick={handleSaveGeneratedItinerary}
                  disabled={isSaving}
                  className="bg-green-600 hover:bg-green-700 text-white px-6 py-2 rounded-lg font-medium flex items-center"
                >
                  {isSaving ? (
                    <>
                      <svg className="animate-spin -ml-1 mr-3 h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                        <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                        <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                      </svg>
                      Saving...
                    </>
                  ) : (
                    <>
                      <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 7H5a2 2 0 00-2 2v9a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-3m-1 4l-3 3m0 0l-3-3m3 3V4" />
                      </svg>
                      Save This Itinerary
                    </>
                  )}
                </button>
              </div>
              
              {generatedItinerary.day_wise_plan && generatedItinerary.day_wise_plan.length > 0 ? (
                generatedItinerary.day_wise_plan.map((day, index) => (
                  <div key={index} className="mb-6 p-4 bg-gray-50 rounded-lg">
                    <h4 className="font-bold text-lg">{day.day || `Day ${index + 1}`}</h4>
                    <p className="font-medium text-indigo-700 mb-2">{day.destination || 'Destination not specified'}</p>
                    
                    <div className="mb-3">
                      <p className="text-sm font-medium text-gray-700">Activities:</p>
                      {day.activities && day.activities.length > 0 ? (
                        <ul className="list-disc pl-5">
                          {day.activities.map((activity, actIdx) => (
                            <li key={actIdx} className="text-sm">{activity}</li>
                          ))}
                        </ul>
                      ) : (
                        <p className="text-sm italic text-gray-500">No activities planned</p>
                      )}
                    </div>
                    
                    {day.accomodations && day.accomodations.length > 0 && (
                      <div className="mb-3">
                        <p className="text-sm font-medium text-gray-700">Accommodations:</p>
                        <ul className="list-disc pl-5">
                          {day.accomodations.map((acc, accIdx) => (
                            <li key={accIdx} className="text-sm">{acc.name} {acc.price_range && `(${acc.price_range})`}</li>
                          ))}
                        </ul>
                      </div>
                    )}
                    
                    {day.restaurants && day.restaurants.length > 0 && (
                      <div className="mb-3">
                        <p className="text-sm font-medium text-gray-700">Restaurants:</p>
                        <ul className="list-disc pl-5">
                          {day.restaurants.map((rest, restIdx) => (
                            <li key={restIdx} className="text-sm">{rest.name} {rest.cuisine && `- ${rest.cuisine}`} {rest.price_range && `(${rest.price_range})`}</li>
                          ))}
                        </ul>
                      </div>
                    )}
                    
                    <p className="text-sm font-medium text-gray-800 mt-2">
                      Estimated Cost: {day.estimated_cost || 'Not specified'}
                    </p>
                  </div>
                ))
              ) : (
                <div className="p-4 bg-yellow-50 text-yellow-800 rounded-lg">
                  <p>No day-by-day plan available in the generated itinerary.</p>
                </div>
              )}
              
              {generatedItinerary.additional_suggestions && (
                <div className="mt-4 p-4 bg-blue-50 rounded-lg">
                  <h4 className="font-semibold mb-2">Additional Suggestions</h4>
                  
                  {generatedItinerary.additional_suggestions.restaurants && generatedItinerary.additional_suggestions.restaurants.length > 0 && (
                    <div className="mb-2">
                      <p className="text-sm font-medium">Restaurants:</p>
                      <ul className="list-disc pl-5">
                        {generatedItinerary.additional_suggestions.restaurants.map((item, idx) => (
                          <li key={idx} className="text-sm">{item}</li>
                        ))}
                      </ul>
                    </div>
                  )}
                  
                  {generatedItinerary.additional_suggestions.transportation && generatedItinerary.additional_suggestions.transportation.length > 0 && (
                    <div>
                      <p className="text-sm font-medium">Transportation:</p>
                      <ul className="list-disc pl-5">
                        {generatedItinerary.additional_suggestions.transportation.map((item, idx) => (
                          <li key={idx} className="text-sm">{item}</li>
                        ))}
                      </ul>
                    </div>
                  )}
                </div>
              )}
            </div>
          )}
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
              Public itineraries are visible in the Explore page and other users can request to join them.
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