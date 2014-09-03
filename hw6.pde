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

Table cData;
PShape usa;
PShape[] states;
int numStates;
ArrayList<PShape> statesList = new ArrayList<PShape>();

void setup() {
  cData = loadTable("CommuterData.csv", "header");
  println(cData.getRowCount() + " total rows");
  
  // Create a new State object for each row of data
  for (TableRow row : cData.rows()) {
      State state = new State(row.getString(0));
      state.numWorkers = row.getFloat(1);
      state.numDroveAlone = row.getFloat(2);
      state.numCarPooled = row.getFloat(3);
      state.numPublicTransit = row.getFloat(4);
      state.numWalked = row.getFloat(5);
      state.numOther = row.getFloat(6);
      state.numWorkedHome = row.getFloat(7);
      state.travelTime = row.getFloat(8);
  }
  
  
  size(1000, 500);  
  usa = loadShape("wikipedia-usa.svg");
  states = usa.getChildren();
  numStates = usa.getChildCount();
  for (int i = 0; i < numStates; i++) {
     PShape p = usa.getChild(i);
     if (p.getName().length() < 3) {
        statesList.add(p);
     } 
  }
  
  for (PShape p : statesList) {
     p.scale(.75); 
  }
  
}

void draw() {
  background(255);
  // Draw the full map
  usa.disableStyle();
  for (PShape p : statesList) {
     shape(p, 0, 0);
  }
}

class State {
   String name;
   float numWorkers, numDroveAlone, numCarPooled, numPublicTransit;
   float numWalked, numOther, numWorkedHome, travelTime;
   
   State(String name) {
      this.name = name; 
   }
   
   String toString() {
      return "State: " + this.name
             + " numWorkers: " + numWorkers; 
   }
}
