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
Table cData;
ArrayList<State> states = new ArrayList<State>();
color[] colors = {#993300, #CC9900, #CC6600, #CC1234, #993999, #883311};

void setup() {
  cData = loadTable("CommuterData.csv", "header");
  
  // Create a new State object for each row of data
  for (TableRow row : cData.rows()) {
      states.add(new State(row));
  }
  
  size(640, 360);
  noLoop();
}

void draw() {
  pieChart(states.get(8));
}

/* Helper Functions */

// Draws Pie Chart, code taken from processing.org
void pieChart(State state) {
  float[] data = state.getPercentages();
  float lastAngle = 0;
  for (int i = 0; i < data.length; i++) {
    float angle = data[i] * 360;
    fill(colors[i]);
    arc(width/2, height/2, 300, 300, lastAngle, lastAngle+radians(angle));
    lastAngle += radians(angle);
  }
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
   float [] getPercentages() {
      float[] data = this.getData();
      float[] percentages = new float[data.length]; 
      for (int i = 0; i < data.length; i++) {
        percentages[i] = data[i] / this.numWorkers;
      }
      return percentages;
   }
}

