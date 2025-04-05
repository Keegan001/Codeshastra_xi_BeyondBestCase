const mongoose = require('mongoose');
const { v4: uuidv4 } = require('uuid');

const daySchema = new mongoose.Schema(
  {
    uuid: {
      type: String,
      default: uuidv4,
      unique: true,
      required: true
    },
    date: {
      type: Date,
      required: true
    },
    itinerary: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Itinerary',
      required: true
    },
    activities: [{
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Activity'
    }],
    notes: {
      type: String,
      trim: true
    }
  },
  { timestamps: true }
);

// Index for efficient queries
daySchema.index({ itinerary: 1, date: 1 });
daySchema.index({ uuid: 1 });

// Method to get the public ID (UUID)
daySchema.methods.getPublicId = function() {
  return this.uuid;
};

// Virtual for day number in the itinerary
daySchema.virtual('dayNumber').get(function() {
  if (this._dayNumber !== undefined) {
    return this._dayNumber;
  }
  return null;
});

daySchema.virtual('dayNumber').set(function(num) {
  this._dayNumber = num;
});

// Include virtuals when converting to JSON
daySchema.set('toJSON', { virtuals: true });
daySchema.set('toObject', { virtuals: true });

const Day = mongoose.model('Day', daySchema);

module.exports = Day; 