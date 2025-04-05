import React, { useState, useEffect, useRef } from 'react';
import { useSelector } from 'react-redux';
import axios from 'axios';
import { toast } from 'react-toastify';
import Chart from 'chart.js/auto';
import api from '../services/api';

const COLORS = ['#0088FE', '#00C49F', '#FFBB28', '#FF8042', '#8884D8'];

const BudgetManager = ({ itineraryId, budget, onUpdate, isEditorRole = false }) => {
  const { token } = useSelector(state => state.auth);
  const [isEditing, setIsEditing] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [totalBudget, setTotalBudget] = useState(budget?.total || 0);
  const [currency, setCurrency] = useState(budget?.currency || 'USD');
  const [showSplitwise, setShowSplitwise] = useState(false);
  const [expenseData, setExpenseData] = useState(null);
  const [isAddingExpense, setIsAddingExpense] = useState(false);
  const [newExpense, setNewExpense] = useState({
    title: '',
    amount: '',
    category: 'other',
    notes: ''
  });
  
  // Chart refs
  const categoryChartRef = useRef(null);
  const balanceChartRef = useRef(null);
  const categoryChartInstance = useRef(null);
  const balanceChartInstance = useRef(null);
  
  useEffect(() => {
    if (budget) {
      setTotalBudget(budget.total);
      setCurrency(budget.currency);
    }
  }, [budget]);
  
  // Make sure to fetch expense data initially if splitwise is enabled
  useEffect(() => {
    if (budget && budget.isSplitwiseEnabled) {
      setShowSplitwise(true);
      fetchExpenseData();
    }
  }, [budget]);
  
  // Create or update charts when expense data changes
  useEffect(() => {
    if (expenseData && showSplitwise) {
      updateCategoryChart();
      updateBalanceChart();
    }
    
    return () => {
      // Cleanup charts on component unmount
      if (categoryChartInstance.current) {
        categoryChartInstance.current.destroy();
      }
      if (balanceChartInstance.current) {
        balanceChartInstance.current.destroy();
      }
    };
  }, [expenseData, showSplitwise]);
  
  const handleUpdateBudget = async () => {
    try {
      setIsLoading(true);
      const response = await api.put(
        `/budget/itineraries/${itineraryId}`,
        { total: totalBudget, currency }
      );
      
      if (response.data.status === 'success') {
        toast.success('Budget updated successfully');
        setIsEditing(false);
        if (onUpdate) onUpdate(response.data.data.budget);
      }
    } catch (error) {
      console.error('Error updating budget:', error);
      toast.error('Failed to update budget');
    } finally {
      setIsLoading(false);
    }
  };
  
  const toggleSplitwiseMode = async () => {
    try {
      setIsLoading(true);
      const response = await api.put(
        `/budget/itineraries/${itineraryId}/splitwise`,
        { isEnabled: !showSplitwise }
      );
      
      if (response.data.status === 'success') {
        setShowSplitwise(!showSplitwise);
        if (!showSplitwise) {
          fetchExpenseData();
        }
        toast.success(`Splitwise mode ${!showSplitwise ? 'enabled' : 'disabled'}`);
        
        // Update the budget object if onUpdate is provided
        if (onUpdate && response.data.data && response.data.data.budget) {
          onUpdate(response.data.data.budget);
        }
      }
    } catch (error) {
      console.error('Error toggling splitwise mode:', error);
      toast.error('Failed to toggle splitwise mode');
    } finally {
      setIsLoading(false);
    }
  };
  
  const fetchExpenseData = async () => {
    try {
      setIsLoading(true);
      const response = await api.get(
        `/budget/itineraries/${itineraryId}/breakdown`
      );
      
      if (response.data.status === 'success') {
        setExpenseData(response.data.data);
      }
    } catch (error) {
      console.error('Error fetching expense data:', error);
      toast.error('Failed to fetch expense data');
    } finally {
      setIsLoading(false);
    }
  };
  
  const handleExpenseInputChange = (e) => {
    const { name, value } = e.target;
    setNewExpense(prev => ({
      ...prev,
      [name]: name === 'amount' ? value : value
    }));
  };
  
  const addExpense = async (e) => {
    e.preventDefault();
    
    if (!newExpense.title || !newExpense.amount) {
      toast.error('Title and amount are required');
      return;
    }
    
    try {
      setIsLoading(true);
      const response = await api.post(
        `/budget/itineraries/${itineraryId}/expenses`,
        newExpense
      );
      
      if (response.data.status === 'success') {
        toast.success('Expense added successfully');
        setNewExpense({
          title: '',
          amount: '',
          category: 'other',
          notes: ''
        });
        setIsAddingExpense(false);
        fetchExpenseData();
      }
    } catch (error) {
      console.error('Error adding expense:', error);
      toast.error('Failed to add expense');
    } finally {
      setIsLoading(false);
    }
  };
  
  const settleExpense = async (memberId, amount) => {
    try {
      setIsLoading(true);
      const response = await api.post(
        `/budget/itineraries/${itineraryId}/settle`,
        { memberId, amount }
      );
      
      if (response.data.status === 'success') {
        toast.success('Expense settled successfully');
        fetchExpenseData();
      }
    } catch (error) {
      console.error('Error settling expense:', error);
      toast.error('Failed to settle expense');
    } finally {
      setIsLoading(false);
    }
  };
  
  // Create category pie chart
  const updateCategoryChart = () => {
    if (!categoryChartRef.current || !expenseData) return;
    
    // Prepare data
    const categories = Object.keys(expenseData.categoryBreakdown || {});
    const values = Object.values(expenseData.categoryBreakdown || {});
    
    // Capitalize category names and filter out zero values
    const nonZeroData = categories.map((cat, index) => ({
      category: cat.charAt(0).toUpperCase() + cat.slice(1),
      value: values[index]
    })).filter(item => item.value > 0);
    
    const labels = nonZeroData.map(item => item.category);
    const dataValues = nonZeroData.map(item => item.value);
    
    // Clean up previous chart if it exists
    if (categoryChartInstance.current) {
      categoryChartInstance.current.destroy();
    }
    
    // Create new chart
    categoryChartInstance.current = new Chart(categoryChartRef.current, {
      type: 'pie',
      data: {
        labels: labels,
        datasets: [{
          data: dataValues,
          backgroundColor: COLORS,
          borderWidth: 1
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            position: 'right',
            labels: {
              font: {
                size: 12
              }
            }
          },
          tooltip: {
            callbacks: {
              label: function(context) {
                const label = context.label || '';
                const value = context.raw || 0;
                return `${label}: ${currency} ${value.toFixed(2)}`;
              }
            }
          }
        }
      }
    });
  };
  
  // Create balance bar chart
  const updateBalanceChart = () => {
    if (!balanceChartRef.current || !expenseData) return;
    
    // Prepare data
    const names = expenseData.balances.map(b => b.name);
    const balances = expenseData.balances.map(b => b.net);
    
    // Generate colors based on positive/negative values
    const bgColors = balances.map(val => val >= 0 ? '#00C49F' : '#FF8042');
    
    // Clean up previous chart if it exists
    if (balanceChartInstance.current) {
      balanceChartInstance.current.destroy();
    }
    
    // Create new chart
    balanceChartInstance.current = new Chart(balanceChartRef.current, {
      type: 'bar',
      data: {
        labels: names,
        datasets: [{
          label: 'Balance',
          data: balances,
          backgroundColor: bgColors,
          borderColor: bgColors,
          borderWidth: 1
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        scales: {
          y: {
            beginAtZero: true,
            ticks: {
              callback: function(value) {
                return `${currency} ${value.toFixed(2)}`;
              }
            }
          }
        },
        plugins: {
          tooltip: {
            callbacks: {
              label: function(context) {
                const value = context.raw;
                return `Balance: ${currency} ${value.toFixed(2)}`;
              }
            }
          },
          legend: {
            display: false
          }
        }
      }
    });
  };
  
  const canEdit = isEditorRole;
  
  return (
    <div className="bg-white rounded-lg shadow-md p-6 mb-6">
      <div className="flex justify-between items-center mb-4">
        <h2 className="text-xl font-bold">Budget Management</h2>
        {!isEditing ? (
          canEdit && (
            <button
              onClick={() => setIsEditing(true)}
              className="bg-indigo-600 text-white px-4 py-2 rounded hover:bg-indigo-700"
              disabled={isLoading}
            >
              Edit Budget
            </button>
          )
        ) : (
          <div className="flex space-x-2">
            <button
              onClick={handleUpdateBudget}
              className="bg-green-600 text-white px-4 py-2 rounded hover:bg-green-700 disabled:bg-green-300"
              disabled={isLoading}
            >
              Save
            </button>
            <button
              onClick={() => setIsEditing(false)}
              className="bg-gray-300 text-gray-800 px-4 py-2 rounded hover:bg-gray-400 disabled:bg-gray-200"
              disabled={isLoading}
            >
              Cancel
            </button>
          </div>
        )}
      </div>
      
      {/* Budget info */}
      <div className="mb-6">
        {isEditing ? (
          <div className="flex flex-col md:flex-row space-y-4 md:space-y-0 md:space-x-4">
            <div className="flex-1">
              <label className="block text-gray-700 mb-2">Budget Amount</label>
              <input
                type="number"
                value={totalBudget}
                onChange={(e) => setTotalBudget(parseFloat(e.target.value))}
                className="w-full p-2 border rounded focus:outline-none focus:ring-2 focus:ring-indigo-500"
                disabled={isLoading}
              />
            </div>
            <div className="flex-1">
              <label className="block text-gray-700 mb-2">Currency</label>
              <select
                value={currency}
                onChange={(e) => setCurrency(e.target.value)}
                className="w-full p-2 border rounded focus:outline-none focus:ring-2 focus:ring-indigo-500"
                disabled={isLoading}
              >
                <option value="USD">USD</option>
                <option value="EUR">EUR</option>
                <option value="GBP">GBP</option>
                <option value="INR">INR</option>
                <option value="JPY">JPY</option>
              </select>
            </div>
          </div>
        ) : (
          <div className="flex justify-between">
            <div>
              <h3 className="text-gray-600 text-sm">Total Budget</h3>
              <p className="text-2xl font-bold">{currency} {budget?.total?.toLocaleString() || 0}</p>
            </div>
            <div>
              <h3 className="text-gray-600 text-sm">Per Person</h3>
              <p className="text-2xl font-bold">{currency} {budget?.perPerson?.toLocaleString() || 0}</p>
            </div>
            <div>
              <h3 className="text-gray-600 text-sm">Spent</h3>
              <p className="text-2xl font-bold">{currency} {budget?.spent?.toLocaleString() || 0}</p>
            </div>
            <div>
              <h3 className="text-gray-600 text-sm">Remaining</h3>
              <p className="text-2xl font-bold">
                {currency} {((budget?.total || 0) - (budget?.spent || 0)).toLocaleString()}
              </p>
            </div>
          </div>
        )}
      </div>
      
      {/* Splitwise toggle */}
      <div className="mb-6">
        <div className="flex items-center justify-between">
          <span className="text-gray-700">Enable Expense Splitting</span>
          {canEdit ? (
            <button
              onClick={toggleSplitwiseMode}
              className={`px-4 py-2 rounded-lg font-medium ${
                showSplitwise 
                  ? 'bg-red-100 text-red-700 hover:bg-red-200' 
                  : 'bg-indigo-100 text-indigo-700 hover:bg-indigo-200'
              }`}
              disabled={isLoading}
            >
              {isLoading ? 'Loading...' : (showSplitwise ? 'Disable Splitting' : 'Enable Splitting')}
            </button>
          ) : (
            <span className={`px-3 py-1 text-sm rounded-full ${
              showSplitwise 
                ? 'bg-green-100 text-green-800' 
                : 'bg-gray-100 text-gray-800'
            }`}>
              {showSplitwise ? 'Enabled' : 'Disabled'}
            </span>
          )}
        </div>
      </div>
      
      {showSplitwise && (
        <div className="space-y-6">
          <div className="flex justify-between items-center">
            <h3 className="text-lg font-bold">Expense Tracking</h3>
            <button
              onClick={() => setIsAddingExpense(!isAddingExpense)}
              className="bg-indigo-600 text-white px-4 py-2 rounded hover:bg-indigo-700"
            >
              {isAddingExpense ? 'Cancel' : 'Add Expense'}
            </button>
          </div>
          
          {isAddingExpense && (
            <div className="bg-gray-50 p-4 rounded-lg mb-4">
              <h4 className="text-md font-medium mb-3">New Expense</h4>
              <form onSubmit={addExpense}>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
                  <div>
                    <label className="block text-gray-700 font-medium mb-2">
                      Title*
                    </label>
                    <input
                      type="text"
                      name="title"
                      value={newExpense.title}
                      onChange={handleExpenseInputChange}
                      className="w-full px-4 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-indigo-500"
                      required
                    />
                  </div>
                  <div>
                    <label className="block text-gray-700 font-medium mb-2">
                      Amount* ({currency})
                    </label>
                    <input
                      type="number"
                      name="amount"
                      value={newExpense.amount}
                      onChange={handleExpenseInputChange}
                      className="w-full px-4 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-indigo-500"
                      min="0"
                      step="0.01"
                      required
                    />
                  </div>
                </div>
                
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
                  <div>
                    <label className="block text-gray-700 font-medium mb-2">
                      Category
                    </label>
                    <select
                      name="category"
                      value={newExpense.category}
                      onChange={handleExpenseInputChange}
                      className="w-full px-4 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-indigo-500"
                    >
                      <option value="accommodation">Accommodation</option>
                      <option value="food">Food</option>
                      <option value="transport">Transportation</option>
                      <option value="attraction">Attraction</option>
                      <option value="other">Other</option>
                    </select>
                  </div>
                  <div>
                    <label className="block text-gray-700 font-medium mb-2">
                      Notes
                    </label>
                    <input
                      type="text"
                      name="notes"
                      value={newExpense.notes}
                      onChange={handleExpenseInputChange}
                      className="w-full px-4 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-indigo-500"
                    />
                  </div>
                </div>
                
                <button
                  type="submit"
                  className="bg-green-600 text-white px-4 py-2 rounded hover:bg-green-700"
                  disabled={isLoading}
                >
                  {isLoading ? 'Adding...' : 'Add Expense'}
                </button>
              </form>
            </div>
          )}
          
          {expenseData ? (
            <div className="space-y-6">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div className="bg-white p-4 rounded-lg shadow">
                  <h4 className="text-lg font-medium mb-3">Expense Breakdown</h4>
                  <div className="h-64 relative">
                    <canvas ref={categoryChartRef}></canvas>
                  </div>
                </div>
                
                <div className="bg-white p-4 rounded-lg shadow">
                  <h4 className="text-lg font-medium mb-3">Member Balances</h4>
                  <div className="h-64 relative">
                    <canvas ref={balanceChartRef}></canvas>
                  </div>
                </div>
              </div>
              
              <div className="bg-white p-4 rounded-lg shadow">
                <h4 className="text-lg font-medium mb-3">Who Owes What?</h4>
                <div className="divide-y">
                  {expenseData.balances.map(balance => (
                    <div key={balance.id} className="py-3">
                      <div className="flex justify-between items-center mb-2">
                        <div>
                          <span className="font-medium">{balance.name}</span>
                          <span className={`ml-2 ${balance.net >= 0 ? 'text-green-600' : 'text-red-600'}`}>
                            {balance.net >= 0 
                              ? `gets back ${currency} ${balance.net.toFixed(2)}` 
                              : `owes ${currency} ${Math.abs(balance.net).toFixed(2)}`}
                          </span>
                        </div>
                        
                        {balance.net < 0 && (
                          <button
                            onClick={() => settleExpense(balance.id, Math.abs(balance.net))}
                            className="text-sm bg-indigo-100 text-indigo-700 px-3 py-1 rounded hover:bg-indigo-200"
                          >
                            Mark as Settled
                          </button>
                        )}
                      </div>
                      
                      {Object.values(balance.details)
                        .filter(detail => detail.amount !== 0)
                        .map(detail => (
                          <div key={detail.id} className="text-sm text-gray-600 ml-4">
                            {detail.amount > 0
                              ? `Gets ${currency} ${detail.amount.toFixed(2)} from ${detail.name}`
                              : `Owes ${currency} ${Math.abs(detail.amount).toFixed(2)} to ${detail.name}`}
                          </div>
                        ))}
                    </div>
                  ))}
                </div>
              </div>
            </div>
          ) : (
            <div className="text-center py-8">
              <p className="text-gray-500 mb-4">No expense data yet. Start adding expenses to track your spending!</p>
              <button
                onClick={fetchExpenseData}
                className="bg-indigo-600 text-white px-4 py-2 rounded hover:bg-indigo-700"
                disabled={isLoading}
              >
                {isLoading ? 'Loading...' : 'Refresh Data'}
              </button>
            </div>
          )}
        </div>
      )}
    </div>
  );
};

export default BudgetManager; 