import { Link } from 'react-router-dom'
import { useSelector, useDispatch } from 'react-redux'
import { logoutUser } from '../store/slices/authSlice'

function Navbar() {
  const { isAuthenticated, user } = useSelector(state => state.auth)
  const dispatch = useDispatch()

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