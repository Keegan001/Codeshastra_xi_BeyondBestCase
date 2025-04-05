import api, { checkApiConnection } from './api'

// Mock data for development environment
const MOCK_ITINERARIES = [
  {
    id: 'mock-1',
    title: 'Trip to Paris',
    destination: 'Paris, France',
    startDate: '2023-06-10',
    endDate: '2023-06-17',
    description: 'Exploring the City of Lights',
    isPrivate: false,
    days: [
      {
        id: 'day-1',
        dayNumber: 1,
        date: '2023-06-10',
        activities: [
          {
            id: 'act-1',
            title: 'Eiffel Tower Visit',
            startTime: '10:00',
            endTime: '12:00',
            placeName: 'Eiffel Tower',
            placeId: 'place-1',
            notes: 'Buy tickets in advance',
            cost: 25
          }
        ]
      }
    ]
  },
  {
    id: 'mock-2',
    title: 'Weekend in Rome',
    destination: 'Rome, Italy',
    startDate: '2023-07-15',
    endDate: '2023-07-17',
    description: 'Exploring ancient history',
    isPrivate: true,
    days: []
  }
];

// Check if we should use mock data in development
let useMockData = false;

// Function to check API connection and update mock data flag
const checkConnection = async () => {
  if (import.meta.env.DEV) {
    useMockData = !(await checkApiConnection());
    if (useMockData) {
      console.info('Using mock data for itineraries (backend not available)');
    }
  }
};

// Initialize connection check
checkConnection();

function getItineraries() {
  // If in development and backend is unavailable, return mock data
  if (useMockData) {
    console.log('Returning mock itineraries data');
    return Promise.resolve(MOCK_ITINERARIES);
  }

  return api.get('/itineraries')
    .then(response => {
      console.log('Itineraries response:', response);
      const data = response.data;
      
      // Handle different possible API response formats
      if (data && data.status === 'success' && data.data) {
        // API format: { status: 'success', message: '...', data: {...}, timestamp: '...' }
        console.log('Standard API response format detected');
        return data.data.itineraries || data.data;
      } else if (data && typeof data === 'object' && data.itineraries) {
        // API format: { itineraries: [...] }
        console.log('Direct itineraries object detected');
        return data.itineraries;
      } else if (Array.isArray(data)) {
        // API format: direct array of itineraries
        console.log('Direct array of itineraries detected');
        return data;
      } else if (data && typeof data === 'object') {
        // Handle other object format
        console.log('Other object format detected, looking for data');
        return data.items || data.data || data.results || [];
      }
      
      console.log('No recognizable format, returning empty array');
      return [];
    })
    .catch(err => {
      console.error('Error fetching itineraries:', err);
      // If we get a network error in development, switch to mock data for future requests
      if (import.meta.env.DEV && err.code === 'ERR_NETWORK') {
        useMockData = true;
        console.info('Switching to mock data after network error');
        return MOCK_ITINERARIES;
      }
      throw err;
    });
}

function getItineraryById(id) {
  // If in development and backend is unavailable, return mock data
  if (useMockData) {
    const mockItinerary = MOCK_ITINERARIES.find(item => item.id === id);
    return Promise.resolve(mockItinerary || null);
  }

  console.log(`Fetching itinerary with ID: ${id}`);
  
  return api.get(`/itineraries/${id}`)
    .then(response => {
      console.log('Itinerary details response:', response);
      
      // The backend response format is:
      // { status: 'success', message: '...', data: { itinerary: {...} }, timestamp: '...' }
      const responseData = response.data;
      
      if (responseData && responseData.data && responseData.data.itinerary) {
        console.log('Found standard API response format with itinerary in data');
        return responseData.data.itinerary;
      } 
      else if (responseData && responseData.itinerary) {
        console.log('Found itinerary directly in response data');
        return responseData.itinerary;
      }
      else if (responseData && (responseData._id || responseData.id)) {
        console.log('Found ID directly in response data');
        return responseData;
      }
      
      console.log('Returning default response data');
      return responseData;
    })
    .catch(err => {
      console.error(`Error fetching itinerary ${id}:`, err);
      if (import.meta.env.DEV && err.code === 'ERR_NETWORK') {
        const mockItinerary = MOCK_ITINERARIES.find(item => item.id === id);
        return mockItinerary || null;
      }
      throw err;
    });
}

