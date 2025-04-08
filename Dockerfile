FROM python:3.10-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    build-essential \
    gcc \
    binutils \
    graphviz \
    git \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 18.x
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
RUN pip install --no-cache-dir plotly pydot lxml

# Create app directory
WORKDIR /app

# Clone uiCA from your fork
RUN git clone --recurse-submodules https://github.com/ReyXX777/uiCA.git

# Set up uiCA
WORKDIR /app/uiCA
COPY setup.sh .
RUN chmod +x setup.sh && ./setup.sh

# Verify instrData exists
RUN ls -la /app/uiCA/instrData && test -f /app/uiCA/instrData/uArchInfo.py || { echo "instrData or uArchInfo.py not found"; ls -la /app/uiCA; exit 1; }

# Go back to app root and install Node.js app
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm install
COPY . .

# Create temp directory for multer
RUN mkdir -p /app/temp && chmod 777 /app/temp

EXPOSE 3000
CMD ["node", "server.js"]