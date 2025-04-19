import React from "react";
import { BrowserRouter as Router, Routes, Route, Link } from "react-router-dom";
import "./../../css/app.css";

const Home = () => (
  <div>
    <h2>Reactive Bee</h2>
    <p>Welcome to Reactive Bee ...</p>
    <img src="images/rubee.svg" alt="rubee"></img>
    <nav>
        <Link to="/home">Home</Link><br />
    </nav>
  </div>
);

const NotFound = () => <h2>404 Not Found</h2>;

export function App() {
  return (
    <Router>
      <Routes>
        <Route path="/home" element={<Home />} />
        <Route path="*" element={<NotFound />} />
      </Routes>
    </Router>
  );
}

