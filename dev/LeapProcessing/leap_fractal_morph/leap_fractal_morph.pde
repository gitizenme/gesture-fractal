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

/*
"fractal cell" by bitcraft, licensed under Creative Commons Attribution-Share Alike 3.0 and GNU GPL license.
Work: http://openprocessing.org/visuals/?visualID= 8221  
License: 
http://creativecommons.org/licenses/by-sa/3.0/
http://creativecommons.org/licenses/GPL/2.0/
*/

import com.leapmotion.leap.*;
import com.leapmotion.leap.processing.LeapMotion;

// constants
final int nmax = 2, hues = 12, r=4, w = 400;

// parameters
boolean mixmode = true;
boolean darkmode;
int colormode;
float cmix;


LeapMotion leapMotion;
Vector avgPos;

void keyPressed() {
  switch(key) {
    case 'c' : colormode++ ; break;
    case 'd' : darkmode = !darkmode; break;
    case 'm' : mixmode = !mixmode; break;
  }
}

color get(float px, float py, color bg) {
  int x = floor(px), y = floor(py);
  if(mag(x-w/2, y-w/2) >= w/2-1) return bg;
  //if (x < 0 || y < 0 || x >= w - 1 || y >= w - 1) return bg;
  float dx = px - x;
  float dy = py - y; 
  int p0 = x + y * width;
  int p1 = p0 + width;
  return lerpColor(
    lerpColor(pixels[p0], pixels[p0+1], dx), 
    lerpColor(pixels[p1], pixels[p1+1], dx),
    dy);
} 


void setup()
{
  size(w, w);
  colorMode(HSB, hues, 1, nmax); 
  leapMotion = new LeapMotion(this);
}

void draw()
{
  // get colors
  color bg = darkmode ? #000000 : #ffffff;
  color fg = darkmode ? #ffffff : #000000;
  float cmix = mixmode ? 3/4f : 1f;
  int hue = colormode % hues;
  
  // map mouse coordinates to complex space
//  float mx = map(mouseX, 0, w, -r, r);
//  float my = map(mouseY, 0, w, -r, r);
  float mx = map(avgPos.getX(), 0, w, -r, r);
  float my = map(avgPos.getY(), 0, w, -r, r);
  
  // transform radius
  float r2 = r * (6 + 3 * sin(frameCount*.05));
  
  // prepare the pixel array
  loadPixels();
  int[] p= new int[w*w];

  // iterate over the pixel array
  for(int x=0; x<width; x++)
    for(int y=0; y<width; y++) {
      
      // map screen space to complex space
      float re = map(x, 0, w, -r, r);
      float im = map(y, 0, w, -r, r);
      
      // get julia set color
      int n=0;
      float rere=re*re;
      float imim=im*im;
      for(;n<nmax;n++) {
        re = re * (rere-3*imim) + mx;
        im = im * (3*rere-imim) + my;
        rere = re*re;
        imim = im*im;
        if(rere+imim > 16) break;
      }

      // map complex space back to screen space
      float x1 = map(re, -r2, r2, 0, w);
      float y1 = map(im, -r2, r2, 0, w);
      
      // calculate new color from julia set color + feedback
      color cnew = color(hue, 1, n);
      color cfeedback = get(x1, y1, bg);
      p[x + y*w] = lerpColor(lerpColor(cnew, cfeedback, cmix), fg, .1);
    }
  
  // show the image
  arrayCopy(p, pixels);
  updatePixels();
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
