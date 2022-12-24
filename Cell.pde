class Cell {
  
  // Keep track of cell position
  float x, y;
  // 4 values: nearest food x, y, nearest neighbour x, y
  float[] inputs;
  // 2 hidden layers, coresponding weights & biases
  float[] h1, h2;
  float[][] w1, w2, w3;
  float[] b1, b2, b3;
  // 2 values: x-movement & y-movement
  float[] outputs;
  
  // Keeps track of the cells "fitness"
  int foodIntake = 0;
 
  Cell(float x, float y) {
    // Set position of cell
    this.x = x;
    this.y = y;
    // Initialize neural network lists
    this.inputs = new float[4];
    this.h1 = new float[8];
    this.h2 = new float[8];
    this.w1 = new float[8][4];
    this.w2 = new float[8][8];
    this.w3 = new float[2][8];
    this.b1 = new float[8];
    this.b2 = new float[8];
    this.b3 = new float[2];
    this.outputs = new float[2];
  }
  
  void init() {
    // Set each weight and bias in the neural network to a random value between -1 & 1
    for(int i = 0; i < this.h1.length; i++) {
      this.b1[i] = random(-1, 1);
      for(int j = 0; j < this.w1[0].length; j++) {
        this.w1[i][j] = random(-1, 1);
      }
    }
    for(int i = 0; i < this.h2.length; i++) {
      this.b2[1] = random(-1, 1);
      for(int j = 0; j < this.w2[0].length; j++) {
        this.w2[i][j] = random(-1, 1);
      }
    }
    for(int i = 0; i < this.outputs.length; i++) {
      this.b3[i] = random(-1, 1);
      for(int j = 0; j < this.w3[0].length; j++) {
        this.w3[i][j] = random(-1, 1);
      }
    }
  }
  
  void calcInputs(Cell[] neighbours, Food[] food) {
    // Initialize input values with zeroes
    this.inputs[0] = 0;
    this.inputs[1] = 0;
    this.inputs[2] = 0;
    this.inputs[3] = 0;
    // Set a reference for the minimum interaction distance
    float minDist = 100;
    // Iterate through provided food list, find nearest food item
    for(Food f: food) {
      // Calculate distance from cell to food item
      float distance = dist(this.x, this.y, f.x, f.y);
      // Draw a green line to food if distance is within minimum interaction distance
      if(distance < 100) {
        // Brightness & width of line inversely proportional to proximity of food item
        int g = int(map(distance, 0, 100, 255, 50));
        float w = map(distance, 0, 100, 2, 0.5);
        stroke(0, g, 0);
        strokeWeight(w);
        line(this.x, this.y, f.x, f.y);
      }
      // Results in the first and second inputs being the horizontal and vertical distances to the nearest food item
      if(distance < minDist) {
        this.inputs[0] = f.x - this.x;
        this.inputs[1] = f.y - this.y;
        minDist = distance;
      }
    }
    // Reset the minimum interaction distance
    minDist = 100;
    // Iterate through provided neighbour list, find nearest neighbouring cell
    for(Cell c: neighbours) {
      // Calculate distance from cell to neighbour
      float distance = dist(this.x, this.y, c.x, c.y);
      // Draw a red line to neighbour if distance is within minimum interaction distance
      if(distance < 100) {
        // Brightness & width of line inversely proportional to proximity of neighbour
        int r = int(map(distance, 0, 100, 255, 50));
        float w = map(distance, 0, 100, 2, 0.5);
        stroke(r, 0, 0);
        strokeWeight(w);
        line(this.x, this.y, c.x, c.y);
      }
      // Results in the third and fourth inputs being the horizontal and vertical distances to the nearest neighbour
      if(distance < minDist && distance != 0) {
        this.inputs[2] = c.x - this.x;
        this.inputs[3] = c.y - this.y;
        minDist = distance;
      }
    }
  }
  
  void step() {
    // Reset values of hidden layers
    for(int i = 0; i < this.h1.length; i++) {
      this.h1[i] = 0;
    }
    for(int i = 0; i < this.h2.length; i++) {
      this.h2[i] = 0;
    }
    // Forward propagation of neural network
    for(int i = 0; i < this.w1.length; i++) {
      for(int j = 0; j < this.inputs.length; j++) {
        this.h1[i] += this.inputs[j] * this.w1[i][j];
      }
      this.h1[i] += this.b1[i];
      // Sigmoid activation function
      this.h1[i] = 1 / (1 + exp(-this.h1[i]));
    }
    for(int i = 0; i < this.w2.length; i++) {
      for(int j = 0; j < this.h1.length; j++) {
        this.h2[i] += this.h1[j] * this.w2[i][j];
      }
      this.h2[i] += this.b2[i];
      // Sigmoid activation function
      this.h2[i] = 1 / (1 + exp(-this.h2[i]));
    }
    for(int i = 0; i < this.w3.length; i++) {
      for(int j = 0; j < this.h2.length; j++) {
        this.outputs[i] += this.h2[j] * this.w3[i][j];
      }
      this.outputs[i] += this.b3[i];
      // Sigmoid activation function, domain (0, 1), mapped to tanh function, domain (-1, 1)
      this.outputs[i] = 1 / (1 + exp(-this.outputs[i]));
      this.outputs[i] = map(this.outputs[i], 0, 1, -1, 1);
    }
    // Set model's outputs to movement variables
    this.x += this.outputs[0];
    this.y += this.outputs[1];
    // Conditions to wrap cells around edges of the canvas
    if(this.x > width) {
      this.x = 0;
    }
    if(this.x < 0) {
      this.x = width;
    }
    if(this.y > height) {
      this.y = 0;
    }
    if(this.y < 0) {
      this.y = height;
    }
  }
  
  void mutate() {
    // Pick a random index for each weight and bias array, increment it by a small random value
    w1[int(random(w1.length))][int(random(w1[0].length))] += random(-0.2, 0.2);
    w2[int(random(w2.length))][int(random(w2[0].length))] += random(-0.2, 0.2);
    w3[int(random(w3.length))][int(random(w3[0].length))] += random(-0.2, 0.2);
    b1[int(random(b1.length))] += random(-0.2, 0.2);
    b2[int(random(b2.length))] += random(-0.2, 0.2);
    b3[int(random(b3.length))] += random(-0.2, 0.2);
  }
   
  Cell splice(Cell a, Cell b, int maxFitness) {
    // Create a new "child" cell
    Cell newCell = new Cell(int(random(width)), int(random(height)));
    // Pick a random number between 0 and the sum of all weight and bias arrays
    int midPoint = int(random(6));
    // Set weights & biases of either cell A or B to the new cell, depending on midpoint
    newCell.w1 = midPoint < 1 ? a.w1 : b.w1;
    newCell.w2 = midPoint < 2 ? a.w2 : b.w2;
    newCell.w3 = midPoint < 3 ? a.w3 : b.w3;
    newCell.b1 = midPoint < 4 ? a.b1 : b.b1;
    newCell.b2 = midPoint < 5 ? a.b2 : b.b2;
    newCell.b3 = midPoint < 6 ? a.b3 : b.b3;
    // Mutate a cell based on max fitness and the average fitness between cells A & B
    int numMutations = (maxFitness * 2) - (a.foodIntake + b.foodIntake);
    for(int i = 0; i < numMutations; i++) {
      newCell.mutate();
    }
    // Finally, return the new "child" cell, which now has a full NN
    return newCell;
  }
  
  void show() {
    // Draws a line showing the direction a cell is moving
    stroke(255);
    strokeWeight(1);
    line(this.x, this.y, this.x + this.outputs[0] * 20, this.y + this.outputs[1] * 20);
    // Text over each cell showing food intake or "fitness"
    textAlign(CENTER);
    text(this.foodIntake, this.x, this.y - 10);
    // Draw a circle to show the maximum interaction distance
    noFill();
    stroke(50);
    strokeWeight(0.5);
    circle(this.x, this.y, 200);
    // Draw a circle to show the cell itself
    noStroke();
    fill(255);
    circle(this.x, this.y, 5);
  }
  
  
}
