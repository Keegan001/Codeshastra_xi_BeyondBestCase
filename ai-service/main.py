from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from google import genai
from google.genai import types
from dotenv import load_dotenv
import os

load_dotenv()
API_KEY = os.getenv("GEMINI_KEY")

client = genai.Client(api_key=API_KEY)
app = FastAPI(
    title="Travel Planner AI Service",
    description="AI-powered service for travel planning and itinerary generation",
    version="1.0.0"
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, replace with specific origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
async def root():
    return {"message": "Travel Planner AI Service is running"}

@app.post("/api/ai/generate_itinerary")
async def generate_itinerary(request: Request):
    data = await request.json()

    # Extract user inputs from request JSON
    destination = data.get("destination")
    path = data.get("path")
    activities = data.get("activities_to_attend")
    trip_length = data.get("trip_length")
    date_range = data.get("date_range")
    budget = data.get("budget")
    accomodations = data.get("accomodations")
    restaurants = data.get("restaurants")
    number_of_people = data.get("numberofpeople")

    user_prompt = f"""
    Please create a travel itinerary with the following details:
    - Destination: {destination}
    - Path: {path}
    - Activities to Attend: {activities}
    - Trip Length: {trip_length} days
    - Date Range: {date_range}
    - Budget: {budget}
    - Accomodations: {accomodations}
    - Restaurants: {restaurants}
    - Number of People: {number_of_people}

    The output should strictly follow this JSON format:
    {{
        "day_wise_plan":[
            {{
                "day": "Day 1",
                "destination": "Destination 1",
                "activities": ["Activity 1", "Activity 2"],
                "accomodations": ["Accomodation 1", "Accomodation 2"],
                "restaurants": ["Restaurant 1", "Restaurant 2"],
                "events": ["Event 1", "Event 2"],
                "transportation": ["Transportation 1", "Transportation 2"],
                "estimated_cost": "Estimated cost of the day"
            }}
        ],
        "additional_suggestions": {{
            "events": ["Event 1", "Event 2"],
            "restaurants": ["Restaurant 1", "Restaurant 2"],
            "accomodations": ["Accomodation 1", "Accomodation 2"],
            "transportation": ["Transportation 1", "Transportation 2"]
        }}
    }}
    """

    response = client.models.generate_content(
        model="gemini-2.0-flash",
        contents=user_prompt,
    )
    return {"message": "Itinerary generated successfully", "itinerary": response.text}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000) 