function createItinerary(formData) {
  // If in development and backend is unavailable, create mock data
  if (useMockData) {
    const newItinerary = {
      ...formData,
      id: `mock-${Date.now()}`,
      days: []
    };
    MOCK_ITINERARIES.push(newItinerary);
    return Promise.resolve(newItinerary);
  }

  // Transform the data to match the backend schema
  const itineraryData = {
    title: formData.title,
    description: formData.description || '',
    destination: {
      name: formData.destination
    },
    dateRange: {
      start: formData.startDate,
      end: formData.endDate
    },
    generateDays: true
  };

  // Add locations data if available
  if (formData.locations && formData.locations.length > 0) {
    // If there's at least one location, use it to set the main destination's location
    if (formData.locations.length > 0) {
      const mainLocation = formData.locations[0];
      itineraryData.destination.location = {
        type: 'Point',
        coordinates: [mainLocation.lng, mainLocation.lat]  // MongoDB uses [lng, lat] format
      };
    }
    
    // Add the full array of locations
    itineraryData.routeLocations = formData.locations.map(loc => ({
      name: loc.name,
      description: loc.description,
      placeId: loc.placeId,
      location: {
        type: 'Point',
        coordinates: [loc.lng, loc.lat]
      }
    }));
  }

  console.log('Sending itinerary data to backend:', itineraryData);

  return api.post('/itineraries', itineraryData)
    .then(response => {
      // Log the complete response to understand the structure
      console.log('Full API response:', response);
      
      // The backend response format is:
      // { status: 'success', message: '...', data: { itinerary: {...} }, timestamp: '...' }
      const responseData = response.data;
      
      if (responseData && responseData.data && responseData.data.itinerary) {
        console.log('Found standard API response format with itinerary in data');
        return responseData.data.itinerary;
      } 
      else if (responseData && responseData.itinerary) {
        console.log('Found itinerary directly in response data');
        return responseData.itinerary;
      }
      else if (responseData && (responseData._id || responseData.id)) {
        console.log('Found ID directly in response data');
        return responseData;
      }
      
      console.log('Returning default response data');
      return responseData;
    })
    .catch(err => {
      console.error('Error creating itinerary:', err);
      if (import.meta.env.DEV && err.code === 'ERR_NETWORK') {
        const newItinerary = {
          ...formData,
          id: `mock-${Date.now()}`,
          days: []
        };
        MOCK_ITINERARIES.push(newItinerary);
        useMockData = true;
        return newItinerary;
      }
      throw err;
    });
}

function updateItinerary(id, formData) {
  // If in development and backend is unavailable, update mock data
  if (useMockData) {
    const index = MOCK_ITINERARIES.findIndex(item => item.id === id);
    if (index !== -1) {
      MOCK_ITINERARIES[index] = { ...MOCK_ITINERARIES[index], ...formData };
      return Promise.resolve(MOCK_ITINERARIES[index]);
    }
    return Promise.reject(new Error('Itinerary not found'));
  }

  // Transform the data to match the backend schema
  let itineraryData = {};
  
  if (formData.title) itineraryData.title = formData.title;
  if (formData.description !== undefined) itineraryData.description = formData.description;
  
  if (formData.destination) {
    itineraryData.destination = { 
      name: formData.destination 
    };
  }
  
  if (formData.startDate && formData.endDate) {
    itineraryData.dateRange = {
      start: formData.startDate,
      end: formData.endDate
    };
  }

  // Add locations data if available
  if (formData.locations && formData.locations.length > 0) {
    // If there's at least one location, use it to set the main destination's location
    if (formData.locations.length > 0) {
      const mainLocation = formData.locations[0];
      if (!itineraryData.destination) {
        itineraryData.destination = {};
      }
      itineraryData.destination.location = {
        type: 'Point',
        coordinates: [mainLocation.lng, mainLocation.lat]  // MongoDB uses [lng, lat] format
      };
    }
    
    // Add the full array of locations
    itineraryData.routeLocations = formData.locations.map(loc => ({
      name: loc.name,
      description: loc.description,
      placeId: loc.placeId,
      location: {
        type: 'Point',
        coordinates: [loc.lng, loc.lat]
      }
    }));
  }

  return api.put(`/itineraries/${id}`, itineraryData)
    .then(response => {
      // The backend might return { itinerary: {...} } or just the itinerary object
      const data = response.data;
      return data.itinerary || data;
    });
}

function deleteItinerary(id) {
  // If in development and backend is unavailable, delete from mock data
  if (useMockData) {
    const index = MOCK_ITINERARIES.findIndex(item => item.id === id);
    if (index !== -1) {
      MOCK_ITINERARIES.splice(index, 1);
      return Promise.resolve({ success: true });
    }
    return Promise.reject(new Error('Itinerary not found'));
  }

  return api.delete(`/itineraries/${id}`)
    .then(response => response.data);
}

function addDayToItinerary(itineraryId, dayData) {
  // If in development and backend is unavailable, add day to mock data
  if (useMockData) {
    const itinerary = MOCK_ITINERARIES.find(item => item.id === itineraryId);
    if (itinerary) {
      const newDay = { ...dayData, id: `day-${Date.now()}`, activities: [] };
      if (!itinerary.days) {
        itinerary.days = [];
      }
      itinerary.days.push(newDay);
      return Promise.resolve(itinerary);
    }
    return Promise.reject(new Error('Itinerary not found'));
  }

  return api.post(`/itineraries/${itineraryId}/days`, dayData)
    .then(response => response.data);
}

