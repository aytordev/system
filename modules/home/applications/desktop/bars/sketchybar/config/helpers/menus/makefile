# Makefile for menu helpers
# Simplified and consistent with other helper makefiles

CC = clang
CFLAGS = -std=c99 -O3 -Wall -Wextra
FRAMEWORKS = -F/System/Library/PrivateFrameworks/ -framework Carbon -framework SkyLight
BINDIR = bin

TARGET = $(BINDIR)/menus
SOURCE = menus.c

.PHONY: all clean

all: $(TARGET)

$(TARGET): $(SOURCE) | $(BINDIR)
	$(CC) $(CFLAGS) $(FRAMEWORKS) $(SOURCE) -o $@

$(BINDIR):
	mkdir -p $@

clean:
	rm -rf $(BINDIR)