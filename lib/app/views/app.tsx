import React from "react";
import { BrowserRouter as Router, Routes, Route, Link } from "react-router-dom";
import { User } from "./user";

const Home = () => (
  <div>
    <h2>Home Page</h2>
    <p>Welcome to the React app!</p>
    <nav>
        <Link to="/home">Home</Link><br />
        <Link to="/users">Users</Link>
    </nav>
  </div>
);

const NotFound = () => (
  <div>
    <h2>404 - Not Found</h2>
    <p>The page you are looking for does not exist.</p>
  </div>
);

export function App() {
  return (
    <Router>
      <Routes>
        <Route path="/home" element={<Home />} />
        <Route path="/users" element={<User />} />
        <Route path="*" element={<NotFound />} />
      </Routes>
    </Router>
  );
}

