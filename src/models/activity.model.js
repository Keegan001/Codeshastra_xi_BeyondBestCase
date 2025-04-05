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

const activitySchema = new mongoose.Schema(
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
    type: {
      type: String,
      enum: ['attraction', 'food', 'transport', 'accommodation', 'other'],
      required: true
    },
    day: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Day',
      required: true
    },
    location: {
      name: {
        type: String,
        required: true
      },
      coordinates: {
        type: pointSchema,
        required: true
      },
      address: {
        type: String,
        trim: true
      },
      placeId: {
        type: String,
        trim: true
      }
    },
    timeRange: {
      start: {
        type: Date,
        required: true
      },
      end: {
        type: Date,
        required: true
      }
    },
    cost: {
      amount: {
        type: Number,
        default: 0
      },
      currency: {
        type: String,
        default: 'USD'
      }
    },
    notes: {
      type: String,
      trim: true
    },
    reservationInfo: {
      type: String,
      trim: true
    }
  },
  { timestamps: true }
);

// Index for efficient queries
activitySchema.index({ day: 1 });
// activitySchema.index({ uuid: 1 }); // Removed to avoid duplicate index with the unique property
activitySchema.index({ 'location.coordinates': '2dsphere' });

// Method to get the public ID (UUID)
activitySchema.methods.getPublicId = function() {
  return this.uuid;
};

// Pre-save hook to ensure time range is valid
activitySchema.pre('save', function(next) {
  if (this.timeRange.end < this.timeRange.start) {
    const err = new Error('End time cannot be before start time');
    err.status = 400;
    return next(err);
  }
  next();
});

export const Activity = mongoose.model('Activity', activitySchema);
 