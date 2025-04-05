const router = require('express').Router();
const itineraryController = require('../controllers/itinerary.controller');
const auth = require('../middleware/auth');
const { validateRequest } = require('../middleware/validator');

/**
 * @swagger
 * tags:
 *   name: Itineraries
 *   description: Itinerary management endpoints
 */

/**
 * @swagger
 * /api/itineraries:
 *   post:
 *     summary: Create a new itinerary
 *     tags: [Itineraries]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/ItineraryCreate'
 *     responses:
 *       201:
 *         description: Itinerary created successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ItineraryResponse'
 *       400:
 *         description: Invalid request
 *       401:
 *         description: Unauthorized
 */
router.post(
  '/',
  auth.authenticate,
  validateRequest('createItinerary'),
  itineraryController.createItinerary
);

/**
 * @swagger
 * /api/itineraries:
 *   get:
 *     summary: Get all itineraries for a user
 *     tags: [Itineraries]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: sort
 *         schema:
 *           type: string
 *         description: Field to sort by (defaults to createdAt)
 *       - in: query
 *         name: order
 *         schema:
 *           type: string
 *           enum: [asc, desc]
 *         description: Sort order (defaults to desc)
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *         description: Page number (defaults to 1)
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *         description: Items per page (defaults to 20)
 *       - in: query
 *         name: search
 *         schema:
 *           type: string
 *         description: Search query for itinerary title or destination
 *     responses:
 *       200:
 *         description: List of itineraries
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ItinerariesResponse'
 *       401:
 *         description: Unauthorized
 */
router.get(
  '/',
  auth.authenticate,
  itineraryController.getItineraries
);

/**
 * @swagger
 * /api/itineraries/days/{dayId}:
 *   get:
 *     summary: Get a day by ID
 *     tags: [Itineraries]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: dayId
 *         required: true
 *         schema:
 *           type: string
 *         description: Day ID or UUID
 *     responses:
 *       200:
 *         description: Day details
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/DayResponse'
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden
 *       404:
 *         description: Day not found
 */
router.get(
  '/days/:dayId',
  auth.authenticate,
  itineraryController.getDayById
);

/**
 * @swagger
 * /api/itineraries/days/{dayId}:
 *   put:
 *     summary: Update a day
 *     tags: [Itineraries]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: dayId
 *         required: true
 *         schema:
 *           type: string
 *         description: Day ID or UUID
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/DayUpdate'
 *     responses:
 *       200:
 *         description: Day updated successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/DayResponse'
 *       400:
 *         description: Invalid request
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden
 *       404:
 *         description: Day not found
 */
router.put(
  '/days/:dayId',
  auth.authenticate,
  validateRequest('updateDay'),
  itineraryController.updateDay
);

/**
 * @swagger
 * /api/itineraries/days/{dayId}/activities:
 *   post:
 *     summary: Add an activity to a day
 *     tags: [Itineraries]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: dayId
 *         required: true
 *         schema:
 *           type: string
 *         description: Day ID or UUID
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/ActivityCreate'
 *     responses:
 *       201:
 *         description: Activity added successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/DayResponse'
 *       400:
 *         description: Invalid request
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden
 *       404:
 *         description: Day not found
 */
router.post(
  '/days/:dayId/activities',
  auth.authenticate,
  validateRequest('createActivity'),
  itineraryController.addActivity
);

/**
 * @swagger
 * /api/itineraries/days/{dayId}/reorder:
 *   post:
 *     summary: Reorder activities for a day
 *     tags: [Itineraries]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: dayId
 *         required: true
 *         schema:
 *           type: string
 *         description: Day ID or UUID
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - activityIds
 *             properties:
 *               activityIds:
 *                 type: array
 *                 items:
 *                   type: string
 *                 description: Ordered array of activity IDs
 *     responses:
 *       200:
 *         description: Activities reordered successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/DayResponse'
 *       400:
 *         description: Invalid request
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden
 *       404:
 *         description: Day not found
 */
