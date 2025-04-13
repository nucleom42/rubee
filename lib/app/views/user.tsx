import React, { useEffect, useState } from "react";

type User = {
  id: number;
  name: string;
  email: string;
};

export function User() {
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    setUsers([{id: 1, name: "User1", email: "9t6yD@example.com"}, {id: 2, name: "User2", email: "9t6yD@example.com"}]);
    setLoading(false);
  }, []);

  if (loading) return <p>Loading users...</p>;
  if (error) return <p>Error: {error}</p>;

  return (
    <div>
      <h2>User List</h2>
      <ul>
        {users.map((user) => (
          <li key={user.id}>
            <strong>{user.name}</strong> – {user.email}
          </li>
        ))}
      </ul>
    </div>
  );
}

