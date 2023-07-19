
class Corner {
  float realX, realY;
  float calcX, calcY;
  float beltLength;

  Corner(float real_X, float real_Y) {
    realX = real_X;
    realY = real_Y;
  }
}

Corner[] corners = new Corner[4];

float machineX, machineY;

// real coordinates
float[][] realCoordinates = {
  {0, 0, }, {1000, 0, },
  {0, 500, }, {1000, 500, }};
//add error in MM
float realCoordinatesError = 0;

int state = 0;


void setup() {
  size(1200, 700);
  noSmooth();
  background(10);

  for (int i = 0; i < 4; i++) {
    corners[i] = new Corner(realCoordinates[i][0] + randomGaussian()*realCoordinatesError, realCoordinates[i][1] +randomGaussian()*realCoordinatesError);
  }
  //initiate machine at random coordinates
  machineX = random(100, 900);
  machineY = random(100, 400);
}


void takeMeasurement(float x, float y, float errorMM) {
  for (int i = 0; i < 4; i++) {
    corners[i].beltLength = dist(x, y, corners[i].realX, corners[i].realY) + randomGaussian()*errorMM;
  }
}


void draw() {

  background(10);
  translate(100, 100);

  //draw real corners
  stroke(20, 150, 20);
  strokeWeight(6);
  for (int i = 0; i < 4; i++) {
    point( corners[i].realX, corners[i].realY);
  }
  //draw Maslow4 and belts
  noStroke();
  fill(20, 50, 80);
  ellipse(machineX, machineY, 40, 40);
  fill(100, 130, 150);
  ellipse(machineX, machineY, 20, 20);
  strokeWeight(2);
  stroke(100, 130, 150);
  for (int i = 0; i < 4; i++) {
    line(machineX, machineY, corners[i].realX, corners[i].realY);
  }
  //measuring belt lengths at the start
  takeMeasurement(machineX, machineY, 0.5);
  int textoffs = 40;
  fill(245);
  text(corners[0].beltLength, machineX - textoffs, machineY - textoffs );
  text(corners[1].beltLength, machineX + textoffs, machineY - textoffs );
  text(corners[2].beltLength, machineX - textoffs, machineY + textoffs );
  text(corners[3].beltLength, machineX + textoffs, machineY + textoffs );

  if (dragged) {
    machineX = mouseX-100;
    machineY = mouseY-100;
  }

  switch(state) {
  case 0:
    break;

  case 1:
    // initiate movement to the next circle
    break;
  }
}

boolean dragged = false;

void mousePressed() {

  if ( dist (mouseX-100, mouseY-100, machineX, machineY) < 40) {
    dragged = true;
    //println("drag on");
  }
  //println( dist (mouseX,mouseY,machineX, machineY) );
}

void mouseReleased() {
  dragged = false;
  //println("drag off");
}
