FROM python:3.10-slim

# Install dependencies
RUN apt-get update && apt-get install -y curl build-essential gcc as graphviz git

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs

# Install Python dependencies
RUN pip install plotly

# Create app directory
WORKDIR /app

# Clone uiCA from your GitHub fork
RUN git clone https://github.com/ReyXX777/uiCA.git

# Set up uiCA
WORKDIR /app/uiCA
RUN chmod +x setup.sh && ./setup.sh

# Go back to app root and copy backend files
WORKDIR /app
COPY . .

# Install Node dependencies
RUN npm install

# Start server
CMD ["node", "server.js"]
