# Use an official Ruby runtime as a parent image
FROM ruby:3.4.1

# Set the working directory inside the container
WORKDIR /app

# Install system dependencies required for your app (e.g., build tools for gems like pg, etc.)
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs

# Copy Gemfile and Gemfile.lock, then install dependencies
COPY ../Gemfile Gemfile.lock ./
RUN bundle install

# Copy the rest of the application files into the container
COPY .. .

# Ensure scripts are executable (after the files are copied)
RUN chmod +x ./bin/rubee

# Set the environment variable RACK_ENV to production
ENV RACK_ENV=production

# Initialize the database (make sure this script exists in your project structure)
RUN ./com/db init

RUN ./com/db run:create_users

# Expose the port the app will run on
EXPOSE 8080

# Run the app (ensure this command correctly starts your app)
CMD ./com/rubee start:8080
