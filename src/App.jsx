import { BrowserRouter, Routes, Route } from 'react-router-dom'
import { Provider } from 'react-redux'
import store from './store'

import MainLayout from './layouts/MainLayout'
import Home from './pages/Home'
import Login from './pages/Login'
import Register from './pages/Register'
import Profile from './pages/Profile'
import About from './pages/About'
import Itineraries from './pages/Itineraries'
import CreateItinerary from './pages/CreateItinerary'
import ItineraryDetails from './pages/ItineraryDetails'
import DayPlanner from './pages/DayPlanner'
import PlaceSearch from './pages/PlaceSearch'

function App() {
  return (
    <Provider store={store}>
      <BrowserRouter>
        <Routes>
          <Route path="/" element={<MainLayout />}>
            <Route index element={<Home />} />
            <Route path="login" element={<Login />} />
            <Route path="register" element={<Register />} />
            <Route path="profile" element={<Profile />} />
            <Route path="about" element={<About />} />
            <Route path="itineraries" element={<Itineraries />} />
            <Route path="itineraries/new" element={<CreateItinerary />} />
            <Route path="itineraries/:id" element={<ItineraryDetails />} />
            <Route path="itineraries/:id/days/:dayId" element={<DayPlanner />} />
            <Route path="places/search" element={<PlaceSearch />} />
            {/* Additional routes will be added in future phases */}
          </Route>
        </Routes>
      </BrowserRouter>
    </Provider>
  )
}

export default App
