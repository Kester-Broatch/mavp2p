define DOCKERFILE_RELEASE
FROM $(BASE_IMAGE)
RUN apk add --no-cache zip make git tar
WORKDIR /s
COPY go.mod go.sum ./
RUN go mod download
COPY . ./
RUN make release-nodocker
endef
export DOCKERFILE_RELEASE

release:
	echo "$$DOCKERFILE_RELEASE" | docker build . -f - -t temp \
	&& docker run --rm -it -v $(PWD):/out \
	temp sh -c "rm -rf /out/release && cp -r /s/release /out/"

release-nodocker:
	$(eval VERSION := $(shell git describe --tags))
	$(eval GOBUILD := go build -ldflags '-X "main.version=$(VERSION)"')
	rm -rf release && mkdir release

	CGO_ENABLED=0 GOOS=windows GOARCH=amd64 $(GOBUILD) -o /tmp/mavp2p.exe
	cd /tmp && zip -q $(PWD)/release/mavp2p_$(VERSION)_windows_amd64.zip mavp2p.exe

	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 $(GOBUILD) -o /tmp/mavp2p
	tar -C /tmp -czf $(PWD)/release/mavp2p_$(VERSION)_linux_amd64.tar.gz --owner=0 --group=0 mavp2p

	CGO_ENABLED=0 GOOS=linux GOARCH=arm GOARM=6 $(GOBUILD) -o /tmp/mavp2p
	tar -C /tmp -czf $(PWD)/release/mavp2p_$(VERSION)_linux_arm6.tar.gz --owner=0 --group=0 mavp2p

	CGO_ENABLED=0 GOOS=linux GOARCH=arm GOARM=7 $(GOBUILD) -o /tmp/mavp2p
	tar -C /tmp -czf $(PWD)/release/mavp2p_$(VERSION)_linux_arm7.tar.gz --owner=0 --group=0 mavp2p

	CGO_ENABLED=0 GOOS=linux GOARCH=arm64 $(GOBUILD) -o /tmp/mavp2p
	tar -C /tmp -czf $(PWD)/release/mavp2p_$(VERSION)_linux_arm64.tar.gz --owner=0 --group=0 mavp2p
