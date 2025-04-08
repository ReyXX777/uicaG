FROM python:3.10-slim

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    build-essential \
    gcc \
    binutils \
    graphviz \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
RUN pip install plotly

# Create app directory
WORKDIR /app

# Clone uiCA from your GitHub fork
RUN git clone https://github.com/ReyXX777/uiCA.git

# Set up uiCA safely
WORKDIR /app/uiCA
RUN chmod +x setup.sh && bash -c "./setup.sh || echo 'setup.sh failed in Docker build, continuing...'"
RUN ls -la /app/uiCA/instrData && test -f /app/uiCA/instrData/uArchInfo.py || { echo "instrData or uArchInfo.py not found"; ls -la /app/uiCA; exit 1; }
# Go back to app root and copy backend files
WORKDIR /app
COPY . .

# Create temp directory for multer
RUN mkdir -p /app/temp

# Install Node dependencies
RUN npm install

# Start server
CMD ["node", "server.js"]
