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

const collaboratorSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  role: {
    type: String,
    enum: ['editor', 'viewer'],
    default: 'viewer',
    required: true
  }
});

const itinerarySchema = new mongoose.Schema(
  {
    uuid: {
      type: String,
      default: uuidv4,
      unique: true,
      required: true
    },
    title: {
      type: String,
      required: true,
      trim: true
    },
    description: {
      type: String,
      trim: true
    },
    owner: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true
    },
    collaborators: [collaboratorSchema],
    destination: {
      name: {
        type: String,
        required: true
      },
      location: {
        type: pointSchema,
        required: true
      },
      country: {
        type: String,
        required: true
      }
    },
    dateRange: {
      start: {
        type: Date,
        required: true
      },
      end: {
        type: Date,
        required: true
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

// Pre-save hook to ensure dates are valid
itinerarySchema.pre('save', function(next) {
  if (this.dateRange.end < this.dateRange.start) {
    const err = new Error('End date cannot be before start date');
    err.status = 400;
    return next(err);
  }
  next();
});

export const Itinerary = mongoose.model('Itinerary', itinerarySchema);

