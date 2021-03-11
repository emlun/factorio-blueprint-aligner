VERSION := $(shell sed -n '/"version"/{s/"version"//;s/^[^"]*"//;s/".*//;p}' src/info.json)
NAME := $(shell sed -n '/"name"/{s/"name"//;s/^[^"]*"//;s/".*//;p}' src/info.json)
DIST_DIR := "$(CURDIR)/dist"
DIST_BASENAME := "$(NAME)_$(VERSION)"
DIST_FILE := "$(DIST_DIR)/$(DIST_BASENAME).zip"

default: $(DIST_FILE)

clean:
	rm -r "$(DIST_DIR)"

$(DIST_DIR):
	mkdir -p "$(DIST_DIR)"

$(DIST_FILE): $(DIST_DIR) $(shell find src)
	rsync -avP --delete src/ "dist/$(DIST_BASENAME)/"
	cd dist && zip -r -FS $@ "$(DIST_BASENAME)"