router.post(
  '/days/:dayId/reorder',
  auth.authenticate,
  validateRequest('reorderActivities'),
  itineraryController.reorderActivities
);

/**
 * @swagger
 * /api/itineraries/activities/{activityId}:
 *   put:
 *     summary: Update an activity
 *     tags: [Itineraries]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: activityId
 *         required: true
 *         schema:
 *           type: string
 *         description: Activity ID or UUID
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/ActivityUpdate'
 *     responses:
 *       200:
 *         description: Activity updated successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ActivityResponse'
 *       400:
 *         description: Invalid request
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden
 *       404:
 *         description: Activity not found
 */
router.put(
  '/activities/:activityId',
  auth.authenticate,
  validateRequest('updateActivity'),
  itineraryController.updateActivity
);

/**
 * @swagger
 * /api/itineraries/activities/{activityId}:
 *   delete:
 *     summary: Delete an activity
 *     tags: [Itineraries]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: activityId
 *         required: true
 *         schema:
 *           type: string
 *         description: Activity ID or UUID
 *     responses:
 *       200:
 *         description: Activity deleted successfully
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden
 *       404:
 *         description: Activity not found
 */
router.delete(
  '/activities/:activityId',
  auth.authenticate,
  itineraryController.deleteActivity
);

/**
 * @swagger
 * /api/itineraries/{id}:
 *   get:
 *     summary: Get an itinerary by ID
 *     tags: [Itineraries]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Itinerary ID or UUID
 *     responses:
 *       200:
 *         description: Itinerary details
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ItineraryResponse'
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden
 *       404:
 *         description: Itinerary not found
 */
router.get(
  '/:id',
  auth.authenticate,
  itineraryController.getItineraryById
);

/**
 * @swagger
 * /api/itineraries/{id}:
 *   put:
 *     summary: Update an itinerary
 *     tags: [Itineraries]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Itinerary ID or UUID
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/ItineraryUpdate'
 *     responses:
 *       200:
 *         description: Itinerary updated successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ItineraryResponse'
 *       400:
 *         description: Invalid request
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden
 *       404:
 *         description: Itinerary not found
 */
router.put(
  '/:id',
  auth.authenticate,
  validateRequest('updateItinerary'),
  itineraryController.updateItinerary
);

/**
 * @swagger
 * /api/itineraries/{id}:
 *   delete:
 *     summary: Delete an itinerary
 *     tags: [Itineraries]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Itinerary ID or UUID
 *     responses:
 *       200:
 *         description: Itinerary deleted successfully
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden
 *       404:
 *         description: Itinerary not found
 */
router.delete(
  '/:id',
  auth.authenticate,
  itineraryController.deleteItinerary
);

/**
 * @swagger
 * /api/itineraries/{id}/collaborators:
 *   post:
 *     summary: Add a collaborator to an itinerary
 *     tags: [Itineraries]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Itinerary ID or UUID
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *               - role
 *             properties:
 *               email:
 *                 type: string
 *                 format: email
 *               role:
 *                 type: string
 *                 enum: [editor, viewer]
 *     responses:
 *       200:
 *         description: Collaborator added successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ItineraryResponse'
 *       400:
 *         description: Invalid request
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden
 *       404:
 *         description: Itinerary or user not found
 */
router.post(
  '/:id/collaborators',
  auth.authenticate,
  validateRequest('addCollaborator'),
  itineraryController.addCollaborator
);

/**
 * @swagger
 * /api/itineraries/{id}/collaborators/{collaboratorId}:
 *   delete:
 *     summary: Remove a collaborator from an itinerary
 *     tags: [Itineraries]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Itinerary ID or UUID
 *       - in: path
 *         name: collaboratorId
 *         required: true
 *         schema:
 *           type: string
 *         description: Collaborator user ID
 *     responses:
 *       200:
 *         description: Collaborator removed successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ItineraryResponse'
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden
 *       404:
 *         description: Itinerary or collaborator not found
 */
router.delete(
  '/:id/collaborators/:collaboratorId',
  auth.authenticate,
  itineraryController.removeCollaborator
);

module.exports = router; 