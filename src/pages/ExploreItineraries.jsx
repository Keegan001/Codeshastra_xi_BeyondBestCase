import React, { useState, useEffect } from 'react';
import { useNavigate, Navigate } from 'react-router-dom';
import { toast } from 'react-toastify';
import { FaSearch, FaMapMarkerAlt, FaUserPlus, FaCheck, FaUser } from 'react-icons/fa';
import { useSelector, useDispatch } from 'react-redux';
import { fetchPublicItineraries } from '../store/slices/itinerarySlice';
import api from '../services/api';

// Components
import Loader from '../components/Loader';
import Pagination from '../components/Pagination';

const ExploreItineraries = () => {
  const [search, setSearch] = useState('');
  const [pagination, setPagination] = useState({
    page: 1,
    limit: 10
  });
  const [requestedItineraries, setRequestedItineraries] = useState([]);
  
  // Get authentication state and itineraries from Redux
  const { isAuthenticated, user } = useSelector(state => state.auth);
  const { publicItineraries, isLoading, error } = useSelector(state => state.itinerary);
  const dispatch = useDispatch();
  
  const navigate = useNavigate();

  // Redirect if not authenticated
  if (!isAuthenticated) {
    return <Navigate to="/login" />
  }

  useEffect(() => {
    if (isAuthenticated) {
      fetchItineraries();
    }
  }, [pagination.page, search, isAuthenticated]);

  const fetchItineraries = () => {
    if (!isAuthenticated) return;
    
    dispatch(fetchPublicItineraries({
      page: pagination.page,
      limit: pagination.limit,
      search
    }));
  };

  const handleSearch = (e) => {
    e.preventDefault();
    // Reset to first page when searching
    setPagination({ ...pagination, page: 1 });
    fetchItineraries();
  };

  const handlePageChange = (newPage) => {
    setPagination({ ...pagination, page: newPage });
  };

  const handleRequestJoin = async (itineraryId) => {
    try {
      const response = await api.post(
        `/itineraries/${itineraryId}/join-request`,
        {}
      );

      if (response.data.success) {
        toast.success('Join request sent successfully');
        // Add this itinerary to the requested list so we can disable the button
        setRequestedItineraries([...requestedItineraries, itineraryId]);
      }
    } catch (err) {
      console.error('Error requesting to join:', err);
      const errorMsg = err.response?.data?.message || 'Failed to send join request';
      toast.error(errorMsg);
    }
  };

  const viewItineraryDetails = (itineraryId) => {
    navigate(`/itineraries/${itineraryId}`);
  };

  // Check if the current user is the owner of an itinerary
  const isUserOwner = (itinerary) => {
    if (!user || !itinerary || !itinerary.owner) return false;
    
    // Get owner ID from itinerary
    const ownerId = itinerary.owner._id || itinerary.owner.id || itinerary.owner;
    
    // Get current user ID
    const userId = user._id || user.id;
    
    // Compare as strings to ensure proper comparison
    return String(ownerId) === String(userId);
  };

  // Check if the current user is a collaborator in an itinerary
  const isUserCollaborator = (itinerary) => {
    if (!user || !itinerary || !itinerary.collaborators) return false;
    
    // Get current user ID
    const userId = user._id || user.id;
    
    // Check if the user is in the collaborators array
    return itinerary.collaborators.some(collab => {
      const collaboratorId = collab.user._id || collab.user.id || collab.user;
      return String(collaboratorId) === String(userId);
    });
  };

  // Extract itineraries from Redux state
  const itineraries = publicItineraries?.data || [];
  const paginationInfo = publicItineraries?.pagination || { total: 0, pages: 0 };

  return (
    <div className="container mx-auto px-4 py-8">
      <h1 className="text-3xl font-bold mb-8 text-center">Explore Public Itineraries</h1>
      
      {/* Search Box */}
      <div className="mb-8">
        <form onSubmit={handleSearch} className="flex items-center">
          <div className="relative flex-grow">
            <input
              type="text"
              className="w-full p-3 pl-10 border border-gray-300 rounded-l-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
              placeholder="Search itineraries by title, destination..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
            />
            <FaSearch className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" />
          </div>
          <button
            type="submit"
            className="bg-indigo-600 text-white px-6 py-3 rounded-r-md hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-indigo-500"
          >
            Search
          </button>
        </form>
      </div>

      {/* Content section */}
      {isLoading ? (
        <div className="flex justify-center my-8">
          <Loader />
        </div>
      ) : error ? (
        <div className="text-center text-red-500 my-8">{error}</div>
      ) : itineraries.length === 0 ? (
        <div className="text-center text-gray-500 my-8">
          No public itineraries found. Try adjusting your search criteria.
        </div>
      ) : (
        <div>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {itineraries.map((itinerary) => (
              <div 
                key={itinerary._id}
                className="border border-gray-200 rounded-lg shadow-md overflow-hidden hover:shadow-lg transition-shadow"
              >
                <div className="bg-gray-100 h-40 flex items-center justify-center">
                  {itinerary.coverImage ? (
                    <img 
                      src={itinerary.coverImage} 
                      alt={itinerary.title} 
                      className="w-full h-full object-cover"
                    />
                  ) : (
                    <FaMapMarkerAlt className="text-5xl text-gray-400" />
                  )}
                </div>
                
                <div className="p-4">
                  <h2 className="text-xl font-semibold mb-2 text-indigo-700">{itinerary.title}</h2>
                  
                  <div className="mb-3 text-sm text-gray-600">
                    <div className="flex items-center mb-1">
                      <span className="font-medium">Creator:</span>
                      <span className="ml-2">
                        {isUserOwner(itinerary) ? (
                          <span className="flex items-center text-indigo-600">
                            {itinerary.owner?.username || 'You'} <FaUser className="ml-1" size={12} />
                          </span>
                        ) : (
                          itinerary.owner?.username || 'Anonymous'
                        )}
                      </span>
                    </div>
                    
                    <div className="flex items-center mb-1">
                      <span className="font-medium">Destinations:</span>
                      <span className="ml-2">
                        {itinerary.destinations?.join(', ') || itinerary.destination?.name || itinerary.destination || 'Not specified'}
                      </span>
                    </div>
                    
                    <div className="flex items-center">
                      <span className="font-medium">Duration:</span>
                      <span className="ml-2">
                        {itinerary.dateRange ? (
                          `${new Date(itinerary.dateRange.start).toLocaleDateString()} - ${new Date(itinerary.dateRange.end).toLocaleDateString()}`
                        ) : itinerary.startDate && itinerary.endDate ? (
                          `${new Date(itinerary.startDate).toLocaleDateString()} - ${new Date(itinerary.endDate).toLocaleDateString()}`
                        ) : 'Not specified'}
                      </span>
                    </div>
                  </div>
                  
                  <div className="flex justify-between mt-4">
                    <button
                      onClick={() => viewItineraryDetails(itinerary._id)}
                      className="px-4 py-2 bg-indigo-600 text-white rounded hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-indigo-500"
                    >
                      View Details
                    </button>
                    
                    {!isUserOwner(itinerary) && !isUserCollaborator(itinerary) && (
                      <button
                        onClick={() => handleRequestJoin(itinerary._id)}
                        disabled={requestedItineraries.includes(itinerary._id)}
                        className={`px-4 py-2 rounded flex items-center ${
                          requestedItineraries.includes(itinerary._id)
                            ? 'bg-green-500 text-white cursor-not-allowed'
                            : 'bg-blue-600 text-white hover:bg-blue-700'
                        }`}
                      >
                        {requestedItineraries.includes(itinerary._id) ? (
                          <>
                            <FaCheck className="mr-1" />
                            Requested
                          </>
                        ) : (
                          <>
                            <FaUserPlus className="mr-1" />
                            Join
                          </>
                        )}
                      </button>
                    )}
                    
                    {isUserCollaborator(itinerary) && (
                      <span className="px-4 py-2 bg-green-100 text-green-700 rounded flex items-center">
                        <FaCheck className="mr-1" />
                        Member
                      </span>
                    )}
                    
                    {isUserOwner(itinerary) && (
                      <span className="px-4 py-2 bg-gray-200 text-gray-700 rounded flex items-center">
                        Your Itinerary
                      </span>
                    )}
                  </div>
                </div>
              </div>
            ))}
          </div>
          
          {/* Pagination */}
          {paginationInfo.pages > 1 && (
            <div className="mt-8">
              <Pagination
                currentPage={pagination.page}
                totalPages={paginationInfo.pages}
                onPageChange={handlePageChange}
              />
            </div>
          )}
        </div>
      )}
    </div>
  );
};

export default ExploreItineraries; 