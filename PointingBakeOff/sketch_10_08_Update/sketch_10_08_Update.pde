import java.awt.AWTException;
import java.awt.Rectangle;
import java.awt.Point;
import java.awt.Robot;
import java.awt.event.InputEvent;
import java.util.ArrayList;
import java.util.Collections;
import processing.core.PApplet;

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

int resetX = 310;
int resetY = 310;

int numRepeats = 1; //sets the number of times each button repeats in the test

void setup()
{
  size(700, 700); // set the size of the window
  //fullScreen();
  //noCursor(); //hides the system cursor if you want
  //noStroke(); //turn off all strokes, we're just using fills here (can change this if you want)
  textFont(createFont("Arial", 16)); //sets the font to Arial size 16
  textAlign(CENTER);
  frameRate(60);
  ellipseMode(CENTER); //ellipses are drawn from the center (BUT RECTANGLES ARE NOT!)
  //rectMode(CENTER); //enabling will break the scaffold code, but you might find it easier to work with centered rects

  try {
    robot = new Robot(); //create a "Java Robot" class that can move the system cursor
  } 
  catch (AWTException e) {
    e.printStackTrace();
  }

  //===DON'T MODIFY MY RANDOM ORDERING CODE==
  for (int i = 0; i < 16; i++) //generate list of targets and randomize the order
      // number of buttons in 4x4 grid
    for (int k = 0; k < numRepeats; k++)
      // number of times each button repeats
      trials.add(i);

  Collections.shuffle(trials); // randomize the order of the buttons
  System.out.println("trial order: " + trials);
  
  frame.setLocation(0,0); // put window in top left corner of screen (doesn't always work)
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
    
  //fill(255, 0, 0, 200); // set fill color to translucent red
  //ellipse(mouseX, mouseY, 50, 50); //draw user cursor as a circle with a diameter of 20
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
  
  //this is a really slow placeholder check until I figure out how to math
  for (int i = 0; i < 16; i++) // for all button
  {
    Rectangle bounds = getMarginButtonLocation(i);
    if ((mouseX > bounds.x && mouseX < bounds.x + bounds.width) &&
        (mouseY > bounds.y && mouseY < bounds.y + bounds.height))
      return i; //return the closest box's ID
  }
  return backup;
  /*
  int row = (int)((float)mouseY / height) * 4;
  int col = (int)((float)mouseX / width) * 4;
  */
}

//you can edit this method to change how buttons appear
void drawButton(int i)
{
  Rectangle bounds = getButtonLocation(i);
  Rectangle marginBounds = getMarginButtonLocation(i);
  
  if (trials.get(trialNum) == i) // see if current button is the target
  { 
    fill(0, 255, 255); // if so, fill cyan
    stroke(124, 252, 0);
  }
  else
    fill(200); // if not, fill gray 200

  // enlarge and outline the box mouse is "on"
  if ((mouseX > marginBounds.x && mouseX < marginBounds.x + marginBounds.width) &&
      (mouseY > marginBounds.y && mouseY < marginBounds.y + marginBounds.height)) // check to see if mouse is "on" box
  {
    if (trials.get(trialNum) == i) { //outline in green if correct
      stroke(124, 152, 0);
    }
    else  //outline in orange if incorrect
      stroke(255, 150, 0); 
    strokeWeight(14);
    rect(marginBounds.x, marginBounds.y, marginBounds.width, marginBounds.height);
  }
  else { //draw other buttons
    noStroke();
    rect(bounds.x, bounds.y, bounds.width, bounds.height);
  }
  
  drawLine();
}

void drawLine() { //draws a guideline to the button to click
  int destination = trials.get(trialNum);
  Point destinationCenter = getBoxCenter(destination);
  stroke(0, 255, 255);
  strokeWeight(10);
  line(mouseX, mouseY, destinationCenter.x, destinationCenter.y);
}

void mousePressed() // test to see if hit was in target!
{
  //System.out.println("X: " + mouseX);
  //System.out.println("Y: " + mouseY);
  
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
  } 
  else
  {
    //System.out.println("MISSED! " + trialNum + " " + (millis() - startTime)); // fail
    misses++;
  }

  trialNum++; //Increment trial number

  //reset mouse to top left center square
  //mouseX = resetX;
  //mouseY = resetY;
  
  //in this example code, we move the mouse back to the middle
  //robot.mouseMove(resetX, resetY);
}  

void mouseMoved()
{
   //can do stuff everytime the mouse is moved (i.e., not clicked)
   //https://processing.org/reference/mouseMoved_.html
}

void mouseDragged()
{
  //can do stuff everytime the mouse is dragged
  //https://processing.org/reference/mouseDragged_.html
}

void keyPressed() 
{
  //can use the keyboard if you wish
  //https://processing.org/reference/keyTyped_.html
  //https://processing.org/reference/keyCode.html
  
  //robot.mouseMove(center.x, center.y);
  mousePressed();
  //robot.mouseRelease(InputEvent.BUTTON1_MASK);
}