# stepper-control.py

import sys
import tty, termios
import time
import select
# import RPi.GPIO as GPIO

def get_stdin_char():
    # See: 
    # 	https://stackoverflow.com/questions/37726138/disable-buffering-of-sys-stdin-in-python-3
    # 	https://docs.python.org/3/library/tty.html#module-tty
    #
    buf   = ""
    stdin = sys.stdin.fileno()
    tattr = termios.tcgetattr(stdin)
    try:
        tty.setcbreak(stdin, termios.TCSANOW)
        # Is stdin ready to read?
        si, _, _ = select.select([sys.stdin], [], [], 0)
        if si:
            buf += sys.stdin.read(1)
    finally:
        termios.tcsetattr(stdin, termios.TCSANOW, tattr)
    return buf if len(buf) > 0 else None

def next_step(stepseqnum, stepdir):
    stepseq     = [ [1,0,0,1],
                    [1,0,0,0],
                    [1,1,0,0],
                    [0,1,0,0],
                    [0,1,1,0],
                    [0,0,1,0],
                    [0,0,1,1],
                    [0,0,0,1] ]
    steplen     = len(stepseq)

    stepseqnum += stepdir
    if stepseqnum >= steplen:
        stepseqnum = 0
    if stepseqnum < 0:
        stepseqnum = steplen+stepdir
    return (stepseqnum, stepseq[stepseqnum])

def stepper_off():
    return [ 0, 0, 0, 0 ]

def set_stepper_drive(motornum, stepdata):
    #
    # motornum is stepper motor number 0-3 (assumes pistep2 interface)
    # See: https://thepihut.com/products/pistep2-quad-stepper-motor-controller-for-raspberry-pi
    #
    # Physical pins 11, 12, 13, 15 for Motor A (GPIO 17, 18, 27, 22)
    # Physical pins 7, 22, 18. 16 for Motor B (GPIO 4, 25, 24, 23)
    # Physical pins 33, 32, 31, 29 for Motor C (GPIO 13,12,6,5)
    # Physical Pins 38, 37, 36, 35 for Motor D (GPIO 20,26,16,19)
    #
    motorpins = [ [17, 18, 27, 22],
                  [ 4, 25, 24, 23],
                  [13, 12,  6,  5],
                  [20, 26, 16, 19],
                ]
    steppins  = motorpins[motornum]
    for pin in range(len(steppins)):
        iopin = steppins[pin]
        if stepdata[pin] != 0:
            # print( f"Enable GPIO {iopin}" )
            #@@GPIO.output(iopin, True)
            pass
        else:
            # print( f"Disable GPIO {iopin}" )
            #@@GPIO.output(iopin, False)
            pass
    return

def main_loop():
    waittime  = 0.0025  # 2.5ms wait between steps
    waitstep  = 0.0005  # 0.5ms wait increment
    waittime  = 1       # @@for offline testing@@
    waitstep  = 0.1     # @@for offline testing@@
    running   = False   # Start with motor stopped
    stepnum   = 0       # Step sequence number
    stepdir   = 1       # +1 forward, -1 backward (or +2, -2?)

    print("Control options:")
    print("  r         Run/resume motion")
    print("  s         Stop motion")
    print("  f         Move forwards")
    print("  b         Move backwards")
    print("  > or .    Go faster")
    print("  < or ,    Go slower")
    print("  q         Stop movement and exit")

    while True:
        # Test for keypress
        c = get_stdin_char()
        if c:
            print(f"Entered '{c}'")
            if c == "q":
                break
            elif c in ">.":
                waittime -= waitstep    # Faster: reduce waittime
                if waittime < waitstep:
                    waittime = waitstep
            elif c in "<,":
                waittime += waitstep    # Slower: increase waittime
            elif c == "s":
                running = False         # Pause
            elif c == "r":
                running = True          # Resume
            elif c == "f":
                stepdir = +1            # Direction forwards
            elif c == "b":
                stepdir = -1            # Direction backwards
            else:
                print(f"Unrecognized '{c}'\n")
        # Next step
        if running:
            stepnum, stepdata = next_step(stepnum, stepdir)
            print(f"stepnum {stepnum}, stepdata {stepdata}, stepdir {stepdir}, waittime {waittime:6.4f}")
            # drive stepper motor
            set_stepper_drive(0, stepdata)
        # Wait before moving on
        time.sleep(waittime)

    print("Exiting")
    set_stepper_drive(0, stepper_off())

# Print instruction summary
main_loop()
# Print exit summary
