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

class Tree {
  float x, y;
  float h;
  float steps;
   
  Tree() {
    x = 0;
    y = 0;
    h = 0;
    steps = 0;
  }
   
  Tree(int x_, int y_, int h_, int s_) {
    x = x_;
    y = y_;
    h = map(h_, 0, height, 0, 160);
    steps = s_;
  }
   
  void render() {
    stroke(32);
    branch(x, y, -HALF_PI, h);
  }
   
  void branch(float x_, float y_, float a_, float s_) {
    strokeWeight(s_/16);
    float a = random(-PI/16, PI/16)+a_;
    float nx = cos(a)*s_+x_;
    float ny = sin(a)*s_+y_;
    stroke(32, 16*s_);
    line(x_, y_, nx, ny);
    if (s_>10) {
      branch(nx, ny, a_-random(PI/4), s_*random(0.6, 0.8));
      branch(nx, ny, a_, s_*random(0.6, 0.8));
      branch(nx, ny, a_+random(PI/4), s_*random(0.6, 0.8));
    } else {
      float w = random(155, 255);
      stroke(255, w, w, random(32, 192));
      strokeWeight(random(0, 8));
      point(nx+random(-2, 2), ny+random(-2, 2));
    }
  }
}


LeapMotion leapMotion;
float theta;   
Vector avgPos;

void setup()
{
    size(640, 360);
    background(20);
    frameRate(30);
    leapMotion = new LeapMotion(this);
}

void draw()
{
//  Tree tree = new Tree((int)avgPos.getX(), (int)avgPos.getY(), width, 10);
  if(avgPos.getX() != 0) {
    translate(width/2,height);
    Tree tree = new Tree((int)avgPos.getX(), height, (int)avgPos.getY(), 5);
    tree.render();
    avgPos = Vector.zero();
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
//    System.out.println("Frame id: " + frame.id()
//                 + ", timestamp: " + frame.timestamp()
//                 + ", hands: " + frame.hands().count()
//                 + ", fingers: " + frame.fingers().count()
//                 + ", tools: " + frame.tools().count());
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
//        System.out.println("Hand sphere radius: " + hand.sphereRadius()
//                         + " mm, palm position: " + hand.palmPosition());

        // Get the hand's normal vector and direction
//        Vector normal = hand.palmNormal();
//        Vector direction = hand.direction();

        // Calculate the hand's pitch, roll, and yaw angles
//        System.out.println("Hand pitch: " + Math.toDegrees(direction.pitch()) + " degrees, "
//                         + "roll: " + Math.toDegrees(normal.roll()) + " degrees, "
//                         + "yaw: " + Math.toDegrees(direction.yaw()) + " degrees\n");
    }
}
