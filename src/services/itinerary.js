import api from './api'

function getItineraries() {
  return api.get('/itineraries')
    .then(response => response.data)
}

function getItineraryById(id) {
  return api.get(`/itineraries/${id}`)
    .then(response => response.data)
}

function createItinerary(itineraryData) {
  return api.post('/itineraries', itineraryData)
    .then(response => response.data)
}

function updateItinerary(id, itineraryData) {
  return api.put(`/itineraries/${id}`, itineraryData)
    .then(response => response.data)
}

function deleteItinerary(id) {
  return api.delete(`/itineraries/${id}`)
    .then(response => response.data)
}

function addDayToItinerary(itineraryId, dayData) {
  return api.post(`/itineraries/${itineraryId}/days`, dayData)
    .then(response => response.data)
}

export {
  getItineraries,
  getItineraryById,
  createItinerary,
  updateItinerary,
  deleteItinerary,
  addDayToItinerary
} 