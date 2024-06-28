# stepper-control.py

# To set up environment:
#
# SSH to RPi:
#  ssh graham@192.168.1.23  (p:a...?)
# or:
#  ssh graham@mcreader.local
#

# venv notes (NOT NEEDED)
#
#  $(which python3) -m venv venv
#  . venv/bin/activate
#  pip install --upgrade pip
#  pip install wheel
#  pip install RPi.GPIO
#

import sys
import tty, termios
import time
import select
import RPi.GPIO as GPIO

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

def stepper_pins(motornum):
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
    return steppins

def stepper_init(motornum):
    # Use BCM GPIO references instead of physical pin numbers
    GPIO.setmode(GPIO.BCM)
    steppins  = stepper_pins(motornum)
    for pin in steppins:
        GPIO.setup(pin,GPIO.OUT)
        GPIO.output(pin, False)
    return

def stepper_off():
    return [ 0, 0, 0, 0 ]

def set_stepper_drive(motornum, stepdata):
    steppins  = stepper_pins(motornum)
    for pin in range(len(steppins)):
        iopin = steppins[pin]
        if stepdata[pin] != 0:
            # print( f"Enable GPIO {iopin}" )
            GPIO.output(iopin, True)
            pass
        else:
            # print( f"Disable GPIO {iopin}" )
            GPIO.output(iopin, False)
            pass
    return

def main_loop():
    # The interval between slowing down the stepper motor styeps by 0.1ms is 
    # calculated as follows:
    #
    # Tape spool diameter at start: 44mm, at end: 69mm (measured)
    # Total number of steps to read tape: 238K (measured)
    # Initial speed: 3ms between steps (setting seems to work)
    # End speed: 44/69*3ms = 4.7ms between steps, for constant tape speed
    # Number of 0.1ms increments in wait between at steps start and end: 17
    # Number of steps between increments: 238K/17 = 14K = "slowrate" below

    waittime  = 0.0030      # 3.0ms wait between steps (initial)
    waitstep  = 0.0005      # 0.5ms wait increment     (k/b change)
    slowrate  = 14000       # Interval (steps) between increase of stepper wait by 0.1ms
    slowcount = slowrate    # Steps to next speed reduction

    running   = False       # Start with motor stopped
    stepnum   = 0           # Step sequence number
    stepdir   = 1           # +1 forward, -1 backward (or +2, -2?)
    debugging = False       # Debug display enabled
    steptotal = 0           # Count total number of steps

    print("Control options:")
    print("  r         Run/resume motion")
    print("  s         Stop motion")
    print("  f         Move forwards")
    print("  b         Move backwards")
    print("  > or .    Go faster")
    print("  < or ,    Go slower")
    print("  d         Debug display on")
    print("  x         Debug display off")
    print("  q         Stop movement and exit")

    stepper_init(0)

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
            elif c == "d":
                debugging = True
            elif c == "x":
                debugging = False
            elif c == " ":
                pass
            else:
                print(f"Unrecognized '{c}'\n")
            print(f"steptotal {steptotal:>8d}, waittime {waittime:6.4f}, slowcount {slowcount:>6d}, stepdir {stepdir}, stepnum {stepnum}")
        # Next step
        if running:
            stepnum, stepdata = next_step(stepnum, stepdir)
            # drive stepper motor
            set_stepper_drive(0, stepdata)
            steptotal += 1
            if debugging:
                print(f"steptotal {steptotal:>8d}, waittime {waittime:6.4f}, slowcount {slowcount:>6d}, stepdir {stepdir}, stepnum {stepnum}")
        # Wait before moving on
        # Every "slowrate" steps, increase stepper wait interval by 0.1ms, to compensate for
        # increased diameter of tape on take-up spool.  Without this, the tape speed increases
        # and frames may become merged.
        time.sleep(waittime)
        slowcount -= 1
        if slowcount <= 0:
            waittime += 0.0001                  # Increase wait between steps by 0.1ms
            slowcount = slowrate                # Reset counter to next slowdown point
            print(f"steptotal {steptotal:>8d}, waittime {waittime:6.4f}")

    print("Exiting")
    set_stepper_drive(0, stepper_off())

# Print instruction summary
main_loop()
# Print exit summary
