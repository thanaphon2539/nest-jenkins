FROM node:20

# ติดตั้ง pnpm
RUN corepack enable

WORKDIR /usr/src/app

COPY package*.json ./
RUN pnpm install

COPY . .

RUN pnpm build

EXPOSE 3005
CMD ["pnpm", "start:prod"]
