import React, { useEffect, useState } from "react";

interface User {
  id: number;
  email: string;
  password: string;
}

export function User() {
  const [users, setUsers] = useState([]);

  useEffect(() => {
    fetch("api/users")
      .then((response) => response.json())
      .then((data) => setUsers(data));
  }, []);

  return (
    <>
      <h2>Users</h2>
      <ul>
        {users.map((user) => (
          <li key={user.id}>{user.id} {user.email}</li>
        ))}
      </ul>
    </>
  );
}
