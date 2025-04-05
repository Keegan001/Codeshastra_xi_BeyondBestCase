import { Link } from 'react-router-dom'
import { useSelector, useDispatch } from 'react-redux'
import { useState, useEffect } from 'react'
import { motion } from 'framer-motion'
import { logoutUser } from '../store/slices/authSlice'
import { 
  Bell, 
  Globe, 
  Home, 
  LogOut, 
  User, 
  Menu, 
  X, 
  Book,
  Info,
  LogIn,
  UserPlus
} from 'lucide-react'
import { Button } from './ui/button'
import api from '../services/api'
import "../pages/HeroSection.css" // Import our glassmorphism styles
import logo from '../assets/logo.svg' // Import our custom logo

function Navbar() {
  const { isAuthenticated, user } = useSelector(state => state.auth)
  const dispatch = useDispatch()
  const [hasPendingRequests, setHasPendingRequests] = useState(false)
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false)

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
    <motion.nav 
      className="sticky top-0 z-50 bg-gradient-to-r from-[#56288A] to-[#864BD8] text-white shadow-md nav-pattern"
      initial={{ y: -100 }}
      animate={{ y: 0 }}
      transition={{ duration: 0.5 }}
    >
      <div className="container mx-auto px-4 py-3">
        <div className="flex justify-between items-center">
          <div className="flex items-center space-x-6">
            <Link to="/" className="flex items-center group">
              <motion.div
                initial={{ rotate: 0 }}
                whileHover={{ rotate: 15, scale: 1.1 }}
                transition={{ duration: 0.3 }}
              >
                <img src={logo} alt="Safar Logo" className="h-10 w-10 mr-2" />
              </motion.div>
              <motion.span 
                className="text-2xl font-bold bg-clip-text text-transparent bg-gradient-to-r from-white to-amber-200"
                whileHover={{ scale: 1.05 }}
                transition={{ duration: 0.2 }}
              >
                Safar
              </motion.span>
            </Link>
            <div className="hidden md:flex space-x-6">
              <Link to="/" className="hover:text-indigo-200 flex items-center gap-2 group">
                <Home className="h-5 w-5 group-hover:text-amber-300 transition-colors" />
                <span>Home</span>
              </Link>
              {isAuthenticated && (
                <Link to="/itineraries" className="hover:text-indigo-200 flex items-center gap-2 group">
                  <Book className="h-5 w-5 group-hover:text-amber-300 transition-colors" />
                  <span>My Journeys</span>
                </Link>
              )}
              <Link to="/itineraries/explore" className="hover:text-indigo-200 flex items-center gap-2 group">
                <Globe className="h-5 w-5 group-hover:text-amber-300 transition-colors" />
                <span>Explore</span>
              </Link>
              <Link to="/about" className="hover:text-indigo-200 flex items-center gap-2 group">
                <Info className="h-5 w-5 group-hover:text-amber-300 transition-colors" />
                <span>About</span>
              </Link>
            </div>
          </div>
          
          <div className="hidden md:flex items-center space-x-4">
            {isAuthenticated ? (
              <div className="flex items-center space-x-4">
                <motion.div 
                  className="glass px-4 py-1.5 rounded-full flex items-center gap-2"
                  whileHover={{ scale: 1.02 }}
                  transition={{ duration: 0.2 }}
                >
                  <User className="h-4 w-4 text-amber-200" />
                  <span className="text-sm">
                    {user?.name || 'User'}
                  </span>
                </motion.div>
                
                {hasPendingRequests && (
                  <motion.div
                    whileHover={{ scale: 1.1 }}
                    whileTap={{ scale: 0.95 }}
                  >
                    <Link to="/itineraries" className="relative inline-block">
                      <Bell className="text-amber-300 w-5 h-5" />
                      <span className="absolute top-0 right-0 -mt-1 -mr-1 bg-red-500 text-white text-xs rounded-full w-4 h-4 flex items-center justify-center">
                        !
                      </span>
                    </Link>
                  </motion.div>
                )}
                
                <motion.div
                  whileHover={{ scale: 1.02 }}
                  transition={{ duration: 0.2 }}
                >
                  <Link to="/profile">
                    <Button 
                      variant="outline" 
                      size="default"
                      icon={<User className="h-4 w-4" />}
                    >
                      Profile
                    </Button>
                  </Link>
                </motion.div>
                
                <Button 
                  variant="outline" 
                  size="default"
                  icon={<LogOut className="h-4 w-4" />}
                  onClick={handleLogout}
                >
                  Logout
                </Button>
              </div>
            ) : (
              <div className="flex items-center space-x-4">
                <Link 
                  to="/login" 
                  className="flex items-center gap-1.5"
                >
                  <Button 
                    variant="outline" 
                    size="default"
                    icon={<LogIn className="h-4 w-4" />}
                  >
                    Login
                  </Button>
                </Link>
                
                <Link 
                  to="/register" 
                  className="flex items-center gap-1.5"
                >
                  <Button 
                    variant="glass" 
                    size="default"
                    icon={<UserPlus className="h-4 w-4" />}
                  >
                    Sign Up
                  </Button>
                </Link>
              </div>
            )}
          </div>
          
          {/* Mobile menu button */}
          <div className="md:hidden">
            <button 
              onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
              className="p-2 rounded-lg hover:bg-indigo-500 transition-colors"
            >
              {mobileMenuOpen ? (
                <X className="h-6 w-6" />
              ) : (
                <Menu className="h-6 w-6" />
              )}
            </button>
          </div>
        </div>
        
        {/* Mobile menu */}
        {mobileMenuOpen && (
          <motion.div 
            className="md:hidden mt-4 pb-4 space-y-3"
            initial={{ opacity: 0, height: 0 }}
            animate={{ opacity: 1, height: 'auto' }}
            transition={{ duration: 0.3 }}
          >
            <Link 
              to="/" 
              className="block py-2 px-3 rounded-lg hover:bg-indigo-500 flex items-center gap-2"
              onClick={() => setMobileMenuOpen(false)}
            >
              <Home className="h-5 w-5" />
              <span>Home</span>
            </Link>
            
            {isAuthenticated && (
              <Link 
                to="/itineraries" 
                className="block py-2 px-3 rounded-lg hover:bg-indigo-500 flex items-center gap-2"
                onClick={() => setMobileMenuOpen(false)}
              >
                <Book className="h-5 w-5" />
                <span>My Journeys</span>
              </Link>
            )}
            
            <Link 
              to="/itineraries/explore" 
              className="block py-2 px-3 rounded-lg hover:bg-indigo-500 flex items-center gap-2"
              onClick={() => setMobileMenuOpen(false)}
            >
              <Globe className="h-5 w-5" />
              <span>Explore</span>
            </Link>
            
            <Link 
              to="/about" 
              className="block py-2 px-3 rounded-lg hover:bg-indigo-500 flex items-center gap-2"
              onClick={() => setMobileMenuOpen(false)}
            >
              <Info className="h-5 w-5" />
              <span>About</span>
            </Link>
            
            {isAuthenticated ? (
              <>
                <Link 
                  to="/profile" 
                  className="block py-2 px-3 rounded-lg hover:bg-indigo-500 flex items-center gap-2"
                  onClick={() => setMobileMenuOpen(false)}
                >
                  <User className="h-5 w-5" />
                  <span>Profile</span>
                </Link>
                
                <button 
                  onClick={() => {
                    handleLogout();
                    setMobileMenuOpen(false);
                  }}
                  className="block w-full text-left py-2 px-3 rounded-lg hover:bg-indigo-500 flex items-center gap-2"
                >
                  <LogOut className="h-5 w-5" />
                  <span>Logout</span>
                </button>
              </>
            ) : (
              <>
                <Link 
                  to="/login" 
                  className="block py-2 px-3 rounded-lg hover:bg-indigo-500 flex items-center gap-2"
                  onClick={() => setMobileMenuOpen(false)}
                >
                  <LogIn className="h-5 w-5" />
                  <span>Login</span>
                </Link>
                
                <Link 
                  to="/register" 
                  className="block py-2 px-3 bg-white bg-opacity-20 backdrop-blur-sm rounded-lg hover:bg-opacity-30 flex items-center gap-2"
                  onClick={() => setMobileMenuOpen(false)}
                >
                  <UserPlus className="h-5 w-5" />
                  <span>Sign Up</span>
                </Link>
              </>
            )}
          </motion.div>
        )}
      </div>
    </motion.nav>
  )
}

export default Navbar 