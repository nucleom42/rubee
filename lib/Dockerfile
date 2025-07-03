# Use an official Ruby runtime as a parent image
FROM docker.io/library/ruby:3.4.1

# Set the working directory inside the container
WORKDIR /app

# Install system dependencies + Node 20 via n
RUN apt-get update -qq && apt-get install -y \
  curl \
  build-essential \
  libpq-dev \
  python3 \
  make \
  g++ \
  && curl -fsSL https://raw.githubusercontent.com/tj/n/master/bin/n | bash -s 20 \
  && npm install -g npm


# Copy the rest of the application files into the container
COPY . .

# Remove Gemfile.lock to make sure it's re-downloaded and install dependencies
RUN rm -f Gemfile.lock \
 && bundle lock --add-platform ruby \
 && bundle install --redownload


# Set the environment variable RACK_ENV to production
ENV RACK_ENV=production

# init react app
RUN rubee react prepare

# Initialize the database
RUN rubee db init
RUN rubee db run:all

# Expose the port the app will run on
EXPOSE 7000

# Run the app (ensure this command correctly starts your app)
CMD rubee start
