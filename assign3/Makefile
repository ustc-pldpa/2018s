all: main.byte

BUILD = corebuild
FLAGS = -use-ocamlfind -use-menhir

%.byte: always
	$(BUILD) $(FLAGS) src/$@

clean:
	rm -rf *.byte *.top _build

always:

.PHONY: always
