import React, { useState, useEffect, useRef } from 'react';
import { useSelector } from 'react-redux';
import axios from 'axios';
import { toast } from 'react-toastify';
import { io } from 'socket.io-client';
import api from '../services/api';

const DayComments = ({ dayId }) => {
  const { token, user } = useSelector(state => state.auth);
  const [comments, setComments] = useState([]);
  const [newComment, setNewComment] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [socket, setSocket] = useState(null);
  const commentsEndRef = useRef(null);
  const [error, setError] = useState(null);
  
  // Initialize socket connection
  useEffect(() => {
    // Get token directly from localStorage to ensure it's the most current
    const authToken = localStorage.getItem('token');
    if (!authToken) {
      setError('Authentication required to view comments');
      return;
    }
    
    const socketInstance = io('http://localhost:5000', {
      auth: { token: authToken },
      reconnectionAttempts: 5,
      reconnectionDelay: 1000,
      timeout: 5000
    });
    
    socketInstance.on('connect', () => {
      console.log('Socket connected');
      // Join day room
      socketInstance.emit('join-day', dayId);
      // Clear any socket-related errors
      if (error && error.includes('Socket')) {
        setError(null);
      }
    });
    
    socketInstance.on('connect_error', (err) => {
      console.error('Socket connection error:', err.message);
      setError(`Socket connection error: ${err.message}`);
      // Fallback to regular polling if socket connection fails
      fetchComments();
    });

    socketInstance.on('disconnect', (reason) => {
      console.log('Socket disconnected:', reason);
      if (reason === 'io server disconnect') {
        // the disconnection was initiated by the server, reconnect manually
        socketInstance.connect();
      }
      // fallback to polling if socket is disconnected
      fetchComments();
    });
    
    socketInstance.on('new-comment', (data) => {
      if (data.dayId === dayId) {
        setComments(prev => [...prev, data.comment]);
      }
    });
    
    socketInstance.on('comment-deleted', (data) => {
      if (data.dayId === dayId) {
        setComments(prev => prev.filter(c => c.id !== data.commentId));
      }
    });
    
    socketInstance.on('error', (error) => {
      console.error('Socket error:', error);
      toast.error('Socket error: ' + error.message);
    });
    
    setSocket(socketInstance);
    
    return () => {
      if (socketInstance) {
        socketInstance.disconnect();
      }
    };
  }, [dayId]);
  
  // Fetch comments when component mounts
  useEffect(() => {
    if (dayId) {
      fetchComments();
    }
  }, [dayId]);
  
  // Scroll to bottom when comments change
  useEffect(() => {
    scrollToBottom();
  }, [comments]);
  
  const fetchComments = async () => {
    try {
      setIsLoading(true);
      setError(null);
      
      // Use the api service which automatically adds auth headers
      console.log('Fetching comments for day:', dayId);
      
      const response = await api.get(`/comments/day/${dayId}`);
      
      console.log('Comments response:', response.data);
      
      if (response.data && response.data.status === 'success') {
        setComments(response.data.data.comments || []);
      } else {
        setError('Failed to fetch comments');
      }
    } catch (error) {
      console.error('Error fetching comments:', error);
      
      // Provide more specific error messages based on response status
      if (error.response) {
        console.log('Error response status:', error.response.status);
        console.log('Error response data:', error.response.data);
        
        if (error.response.status === 403) {
          setError('You don\'t have permission to view these comments');
        } else if (error.response.status === 401) {
          setError('Please login to view comments');
        } else if (error.response.status === 404) {
          // If comments not found, just set empty array instead of showing error
          setComments([]);
          setError(null);
        } else {
          setError(`Failed to fetch comments: ${error.response.data?.message || 'Server error'}`);
        }
      } else {
        setError('Failed to connect to the server');
      }
    } finally {
      setIsLoading(false);
    }
  };
  
  const handleAddComment = async (e) => {
    e.preventDefault();
    
    if (!newComment.trim()) {
      toast.error('Comment text is required');
      return;
    }
    
    try {
      setIsLoading(true);
      setError(null);
      
      // Using socket to add comment
      if (socket && socket.connected) {
        socket.emit('add-comment', {
          dayId,
          text: newComment
        });
        
        // Clear input field
        setNewComment('');
      } else {
        // Fallback to REST API if socket is not available
        console.log('Adding comment via REST API');
        
        // Use the api service instead of direct axios
        const response = await api.post(
          `/comments/day/${dayId}`,
          { text: newComment }
        );
        
        if (response.data.status === 'success') {
          setComments(prev => [...prev, response.data.data.comment]);
          setNewComment('');
        }
      }
    } catch (error) {
      console.error('Error adding comment:', error);
      
      if (error.response?.status === 403) {
        setError('You don\'t have permission to add comments');
      } else {
        setError(`Failed to add comment: ${error.response?.data?.message || error.message}`);
      }
    } finally {
      setIsLoading(false);
    }
  };
  
  const handleDeleteComment = async (commentId) => {
    try {
      setIsLoading(true);
      setError(null);
      
      console.log('Deleting comment:', commentId);
      
      // Use the api service instead of direct axios
      const response = await api.delete(
        `/comments/day/${dayId}/comments/${commentId}`
      );
      
      if (response.data.status === 'success') {
        setComments(prev => prev.filter(c => c.id !== commentId));
        toast.success('Comment deleted successfully');
      }
    } catch (error) {
      console.error('Error deleting comment:', error);
      
      if (error.response?.status === 403) {
        setError('You don\'t have permission to delete this comment');
      } else {
        setError('Failed to delete comment');
      }
    } finally {
      setIsLoading(false);
    }
  };
  
  const scrollToBottom = () => {
    commentsEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };
  
  const formatTimestamp = (timestamp) => {
    const date = new Date(timestamp);
    return date.toLocaleString('en-US', {
      month: 'short',
      day: 'numeric',
      hour: 'numeric',
      minute: 'numeric',
      hour12: true
    });
  };
  
  return (
    <div className="bg-white rounded-lg shadow-md p-6 mb-6">
      <div className="flex justify-between items-center mb-4">
        <h2 className="text-xl font-bold">Comments</h2>
        
        <button 
          onClick={() => fetchComments()} 
          className="text-indigo-600 hover:text-indigo-800 flex items-center"
          title="Refresh comments"
          disabled={isLoading}
        >
          <svg xmlns="http://www.w3.org/2000/svg" className={`h-5 w-5 ${isLoading ? 'animate-spin' : ''}`} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
            <path strokeLinecap="round" strokeLinejoin="round" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
          </svg>
          {isLoading && <span className="ml-1">Loading...</span>}
        </button>
      </div>
      
      {error && (
        <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded mb-4 flex justify-between items-center">
          <p>{error}</p>
          <button 
            onClick={() => fetchComments()} 
            className="text-red-700 hover:text-red-900 ml-2"
            title="Try again"
          >
            Try again
          </button>
        </div>
      )}
      
      <div className="bg-gray-50 p-4 rounded-lg mb-4 max-h-96 overflow-y-auto">
        {isLoading && comments.length === 0 ? (
          <div className="text-center py-4">
            <div className="inline-block animate-spin rounded-full h-8 w-8 border-t-2 border-b-2 border-indigo-500"></div>
            <p className="mt-2 text-gray-500">Loading comments...</p>
          </div>
        ) : comments.length === 0 ? (
          <p className="text-gray-500 text-center py-4">No comments yet. Be the first to comment!</p>
        ) : (
          <div className="space-y-4">
            {comments.map(comment => (
              <div key={comment.id} className="bg-white p-3 rounded-lg shadow-sm">
                <div className="flex justify-between items-start">
                  <div>
                    <div className="font-medium text-indigo-700">{comment.user.name}</div>
                    <div className="text-sm text-gray-500">{formatTimestamp(comment.createdAt)}</div>
                  </div>
                  {comment.user.id === user?.id && (
                    <button
                      onClick={() => handleDeleteComment(comment.id)}
                      className="text-red-600 hover:text-red-800"
                      title="Delete comment"
                    >
                      <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
                        <path fillRule="evenodd" d="M9 2a1 1 0 00-.894.553L7.382 4H4a1 1 0 000 2v10a2 2 0 002 2h8a2 2 0 002-2V6a1 1 0 100-2h-3.382l-.724-1.447A1 1 0 0011 2H9zM7 8a1 1 0 012 0v6a1 1 0 11-2 0V8zm5-1a1 1 0 00-1 1v6a1 1 0 102 0V8a1 1 0 00-1-1z" clipRule="evenodd" />
                      </svg>
                    </button>
                  )}
                </div>
                <p className="mt-2">{comment.text}</p>
              </div>
            ))}
            <div ref={commentsEndRef} />
          </div>
        )}
      </div>
      
      <form onSubmit={handleAddComment} className="flex space-x-2">
        <input
          type="text"
          value={newComment}
          onChange={(e) => setNewComment(e.target.value)}
          placeholder="Add a comment..."
          className="flex-1 px-4 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-indigo-500"
          disabled={isLoading}
        />
        <button
          type="submit"
          className="bg-indigo-600 text-white px-4 py-2 rounded hover:bg-indigo-700 disabled:bg-indigo-300"
          disabled={isLoading}
        >
          {isLoading ? 'Posting...' : 'Post'}
        </button>
      </form>
    </div>
  );
};

export default DayComments; 