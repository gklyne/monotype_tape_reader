# makefile

.SUFFIXES: scad stl 3mf

%.stl : %.scad
	# /Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD -o $@ $<
	/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD -d $@.deps -o $@ $<

%.3mf : %.scad
	# /Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD -o $@ $<
	/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD -d $@.deps -o $@ $<

monotype-tape-reader-winder.3mf: \
	/Users/graham/workspace/github/gklyne/monotype_tape_reader/monotype-tape-reader.scad \
	/Users/graham/workspace/github/gklyne/monotype_tape_reader/monotype-tape-reader-defs.scad \
	monotype-tape-reader-winder.scad

monotype-tape-reader-winder.stl: \
	/Users/graham/workspace/github/gklyne/monotype_tape_reader/monotype-tape-reader.scad \
	/Users/graham/workspace/github/gklyne/monotype_tape_reader/monotype-tape-reader-defs.scad \
	monotype-tape-reader-winder.scad
