require('dotenv').config();

const config = {
  env: process.env.NODE_ENV || 'development',
  port: process.env.PORT || 5000,
  mongoUri: process.env.MONGODB_URI || 'mongodb://localhost:27017/travel-planner',
  jwtSecret: process.env.JWT_SECRET || 'your-secret-key',
  jwtExpiresIn: process.env.JWT_EXPIRES_IN || '24h',
  corsOrigin: process.env.CORS_ORIGIN || '*'
};

// Validate required config
const requiredConfigs = ['jwtSecret'];
requiredConfigs.forEach(configKey => {
  if (config.env === 'production' && (!config[configKey] || config[configKey] === 'your-secret-key')) {
    console.error(`Error: ${configKey} is required in production environment`);
    process.exit(1);
  }
});

module.exports = config; 