function About() {
  return (
    <div className="max-w-4xl mx-auto py-12">
      <h1 className="text-3xl md:text-4xl font-bold mb-8 text-center">
        About Travel Planner
      </h1>
      
      <div className="bg-white rounded-lg shadow-md p-8 mb-8">
        <h2 className="text-2xl font-bold mb-4">Our Mission</h2>
        <p className="text-lg leading-relaxed mb-6">
          At Travel Planner, we believe that the best trips are the ones that are well-planned
          but leave room for spontaneity. Our mission is to simplify the travel planning process,
          making it more collaborative and enjoyable, so you can focus on creating unforgettable
          memories.
        </p>
        <p className="text-lg leading-relaxed">
          Whether you're a solo adventurer, a couple on a romantic getaway, or a family planning
          the annual vacation, our platform provides the tools you need to create the perfect itinerary,
          stay organized, and make the most of your travel experience.
        </p>
      </div>
      
      <div className="bg-white rounded-lg shadow-md p-8 mb-8">
        <h2 className="text-2xl font-bold mb-4">Our Story</h2>
        <p className="text-lg leading-relaxed mb-6">
          Travel Planner was born out of frustration with the existing travel planning tools.
          As avid travelers ourselves, we found that coordinating trips with friends and family
          was often a chaotic experience involving multiple spreadsheets, countless messaging apps,
          and fragmented information.
        </p>
        <p className="text-lg leading-relaxed">
          We set out to create a comprehensive platform that combines powerful planning features
          with a simple, intuitive interface. After months of development and testing, Travel Planner
          was launched with the goal of revolutionizing how people plan and experience travel.
        </p>
      </div>
      
      <div className="bg-white rounded-lg shadow-md p-8">
        <h2 className="text-2xl font-bold mb-6">Our Values</h2>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          <div>
            <h3 className="text-xl font-semibold mb-3 text-indigo-600">Simplicity</h3>
            <p className="text-gray-700">
              We believe in keeping things simple. Our platform is designed to be intuitive
              and easy to use, even for first-time travelers.
            </p>
          </div>
          <div>
            <h3 className="text-xl font-semibold mb-3 text-indigo-600">Collaboration</h3>
            <p className="text-gray-700">
              Travel is better when shared. We've built our tools to make group planning
              seamless and enjoyable for everyone involved.
            </p>
          </div>
          <div>
            <h3 className="text-xl font-semibold mb-3 text-indigo-600">Adventure</h3>
            <p className="text-gray-700">
              We encourage exploration and new experiences. Our platform helps you discover
              hidden gems and create unique itineraries.
            </p>
          </div>
        </div>
      </div>
    </div>
  )
}

export default About 