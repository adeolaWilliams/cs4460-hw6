/* 
CS 4460 Homework 6 [Alex Roe]
CommuterData.csv is structured like below
State,Total Workers,Drove Alone,Car-pooled,
Used Public Transportation,Walked,Other,Worked at home,
Mean travel time to work (minutes)

United States
Alabama
.
.
Wyoming
*/

/* Main Functions */

import controlP5.*;

ControlP5 cp5;
DropdownList dropDown;
Table cData;
ArrayList<State> states = new ArrayList<State>();
ArrayList<Slice> pieSlices;
color[] colors = {#993300, #CC9900, #CC6600, #CC1234, #993999, #883311};
int pieRadius = 100;
int stateIndex;
int activePie;

void setup() {
  size(1280, 500);
  
  cData = loadTable("CommuterData.csv", "header");
  // Create a new State object for each row of data
  for (TableRow row : cData.rows()) {
      states.add(new State(row));
  }
  cp5 = new ControlP5(this);
  dropDown = cp5.addDropdownList("myList-d1")
            .setPosition((width/4)-50, height-(height/4));
  customizeList(dropDown);
  
  this.stateIndex = 0;
  this.activePie = -1;
}

// Manages the P5 events
void controlEvent(ControlEvent theEvent) {
  if (theEvent.isGroup()) {
    // check if the Event was triggered from a ControlGroup
    this.stateIndex = int (theEvent.getGroup().getValue());
    this.activePie = -1;
  } 
}

void draw() {
  background(190);
  pieChart(states.get(this.stateIndex));
}

void mouseMoved() {
   if (inPieChart(mouseX, mouseY)) {
      for (Slice slice : pieSlices) {
         if (slice.contains(mouseX, mouseY)) {
            this.activePie = slice.id;
         } 
      }
   } else {
      this.activePie = -1;
   }
}

/* Helper Functions */

void customizeList(DropdownList ddl) {
  ddl.setBackgroundColor(color(190));
  ddl.setItemHeight(20);
  ddl.setBarHeight(15);
  ddl.captionLabel().set("dropdown");
  ddl.captionLabel().style().marginTop = 3;
  ddl.captionLabel().style().marginLeft = 3;
  ddl.valueLabel().style().marginTop = 3;
  for (int i = 0; i < states.size(); i++) {
    ddl.addItem(states.get(i).name, i);
  }
  //ddl.scroll(0);
  ddl.setColorBackground(color(60));
  ddl.setColorActive(color(255, 128));
  ddl.setValue(this.stateIndex);
}

// Draws Pie Chart, code taken from processing.org
void pieChart(State state) {
  float[] numbers = state.getData();
  float[] data = state.getPercentages();
  float lastAngle = 0;
  pieSlices = new ArrayList<Slice>();
  for (int i = 0; i < data.length; i++) {
    float angle = data[i] * 360;
    fill(colors[i]);
     Slice curSlice = new Slice(i, lastAngle, 
                                 lastAngle+radians(angle), 
                                  this.pieRadius, numbers[i]);
     if (activePie == i) { curSlice.active = true; }
     curSlice.draw();
     curSlice.drawLabel();
     pieSlices.add(curSlice);
    
    // Increase the Angle for the next pass
    lastAngle += radians(angle);
  }
}

boolean inPieChart(int mx, int my) {
   int pieX = (width/6);
   int pieY = (height/2);
   return ((pow((mx - pieX), 2) + pow((my - pieY), 2)) < pow(this.pieRadius, 2));
}

/* Classes */
class State {
   String name;
   float numWorkers, numDroveAlone, numCarPooled, numPublicTransit;
   float numWalked, numOther, numWorkedHome, travelTime;
   
   // Constructor that takes in a Tablerow
   State(TableRow row) {
      this.name = row.getString(0);
      this.numWorkers = row.getFloat(1);
      this.numDroveAlone = row.getFloat(2);
      this.numCarPooled = row.getFloat(3);
      this.numPublicTransit = row.getFloat(4);
      this.numWalked = row.getFloat(5);
      this.numOther = row.getFloat(6);
      this.numWorkedHome = row.getFloat(7);
      this.travelTime = row.getFloat(8); 
   }
   
   // Returns the data in a float array
   float[] getData() {
      float[] data = {this.numDroveAlone, this.numCarPooled, 
                      this.numPublicTransit, this.numWalked, 
                      this.numOther, this.numWorkedHome};
      return data;
   }
   
   // Returns the data as a percentage in a float array
   float[] getPercentages() {
      float[] data = this.getData();
      float[] percentages = new float[data.length]; 
      for (int i = 0; i < data.length; i++) {
        percentages[i] = data[i] / this.numWorkers;
      }
      return percentages;
   }
}

// Class that represents a slice of a pie chart
class Slice {
   int id;
   float startAngle, endAngle, pieRadius, data;
   boolean active;
   
   Slice(int id, float startAngle, 
         float endAngle, float pieRadius,
         float data) {
      this.id = id;
      this.startAngle = startAngle;
      this.endAngle = endAngle;
      this.pieRadius = pieRadius;
      this.active = false;
      this.data = data;
   }
   
   void draw() {
     if (this.active) {
        fill(#FFFFFF);
        text(int (data), 50, 50);
        fill(100); 
     }
     arc(width/6, height/2, this.pieRadius * 2, this.pieRadius * 2,
        startAngle, endAngle);
   }
   
   void drawLabel() {
      float middle = (startAngle + endAngle) / 2;
      float labelX = cos(middle) * this.pieRadius + width/6;
      float labelY = sin(middle) * this.pieRadius + height/2;
      fill(#FFFFFF);
      text("placeholder", labelX, labelY);
   }
   
   boolean contains(float mx, float my) {
      int pieX = (width/6);
      int pieY = (height/2);
      float angle = -1*(atan2(my - pieY, pieX - mx) - PI);
      if (angle >= this.startAngle) {
         if (angle <= this.endAngle) {
            return true;
         } 
      }
      return false;
   }
}

