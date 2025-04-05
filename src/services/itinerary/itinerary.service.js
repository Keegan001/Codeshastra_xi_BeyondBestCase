import { Itinerary, Day, Activity } from '../../models/index.js';
import { ApiError } from '../../middleware/errorHandler.js';
import mongoose from 'mongoose';

/**
 * ItineraryService - Handles itinerary-related operations
 */
class ItineraryService {
  /**
   * Create a new itinerary
   * @param {String} userId - User ID
   * @param {Object} itineraryData - Itinerary creation data
   * @returns {Object} Created itinerary
   */
  async createItinerary(userId, itineraryData) {
    try {
      // Validate required fields
      if (!itineraryData.title || !itineraryData.destination || !itineraryData.dateRange) {
        throw ApiError.badRequest('Missing required fields');
      }

      // Create itinerary
      const itinerary = new Itinerary({
        title: itineraryData.title,
        description: itineraryData.description,
        owner: userId,
        destination: itineraryData.destination,
        dateRange: {
          start: new Date(itineraryData.dateRange.start),
          end: new Date(itineraryData.dateRange.end)
        },
        transportation: itineraryData.transportation || { mode: 'mixed' },
        budget: itineraryData.budget || { currency: 'USD', total: 0, spent: 0 }
      });

      await itinerary.save();

      // Generate days for the itinerary if requested
      if (itineraryData.generateDays) {
        await this.generateDaysForItinerary(itinerary);
      }

      return itinerary;
    } catch (error) {
      if (error.name === 'ValidationError') {
        throw ApiError.badRequest(error.message);
      }
      throw error;
    }
  }

  /**
   * Generate days for an itinerary based on date range
   * @param {Object} itinerary - Itinerary object
   * @returns {Array} Created days
   */
  async generateDaysForItinerary(itinerary) {
    const days = [];
    const startDate = new Date(itinerary.dateRange.start);
    const endDate = new Date(itinerary.dateRange.end);
    
    // Loop through each day in the date range
    for (let date = new Date(startDate); date <= endDate; date.setDate(date.getDate() + 1)) {
      const day = new Day({
        date: new Date(date),
        itinerary: itinerary._id
      });
      
      await day.save();
      days.push(day);
    }

    // Update itinerary with day references
    itinerary.days = days.map(day => day._id);
    await itinerary.save();
    
    return days;
  }

  /**
   * Get all itineraries for a user
   * @param {String} userId - User ID
   * @param {Object} query - Query parameters (sort, filter)
   * @returns {Array} Itineraries
   */
  async getItineraries(userId, query = {}) {
    const { sort = 'createdAt', order = 'desc', limit = 20, page = 1 } = query;
    
    // Build query
    const filter = { owner: userId };
    
    // Add additional filters if provided
    if (query.search) {
      filter.$or = [
        { title: { $regex: query.search, $options: 'i' } },
        { 'destination.name': { $regex: query.search, $options: 'i' } }
      ];
    }
    
    if (query.startDate) {
      filter['dateRange.start'] = { $gte: new Date(query.startDate) };
    }
    
    if (query.endDate) {
      filter['dateRange.end'] = { $lte: new Date(query.endDate) };
    }
    
    // Create sort object
    const sortObj = {};
    sortObj[sort] = order === 'desc' ? -1 : 1;
    
    // Calculate pagination
    const skip = (page - 1) * limit;
    
    // Execute query
    const itineraries = await Itinerary.find(filter)
      .sort(sortObj)
      .skip(skip)
      .limit(Number(limit))
      .populate('owner', 'name email');
    
    // Get total count for pagination
    const total = await Itinerary.countDocuments(filter);
    
    return {
      itineraries,
      pagination: {
        total,
        page: Number(page),
        pages: Math.ceil(total / limit)
      }
    };
  }

  /**
   * Get itinerary by ID
   * @param {String} itineraryId - Itinerary ID (can be MongoDB ID or UUID)
   * @param {String} userId - User ID
   * @returns {Object} Itinerary
   */
  async getItineraryById(itineraryId, userId) {
    // Check if itineraryId is a UUID or MongoDB ID
    const query = mongoose.isValidObjectId(itineraryId)
      ? { _id: itineraryId }
      : { uuid: itineraryId };

    // Find itinerary
    const itinerary = await Itinerary.findOne(query)
      .populate('owner', 'name email')
      .populate('collaborators.user', 'name email')
      .populate({
        path: 'days',
        options: { sort: { date: 1 } }
      });

    if (!itinerary) {
      throw ApiError.notFound('Itinerary not found');
    }

    // Check if user is owner or collaborator
    const isOwner = itinerary.owner._id.toString() === userId;
    const isCollaborator = itinerary.collaborators.some(
      c => c.user._id.toString() === userId
    );

    if (!isOwner && !isCollaborator) {
      throw ApiError.forbidden('Access denied');
    }

    return itinerary;
  }

