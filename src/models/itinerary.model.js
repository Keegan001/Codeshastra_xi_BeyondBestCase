import mongoose from 'mongoose';
import { v4 as uuidv4 } from 'uuid';

const pointSchema = new mongoose.Schema({
  type: {
    type: String,
    enum: ['Point'],
    default: 'Point'
  },
  coordinates: {
    type: [Number] // [longitude, latitude]
  }
});

const collaboratorSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  },
  role: {
    type: String,
    enum: ['editor', 'viewer'],
    default: 'viewer'
  }
});

const itinerarySchema = new mongoose.Schema(
  {
    uuid: {
      type: String,
      default: uuidv4,
      unique: true
    },
    title: {
      type: String,
      trim: true
    },
    description: {
      type: String,
      trim: true
    },
    owner: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    collaborators: [collaboratorSchema],
    destination: {
      name: {
        type: String
      },
      location: {
        type: pointSchema
      },
      country: {
        type: String
      }
    },
    dateRange: {
      start: {
        type: Date
      },
      end: {
        type: Date
      }
    },
    days: [{
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Day'
    }],
    budget: {
      currency: {
        type: String,
        default: 'USD'
      },
      total: {
        type: Number,
        default: 0
      },
      spent: {
        type: Number,
        default: 0
      },
      categories: {
        type: Map,
        of: Number,
        default: {}
      }
    },
    transportation: {
      mode: {
        type: String,
        enum: ['flying', 'driving', 'transit', 'mixed'],
        default: 'mixed'
      },
      details: {
        type: mongoose.Schema.Types.Mixed
      }
    },
    version: {
      type: Number,
      default: 1
    }
  },
  { timestamps: true }
);

// Index for efficient queries
itinerarySchema.index({ owner: 1 });
itinerarySchema.index({ 'destination.location': '2dsphere' });

// Method to get the public ID (UUID)
itinerarySchema.methods.getPublicId = function() {
  return this.uuid;
};

export const Itinerary = mongoose.model('Itinerary', itinerarySchema);

