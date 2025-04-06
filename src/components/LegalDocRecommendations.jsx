import { useState, useEffect } from 'react';
import axios from 'axios';
import { Card } from './ui/card';
import Loader from './Loader';

function LegalDocRecommendations({ source, destination }) {
  const [recommendations, setRecommendations] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  useEffect(() => {
    async function fetchLegalDocs() {
      if (!source || !destination) return;
      
      setLoading(true);
      setError(null);
      
      try {
        // Make API call to the legal documents endpoint
        const response = await axios.post('http://localhost:8000/api/ai/legal-docs', {
          source,
          destination
        });
        
        // Get the response data
        const responseData = response.data;
        
        // Process the response data
        try {
          // If it's already structured properly, use it directly
          if (Array.isArray(responseData)) {
            setRecommendations(responseData);
          } 
          // If it's an object with a documents property that contains documents array
          else if (responseData.documents && responseData.documents.documents && Array.isArray(responseData.documents.documents)) {
            setRecommendations(responseData.documents.documents);
          }
          // If it's an object with a message and documents
          else if (responseData.message && responseData.documents && responseData.documents.documents) {
            setRecommendations(responseData.documents.documents);
          }
          // If it's an object with a documents property, extract it
          else if (responseData.documents && Array.isArray(responseData.documents)) {
            setRecommendations(responseData.documents);
          } 
          // If it's a string (possibly JSON or text with JSON), try to parse it
          else if (typeof responseData === 'string') {
            // Clean the response if it contains markdown code blocks
            let cleanedText = responseData.trim();
            cleanedText = cleanedText.replace(/```json\s*|\s*```/g, '');
            
            // Parse the cleaned text
            const parsedData = JSON.parse(cleanedText);
            
            // Extract documents array based on the specific format
            let documents;
            if (parsedData.documents && parsedData.documents.documents) {
              documents = parsedData.documents.documents;
            } else if (parsedData.documents) {
              documents = parsedData.documents;
            } else {
              documents = parsedData;
            }
            
            if (Array.isArray(documents)) {
              setRecommendations(documents);
            } else {
              throw new Error("Response data is not in the expected format");
            }
          } else {
            throw new Error("Response data is not in the expected format");
          }

          // If there are additional requirements in the response, add them as a document
          if (responseData.documents && responseData.documents.additional_requirements) {
            const additionalReqs = responseData.documents.additional_requirements;
            if (Array.isArray(additionalReqs) && additionalReqs.length > 0) {
              const additionalRequirementsDoc = {
                name: "Additional Requirements",
                requirements: additionalReqs.map(req => req.requirement)
              };
              setRecommendations(prev => [...prev, additionalRequirementsDoc]);
            }
          }
        } catch (parseError) {
          console.error("Error parsing legal documents response:", parseError);
          throw new Error("Failed to parse legal document recommendations");
        }
      } catch (err) {
        console.error("Error fetching legal document recommendations:", err);
        setError("Failed to get legal document recommendations. Please try again later.");
      } finally {
        setLoading(false);
      }
    }
    
    fetchLegalDocs();
  }, [source, destination]);
  
  if (loading) {
    return (
      <div className="p-4">
        <h3 className="text-lg font-medium mb-2">Finding essential legal documents for traveling from {source} to {destination}...</h3>
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
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
        </svg>
        Required Legal Documents: {source} to {destination}
      </h3>
      
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        {Array.isArray(recommendations) ? recommendations.map((doc, index) => (
          <Card key={index} className="p-4 hover:shadow-lg transition-shadow">
            <h4 className="text-lg font-semibold mb-2 text-[#56288A]">{doc.name || doc.document_type}</h4>
            
            {doc.validityPeriod && (
              <p className="text-sm font-medium text-gray-700 mb-3">
                Validity: {doc.validityPeriod}
              </p>
            )}

            {doc.mandatory !== undefined && (
              <p className="text-sm font-medium mb-3">
                <span className={`px-2 py-1 rounded-full ${
                  doc.mandatory 
                    ? 'bg-red-100 text-red-800' 
                    : 'bg-gray-100 text-gray-800'
                }`}>
                  {doc.mandatory ? 'Required' : 'Optional'}
                </span>
              </p>
            )}
            
            {(doc.requirements && doc.requirements.length > 0) && (
              <>
                <h5 className="text-sm font-medium text-gray-700 mb-1">Requirements:</h5>
                <ul className="mb-3 text-sm list-disc list-inside">
                  {doc.requirements.map((requirement, i) => (
                    <li key={i} className="text-gray-600">{requirement}</li>
                  ))}
                </ul>
              </>
            )}
            
            {doc.processingTime && (
              <p className="text-sm text-gray-600 mb-2">
                <span className="font-medium">Processing Time:</span> {doc.processingTime}
              </p>
            )}
            
            {doc.note && (
              <div className="mt-2 pt-2 border-t border-gray-100">
                <p className="text-sm italic text-gray-600">{doc.note}</p>
              </div>
            )}
          </Card>
        )) : <p>No document recommendations available.</p>}
      </div>
    </div>
  );
}

export default LegalDocRecommendations; 