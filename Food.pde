class Food {
  
  // Keep track of food position
  int x, y;
  
  Food(int x, int y) {
    // Initialize position variables
    this.x = x;
    this.y = y;
  }
  
  void show() {
    // Draw circles to show the food object
    noStroke();
    fill(0, 255, 0);
    circle(this.x, this.y, 10);
    fill(0, 155, 0);
    circle(this.x, this.y, 6);
  }
  
}
