FROM node:20

# เปิดใช้งาน pnpm ผ่าน corepack
RUN corepack enable

WORKDIR /usr/src/app

COPY package*.json ./
RUN pnpm install

COPY . .

RUN pnpm build

EXPOSE 3000
CMD ["pnpm", "start:prod"]
