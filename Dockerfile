FROM python:3.10-slim


# Instala dependencias para Node.js
RUN apt-get update && apt-get install -y curl gnupg \
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Crear el directorio de trabajo para backend y frontend
WORKDIR /app

# Copiar backend e instalar
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY playground.py ./

# Copiar frontend y su package.json e instalar dependencias
COPY agent-ui/package*.json ./agent-ui/
RUN cd agent-ui && npm install

COPY agent-ui ./agent-ui

# Instalar concurrently para correr ambos procesos
RUN npm install -g concurrently

# Exponer puertos frontend y backend
EXPOSE 3000 7777

# CMD para correr backend y frontend juntos con concurrently
CMD ["concurrently", "uvicorn playground:app --host 0.0.0.0 --port 7777", "npm --prefix agent-ui run dev"]
