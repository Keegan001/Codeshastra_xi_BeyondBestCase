import express from 'express';
import itineraryController from '../controllers/itinerary.controller.js';
import {authenticate} from '../middleware/auth.js';
import { validateRequest } from '../middleware/validator.js';

const router = express.Router();

// Create a new itinerary
router.post(
  '/',
  authenticate,
  validateRequest('createItinerary'),
  itineraryController.createItinerary
);

// Get all itineraries for a user
router.get(
  '/',
  authenticate,
  itineraryController.getItineraries
);

// Get a day by ID
router.get(
  '/days/:dayId',
  authenticate,
  itineraryController.getDayById
);

// Update a day
router.put(
  '/days/:dayId',
  authenticate,
  validateRequest('updateDay'),
  itineraryController.updateDay
);

// Add an activity to a day
router.post(
  '/days/:dayId/activities',
  authenticate,
  validateRequest('createActivity'),
  itineraryController.addActivity
);

// Reorder activities for a day
router.post(
  '/days/:dayId/reorder',
  authenticate,
  validateRequest('reorderActivities'),
  itineraryController.reorderActivities
);

// Update an activity
router.put(
  '/activities/:activityId',
  authenticate,
  validateRequest('updateActivity'),
  itineraryController.updateActivity
);

// Delete an activity
router.delete(
  '/activities/:activityId',
  authenticate,
  itineraryController.deleteActivity
);

// Get an itinerary by ID
router.get(
  '/:id',
  authenticate,
  itineraryController.getItineraryById
);

// Update an itinerary
router.put(
  '/:id',
  authenticate,
  validateRequest('updateItinerary'),
  itineraryController.updateItinerary
);

// Delete an itinerary
router.delete(
  '/:id',
  authenticate,
  itineraryController.deleteItinerary
);

// Add a collaborator to an itinerary
router.post(
  '/:id/collaborators',
  authenticate,
  validateRequest('addCollaborator'),
  itineraryController.addCollaborator
);

// Remove a collaborator from an itinerary
router.delete(
  '/:id/collaborators/:collaboratorId',
  authenticate,
  itineraryController.removeCollaborator
);

export default router; 