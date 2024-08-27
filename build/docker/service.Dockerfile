ARG GO_VERSION=1.22
FROM golang:${GO_VERSION} AS builder
ENV GOPRIVATE=github.com/agilitree
ENV CGO_ENABLED=0
ARG TOKEN=""

WORKDIR /webkins
COPY .git/ ./.git/
COPY go.mod .
COPY go.sum .
COPY service/ ./service/
COPY ui/ ./ui/
COPY build/scripts ./build/scripts
RUN mkdir -p -m 0700 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts

RUN --mount=type=ssh mkdir -p -m 0700 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts

RUN --mount=type=ssh if [ -n "$TOKEN" ]; then \
      git config --global url."https://$TOKEN@github.com/".insteadOf "https://github.com/" ; \
      else git config --global url."ssh://git@github.com/".insteadOf "https://github.com/"; echo "SSH";\
    fi

RUN --mount=type=ssh go mod download && \
    go mod verify && \
    ./build/scripts/build.sh service && \
    echo "webkins:*:65534:65534:webkins:/_nonexistent:/bin/false" >> /etc/passwd

FROM node:20-alpine AS uibuilder

WORKDIR /webkins_ui
COPY ui/ /webkins_ui
RUN npm install --ignore-scripts && npm run build

FROM scratch

COPY --from=builder /etc/passwd /etc/passwd
WORKDIR /webkins
USER webkins
COPY --from=builder /webkins/bin/linux/amd64/service /webkins/service
COPY --from=uibuilder /webkins_ui/dist /webkins/html/

ENTRYPOINT ["/webkins/server"]
