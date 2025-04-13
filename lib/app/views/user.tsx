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
    fetch("/users")
      .then((res) => {
        if (!res.ok) throw new Error("Failed to fetch users");
        return res.json();
      })
      .then((data: User[]) => {
        setUsers(data);
        setLoading(false);
      })
      .catch((err) => {
        setError(err.message);
        setLoading(false);
      });
  }, []);

  if (loading) return <p>Loading users...</p>;
  if (error) return <p>Error: {error}</p>;

  return (
    <div>
      <h2 className="text-xl font-bold mb-2">User List</h2>
      <ul className="space-y-1">
        {users.map((user) => (
          <li key={user.id} className="border-b py-1">
            <strong>{user.name}</strong> – {user.email}
          </li>
        ))}
      </ul>
    </div>
  );
}

