// lib/app/views/App.tsx
import React from "react";
import { BrowserRouter as Router, Routes, Route, Link } from "react-router-dom";
import { User } from "./User";

const Home = () => (
  <div>
    <h2 className="text-xl font-bold">Home Page</h2>
    <p>Welcome to the React app!</p>
  </div>
);

export function App() {
  return (
    <Router>
      <nav className="space-x-4 border-b mb-4 pb-2">
        <Link to="/">Home</Link></br>
        <Link to="/users">Users</Link>
      </nav>

      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/users" element={<User />} />
      </Routes>
    </Router>
  );
}

