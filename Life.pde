Food[] food;
Cell[] cells;

int numFood = 50;
int numCells = 10;
int lifespan = 1000;
int gen = 1;

// Setup() is the first method called, and initializes the environment
void setup() {
  // Create a canvas
  size(600, 400);
  // Initialize food list with random food positions
  food = new Food[numFood];
  for(int i = 0; i < numFood; i++) {
    food[i] = new Food(int(random(width)), int(random(height)));
  }
  // Initialize cell list with random cell positions
  cells = new Cell[numCells];
  for(int i = 0; i < numCells; i++) {
    cells[i] = new Cell(int(random(width)), int(random(height)));
    // Initialize the cell's neural network with random weights and biases
    cells[i].init();
  }
}

// Draw() is the main render loop, running continuously until the program is exited
void draw() {
  // Draw a dark background
  background(20);
  // Show each food item
  for(Food f: food) {
    f.show();
  }
  // Iterate through list of cells and compute interactions
  for(Cell c: cells) {
    c.calcInputs(cells, food);
    // Do not update the cell if its life is over
    if(lifespan > 0) {
      c.step();
    }
    // Cell & food collision
    for(int i = 0; i < food.length; i++) {
      if(dist(c.x, c.y, food[i].x, food[i].y) < 10) {
        // Create new food with random position so that no food is created or destroyed
        food[i] = new Food(int(random(width)), int(random(height)));
        // Increment the cell's food intake (fitness)
        c.foodIntake++;
      }
    }
    // Finally, render the cell to the canvas
    c.show();
  }
  // Rendering lifespan and generation info on the canvas
  textAlign(LEFT);
  text("Life: " + lifespan, 10, 20);
  textAlign(RIGHT);
  text("Generation: " + gen, width - 20, 20);
  // Reset generation once lifespan has elapsed
  if(lifespan > 0) {
    lifespan--;
  } else {
    newGen();
    gen++;
  }
}

void newGen() {
  // Set references for keeping track fitness information
  int maxFitness = 0;
  int minFitness = 100;
  int totalFitness = 0;
  // Iterate through cells, compute fitness info
  for(Cell c: cells) {
    totalFitness += c.foodIntake;
    if(c.foodIntake > maxFitness) {
      maxFitness = c.foodIntake;
    }
    if(c.foodIntake < minFitness) {
      minFitness = c.foodIntake; 
    }
  }
  // Create a new array to temporarily manage the next generation of cells
  Cell newCells[] = new Cell[cells.length];
  // Create an arraylist to hold cell copies proportional to fitness
  ArrayList<Cell> genePool = new ArrayList<Cell>();
  for(Cell c: cells) {
    // Add 5x copies of each cell per food item consumed, +1 to ensure every cell is copied at least once
    int copies = c.foodIntake * 5 + 1;
    for(int i = 0; i < copies; i++) {
      genePool.add(c);
    }
  }
  // For each new cell, pick two "parents" and splice their neural networks into the "child"
  for(int i = 0;  i < newCells.length; i++) {
    Cell cellA = genePool.get(int(random(genePool.size())));
    Cell cellB = genePool.get(int(random(genePool.size())));
    newCells[i] = cellA.splice(cellA, cellB, maxFitness);
  }
  // Finally, write the newCells list to the main cell list & reset the lifespan.
  cells = newCells;
  lifespan = 500;
  println(totalFitness);
}
