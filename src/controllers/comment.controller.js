import { Day } from '../models/day.model.js';
import { ApiError } from '../middleware/errorHandler.js';
import { ApiResponse } from '../middleware/apiResponse.js';
import websocketService from '../services/websocket.service.js';

/**
 * CommentController - Handles comments operations
 */
class CommentController {
  /**
   * Add comment to day
   * @param {Object} req - Request object
   * @param {Object} res - Response object
   * @param {Function} next - Next middleware function
   */
  async addComment(req, res, next) {
    try {
      const userId = req.user.id;
      const dayId = req.params.dayId;
      const { text } = req.body;
      
      if (!text) {
        throw ApiError.badRequest('Comment text is required');
      }
      
      // Find day and populate itinerary info for access check
      const day = await Day.findById(dayId).populate({
        path: 'itinerary',
        select: 'owner collaborators'
      });
      
      if (!day) {
        throw ApiError.notFound('Day not found');
      }
      
      // Check if user has access to day
      const isOwner = day.itinerary.owner.toString() === userId;
      const isCollaborator = day.itinerary.collaborators.some(
        c => c.user && c.user.toString() === userId
      );
      
      if (!isOwner && !isCollaborator) {
        throw ApiError.forbidden('Access denied');
      }
      
      // Add comment
      day.comments.push({
        user: userId,
        text,
        createdAt: new Date()
      });
      
      await day.save();
      
      // Get populated comment for response
      const updatedDay = await Day.findById(dayId).populate({
        path: 'comments.user',
        select: 'name email'
      });
      
      const newComment = updatedDay.comments[updatedDay.comments.length - 1];
      
      // Notify all users in the day's room
      websocketService.emitToDay(dayId, 'new-comment', {
        dayId,
        comment: {
          id: newComment._id,
          text: newComment.text,
          createdAt: newComment.createdAt,
          user: {
            id: newComment.user._id,
            name: newComment.user.name,
            email: newComment.user.email
          }
        }
      });
      
      ApiResponse.success(res, 201, 'Comment added successfully', {
        comment: newComment
      });
    } catch (error) {
      next(error);
    }
  }
  
  /**
   * Get comments for a day
   * @param {Object} req - Request object
   * @param {Object} res - Response object
   * @param {Function} next - Next middleware function
   */
  async getComments(req, res, next) {
    try {
      const userId = req.user.id;
      const dayId = req.params.dayId;
      
      // Find day and populate comments with user info
      const day = await Day.findById(dayId)
        .populate({
          path: 'itinerary',
          select: 'owner collaborators'
        })
        .populate({
          path: 'comments.user',
          select: 'name email'
        });
      
      if (!day) {
        throw ApiError.notFound('Day not found');
      }
      
      // Check if user has access to day
      const isOwner = day.itinerary.owner.toString() === userId;
      const isCollaborator = day.itinerary.collaborators.some(
        c => c.user && c.user.toString() === userId
      );
      
      if (!isOwner && !isCollaborator) {
        throw ApiError.forbidden('Access denied');
      }
      
      // Format comments for response
      const comments = day.comments.map(comment => ({
        id: comment._id,
        text: comment.text,
        createdAt: comment.createdAt,
        user: {
          id: comment.user._id,
          name: comment.user.name || comment.user.email,
          email: comment.user.email
        }
      }));
      
      ApiResponse.success(res, 200, 'Comments retrieved successfully', {
        comments
      });
    } catch (error) {
      next(error);
    }
  }
  
  /**
   * Delete a comment
   * @param {Object} req - Request object
   * @param {Object} res - Response object
   * @param {Function} next - Next middleware function
   */
  async deleteComment(req, res, next) {
    try {
      const userId = req.user.id;
      const dayId = req.params.dayId;
      const commentId = req.params.commentId;
      
      // Find day
      const day = await Day.findById(dayId).populate({
        path: 'itinerary',
        select: 'owner collaborators'
      });
      
      if (!day) {
        throw ApiError.notFound('Day not found');
      }
      
      // Find comment
      const commentIndex = day.comments.findIndex(c => c._id.toString() === commentId);
      
      if (commentIndex === -1) {
        throw ApiError.notFound('Comment not found');
      }
      
      const comment = day.comments[commentIndex];
      
      // Check if user is the comment author or itinerary owner
      const isAuthor = comment.user.toString() === userId;
      const isItineraryOwner = day.itinerary.owner.toString() === userId;
      
      if (!isAuthor && !isItineraryOwner) {
        throw ApiError.forbidden('You can only delete your own comments or as the itinerary owner');
      }
      
      // Remove comment
      day.comments.splice(commentIndex, 1);
      await day.save();
      
      // Notify all users in the day's room
      websocketService.emitToDay(dayId, 'comment-deleted', {
        dayId,
        commentId
      });
      
      ApiResponse.success(res, 200, 'Comment deleted successfully', {
        commentId
      });
    } catch (error) {
      next(error);
    }
  }
}

export default new CommentController(); 