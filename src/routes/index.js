import express from 'express';
import authRoutes from './auth.routes.js';
import userRoutes from './user.routes.js';
import itineraryRoutes from './itinerary.routes.js';
import placeRoutes from './place.routes.js';
import templateRoutes from './template.routes.js';

const router = express.Router();

// Health check endpoint
router.get('/health', (req, res) => {
  res.status(200).json({
    status: 'success',
    message: 'API is running',
    timestamp: new Date().toISOString()
  });
});

// API routes
router.use('/auth', authRoutes);
router.use('/users', userRoutes);
router.use('/itineraries', itineraryRoutes);
router.use('/places', placeRoutes);
router.use('/templates', templateRoutes);

export default router; 