import api from './api'

function searchPlaces(query) {
  return api.get(`/places/search?query=${encodeURIComponent(query)}`)
    .then(response => response.data)
}

function getPlaceById(id) {
  return api.get(`/places/${id}`)
    .then(response => response.data)
}

export {
  searchPlaces,
  getPlaceById
} 