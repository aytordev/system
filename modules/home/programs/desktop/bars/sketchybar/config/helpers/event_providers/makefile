# Common makefile for event providers
# Eliminates duplication between cpu_load and network_load makefiles

# Common compiler settings
CC = clang
CFLAGS = -std=c99 -O3 -Wall -Wextra
BINDIR = bin

# Shared header
SHARED_HEADER = sketchybar.h

# Targets
CPU_LOAD_TARGET = cpu_load/$(BINDIR)/cpu_load
NETWORK_LOAD_TARGET = network_load/$(BINDIR)/network_load

.PHONY: all clean cpu_load network_load

all: $(CPU_LOAD_TARGET) $(NETWORK_LOAD_TARGET)

# CPU load event provider
$(CPU_LOAD_TARGET): cpu_load/cpu_load.c cpu_load/cpu.h $(SHARED_HEADER) | cpu_load/$(BINDIR)
	$(CC) $(CFLAGS) cpu_load/cpu_load.c -o $@

# Network load event provider
$(NETWORK_LOAD_TARGET): network_load/network_load.c network_load/network.h $(SHARED_HEADER) | network_load/$(BINDIR)
	$(CC) $(CFLAGS) network_load/network_load.c -o $@

# Create bin directories
cpu_load/$(BINDIR):
	mkdir -p $@

network_load/$(BINDIR):
	mkdir -p $@

# Individual targets
cpu_load: $(CPU_LOAD_TARGET)

network_load: $(NETWORK_LOAD_TARGET)

# Clean targets
clean:
	rm -rf cpu_load/$(BINDIR)
	rm -rf network_load/$(BINDIR)