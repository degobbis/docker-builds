ARG VERSION
ARG TAG="$VERSION-alpine"

FROM golang:$TAG AS mhsbuild

ARG TARGETARCH

RUN GOOS=linux GOARCH=$TARGETARCH go install -v github.com/mailhog/mhsendmail@latest

FROM scratch

ARG TARGETARCH

COPY --from=mhsbuild /go/bin/mhsendmail ./mhsendmail