/**
 * Generate an AI-powered itinerary using the external API
 * @param {Object} data - Itinerary generation parameters
 * @param {string} data.source - Starting location
 * @param {string} data.destination - Main destination
 * @param {string[]} data.activities_to_attend - List of activities or places to include
 * @param {string[]} data.date_range - Array with start and end dates ["YYYY-MM-DD", "YYYY-MM-DD"]
 * @param {string} data.budget - Budget amount with currency (e.g., "25000 INR")
 * @param {number} data.numberofpeople - Number of travelers
 * @returns {Promise<Object>} The generated itinerary data
 */
function generateAIItinerary(data) {
  // If in development and backend is unavailable, return mock data
  if (useMockData) {
    console.log('Using mock data for AI itinerary generation');
    
    // Create a simple mock response that mimics the expected format
    const mockResponse = {
      message: "Itinerary generated successfully",
      itinerary: {
        day_wise_plan: [
          {
            day: `Day 1 (${data.date_range[0]})`,
            destination: `Travel from ${data.source} to ${data.destination}`,
            activities: [
              `Travel Day: ${data.source} to ${data.destination}`,
              "Check into Hotel"
            ],
            accomodations: [
              {
                name: "Sample Hotel",
                price_range: "INR 5000-7000"
              }
            ],
            restaurants: [
              {
                name: "Sample Restaurant",
                cuisine: "Local Cuisine",
                price_range: "INR 800-1200"
              }
            ],
            estimated_cost: "INR 7000-10000"
          },
          {
            day: `Day 2 (${new Date(new Date(data.date_range[0]).getTime() + 86400000).toISOString().split('T')[0]})`,
            destination: data.destination,
            activities: data.activities_to_attend.slice(0, 2),
            accomodations: [
              {
                name: "Sample Hotel",
                price_range: "INR 5000-7000"
              }
            ],
            restaurants: [
              {
                name: "Another Restaurant",
                cuisine: "International",
                price_range: "INR 1000-1500"
              }
            ],
            estimated_cost: "INR 6000-8000"
          }
        ],
        additional_suggestions: {
          restaurants: [
            "Try local street food for an authentic experience.",
            "Visit the main market area for diverse dining options."
          ],
          transportation: [
            "Use public transport for cost savings.",
            "Consider renting a car for day trips."
          ]
        }
      }
    };
    
    return Promise.resolve(mockResponse);
  }
  
  console.log('Sending data to AI itinerary generator (via backend):', data);
  
  // Make sure all required data is present
  if (!data.source || !data.destination || !data.activities_to_attend || 
      !data.date_range || !data.budget || !data.numberofpeople) {
    return Promise.reject(new Error('Missing required fields for itinerary generation'));
  }
  
  // Call our backend API endpoint which will proxy to the external service
  return api.post('/ai/generate-itinerary', data)
    .then(response => {
      console.log('AI itinerary generation response:', response);
      
      // Handle different response formats
      const responseData = response.data;
      
      // Check if response has the expected structure
      if (responseData.status === 'success' && responseData.data && responseData.data.itinerary) {
        return {
          message: responseData.message,
          itinerary: responseData.data.itinerary
        };
      }
      
      // If the external API returns directly without our backend wrapper
      if (responseData.itinerary) {
        return responseData;
      }
      
      // Fallback for any other format
      console.warn('Unexpected response format from AI service:', responseData);
      return {
        message: "Itinerary generated with unexpected format",
        itinerary: responseData
      };
    })
    .catch(error => {
      console.error('Error generating AI itinerary:', error);
      
      // If we get a network error and are in development, switch to mock data
      if (import.meta.env.DEV && (error.code === 'ERR_NETWORK' || error.message?.includes('Network Error'))) {
        console.info('Network error encountered, using mock data instead');
        useMockData = true;
        
        return generateAIItinerary(data); // Re-call this function which will now use mock data
      }
      
      throw error;
    });
}

function addCollaboratorToItinerary(itineraryId, email, role) {
  // If in development and backend is unavailable, use mock data
  if (useMockData) {
    const mockItinerary = MOCK_ITINERARIES.find(item => item.id === itineraryId);
    if (mockItinerary) {
      if (!mockItinerary.collaborators) {
        mockItinerary.collaborators = [];
      }
      mockItinerary.collaborators.push({
        user: {
          id: `mock-user-${Date.now()}`,
          email,
          name: email.split('@')[0]
        },
        role
      });
      return Promise.resolve(mockItinerary);
    }
    return Promise.reject(new Error('Itinerary not found'));
  }

  return api.post(`/itineraries/${itineraryId}/collaborators`, { email, role })
    .then(response => {
      console.log('Add collaborator response:', response);
      const data = response.data;
      return data.itinerary || data;
    })
    .catch(err => {
      console.error(`Error adding collaborator to itinerary ${itineraryId}:`, err);
      throw err;
    });
}

