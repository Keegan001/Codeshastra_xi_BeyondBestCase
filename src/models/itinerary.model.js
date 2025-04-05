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

const locationSchema = new mongoose.Schema({
  name: {
    type: String,
    trim: true
  },
  description: {
    type: String,
    trim: true
  },
  placeId: {
    type: String
  },
  location: {
    type: pointSchema
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

const joinRequestSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  },
  status: {
    type: String,
    enum: ['pending', 'approved', 'rejected'],
    default: 'pending'
  },
  requestedAt: {
    type: Date,
    default: Date.now
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
    joinRequests: [joinRequestSchema],
    isPrivate: {
      type: Boolean,
      default: false,
      description: 'Flag to indicate if the itinerary is private or public'
    },
    publiclyJoinable: {
      type: Boolean,
      default: true,
      description: 'Flag to indicate if users can request to join this itinerary'
    },
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
    routeLocations: [locationSchema],
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
itinerarySchema.index({ 'routeLocations.location': '2dsphere' });
itinerarySchema.index({ isPrivate: 1 }); // Index for querying public itineraries

// Method to get the public ID (UUID)
itinerarySchema.methods.getPublicId = function() {
  return this.uuid;
};

export const Itinerary = mongoose.model('Itinerary', itinerarySchema);

