import React from 'react';

const Button = ({ 
  children, 
  onClick, 
  type = 'button', 
  className = '', 
  disabled = false, 
  variant = 'default',
  size = 'default'
}) => {
  const baseClasses = 'inline-flex items-center justify-center font-medium rounded-md transition-colors focus:outline-none';
  
  const variantClasses = {
    default: 'bg-indigo-600 text-white hover:bg-indigo-700 disabled:bg-indigo-300',
    outline: 'border border-gray-300 bg-white text-gray-700 hover:bg-gray-50 disabled:bg-gray-100',
    destructive: 'bg-red-600 text-white hover:bg-red-700 disabled:bg-red-300'
  };
  
  const sizeClasses = {
    sm: 'text-xs px-2 py-1 rounded',
    default: 'text-sm px-4 py-2 rounded-md',
    lg: 'text-base px-6 py-3 rounded-lg'
  };
  
  const classes = `${baseClasses} ${variantClasses[variant]} ${sizeClasses[size]} ${className}`;
  
  return (
    <button
      type={type}
      className={classes}
      onClick={onClick}
      disabled={disabled}
    >
      {children}
    </button>
  );
};

export { Button }; 