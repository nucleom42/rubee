module TestSeed
  def self.load
    puts "Loading test seed data..."
    
    # Create users
    user1 = User.create(email: 'user1@test.com', password: 'password1')
    user2 = User.create(email: 'user2@test.com', password: 'password2')
    
    # Create comments
    comment1 = Comment.create(text: 'First comment', user_id: user1.id)
    comment2 = Comment.create(text: 'Second comment', user_id: user2.id)
    
    # Create accounts
    Account.create(addres: '13th Ave, NY', user_id: user1.id)
    Account.create(addres: '14th Ave, NY', user_id: user2.id)
    
    # Create addresses
    Address.create(street: '13th Ave', city: 'NY', state: 'NY', zip: '55555', apt: 'Apt 1', user_id: user1.id)
    
    # Create clients
    Client.create(name: 'Test Client 1', digest_password: 'hashed_password_1')
    Client.create(name: 'Test Client 2', digest_password: 'hashed_password_2')
    
    # Create posts
    Post.create(user_id: user1.id, comment_id: comment1.id)
    Post.create(user_id: user2.id, comment_id: comment2.id)
    
    puts "Test seed data loaded successfully."
  rescue => e
    puts "Error loading test seed data: #{e.message}"
    puts e.backtrace
  end
end
