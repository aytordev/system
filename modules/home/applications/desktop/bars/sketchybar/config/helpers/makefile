# Main makefile for sketchybar helpers
# Preserves existing structure while eliminating duplication

.PHONY: all clean event_providers menus

all: event_providers menus

event_providers:
	@$(MAKE) -C event_providers

menus:
	@$(MAKE) -C menus

clean:
	@$(MAKE) -C event_providers clean
	@$(MAKE) -C menus clean

# Individual targets for development
cpu_load:
	@$(MAKE) -C event_providers cpu_load

network_load:
	@$(MAKE) -C event_providers network_load