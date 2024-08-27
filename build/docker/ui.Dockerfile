FROM node:20-alpine AS builder

WORKDIR /webkins_ui
COPY ./ui /webkins_ui
RUN npm install --ignore-scripts && npm run build

FROM ubuntu:20.04

RUN mkdir -p /webkins_ui/mnt && mkdir -p /webkins_ui/build
WORKDIR /webkins_ui/build
COPY --from=builder /webkins_ui/dist/ /webkins_ui/build

ENTRYPOINT ["cp", "-r", "./", "../mnt/"]
