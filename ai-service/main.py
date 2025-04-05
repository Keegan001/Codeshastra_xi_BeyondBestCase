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
        You are a travel itinerary planner AI. Generate a detailed, structured, and strictly valid JSON itinerary based on the input details provided below.

        INPUT PARAMETERS:
        - destination: [string] – Main destination of the trip.
        - path: [list of strings] – Specific places or areas to cover in the trip.
        - activities_to_attend: [list of strings] – Desired activities.
        - trip_length: [integer] – Number of days for the trip.
        - date_range: [start_date, end_date] – Date range for the trip.
        - budget: [string] – Total budget for the entire trip.
        - accomodations: [list of preferences] – Hotel or stay preferences.
        - restaurants: [list of preferences] – Preferred cuisines or restaurant types.
        - numberofpeople: [integer] – Number of travelers.

        RESPONSE FORMAT RULES:
        - Output only valid JSON (do not wrap with triple backticks or any Markdown).
        - The root structure must have:
        - `day_wise_plan`: an array of objects, one for each day.
        - `additional_suggestions`: an object with more recommendations.

        DAY-WISE PLAN FORMAT:
        ```json
        "day_wise_plan": [
        {
            "day": "Day 1 (YYYY-MM-DD)",
            "destination": "Specific places for this day",
            "activities": ["Activity 1", "Activity 2"],
            "accomodations": ["Hotel 1"],
            "restaurants": ["Restaurant 1"],
            "events": ["Event 1", "Event 2"],  // Optional events for that date
            "transportation": ["Transport method(s)"],
            "estimated_cost": "Approximate cost of the day (in local currency)"
        },
        ...
        ]

    """

    response = client.models.generate_content(
        model="gemini-2.0-flash",
        contents=user_prompt,
    )
    return {"message": "Itinerary generated successfully", "itinerary": response.text}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000) 