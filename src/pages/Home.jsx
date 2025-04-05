import { Link } from 'react-router-dom'

function Home() {
  return (
    <div>
      {/* Hero Section */}
      <section className="py-12 md:py-20">
        <div className="text-center">
          <h1 className="text-4xl md:text-6xl font-bold mb-6">
            Your Journey, <span className="text-indigo-600">Your Way</span>
          </h1>
          <p className="text-xl text-gray-600 mb-8 max-w-2xl mx-auto">
            Create personalized travel itineraries, collaborate with friends, and
            explore new destinations with ease.
          </p>
          <div className="flex flex-col md:flex-row justify-center gap-4">
            <Link
              to="/register"
              className="bg-indigo-600 text-white px-6 py-3 rounded-lg font-medium hover:bg-indigo-700"
            >
              Get Started
            </Link>
            <Link
              to="/about"
              className="bg-white text-indigo-600 border border-indigo-600 px-6 py-3 rounded-lg font-medium hover:bg-gray-50"
            >
              Learn More
            </Link>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="py-12 bg-gray-50">
        <div className="text-center mb-12">
          <h2 className="text-3xl font-bold mb-4">
            Plan Your Perfect Trip
          </h2>
          <p className="text-gray-600 max-w-2xl mx-auto">
            Our platform gives you all the tools you need to create, manage, and share
            your travel plans.
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          <div className="bg-white p-6 rounded-lg shadow-md">
            <div className="h-12 w-12 bg-indigo-100 text-indigo-600 rounded-lg flex items-center justify-center mb-4">
              <svg className="h-6 w-6" fill="currentColor" viewBox="0 0 24 24">
                <path d="M12 22a10 10 0 1 1 0-20 10 10 0 0 1 0 20zm0-2a8 8 0 1 0 0-16 8 8 0 0 0 0 16zm-3.54-4.54a1 1 0 0 1 1.41-1.41L12 16.17l2.12-2.12a1 1 0 1 1 1.42 1.41l-2.83 2.83a1 1 0 0 1-1.42 0l-2.83-2.83z" />
              </svg>
            </div>
            <h3 className="text-xl font-semibold mb-2">Easy Planning</h3>
            <p className="text-gray-600">
              Create detailed day-by-day itineraries with our intuitive interface.
              Add activities, accommodations, and transportation.
            </p>
          </div>

          <div className="bg-white p-6 rounded-lg shadow-md">
            <div className="h-12 w-12 bg-indigo-100 text-indigo-600 rounded-lg flex items-center justify-center mb-4">
              <svg className="h-6 w-6" fill="currentColor" viewBox="0 0 24 24">
                <path d="M17 17a5 5 0 1 1-4.6-5 1 1 0 0 1 1.4 1.4 3 3 0 1 0 2.8 2.8 1 1 0 1 1 1.4 1.4A5 5 0 0 1 17 17zM7 7a5 5 0 1 1-4.6-5 1 1 0 0 1 1.4 1.4 3 3 0 1 0 2.8 2.8 1 1 0 1 1 1.4 1.4A5 5 0 0 1 7 7zm10 0a3 3 0 0 1-3-3 1 1 0 0 1 2 0 1 1 0 0 0 1 1 1 1 0 0 1 0 2zm-5 10a3 3 0 0 1-3-3 1 1 0 0 1 2 0 1 1 0 0 0 1 1 1 1 0 0 1 0 2z" />
              </svg>
            </div>
            <h3 className="text-xl font-semibold mb-2">Collaborate</h3>
            <p className="text-gray-600">
              Share your itineraries with friends and family. Plan together in real-time
              and make group decisions effortlessly.
            </p>
          </div>

          <div className="bg-white p-6 rounded-lg shadow-md">
            <div className="h-12 w-12 bg-indigo-100 text-indigo-600 rounded-lg flex items-center justify-center mb-4">
              <svg className="h-6 w-6" fill="currentColor" viewBox="0 0 24 24">
                <path d="M20 11a8 8 0 0 1-8 8 1 1 0 0 1 0-2 6 6 0 0 0 6-6 1 1 0 0 1 2 0zm-2-3a6 6 0 0 1-6 6 1 1 0 0 1 0-2 4 4 0 0 0 4-4 1 1 0 0 1 2 0zM6 7a1 1 0 1 1 0 2 1 1 0 0 1 0-2zm0 4a1 1 0 1 1 0 2 1 1 0 0 1 0-2zm0 4a1 1 0 1 1 0 2 1 1 0 0 1 0-2z" />
              </svg>
            </div>
            <h3 className="text-xl font-semibold mb-2">Interactive Maps</h3>
            <p className="text-gray-600">
              Visualize your journey with interactive maps. Plot your routes and
              discover nearby attractions and points of interest.
            </p>
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-12 md:py-20 bg-indigo-600 text-white">
        <div className="text-center">
          <h2 className="text-3xl md:text-4xl font-bold mb-6">
            Ready to Start Your Adventure?
          </h2>
          <p className="text-xl mb-8 max-w-2xl mx-auto">
            Join thousands of travelers who plan their perfect trips with our platform.
          </p>
          <Link
            to="/register"
            className="bg-white text-indigo-600 px-6 py-3 rounded-lg font-medium hover:bg-gray-100"
          >
            Sign Up for Free
          </Link>
        </div>
      </section>
    </div>
  )
}

export default Home 