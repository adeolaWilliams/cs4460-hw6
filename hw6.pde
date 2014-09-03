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
ArrayList<State> states = new ArrayList<State>();

void setup() {
  cData = loadTable("CommuterData.csv", "header");
  
  // Create a new State object for each row of data
  for (TableRow row : cData.rows()) {
      states.add(new State(row));
  }
}

class State {
   String name;
   float numWorkers, numDroveAlone, numCarPooled, numPublicTransit;
   float numWalked, numOther, numWorkedHome, travelTime;
   
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
}
