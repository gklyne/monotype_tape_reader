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
	rm *.stl
	rm *.deps

all: \
	reader-baseplate.3mf \
	reader-winder.3mf \
	reader-bridge.3mf \
	reader-camholder.3mf

allstl: \
	reader-baseplate.stl \
	reader-winder.stl \
	reader-bridge.stl \
	reader-camholder.stl

allgcode: \
	reader-baseplate.gcode \
	reader-winder.gcode \
	reader-bridge.gcode \
	reader-camholder.gcode

#.3mf dependencies

reader-baseplate.3mf: \
	/Users/graham/workspace/github/gklyne/monotype_tape_reader/reader-common.scad \
	/Users/graham/workspace/github/gklyne/monotype_tape_reader/reader-defs.scad \
	reader-baseplate.scad

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


# .stl dependencies

reader-baseplate.stl: \
	/Users/graham/workspace/github/gklyne/monotype_tape_reader/reader-common.scad \
	/Users/graham/workspace/github/gklyne/monotype_tape_reader/reader-defs.scad \
	reader-baseplate.scad

reader-winder.stl: \
	/Users/graham/workspace/github/gklyne/monotype_tape_reader/reader-common.scad \
	/Users/graham/workspace/github/gklyne/monotype_tape_reader/reader-defs.scad \
	reader-winder.scad

reader-bridge.stl: \
	/Users/graham/workspace/github/gklyne/monotype_tape_reader/reader-common.scad \
	/Users/graham/workspace/github/gklyne/monotype_tape_reader/reader-defs.scad \
	reader-bridge.scad

reader-camholder.stl: \
	/Users/graham/workspace/github/gklyne/monotype_tape_reader/reader-common.scad \
	/Users/graham/workspace/github/gklyne/monotype_tape_reader/reader-defs.scad \
	reader-camholder.scad

