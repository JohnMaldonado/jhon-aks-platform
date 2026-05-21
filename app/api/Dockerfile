# ─── Stage 1: build ──────────────────────────────────────────────────────────
# Instala dependencias. Este stage NO va a la imagen final.
FROM node:20-alpine AS builder

WORKDIR /app

# Copia solo package.json primero — Docker cachea esta capa si no cambia
# Evita reinstalar node_modules en cada build si solo cambió el código
COPY package.json ./
RUN npm install --only=production

# ─── Stage 2: runtime ────────────────────────────────────────────────────────
# Imagen final — solo lo necesario para correr, sin herramientas de build
FROM node:20-alpine AS runtime

# AP-04: nunca correr como root
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copia node_modules del stage anterior (ya instalados, sin npm)
COPY --from=builder /app/node_modules ./node_modules

# Copia el código fuente
COPY src/ ./src/
COPY package.json ./

# AP-04: cambiar ownership antes de USER
RUN chown -R appuser:appgroup /app

# AP-04: ejecutar como usuario no-root
USER appuser

EXPOSE 3000

# Healthcheck interno del container (diferente a los K8s probes)
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:3000/healthz/live || exit 1

CMD ["node", "src/index.js"]
