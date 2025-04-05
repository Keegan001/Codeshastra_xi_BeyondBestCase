const itineraryService = require('../services/itinerary/itinerary.service');
const dayService = require('../services/itinerary/day.service');
const { ApiResponse } = require('../middleware/apiResponse');
const { ApiError } = require('../middleware/errorHandler');

/**
 * ItineraryController - Handles itinerary-related API endpoints
 */
class ItineraryController {
  /**
   * Create a new itinerary
   * @param {Object} req - Request object
   * @param {Object} res - Response object
   * @param {Function} next - Next middleware function
   */
  async createItinerary(req, res, next) {
    try {
      const userId = req.user.id;
      const itineraryData = req.body;
      
      const itinerary = await itineraryService.createItinerary(userId, itineraryData);
      
      ApiResponse.success(res, 201, 'Itinerary created successfully', { itinerary });
    } catch (error) {
      next(error);
    }
  }
  
  /**
   * Get all itineraries for a user
   * @param {Object} req - Request object
   * @param {Object} res - Response object
   * @param {Function} next - Next middleware function
   */
  async getItineraries(req, res, next) {
    try {
      const userId = req.user.id;
      const result = await itineraryService.getItineraries(userId, req.query);
      
      ApiResponse.success(res, 200, 'Itineraries retrieved successfully', result);
    } catch (error) {
      next(error);
    }
  }
  
  /**
   * Get itinerary by ID
   * @param {Object} req - Request object
   * @param {Object} res - Response object
   * @param {Function} next - Next middleware function
   */
  async getItineraryById(req, res, next) {
    try {
      const userId = req.user.id;
      const itineraryId = req.params.id;
      
      const itinerary = await itineraryService.getItineraryById(itineraryId, userId);
      
      ApiResponse.success(res, 200, 'Itinerary retrieved successfully', { itinerary });
    } catch (error) {
      next(error);
    }
  }
  
  /**
   * Update itinerary
   * @param {Object} req - Request object
   * @param {Object} res - Response object
   * @param {Function} next - Next middleware function
   */
  async updateItinerary(req, res, next) {
    try {
      const userId = req.user.id;
      const itineraryId = req.params.id;
      const updateData = req.body;
      
      const itinerary = await itineraryService.updateItinerary(itineraryId, updateData, userId);
      
      ApiResponse.success(res, 200, 'Itinerary updated successfully', { itinerary });
    } catch (error) {
      next(error);
    }
  }
  
  /**
   * Delete itinerary
   * @param {Object} req - Request object
   * @param {Object} res - Response object
   * @param {Function} next - Next middleware function
   */
  async deleteItinerary(req, res, next) {
    try {
      const userId = req.user.id;
      const itineraryId = req.params.id;
      
      await itineraryService.deleteItinerary(itineraryId, userId);
      
      ApiResponse.success(res, 200, 'Itinerary deleted successfully');
    } catch (error) {
      next(error);
    }
  }
  
  /**
   * Add collaborator to itinerary
   * @param {Object} req - Request object
   * @param {Object} res - Response object
   * @param {Function} next - Next middleware function
   */
  async addCollaborator(req, res, next) {
    try {
      const userId = req.user.id;
      const itineraryId = req.params.id;
      const { email, role } = req.body;
      
      if (!email || !role) {
        throw ApiError.badRequest('Email and role are required');
      }
      
      const itinerary = await itineraryService.addCollaborator(itineraryId, email, role, userId);
      
      ApiResponse.success(res, 200, 'Collaborator added successfully', { itinerary });
    } catch (error) {
      next(error);
    }
  }
  
  /**
   * Remove collaborator from itinerary
   * @param {Object} req - Request object
   * @param {Object} res - Response object
   * @param {Function} next - Next middleware function
   */
  async removeCollaborator(req, res, next) {
    try {
      const userId = req.user.id;
      const itineraryId = req.params.id;
      const collaboratorId = req.params.collaboratorId;
      
      const itinerary = await itineraryService.removeCollaborator(itineraryId, collaboratorId, userId);
      
      ApiResponse.success(res, 200, 'Collaborator removed successfully', { itinerary });
    } catch (error) {
      next(error);
    }
  }
  
  /**
   * Get day by ID
   * @param {Object} req - Request object
   * @param {Object} res - Response object
   * @param {Function} next - Next middleware function
   */
  async getDayById(req, res, next) {
    try {
      const userId = req.user.id;
      const dayId = req.params.dayId;
      
      const day = await dayService.getDayById(dayId, userId);
      
      ApiResponse.success(res, 200, 'Day retrieved successfully', { day });
    } catch (error) {
      next(error);
    }
  }
  
  /**
   * Update day
   * @param {Object} req - Request object
   * @param {Object} res - Response object
   * @param {Function} next - Next middleware function
   */
  async updateDay(req, res, next) {
    try {
      const userId = req.user.id;
      const dayId = req.params.dayId;
      const updateData = req.body;
      
      const day = await dayService.updateDay(dayId, updateData, userId);
      
      ApiResponse.success(res, 200, 'Day updated successfully', { day });
    } catch (error) {
      next(error);
    }
  }
  
  /**
   * Add activity to day
   * @param {Object} req - Request object
   * @param {Object} res - Response object
   * @param {Function} next - Next middleware function
   */
  async addActivity(req, res, next) {
    try {
      const userId = req.user.id;
      const dayId = req.params.dayId;
      const activityData = req.body;
      
      const day = await dayService.addActivity(dayId, activityData, userId);
      
      ApiResponse.success(res, 201, 'Activity added successfully', { day });
    } catch (error) {
      next(error);
    }
  }
  
  /**
   * Update activity
   * @param {Object} req - Request object
   * @param {Object} res - Response object
   * @param {Function} next - Next middleware function
   */
  async updateActivity(req, res, next) {
    try {
      const userId = req.user.id;
      const activityId = req.params.activityId;
      const updateData = req.body;
      
      const activity = await dayService.updateActivity(activityId, updateData, userId);
      
      ApiResponse.success(res, 200, 'Activity updated successfully', { activity });
    } catch (error) {
      next(error);
    }
  }
  
  /**
   * Delete activity
   * @param {Object} req - Request object
   * @param {Object} res - Response object
   * @param {Function} next - Next middleware function
   */
  async deleteActivity(req, res, next) {
    try {
      const userId = req.user.id;
      const activityId = req.params.activityId;
      
      await dayService.deleteActivity(activityId, userId);
      
      ApiResponse.success(res, 200, 'Activity deleted successfully');
    } catch (error) {
      next(error);
    }
  }
  
  /**
   * Reorder activities for a day
   * @param {Object} req - Request object
   * @param {Object} res - Response object
   * @param {Function} next - Next middleware function
   */
  async reorderActivities(req, res, next) {
    try {
      const userId = req.user.id;
      const dayId = req.params.dayId;
      const { activityIds } = req.body;
      
      if (!activityIds || !Array.isArray(activityIds)) {
        throw ApiError.badRequest('Activity IDs array is required');
      }
      
      const day = await dayService.reorderActivities(dayId, activityIds, userId);
      
      ApiResponse.success(res, 200, 'Activities reordered successfully', { day });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = new ItineraryController(); 