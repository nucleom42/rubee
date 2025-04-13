import React from "react";
import { BrowserRouter as Router, Routes, Route, Link } from "react-router-dom";
import { User } from "./user";
import { RedirectToBackend } from "./utils/redirectToBackend";

const Home = () => (
  <div>
    <h2>Reactive Bee</h2>
    <p>Welcome to Reactive Bee ...</p>
    <nav>
        <Link to="/home">Home</Link><br />
        <Link to="/users">Users</Link>
    </nav>
  </div>
);

export function App() {
  return (
    <Router>
      <Routes>
        <Route path="/home" element={<Home />} />
        <Route path="/users" element={<User />} />
        <Route path="*" element={<RedirectToBackend url="/api/not_found" />} />
      </Routes>
    </Router>
  );
}

