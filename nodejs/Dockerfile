# Stage 1: Build
FROM node:16-alpine AS builder

WORKDIR /usr/src/app

# Chỉ copy package.json trước (nếu không có package-lock.json)
COPY package.json ./

# Install dependencies
RUN npm install --production

# Copy source code
COPY index.js ./

# Stage 2: Runtime
FROM node:16-alpine

WORKDIR /usr/src/app

# Copy từ builder stage
COPY --from=builder /usr/src/app/node_modules ./node_modules
COPY --from=builder /usr/src/app/index.js ./

# Giảm quyền
USER node

EXPOSE 3000
CMD ["node", "index.js"]