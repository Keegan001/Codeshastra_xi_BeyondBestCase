const authService = require('../services/user/auth.service');
const { ApiError } = require('../middleware/errorHandler');

/**
 * AuthController - Handles authentication-related requests
 */
class AuthController {
  /**
   * Register a new user
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware function
   */
  async register(req, res, next) {
    try {
      const { user, token } = await authService.register(req.body);
      res.status(201).json({
        message: 'User registered successfully',
        user,
        token
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Login a user
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware function
   */
  async login(req, res, next) {
    try {
      const { email, password } = req.body;
      const { user, token } = await authService.login(email, password);
      res.status(200).json({
        message: 'Logged in successfully',
        user,
        token
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Request password reset
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware function
   */
  async forgotPassword(req, res, next) {
    try {
      const { email } = req.body;
      const resetInfo = await authService.generatePasswordResetToken(email);
      
      // In a real app, send email with reset link
      // For now, just return the token (not secure for production)
      res.status(200).json({
        message: 'Password reset token generated',
        resetInfo
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Reset password with token
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware function
   */
  async resetPassword(req, res, next) {
    try {
      const { token, newPassword } = req.body;
      await authService.resetPassword(token, newPassword);
      res.status(200).json({
        message: 'Password reset successful'
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Refresh user token
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware function
   */
  async refreshToken(req, res, next) {
    try {
      // User is already authenticated via middleware
      const user = req.user;
      const token = authService.generateToken(user);
      
      res.status(200).json({
        message: 'Token refreshed successfully',
        token
      });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = new AuthController(); 