  /**
   * Update itinerary
   * @param {String} itineraryId - Itinerary ID (can be MongoDB ID or UUID)
   * @param {Object} updateData - Data to update
   * @param {String} userId - User ID
   * @returns {Object} Updated itinerary
   */
  async updateItinerary(itineraryId, updateData, userId) {
    // Check if itineraryId is a UUID or MongoDB ID
    const query = mongoose.isValidObjectId(itineraryId)
      ? { _id: itineraryId }
      : { uuid: itineraryId };

    // Find itinerary
    const itinerary = await Itinerary.findOne(query);
    
    if (!itinerary) {
      throw ApiError.notFound('Itinerary not found');
    }

    // Check if user is owner or editor collaborator
    const isOwner = itinerary.owner.toString() === userId;
    const isEditorCollaborator = itinerary.collaborators.some(
      c => c.user.toString() === userId && c.role === 'editor'
    );

    if (!isOwner && !isEditorCollaborator) {
      throw ApiError.forbidden('Access denied');
    }

    // Allow updating only specific fields
    const allowedUpdates = [
      'title',
      'description',
      'destination',
      'dateRange',
      'transportation',
      'budget'
    ];

    // Filter update data
    const updates = Object.keys(updateData)
      .filter(key => allowedUpdates.includes(key))
      .reduce((obj, key) => {
        obj[key] = updateData[key];
        return obj;
      }, {});

    if (Object.keys(updates).length === 0) {
      throw ApiError.badRequest('No valid update fields provided');
    }

    // Apply version control
    updates.version = itinerary.version + 1;

    // Update itinerary
    const updatedItinerary = await Itinerary.findOneAndUpdate(
      query,
      { $set: updates },
      { new: true, runValidators: true }
    )
      .populate('owner', 'name email')
      .populate('collaborators.user', 'name email');

    return updatedItinerary;
  }

  /**
   * Delete itinerary
   * @param {String} itineraryId - Itinerary ID (can be MongoDB ID or UUID)
   * @param {String} userId - User ID
   * @returns {Boolean} Success status
   */
  async deleteItinerary(itineraryId, userId) {
    // Check if itineraryId is a UUID or MongoDB ID
    const query = mongoose.isValidObjectId(itineraryId)
      ? { _id: itineraryId }
      : { uuid: itineraryId };

    // Find itinerary
    const itinerary = await Itinerary.findOne(query);
    
    if (!itinerary) {
      throw ApiError.notFound('Itinerary not found');
    }

    // Check if user is owner
    if (itinerary.owner.toString() !== userId) {
      throw ApiError.forbidden('Only the owner can delete an itinerary');
    }

    // Start a session for transaction
    const session = await mongoose.startSession();
    session.startTransaction();

    try {
      // Delete all activities for the itinerary's days
      const dayIds = itinerary.days;
      await Activity.deleteMany({ day: { $in: dayIds } }, { session });
      
      // Delete all days for the itinerary
      await Day.deleteMany({ itinerary: itinerary._id }, { session });
      
      // Delete the itinerary
      await Itinerary.deleteOne({ _id: itinerary._id }, { session });
      
      // Commit transaction
      await session.commitTransaction();
    } catch (error) {
      // Abort transaction on error
      await session.abortTransaction();
      throw error;
    } finally {
      // End session
      session.endSession();
    }

    return true;
  }

  /**
   * Add collaborator to itinerary
   * @param {String} itineraryId - Itinerary ID (can be MongoDB ID or UUID)
   * @param {String} collaboratorEmail - Collaborator email
   * @param {String} role - Collaborator role (editor or viewer)
   * @param {String} userId - User ID (owner)
   * @returns {Object} Updated itinerary
   */
  async addCollaborator(itineraryId, collaboratorEmail, role, userId) {
    // Validate role
    if (!['editor', 'viewer'].includes(role)) {
      throw ApiError.badRequest('Invalid role. Must be editor or viewer');
    }

    // Check if itineraryId is a UUID or MongoDB ID
    const query = mongoose.isValidObjectId(itineraryId)
      ? { _id: itineraryId }
      : { uuid: itineraryId };

    // Find itinerary
    const itinerary = await Itinerary.findOne(query);
    
    if (!itinerary) {
      throw ApiError.notFound('Itinerary not found');
    }

    // Check if user is owner
    if (itinerary.owner.toString() !== userId) {
      throw ApiError.forbidden('Only the owner can add collaborators');
    }

    // Find collaborator user
    const User = mongoose.model('User');
    const collaborator = await User.findOne({ email: collaboratorEmail });
    
    if (!collaborator) {
      throw ApiError.notFound('User not found');
    }

    // Check if user is already a collaborator
    const isCollaborator = itinerary.collaborators.some(
      c => c.user.toString() === collaborator._id.toString()
    );

    if (isCollaborator) {
      throw ApiError.badRequest('User is already a collaborator');
    }

    // Add collaborator
    itinerary.collaborators.push({
      user: collaborator._id,
      role
    });

    await itinerary.save();

    // Populate and return
    return await Itinerary.findById(itinerary._id)
      .populate('owner', 'name email')
      .populate('collaborators.user', 'name email');
  }

  /**
   * Remove collaborator from itinerary
   * @param {String} itineraryId - Itinerary ID (can be MongoDB ID or UUID)
   * @param {String} collaboratorId - Collaborator user ID
   * @param {String} userId - User ID (owner)
   * @returns {Object} Updated itinerary
   */
  async removeCollaborator(itineraryId, collaboratorId, userId) {
    // Check if itineraryId is a UUID or MongoDB ID
    const query = mongoose.isValidObjectId(itineraryId)
      ? { _id: itineraryId }
      : { uuid: itineraryId };

    // Find itinerary
    const itinerary = await Itinerary.findOne(query);
    
    if (!itinerary) {
      throw ApiError.notFound('Itinerary not found');
    }

    // Check if user is owner
    if (itinerary.owner.toString() !== userId) {
      throw ApiError.forbidden('Only the owner can remove collaborators');
    }

    // Remove collaborator
    itinerary.collaborators = itinerary.collaborators.filter(
      c => c.user.toString() !== collaboratorId
    );

    await itinerary.save();

    // Populate and return
    return await Itinerary.findById(itinerary._id)
      .populate('owner', 'name email')
      .populate('collaborators.user', 'name email');
  }
}

export default new ItineraryService(); 