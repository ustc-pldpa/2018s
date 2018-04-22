BUILD = corebuild
FLAGS = -use-ocamlfind -use-menhir

all: list_example.native

%.native: always
	$(BUILD) $(FLAGS) $@

clean:
	rm -rf *.native *.top _build

always:

.PHONY: always
