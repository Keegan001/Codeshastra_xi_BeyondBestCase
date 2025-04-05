import { useState } from 'react';
import { useDispatch } from 'react-redux';
import { addCollaborator, removeCollaborator } from '../store/slices/itinerarySlice';

function GroupItineraryMembers({ itinerary, isOwner }) {
  const dispatch = useDispatch();
  const [email, setEmail] = useState('');
  const [role, setRole] = useState('viewer');
  const [error, setError] = useState(null);
  const [isAdding, setIsAdding] = useState(false);

  // Extract collaborators safely
  const collaborators = itinerary?.collaborators || [];
  
  // Get itinerary ID (handle different API formats)
  const itineraryId = itinerary?.id || itinerary?._id || itinerary?.uuid;
  
  // Check if the itinerary has owner data for display
  const hasOwnerData = itinerary && itinerary.owner && 
    (itinerary.owner.name || itinerary.owner.email);
    
  // For the owner display
  const ownerName = hasOwnerData ? (itinerary.owner.name || itinerary.owner.email) : 'Owner';
  const ownerEmail = hasOwnerData ? itinerary.owner.email : '';
  
  // Handle adding a new collaborator
  const handleAddCollaborator = (e) => {
    e.preventDefault();
    
    if (!email.trim()) {
      setError('Email is required');
      return;
    }
    
    if (!email.includes('@')) {
      setError('Please enter a valid email address');
      return;
    }
    
    setError(null);
    setIsAdding(true);
    
    dispatch(addCollaborator({ itineraryId, email, role }))
      .unwrap()
      .then(() => {
        setEmail('');
        setIsAdding(false);
      })
      .catch(err => {
        console.error('Failed to add collaborator:', err);
        setError(typeof err === 'string' ? err : 'Failed to add collaborator. User may not exist.');
        setIsAdding(false);
      });
  };
  
  // Handle removing a collaborator
  const handleRemoveCollaborator = (collaboratorId) => {
    if (window.confirm('Are you sure you want to remove this member from the itinerary?')) {
      dispatch(removeCollaborator({ itineraryId, collaboratorId }))
        .catch(err => {
          console.error('Failed to remove collaborator:', err);
          setError(typeof err === 'string' ? err : 'Failed to remove collaborator');
        });
    }
  };
  
  // If not the owner, just show the list of collaborators
  if (!isOwner) {
    return (
      <div className="bg-white rounded-lg shadow-md overflow-hidden mb-8">
        <div className="p-6">
          <h2 className="text-xl font-bold mb-4">Group Members</h2>
          
          {collaborators.length === 0 ? (
            <p className="text-gray-500">No other members in this itinerary.</p>
          ) : (
            <ul className="divide-y divide-gray-200">
              {collaborators.map(collaborator => (
                <li key={collaborator.user._id || collaborator.user.id} className="py-3 flex justify-between items-center">
                  <div>
                    <p className="font-medium">{collaborator.user.name || collaborator.user.email}</p>
                    <p className="text-sm text-gray-500">{collaborator.user.email}</p>
                  </div>
                  <span className="px-2 py-1 text-xs rounded-full bg-indigo-100 text-indigo-800">
                    {collaborator.role === 'editor' ? 'Editor' : 'Viewer'}
                  </span>
                </li>
              ))}
            </ul>
          )}
        </div>
      </div>
    );
  }
  
  // For the owner, show the list with add/remove capabilities
  return (
    <div className="bg-white rounded-lg shadow-md overflow-hidden mb-8">
      <div className="p-6">
        <h2 className="text-xl font-bold mb-4">Group Members</h2>
        
        <form onSubmit={handleAddCollaborator} className="mb-6">
          <div className="mb-4">
            <label htmlFor="email" className="block text-sm font-medium text-gray-700 mb-1">
              Add member by email
            </label>
            <div className="flex space-x-2">
              <input
                type="email"
                id="email"
                value={email}
                onChange={(e) => {
                  setEmail(e.target.value);
                  setError(null);
                }}
                placeholder="Email address"
                className="flex-1 px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
                disabled={isAdding}
              />
              <select
                value={role}
                onChange={(e) => setRole(e.target.value)}
                className="px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
                disabled={isAdding}
              >
                <option value="viewer">Viewer</option>
                <option value="editor">Editor</option>
              </select>
              <button
                type="submit"
                className="bg-indigo-600 text-white px-4 py-2 rounded-lg hover:bg-indigo-700 disabled:bg-indigo-300"
                disabled={isAdding}
              >
                {isAdding ? 'Adding...' : 'Add'}
              </button>
            </div>
            {error && (
              <p className="mt-2 text-sm text-red-600">{error}</p>
            )}
            <p className="mt-2 text-xs text-gray-500">
              Note: Members must have an existing account on this platform to be added.
            </p>
          </div>
        </form>
        
        <div>
          <h3 className="font-medium text-gray-700 mb-3">Current Members</h3>
          
          {/* Show the owner first */}
          {hasOwnerData && (
            <div className="py-3 flex justify-between items-center border-b border-gray-200">
              <div>
                <p className="font-medium">{ownerName}</p>
                <p className="text-sm text-gray-500">{ownerEmail}</p>
              </div>
              <span className="px-2 py-1 text-xs rounded-full bg-green-100 text-green-800">
                Owner
              </span>
            </div>
          )}
          
          {collaborators.length === 0 ? (
            <p className="text-gray-500 py-3">No other members in this itinerary.</p>
          ) : (
            <ul className="divide-y divide-gray-200">
              {collaborators.map(collaborator => (
                <li key={collaborator.user._id || collaborator.user.id} className="py-3 flex justify-between items-center">
                  <div>
                    <p className="font-medium">{collaborator.user.name || collaborator.user.email}</p>
                    <p className="text-sm text-gray-500">{collaborator.user.email}</p>
                  </div>
                  <div className="flex items-center space-x-2">
                    <span className="px-2 py-1 text-xs rounded-full bg-indigo-100 text-indigo-800">
                      {collaborator.role === 'editor' ? 'Editor' : 'Viewer'}
                    </span>
                    <button
                      onClick={() => handleRemoveCollaborator(collaborator.user._id || collaborator.user.id)}
                      className="text-red-600 hover:text-red-800"
                      title="Remove member"
                    >
                      <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
                        <path fillRule="evenodd" d="M9 2a1 1 0 00-.894.553L7.382 4H4a1 1 0 000 2v10a2 2 0 002 2h8a2 2 0 002-2V6a1 1 0 100-2h-3.382l-.724-1.447A1 1 0 0011 2H9zM7 8a1 1 0 012 0v6a1 1 0 11-2 0V8zm5-1a1 1 0 00-1 1v6a1 1 0 102 0V8a1 1 0 00-1-1z" clipRule="evenodd" />
                      </svg>
                    </button>
                  </div>
                </li>
              ))}
            </ul>
          )}
        </div>
      </div>
    </div>
  );
}

export default GroupItineraryMembers; 