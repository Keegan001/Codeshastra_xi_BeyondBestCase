import { Link } from 'react-router-dom'
import { useSelector, useDispatch } from 'react-redux'
import { useState, useEffect } from 'react'
import { logoutUser } from '../store/slices/authSlice'
import { FaBell } from 'react-icons/fa'
import api from '../services/api'

function Navbar() {
  const { isAuthenticated, user } = useSelector(state => state.auth)
  const dispatch = useDispatch()
  const [hasPendingRequests, setHasPendingRequests] = useState(false)

  // Check for pending join requests when user is authenticated
  useEffect(() => {
    if (isAuthenticated && user?._id) {
      checkPendingJoinRequests()
    }
  }, [isAuthenticated, user])

  const checkPendingJoinRequests = async () => {
    try {
      // Get all itineraries the user owns
      const response = await api.get('/itineraries')
      
      if (response.data.success) {
        const itineraries = response.data.data.itineraries || []
        
        // Find itineraries owned by the current user
        const ownedItineraries = itineraries.filter(itinerary => 
          itinerary.owner?._id === user._id || 
          itinerary.owner === user._id
        )
        
        // Check for pending join requests
        let foundPending = false
        
        for (const itinerary of ownedItineraries) {
          if (!itinerary.isPrivate && itinerary.publiclyJoinable) {
            try {
              const requestsResponse = await api.get(`/itineraries/${itinerary._id}/join-requests`)
              
              if (requestsResponse.data.success) {
                const joinRequests = requestsResponse.data.data?.joinRequests || []
                const pendingRequests = joinRequests.filter(req => req.status === 'pending')
                
                if (pendingRequests.length > 0) {
                  foundPending = true
                  break
                }
              }
            } catch (error) {
              console.error(`Error checking join requests for itinerary ${itinerary._id}:`, error)
            }
          }
        }
        
        setHasPendingRequests(foundPending)
      }
    } catch (error) {
      console.error('Error checking for pending join requests:', error)
    }
  }

  function handleLogout() {
    dispatch(logoutUser())
  }

  return (
    <nav className="bg-indigo-600 text-white shadow">
      <div className="container mx-auto px-4 py-3">
        <div className="flex justify-between items-center">
          <div className="flex items-center space-x-4">
            <Link to="/" className="text-xl font-bold">
              Travel Planner
            </Link>
            <div className="hidden md:flex space-x-4">
              <Link to="/" className="hover:text-indigo-200">
                Home
              </Link>
              {isAuthenticated && (
                <Link to="/itineraries" className="hover:text-indigo-200">
                  My Itineraries
                </Link>
              )}
              <Link to="/itineraries/explore" className="hover:text-indigo-200">
                Explore
              </Link>
              <Link to="/about" className="hover:text-indigo-200">
                About
              </Link>
            </div>
          </div>
          
          <div className="flex items-center space-x-4">
            {isAuthenticated ? (
              <>
                <span className="hidden md:inline">
                  Welcome, {user?.name || 'User'}
                </span>
                {hasPendingRequests && (
                  <Link to="/itineraries" className="relative">
                    <FaBell className="text-yellow-300 animate-pulse" />
                    <span className="absolute top-0 right-0 -mt-1 -mr-1 bg-red-500 text-white text-xs rounded-full w-4 h-4 flex items-center justify-center">
                      !
                    </span>
                  </Link>
                )}
                <Link to="/profile" className="hover:text-indigo-200">
                  Profile
                </Link>
                <button 
                  onClick={handleLogout}
                  className="hover:text-indigo-200"
                >
                  Logout
                </button>
              </>
            ) : (
              <>
                <Link to="/login" className="hover:text-indigo-200">
                  Login
                </Link>
                <Link 
                  to="/register" 
                  className="bg-white text-indigo-600 px-4 py-2 rounded hover:bg-indigo-100"
                >
                  Sign Up
                </Link>
              </>
            )}
          </div>
        </div>
      </div>
    </nav>
  )
}

export default Navbar 