import { useState, useEffect } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { fetchItineraryById } from '../store/slices/itinerarySlice';
import { toast } from 'react-toastify';
import aiService from '../services/ai';

const AiEditItinerary = ({ itineraryId }) => {
  const [message, setMessage] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [aiResponse, setAiResponse] = useState('');
  const [showSuggestions, setShowSuggestions] = useState(false);
  const dispatch = useDispatch();
  
  // Get the current itinerary to get day information
  const { currentItinerary } = useSelector(state => state.itinerary);
  const dayCount = currentItinerary?.days?.length || 0;

  const handleMessageChange = (e) => {
    setMessage(e.target.value);
  };

  // Add handlers for preset messages
  const handlePresetMessage = (preset) => {
    setMessage(preset);
    // Focus on the textarea after setting the message
    document.getElementById('ai-message').focus();
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (!message.trim()) {
      toast.error('Please enter a message');
      return;
    }
    
    setIsLoading(true);
    setAiResponse('');
    
    try {
      const response = await aiService.editItineraryWithAI(itineraryId, message);
      
      setAiResponse(response.ai_message || 'Itinerary updated successfully');
      toast.success('Itinerary updated successfully');
      
      // Refresh the itinerary data
      await dispatch(fetchItineraryById(itineraryId)).unwrap();
      
      // Clear the message input
      setMessage('');
    } catch (error) {
      console.error('Error updating itinerary with AI:', error);
      toast.error(error.response?.data?.message || 'Failed to update itinerary');
      setAiResponse('Error: ' + (error.response?.data?.message || 'Failed to update itinerary'));
    } finally {
      setIsLoading(false);
    }
  };

  // Generate day-specific buttons
  const renderDaySpecificButtons = () => {
    if (dayCount === 0) return null;
    
    const buttons = [];
    
    // Add "Add activity" buttons for each day
    for (let i = 1; i <= Math.min(dayCount, 3); i++) {
      buttons.push(
        <button
          key={`add-day-${i}`}
          type="button"
          className="text-sm bg-blue-100 text-blue-800 hover:bg-blue-200 px-3 py-1 rounded-full transition-colors"
          onClick={() => handlePresetMessage(`Add an interesting activity to day ${i}`)}
          disabled={isLoading}
        >
          Add to day {i}
        </button>
      );
    }
    
    // Add "Free day" buttons for each day
    for (let i = 1; i <= Math.min(dayCount, 3); i++) {
      buttons.push(
        <button
          key={`free-day-${i}`}
          type="button"
          className="text-sm bg-green-100 text-green-800 hover:bg-green-200 px-3 py-1 rounded-full transition-colors"
          onClick={() => handlePresetMessage(`Give me a free day on day ${i}`)}
          disabled={isLoading}
        >
          Free day {i}
        </button>
      );
    }
    
    return buttons;
  };

  return (
    <div className="bg-white shadow-md rounded-lg p-6 mb-6">
      <h3 className="text-lg font-semibold mb-4">AI Itinerary Editor</h3>
      
      <form onSubmit={handleSubmit}>
        <div className="mb-4">
          <label htmlFor="ai-message" className="block text-sm font-medium text-gray-700 mb-1">
            What would you like to change about your itinerary?
          </label>
          <textarea
            id="ai-message"
            rows="3"
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
            placeholder="e.g., Add more outdoor activities on day 2, Move the museum visit to the morning, Change the restaurant for dinner on day 3..."
            value={message}
            onChange={handleMessageChange}
            disabled={isLoading}
          ></textarea>
        </div>
        
        {/* Quick prompt buttons */}
        <div className="mb-4">
          <div className="flex justify-between items-center mb-2">
            <p className="text-sm font-medium text-gray-700">Quick Prompts:</p>
            <button 
              type="button"
              className="text-xs text-purple-600 hover:text-purple-800"
              onClick={() => setShowSuggestions(!showSuggestions)}
            >
              {showSuggestions ? 'Hide' : 'Show more'}
            </button>
          </div>
          
          <div className="flex flex-wrap gap-2 mb-2">
            <button
              type="button"
              className="text-sm bg-purple-100 text-purple-800 hover:bg-purple-200 px-3 py-1 rounded-full transition-colors"
              onClick={() => handlePresetMessage("Decrease the budget for this itinerary")}
              disabled={isLoading}
            >
              Decrease Budget
            </button>
            <button
              type="button"
              className="text-sm bg-blue-100 text-blue-800 hover:bg-blue-200 px-3 py-1 rounded-full transition-colors"
              onClick={() => handlePresetMessage("Add __ to day __")}
              disabled={isLoading}
            >
              Add __ to day __
            </button>
            <button
              type="button"
              className="text-sm bg-green-100 text-green-800 hover:bg-green-200 px-3 py-1 rounded-full transition-colors"
              onClick={() => handlePresetMessage("Give me a free day on day __")}
              disabled={isLoading}
            >
              Free day __
            </button>
          </div>
          
          {/* Day-specific buttons */}
          {dayCount > 0 && (
            <div className="flex flex-wrap gap-2">
              {renderDaySpecificButtons()}
            </div>
          )}
          
          {/* Additional suggestions */}
          {showSuggestions && (
            <div className="mt-3 flex flex-wrap gap-2">
              <button
                type="button"
                className="text-sm bg-yellow-100 text-yellow-800 hover:bg-yellow-200 px-3 py-1 rounded-full transition-colors"
                onClick={() => handlePresetMessage("Make the itinerary more budget-friendly")}
                disabled={isLoading}
              >
                Budget-friendly
              </button>
              <button
                type="button"
                className="text-sm bg-red-100 text-red-800 hover:bg-red-200 px-3 py-1 rounded-full transition-colors"
                onClick={() => handlePresetMessage("Add more family-friendly activities")}
                disabled={isLoading}
              >
                Family-friendly
              </button>
              <button
                type="button"
                className="text-sm bg-indigo-100 text-indigo-800 hover:bg-indigo-200 px-3 py-1 rounded-full transition-colors"
                onClick={() => handlePresetMessage("Replace indoor activities with outdoor ones")}
                disabled={isLoading}
              >
                More outdoors
              </button>
            </div>
          )}
        </div>
        
        <button
          type="submit"
          className="bg-indigo-600 text-white px-4 py-2 rounded-md hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2 disabled:opacity-50"
          disabled={isLoading || !message.trim()}
        >
          {isLoading ? 'Updating...' : 'Update Itinerary'}
        </button>
      </form>
      
      {aiResponse && (
        <div className="mt-4 p-3 bg-gray-50 rounded-md">
          <p className="text-sm font-medium text-gray-700 mb-1">AI Response:</p>
          <p className="text-sm text-gray-600">{aiResponse}</p>
        </div>
      )}
      
      <div className="mt-4 text-xs text-gray-500">
        <p>Examples:</p>
        <ul className="list-disc list-inside">
          <li>"Add a coffee break between breakfast and lunch on day 2"</li>
          <li>"Replace the museum visit with an outdoor activity"</li>
          <li>"Rearrange day 3 to have more free time in the evening"</li>
        </ul>
      </div>
    </div>
  );
};

export default AiEditItinerary; 