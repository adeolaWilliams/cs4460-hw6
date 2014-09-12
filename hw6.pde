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
import java.util.Map;

ControlP5 cp5;
DropdownList dropDown;
Table cData;
ArrayList<State> states = new ArrayList<State>();
ArrayList<Slice> pieSlices;
color[] colors = {#993300, #CC9900, #CC6600, #CC1234, #993999, #883311};
int pieRadius = 100;
int activePie, activeBubble, stateIndex, bubId, brushState;
FloatDict droveAloneDict, carPoolDict, publicTransDict;
FloatDict walkedDict, otherDict, homeDict, stateMap;
float maxCommute;
ArrayList<FloatDict> dictList;
ArrayList<Bubble> curBubbles;

void setup() {
  size(800, 500);
  setupDicts();
  maxCommute = -1;
  cData = loadTable("CommuterData.csv", "header");
  // Remove United States entry
  cData.removeRow(0);
  
  setupStates(cData);
  
  // Create a new State object for each row of dat
 
  cp5 = new ControlP5(this);
  dropDown = cp5.addDropdownList("myList-d1")
            .setPosition((width/6)-50, height-(height/4));
  customizeList(dropDown);
  
  this.stateIndex = 0;
  this.activePie = -1;
  this.activeBubble = -1;
  this.brushState = -1;
}

void setupStates(Table cData) {
  int id = 0;
  stateMap = new FloatDict();
  for (TableRow row : cData.rows()) {
      State curState = new State(row, id);
      states.add(curState);
      stateMap.set(curState.name, id);
      id++;
  }
  
  for (State state : states) {
     droveAloneDict.set(state.name, state.numDroveAlone);
     carPoolDict.set(state.name, state.numCarPooled);
     publicTransDict.set(state.name, state.numPublicTransit);
     walkedDict.set(state.name, state.numWalked);
     otherDict.set(state.name, state.numOther);
     homeDict.set(state.name, state.numWorkedHome);
     float max = max(state.getData());
     if (max > maxCommute) {
        maxCommute = max; 
     }
  }  
}

// Setup the dicts to use for sorting for part 2
void setupDicts() {
  droveAloneDict = new FloatDict();
  carPoolDict = new FloatDict();
  publicTransDict = new FloatDict();
  walkedDict = new FloatDict();
  otherDict = new FloatDict();
  homeDict = new FloatDict();
  dictList = new ArrayList<FloatDict>();
  dictList.add(droveAloneDict);
  dictList.add(carPoolDict);
  dictList.add(publicTransDict);
  dictList.add(walkedDict);
  dictList.add(otherDict);
  dictList.add(homeDict);
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
  bubbleChart();
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
      boolean inBub = false;
      for (Bubble cur : curBubbles) {
         if (cur.contains(mouseX, mouseY)) {
            this.activeBubble = cur.id;
            this.brushState = cur.stateId;
            inBub = true;
         }
      }
      
      if (!inBub) {
         this.activeBubble = -1;
         this.brushState = -1; 
      }
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

void bubbleChart() {
   int baseX = width/2 + 100;
   int baseY = height/6;
   int i = 0;
   this.bubId = 0;
   curBubbles = new ArrayList<Bubble>();
   for (FloatDict list : dictList) {
      drawBubbles(baseX, baseY + (i*70), list); 
      i++;
   }
}

void drawBubbles(int baseX, int baseY, FloatDict dict) {
   dict.sortValuesReverse();
   int counter = 0;
   float max = dict.value(0);
   for (int i = 2; i >= 0; i--) {
      String state = dict.key(i);
      float value = dict.value(i);
      int stateId = (int)stateMap.get(state);
      value = value / max;
      float size = value * 60;
      Bubble curBub = new Bubble(this.bubId, size, baseX + (counter*65), 
                                  baseY, stateId);
                                  
      if (this.activeBubble == bubId) { 
        curBub.active = true;
      }
      
      if (this.brushState == stateId) {
         curBub.brushed = true; 
      }
      
      curBub.draw();
      curBubbles.add(curBub);
      counter++;
      this.bubId++;
   } 
}

/* Classes */
class State {
   int id;
   String name;
   float numWorkers, numDroveAlone, numCarPooled, numPublicTransit;
   float numWalked, numOther, numWorkedHome, travelTime;
   
   // Constructor that takes in a Tablerow
   State(TableRow row, int id) {
      this.name = row.getString(0);
      this.numWorkers = row.getFloat(1);
      this.numDroveAlone = row.getFloat(2);
      this.numCarPooled = row.getFloat(3);
      this.numPublicTransit = row.getFloat(4);
      this.numWalked = row.getFloat(5);
      this.numOther = row.getFloat(6);
      this.numWorkedHome = row.getFloat(7);
      this.travelTime = row.getFloat(8);
      this.id = id;
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

class Bubble {
  int id, stateId;
  boolean active, brushed;
  float size, baseX, baseY;
  
  Bubble(int id, float size, float baseX, float baseY, int stateId) {
    this.id = id;
    this.size = size;
    this.baseX = baseX;
    this.baseY = baseY;
    this.stateId = stateId;
  }
  
  void draw() {
    fill(#FFFFFF);
    if (active || brushed) {
       fill(100);
    }
    ellipse(baseX, baseY, size, size);
    fill(100);
    text((int)this.stateId, baseX, baseY); 
  }
  
  boolean contains(float mx, float my) {
    return ((pow((mx - baseX), 2) + pow((my - baseY), 2)) < pow(size/2, 2));
  }
}

