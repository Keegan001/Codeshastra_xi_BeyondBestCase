import express from 'express';
import authController from '../controllers/auth.controller.js';
import {authenticate} from '../middleware/auth.js';
import { validateRequest } from '../middleware/validator.js';

const router = express.Router();

// Register a new user
router.post(
  '/register',
  validateRequest('registerUser'),
  authController.register
);

// Log in a user
router.post(
  '/login',
  validateRequest('loginUser'),
  authController.login
);

// Request password reset
router.post(
  '/forgot-password',
  validateRequest('forgotPassword'),
  authController.forgotPassword
);

// Reset password with token
router.post(
  '/reset-password',
  validateRequest('resetPassword'),
  authController.resetPassword
);

// Refresh access token
router.post(
  '/refresh',
  authenticate,
  authController.refreshToken
);

export default router; 