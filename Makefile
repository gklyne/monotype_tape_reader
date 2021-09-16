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
	${Slicer} -o $@ --gcode $< \
	    --load Prusa_PLA_0.2_config.ini

clean:
	rm *.gcode
	rm *.3mf
	rm *.deps

all: \
	reader-winder.3mf \
	reader-bridge.3mf \
	reader-camholder.3mf

allgcode: \
	reader-winder.gcode \
	reader-bridge.gcode \
	reader-camholder.gcode

reader-winder.3mf: \
	/Users/graham/workspace/github/gklyne/monotype_tape_reader/reader-common.scad \
	/Users/graham/workspace/github/gklyne/monotype_tape_reader/reader-defs.scad \
	reader-winder.scad

reader-bridge.3mf: \
	/Users/graham/workspace/github/gklyne/monotype_tape_reader/reader-common.scad \
	/Users/graham/workspace/github/gklyne/monotype_tape_reader/reader-defs.scad \
	reader-bridge.scad

reader-camholder.3mf: \
	/Users/graham/workspace/github/gklyne/monotype_tape_reader/reader-common.scad \
	/Users/graham/workspace/github/gklyne/monotype_tape_reader/reader-defs.scad \
	reader-camholder.scad
