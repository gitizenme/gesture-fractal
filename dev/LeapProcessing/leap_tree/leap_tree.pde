/*

    Leap Motion library for Processing.
    Copyright (c) 2012-2013 held jointly by the individual authors.

    This file is part of Leap Motion library for Processing.

    Leap Motion library for Processing is free software: you can redistribute it and/or
    modify it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Leap Motion library for Processing is distributed in the hope that it will be
    useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Leap Motion library for Processing.  If not, see
    <http://www.gnu.org/licenses/>.

*/
import com.leapmotion.leap.*;
import com.leapmotion.leap.processing.LeapMotion;


LeapMotion leapMotion;
float theta;   
Vector avgPos;

void setup()
{
    size(640, 360);
    background(20);
    leapMotion = new LeapMotion(this);
}

void draw()
{
  background(0);
  frameRate(30);
  stroke(255);
  // Let's pick an angle 0 to 90 degrees based on the mouse position
//  float a = (mouseX / (float) width) * 90f;
  float a = (avgPos.getX() / (float) width) * 90f;
  // Convert it to radians
  theta = radians(a);
  // Start the tree from the bottom of the screen
  translate(width/2,height);
  // Draw a line 120 pixels
  line(0,0,0,-120);
  // Move to the end of that line
  translate(0,-120);
  // Start the recursive branching!
  branch(120);
}

void branch(float h) {
  // Each branch will be 2/3rds the size of the previous one
  h *= 0.66;
  
  // All recursive functions must have an exit condition!!!!
  // Here, ours is when the length of the branch is 2 pixels or less
  if (h > 2) {
    pushMatrix();    // Save the current state of transformation (i.e. where are we now)
    rotate(theta);   // Rotate by theta
    line(0, 0, 0, -h);  // Draw the branch
    translate(0, -h); // Move to the end of the branch
    branch(h);       // Ok, now call myself to draw two new branches!!
    popMatrix();     // Whenever we get back here, we "pop" in order to restore the previous matrix state
    
    // Repeat the same thing, only branch off to the "left" this time!
    pushMatrix();
    rotate(-theta);
    line(0, 0, 0, -h);
    translate(0, -h);
    branch(h);
    popMatrix();
  }
}

void onInit(final Controller controller)
{
    avgPos = Vector.zero();
    println("Initialized");
}

void onConnect(final Controller controller)
{
    println("Connected");
}

void onDisconnect(final Controller controller)
{
    println("Disconnected");
}

void onExit(final Controller controller)
{
    println("Exited");
}

void onFrame(final Controller controller)
{
    println("Frame");
    Frame frame = controller.frame();
    System.out.println("Frame id: " + frame.id()
                 + ", timestamp: " + frame.timestamp()
                 + ", hands: " + frame.hands().count()
                 + ", fingers: " + frame.fingers().count()
                 + ", tools: " + frame.tools().count());
    if (!frame.hands().empty()) {
        // Get the first hand
        Hand hand = frame.hands().get(0);

        // Check if the hand has any fingers
        FingerList fingers = hand.fingers();
        if (!fingers.empty()) {
            // Calculate the hand's average finger tip position
            avgPos = Vector.zero();
            for (Finger finger : fingers) {
                avgPos = avgPos.plus(finger.tipPosition());
            }
            avgPos = avgPos.divide(fingers.count());
            System.out.println("Hand has " + fingers.count()
                             + " fingers, average finger tip position: " + avgPos);
        }

        // Get the hand's sphere radius and palm position
        System.out.println("Hand sphere radius: " + hand.sphereRadius()
                         + " mm, palm position: " + hand.palmPosition());

        // Get the hand's normal vector and direction
        Vector normal = hand.palmNormal();
        Vector direction = hand.direction();

        // Calculate the hand's pitch, roll, and yaw angles
        System.out.println("Hand pitch: " + Math.toDegrees(direction.pitch()) + " degrees, "
                         + "roll: " + Math.toDegrees(normal.roll()) + " degrees, "
                         + "yaw: " + Math.toDegrees(direction.yaw()) + " degrees\n");
    }
}
