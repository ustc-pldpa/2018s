TARGETS := $(wildcard *.lua)
TARGETS := $(filter-out roguelike.lua, $(TARGETS))

CFLAGS=$(shell pkg-config --cflags lua5.3)
LFLAGS=$(shell pkg-config --libs lua5.3)

.PHONY: default clean
default: native_point.so

solution.bin: $(TARGETS)
	luac -o $@ roguelike.lua $^  # roguelike has to go first so global requires come first

%.so: %.c
	gcc $< -shared -fPIC -o $@ $(CFLAGS) $(LFLAGS)

clean:
	rm -f *.so *.bin
