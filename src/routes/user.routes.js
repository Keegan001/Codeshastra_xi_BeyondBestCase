const express = require('express');
const { body } = require('express-validator');
const userController = require('../controllers/user.controller');
const { validate } = require('../middleware/validator');
const { authenticate } = require('../middleware/auth');

const router = express.Router();

// All routes require authentication
router.use(authenticate);

/**
 * @route GET /api/users/me
 * @desc Get current user profile
 * @access Private
 */
router.get('/me', userController.getProfile);

/**
 * @route PATCH /api/users/me
 * @desc Update user profile
 * @access Private
 */
router.patch(
  '/me',
  [
    body('name').optional().trim().notEmpty().withMessage('Name cannot be empty'),
    body('profileImage').optional().isURL().withMessage('Profile image must be a valid URL'),
    validate
  ],
  userController.updateProfile
);

/**
 * @route POST /api/users/change-password
 * @desc Change user password
 * @access Private
 */
router.post(
  '/change-password',
  [
    body('currentPassword').notEmpty().withMessage('Current password is required'),
    body('newPassword')
      .isLength({ min: 8 })
      .withMessage('Password must be at least 8 characters long')
      .matches(/\d/)
      .withMessage('Password must contain at least one number'),
    validate
  ],
  userController.changePassword
);

/**
 * @route DELETE /api/users/me
 * @desc Delete user account
 * @access Private
 */
router.delete('/me', userController.deleteAccount);

/**
 * @route PATCH /api/users/preferences
 * @desc Update user preferences
 * @access Private
 */
router.patch(
  '/preferences',
  [
    body('preferences').isObject().withMessage('Preferences must be an object'),
    validate
  ],
  userController.updatePreferences
);

module.exports = router; 