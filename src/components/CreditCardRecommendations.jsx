import { useState, useEffect } from 'react';
import { GoogleGenAI } from "@google/genai";
import { Card } from './ui/card';
import Loader from './Loader';

function CreditCardRecommendations({ destination }) {
  const [recommendations, setRecommendations] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  useEffect(() => {
    async function fetchRecommendations() {
      if (!destination) return;
      
      setLoading(true);
      setError(null);
      
      try {
        // Try both environment variable options
        const apiKey = import.meta.env.VITE_GEMINI_KEY || import.meta.env.GEMINI_KEY || "AIzaSyCMwuKcohq5uYsjFnMTddXSm0JRwXusPXk";
        if (!apiKey) {
          throw new Error("Missing Gemini API key");
        }
        
        const ai = new GoogleGenAI({ apiKey: apiKey });
        
        const prompt = `
          As a travel financial advisor, recommend the top 3 credit cards for traveling to ${destination}.
          For each card, provide:
          1. Card name
          2. Annual fee
          3. Key travel benefits (focus on points, lounge access, travel insurance)
          4. Why it's good for ${destination} specifically
          
          Strictly Format the response as a JSON array of objects with the following structure:
          "creditCards": [
            {
              "name": "Card Name",
              "annualFee": "$XXX",
              "benefits": ["Benefit 1", "Benefit 2", "Benefit 3"],
              "destinationValue": "Explanation of why it's good for ${destination}"
            }
          ]
          
          Only return the JSON array, no additional text.
        `;
        
        
        const response = await ai.models.generateContent({
            model: "gemini-2.0-flash",
            contents: prompt,
          });
        
        // Get the response text from the appropriate structure
        // The response object contains candidates array with parts that have the text
        const responseText = response.candidates?.[0]?.content?.parts?.[0]?.text || "";
        
        if (!responseText) {
          throw new Error("Empty response from Gemini API");
        } else {
          console.log(responseText);
        }
        
        // Process the response text - remove markdown code formatting if present
        try {
          // Remove markdown code blocks if present
          let cleanedText = responseText.trim();
          
          // Remove ```json and ``` that may wrap the JSON content
          cleanedText = cleanedText.replace(/```json\s*|\s*```/g, '');
          
          console.log("Cleaned text:", cleanedText);
          
          // Try to parse the entire response as JSON
          const parsedResponse = JSON.parse(cleanedText);
          // Extract the credit cards array from the response if it exists
          const creditCards = parsedResponse.creditCards || parsedResponse;
          setRecommendations(creditCards);
        } catch (jsonError) {
          console.error("Error parsing cleaned JSON:", jsonError);
          
          // If direct parsing still fails, try to extract JSON from the response
          try {
            const jsonStart = responseText.indexOf('[');
            const jsonEnd = responseText.lastIndexOf(']') + 1;
            
            if (jsonStart >= 0 && jsonEnd > jsonStart) {
              const jsonString = responseText.substring(jsonStart, jsonEnd);
              const parsedRecommendations = JSON.parse(jsonString);
              setRecommendations(parsedRecommendations);
            } else {
              // Try to find the creditCards property instead
              const creditCardsStart = responseText.indexOf('"creditCards":');
              if (creditCardsStart >= 0) {
                const objectStart = responseText.indexOf('[', creditCardsStart);
                const objectEnd = responseText.lastIndexOf(']') + 1;
                
                if (objectStart >= 0 && objectEnd > objectStart) {
                  const jsonString = responseText.substring(objectStart, objectEnd);
                  const parsedRecommendations = JSON.parse(jsonString);
                  setRecommendations(parsedRecommendations);
                } else {
                  throw new Error("Could not find creditCards array in response");
                }
              } else {
                throw new Error("Could not find JSON array in response");
              }
            }
          } catch (extractError) {
            console.error("Error parsing JSON from response:", extractError);
            throw new Error("Failed to parse credit card recommendations");
          }
        }
      } catch (err) {
        console.error("Error fetching credit card recommendations:", err);
        setError("Failed to get credit card recommendations. Please try again later.");
      } finally {
        setLoading(false);
      }
    }
    
    fetchRecommendations();
  }, [destination]);
  
  if (loading) {
    return (
      <div className="p-4">
        <h3 className="text-lg font-medium mb-2">Finding the best credit cards for {destination}...</h3>
        <Loader size="small" />
      </div>
    );
  }
  
  if (error) {
    return (
      <div className="p-4 bg-red-50 text-red-700 rounded-lg">
        <p>{error}</p>
      </div>
    );
  }
  
  if (!recommendations || recommendations.length === 0) {
    return null;
  }
  
  return (
    <div className="mb-8">
      <h3 className="text-xl font-bold mb-4 text-gray-800 flex items-center">
        <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5 mr-2 text-[#56288A]" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z" />
        </svg>
        Best Credit Cards for {destination}
      </h3>
      
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        {Array.isArray(recommendations) ? recommendations.map((card, index) => (
          <Card key={index} className="p-4 hover:shadow-lg transition-shadow">
            <h4 className="text-lg font-semibold mb-2 text-[#56288A]">{card.name}</h4>
            <p className="text-sm font-medium text-gray-700 mb-3">Annual Fee: {card.annualFee}</p>
            
            <h5 className="text-sm font-medium text-gray-700 mb-1">Key Benefits:</h5>
            <ul className="mb-3 text-sm list-disc list-inside">
              {card.benefits.map((benefit, i) => (
                <li key={i} className="text-gray-600">{benefit}</li>
              ))}
            </ul>
            
            <div className="mt-2 pt-2 border-t border-gray-100">
              <h5 className="text-sm font-medium text-gray-700 mb-1">Why it's good for {destination}:</h5>
              <p className="text-sm text-gray-600">{card.destinationValue}</p>
            </div>
          </Card>
        )) : <p>No credit card recommendations available.</p>}
      </div>
    </div>
  );
}

export default CreditCardRecommendations; 