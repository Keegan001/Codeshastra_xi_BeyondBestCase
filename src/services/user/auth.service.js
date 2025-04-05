import jwt from 'jsonwebtoken';
import crypto from 'crypto';
import {User} from '../../models/user.model.js';
import { ApiError } from '../../middleware/errorHandler.js';

/**
 * AuthService - Handles authentication operations
 */
class AuthService {
  /**
   * Generate JWT token for a user
   * @param {Object} user - User object
   * @returns {String} JWT token
   */
  generateToken(user) {
    const payload = {
      id: user._id,
      email: user.email,
      role: user.role
    };

    return jwt.sign(payload, process.env.JWT_SECRET, {
      expiresIn: process.env.JWT_EXPIRES_IN || '24h'
    });
  }

  /**
   * Register a new user
   * @param {Object} userData - User registration data
   * @returns {Object} User object and token
   */
  async register(userData) {
    // Check if user already exists
    const existingUser = await User.findOne({ email: userData.email });
    if (existingUser) {
      throw ApiError.badRequest('Email already in use');
    }

    // Create new user
    const user = new User(userData);
    await user.save();

    // Generate token
    const token = this.generateToken(user);

    return { user, token };
  }

  /**
   * Login a user
   * @param {String} email - User email
   * @param {String} password - User password
   * @returns {Object} User object and token
   */
  async login(email, password) {
    // Find user by email
    const user = await User.findOne({ email });
    if (!user) {
      throw ApiError.unauthorized('Invalid credentials');
    }

    // Check password
    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      throw ApiError.unauthorized('Invalid credentials');
    }

    // Generate token
    const token = this.generateToken(user);

    return { user, token };
  }

  /**
   * Generate password reset token
   * @param {String} email - User email
   * @returns {Object} Reset token and its expiry
   */
  async generatePasswordResetToken(email) {
    // Find user by email
    const user = await User.findOne({ email });
    if (!user) {
      throw ApiError.notFound('User not found');
    }

    // Generate random token
    const resetToken = crypto.randomBytes(32).toString('hex');

    // Hash token and set expiry
    user.resetPasswordToken = crypto
      .createHash('sha256')
      .update(resetToken)
      .digest('hex');
    user.resetPasswordExpires = Date.now() + 3600000; // 1 hour

    await user.save();

    return {
      resetToken,
      email: user.email,
      expires: user.resetPasswordExpires
    };
  }

  /**
   * Reset password using token
   * @param {String} token - Reset token
   * @param {String} newPassword - New password
   * @returns {Boolean} Success status
   */
  async resetPassword(token, newPassword) {
    // Hash token to match stored hash
    const resetPasswordToken = crypto
      .createHash('sha256')
      .update(token)
      .digest('hex');

    // Find user by token and check expiry
    const user = await User.findOne({
      resetPasswordToken,
      resetPasswordExpires: { $gt: Date.now() }
    });

    if (!user) {
      throw ApiError.badRequest('Invalid or expired token');
    }

    // Set new password and clear reset token
    user.password = newPassword;
    user.resetPasswordToken = undefined;
    user.resetPasswordExpires = undefined;

    await user.save();

    return true;
  }
}

export default new AuthService(); 