function removeCollaboratorFromItinerary(itineraryId, collaboratorId) {
  // If in development and backend is unavailable, use mock data
  if (useMockData) {
    const mockItinerary = MOCK_ITINERARIES.find(item => item.id === itineraryId);
    if (mockItinerary && mockItinerary.collaborators) {
      mockItinerary.collaborators = mockItinerary.collaborators.filter(
        c => c.user.id !== collaboratorId
      );
      return Promise.resolve(mockItinerary);
    }
    return Promise.reject(new Error('Itinerary or collaborator not found'));
  }

  return api.delete(`/itineraries/${itineraryId}/collaborators/${collaboratorId}`)
    .then(response => {
      console.log('Remove collaborator response:', response);
      const data = response.data;
      return data.itinerary || data;
    })
    .catch(err => {
      console.error(`Error removing collaborator from itinerary ${itineraryId}:`, err);
      throw err;
    });
}

/**
 * Save an AI-generated itinerary to the database
 * @param {Object} generatedItinerary - The AI-generated itinerary data
 * @param {Object} formData - Basic itinerary information
 * @returns {Promise<Object>} The saved itinerary
 */
function saveGeneratedItinerary(generatedItinerary, formData) {
  // If in development and backend is unavailable, create mock data
  if (useMockData) {
    const newItinerary = {
      ...formData,
      id: `mock-${Date.now()}`,
      days: generatedItinerary.day_wise_plan.map((day, index) => ({
        id: `day-${index}`,
        dayNumber: index + 1,
        date: day.day.includes('(') ? day.day.split('(')[1].split(')')[0] : null,
        activities: day.activities.map((activity, actIdx) => ({
          id: `act-${index}-${actIdx}`,
          title: activity,
          startTime: '09:00',
          endTime: '17:00'
        }))
      }))
    };
    MOCK_ITINERARIES.push(newItinerary);
    return Promise.resolve(newItinerary);
  }

  // Transform the data to match the backend schema
  const itineraryData = {
    title: formData.title,
    description: formData.description || `Generated itinerary to ${formData.destination}`,
    destination: {
      name: formData.destination
    },
    dateRange: {
      start: formData.startDate,
      end: formData.endDate
    }
  };

  // Create an array to hold the days data
  const daysData = generatedItinerary.day_wise_plan.map(day => {
    // Extract date from the day string if available (e.g., "Day 1 (2024-01-24)")
    let date = null;
    if (day.day && day.day.includes('(') && day.day.includes(')')) {
      const dateMatch = day.day.match(/\(([^)]+)\)/);
      if (dateMatch && dateMatch[1]) {
        date = dateMatch[1];
      }
    }

    return {
      date: date,
      activities: day.activities.map(activity => ({
        title: activity,
        description: '',
        startTime: '09:00', // Default time
        endTime: '17:00',   // Default time
        type: 'activity'
      })),
      notes: `Destination: ${day.destination}\nEstimated Cost: ${day.estimated_cost}`
    };
  });

  console.log('Sending generated itinerary data to backend:', { itinerary: itineraryData, days: daysData });

  // First create the itinerary
  return api.post('/itineraries', itineraryData)
    .then(response => {
      const savedItinerary = response.data.data?.itinerary || response.data;
      const itineraryId = savedItinerary._id || savedItinerary.id;

      if (!itineraryId) {
        throw new Error('Failed to create itinerary');
      }

      console.log('Created base itinerary:', savedItinerary);

      // Now add each day to the itinerary
      const dayPromises = daysData.map((dayData, index) => {
        return addDayToItinerary(itineraryId, {
          ...dayData,
          dayNumber: index + 1
        });
      });

      // Wait for all days to be added
      return Promise.all(dayPromises)
        .then(() => {
          // Return the full itinerary
          return getItineraryById(itineraryId);
        });
    });
}

// Create the service object
const itineraryService = {
  getItineraries,
  getItineraryById,
  createItinerary,
  updateItinerary,
  deleteItinerary,
  addDayToItinerary,
  generateAIItinerary,
  saveGeneratedItinerary,
  addCollaboratorToItinerary,
  removeCollaboratorFromItinerary
};

// Export as default
export default itineraryService;

// Also export as named for destructuring imports
export { itineraryService };

// Export individual functions for direct imports
export {
  getItineraries,
  getItineraryById,
  createItinerary,
  updateItinerary,
  deleteItinerary,
  addDayToItinerary,
  generateAIItinerary,
  saveGeneratedItinerary,
  addCollaboratorToItinerary,
  removeCollaboratorFromItinerary
}; 