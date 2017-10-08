import java.awt.AWTException;
import java.awt.Rectangle;
import java.awt.Point;
import java.awt.Robot;
import java.awt.event.InputEvent;
import java.util.ArrayList;
import java.util.Collections;
import processing.core.PApplet;
import processing.sound.*;

//when in doubt, consult the Processsing reference: https://processing.org/reference/

int margin = 200; //set the margins around the squares
final int padding = 50; // padding between buttons and also their width/height
final int buttonSize = 40; // padding between buttons and also their width/height
ArrayList<Integer> trials = new ArrayList<Integer>(); //contains the order of buttons that activate in the test
int trialNum = 0; //the current trial number (indexes into trials array above)
int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
int hits = 0; //number of successful clicks
int misses = 0; //number of missed clicks
Robot robot; //initalized in setup 
SoundFile hit; //correct click sound effect
SoundFile miss; //incorrect click sound effect

int numRepeats = 1; //sets the number of times each button repeats in the test

void setup()
{
  size(700, 700); // set the size of the window
  textFont(createFont("Arial", 16)); //sets the font to Arial size 16
  textAlign(CENTER);
  frameRate(60);
  ellipseMode(CENTER); //ellipses are drawn from the center (BUT RECTANGLES ARE NOT!)
  hit = new SoundFile(this, "hit2.mp3");
  miss = new SoundFile(this, "miss.wav");

  //===DON'T MODIFY MY RANDOM ORDERING CODE==
  for (int i = 0; i < 16; i++) //generate list of targets and randomize the order
      // number of buttons in 4x4 grid
    for (int k = 0; k < numRepeats; k++)
      // number of times each button repeats
      trials.add(i);

  Collections.shuffle(trials); // randomize the order of the buttons
  System.out.println("trial order: " + trials);
}


void draw()
{
  background(0); //set background to black

  if (trialNum >= trials.size()) //check to see if test is over
  {
    float timeTaken = (finishTime-startTime) / 1000f;
    float penalty = constrain(((95f-((float)hits*100f/(float)(hits+misses)))*.2f),0,100);
    fill(255); //set fill color to white
    //write to screen (not console)
    text("Finished!", width / 2, height / 2); 
    text("Hits: " + hits, width / 2, height / 2 + 20);
    text("Misses: " + misses, width / 2, height / 2 + 40);
    text("Accuracy: " + (float)hits*100f/(float)(hits+misses) +"%", width / 2, height / 2 + 60);
    text("Total time taken: " + timeTaken + " sec", width / 2, height / 2 + 80);
    text("Average time for each button: " + nf((timeTaken)/(float)(hits+misses),0,3) + " sec", width / 2, height / 2 + 100);
    text("Average time for each button + penalty: " + nf(((timeTaken)/(float)(hits+misses) + penalty),0,3) + " sec", width / 2, height / 2 + 140);
    return; //return, nothing else to do now test is over
  }

  fill(255); //set fill color to white
  text((trialNum + 1) + " of " + trials.size(), 40, 20); //display what trial the user is on

  for (int i = 0; i < 16; i++)// for all button
    drawButton(i); //draw button
  drawLine();
}

//probably shouldn't have to edit this method
Rectangle getButtonLocation(int i) //for a given button ID, what is its location and size
{
   int x = (i % 4) * (padding + buttonSize) + margin;
   int y = (i / 4) * (padding + buttonSize) + margin;
   return new Rectangle(x, y, buttonSize, buttonSize);
}

Rectangle getMarginButtonLocation(int i) //for a given button ID, create a bounding box for the box
{
   int x = (i % 4) * (padding + buttonSize) + margin - (padding/2);
   int y = (i / 4) * (padding + buttonSize) + margin - (padding/2);   
   return new Rectangle(x, y, buttonSize+padding, buttonSize+padding);
}

Point getBoxCenter(int i) //returns the rough center point (x, y) of a box
{
  Rectangle bounds = getButtonLocation(i);
  int xcenter = bounds.x + (bounds.width/2);
  int ycenter = bounds.y + (bounds.width/2);
  return new Point(xcenter, ycenter);
}

int getClosestBox() //returns closest box to current mouseX, mouseY
{
  int backup = 0;
  
  //a slow way to check but I don't know how to do row/col math
  for (int i = 0; i < 16; i++) // for all button
  {
    Rectangle bounds = getMarginButtonLocation(i);
    if ((mouseX > bounds.x && mouseX < bounds.x + bounds.width) &&
        (mouseY > bounds.y && mouseY < bounds.y + bounds.height))
      return i; //return the closest box's ID
  }
  return backup;
}

//you can edit this method to change how buttons appear
void drawButton(int i)
{
  Rectangle bounds = getButtonLocation(i);
  Rectangle marginBounds = getMarginButtonLocation(i);
  
  if (trials.get(trialNum) == i) // see if current button is the target
  { 
    fill(0, 255, 255); // if so, fill cyan
  }
  else
    fill(200); // if not, fill gray 200

  //outline the box mouse is "on"
  if ((mouseX > marginBounds.x && mouseX < marginBounds.x + marginBounds.width) &&
      (mouseY > marginBounds.y && mouseY < marginBounds.y + marginBounds.height)) // check to see if mouse is "on" box
  {
    strokeWeight(15);
    if (trials.get(trialNum) == i) { //outline in green if correct
      stroke(124, 200, 0);
    }
    else  //outline in orange if incorrect
    {
      stroke(255, 150, 0); 
    }
    rect(bounds.x, bounds.y, bounds.width, bounds.height); //draw button;
  }
  else { //draw other buttons
    noStroke();
    rect(bounds.x, bounds.y, bounds.width, bounds.height);
  }
}

void drawLine() { //draws a guideline to the button to click
  int destination = trials.get(trialNum);
  Point destinationCenter = getBoxCenter(destination);
  stroke(124, 200, 0);
  strokeWeight(2);
  line(mouseX, mouseY, destinationCenter.x, destinationCenter.y);
  
  //draw guideline to next button as well
  if (trialNum < trials.size()-1) {
  int next = trials.get(trialNum+1);
  Point nextCenter = getBoxCenter(next);
  stroke(255);
  strokeWeight(2);
  line(destinationCenter.x, destinationCenter.y, nextCenter.x, nextCenter.y);
  }
}

void mousePressed() // test to see if hit was in target!
{
  if (trialNum >= trials.size()) //if task is over, just return
    return;

  if (trialNum == 0) //check if first click, if so, start timer
    startTime = millis();

  if (trialNum == trials.size() - 1) //check if final click
  {
    finishTime = millis();
    //write to terminal some output. Useful for debugging too.
    println("we're done!");
  }
  
  //snap to closest button
  int closest = getClosestBox();
  Point center = getBoxCenter(closest);
  mouseX = center.x;
  mouseY = center.y;
  
  Rectangle bounds = getButtonLocation(trials.get(trialNum));

 //check to see if mouse cursor is inside button 
  if ((mouseX > bounds.x && mouseX < bounds.x + bounds.width) && (mouseY > bounds.y && mouseY < bounds.y + bounds.height)) // test to see if hit was within bounds
  {
    //System.out.println("HIT! " + trialNum + " " + (millis() - startTime)); // success
    hits++; 
    hit.play();
  } 
  else
  {
    //System.out.println("MISSED! " + trialNum + " " + (millis() - startTime)); // fail
    misses++;
    miss.play();
  }

  trialNum++; //Increment trial number
}  

void keyPressed() 
{
  mousePressed();
}