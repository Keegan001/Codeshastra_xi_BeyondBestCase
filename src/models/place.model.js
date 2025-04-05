import mongoose from 'mongoose';
import { v4 as uuidv4 } from 'uuid';


const pointSchema = new mongoose.Schema({
  type: {
    type: String,
    enum: ['Point'],
    default: 'Point',
    required: true
  },
  coordinates: {
    type: [Number], // [longitude, latitude]
    required: true
  }
});

const placeSchema = new mongoose.Schema(
  {
    uuid: {
      type: String,
      default: uuidv4,
      unique: true,
      required: true
    },
    name: {
      type: String,
      required: true,
      trim: true
    },
    placeId: {
      type: String,
      trim: true,
      index: true
    },
    location: {
      type: pointSchema,
      required: true
    },
    address: {
      type: String,
      trim: true
    },
    phone: {
      type: String,
      trim: true
    },
    website: {
      type: String,
      trim: true
    },
    types: [{
      type: String,
      trim: true
    }],
    photos: [{
      url: String,
      attribution: String
    }],
    rating: {
      type: Number,
      min: 0,
      max: 5
    },
    priceLevel: {
      type: Number,
      min: 0,
      max: 4
    },
    openingHours: {
      type: mongoose.Schema.Types.Mixed
    },
    country: {
      type: String,
      trim: true
    },
    city: {
      type: String,
      trim: true
    },
    metadata: {
      type: mongoose.Schema.Types.Mixed
    }
  },
  { timestamps: true }
);

// Index for efficient queries
placeSchema.index({ 'location': '2dsphere' });
placeSchema.index({ name: 'text', address: 'text' });
placeSchema.index({ types: 1 });

// Method to get the public ID (UUID)
placeSchema.methods.getPublicId = function() {
  return this.uuid;
};

export const Place = mongoose.model('Place', placeSchema); 