#!/usr/bin/python
# Import required libraries
import sys
import time
import RPi.GPIO as GPIO

# PiStep2 pins to use:
#
# Physical pins 11, 12, 13, 15 for Motor A (GPIO 17, 18, 27, 22)
# Physical pins 7, 22, 18. 16 for Motor B (GPIO 4, 25, 24, 23)
# Physical pins 33, 32, 31, 29 for Motor C (GPIO 13,12,6,5)
# Physical Pins 38, 37, 36, 35 for Motor D (GPIO 20,26,16,19)


# Use BCM GPIO references
# instead of physical pin numbers
GPIO.setmode(GPIO.BCM)

# Define GPIO signals to use
# Physical pins 11,12,13,15  -- motor A on Pistep 2 hat
StepPins = [17,18,27,22]

# Set all pins as output
for pin in StepPins:
  print("Setup pins")
  GPIO.setup(pin,GPIO.OUT)
  GPIO.output(pin, False)

# Define advanced sequence
# as shown in manufacturers datasheet
Seq = [[1,0,0,1],
       [1,0,0,0],
       [1,1,0,0],
       [0,1,0,0],
       [0,1,1,0],
       [0,0,1,0],
       [0,0,1,1],
       [0,0,0,1]]

StepCount = len(Seq)
StepDir = 1 # Set to 1 or 2 for clockwise
            # Set to -1 or -2 for anti-clockwise

# Read wait time from command line
if len(sys.argv)>1:
  WaitTime = int(sys.argv[1])/float(1000)
else:
  WaitTime = 10/float(1000)

# Initialise variables
StepCounter = 0
WaitTime    = 0.0025

# Start main loop
while True:

  print( StepCounter, Seq[StepCounter] )

  for pin in range(0, 4):
    xpin = StepPins[pin]#
    if Seq[StepCounter][pin]!=0:
      # print( " Enable GPIO %i" %(xpin) )
      GPIO.output(xpin, True)
    else:
      GPIO.output(xpin, False)

  StepCounter += StepDir

  # If we reach the end of the sequence
  # start again
  if (StepCounter>=StepCount):
    StepCounter = 0
  if (StepCounter<0):
    StepCounter = StepCount+StepDir

  # Wait before moving on
  time.sleep(WaitTime)

