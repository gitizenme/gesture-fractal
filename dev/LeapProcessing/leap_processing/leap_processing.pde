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
    else {
      avgPos = Vector.zero();
    }
}
