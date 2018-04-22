all: datalog.native sat.native

%.native: %.ml
	corebuild $@

clean:
	rm -rf *.native _build
