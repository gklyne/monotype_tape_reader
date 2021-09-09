# makefile

.SUFFIXES: scad stl 3mf gcode

OpenSCAD = /Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD
Slicer = /Applications/Original\ Prusa\ Drivers/PrusaSlicer.app/Contents/MacOS/PrusaSlicer

%.stl : %.scad
	${OpenSCAD} -o $@ $<
	# ${OpenSCAD} -d $@.deps -o $@ $<

%.3mf : %.scad
	${OpenSCAD} -o $@ $<
	# ${OpenSCAD} -d $@.deps -o $@ $<

%.gcode : %.3mf
	${Slicer} -o $@ --gcode $<

clean:
	rm *.gcode
	rm *.3mf
	rm *.deps

all: \
	monotype-tape-reader-winder.3mf \
	monotype-tape-reader-bridge.3mf \
	monotype-tape-reader-camholder.3mf

allgcode: \
	monotype-tape-reader-winder.gcode \
	monotype-tape-reader-bridge.gcode \
	monotype-tape-reader-camholder.gcode

monotype-tape-reader-winder.3mf: \
	/Users/graham/workspace/github/gklyne/monotype_tape_reader/monotype-tape-reader.scad \
	/Users/graham/workspace/github/gklyne/monotype_tape_reader/monotype-tape-reader-defs.scad \
	monotype-tape-reader-winder.scad

monotype-tape-reader-bridge.3mf: \
	/Users/graham/workspace/github/gklyne/monotype_tape_reader/monotype-tape-reader.scad \
	/Users/graham/workspace/github/gklyne/monotype_tape_reader/monotype-tape-reader-defs.scad \
	monotype-tape-reader-bridge.scad

monotype-tape-reader-camholder.3mf: \
	/Users/graham/workspace/github/gklyne/monotype_tape_reader/monotype-tape-reader.scad \
	/Users/graham/workspace/github/gklyne/monotype_tape_reader/monotype-tape-reader-defs.scad \
	monotype-tape-reader-camholder.scad
