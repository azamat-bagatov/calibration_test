
class Corner {
  float realX, realY;
  float calcX, calcY;
  float beltLength;

  Corner(float real_X, float real_Y) {
    realX = real_X;
    realY = real_Y;
    
    calcX = -10;
    calcY = -10;
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
  targetX = machineX;
  targetY = machineY;
}


void takeMeasurement(float x, float y, float errorMM) {
  for (int i = 0; i < 4; i++) {   
    corners[i].beltLength = dist(x, y, corners[i].realX, corners[i].realY) + randomGaussian()*errorMM;
    //println(" machineX = " + x + ", machineY = " + y + "l = " + corners[0].beltLength);
  }
}


void draw() {

  

  render();

  if (dragged) {
    machineX = mouseX-100;
    machineY = mouseY-100;
  }

  switch(state) {
  case 0:
    break;

  case 1:
    // go to midpoint
    if(!start) {
      belts_set_target(520, 520);
      start = true;
    }
    if (!moving) {
      state = 2;
      //record values
      println("reached midpoint, recording values");
      takeMeasurement(machineX, machineY, 0.5);
      l2 = corners[0].beltLength; // top left ( zero corner)
      l1 = corners[2].beltLength; // bottom left 
      m1Y = machineY;
    }
    break;

  case 2:
    if (!moving)
    {
      //look for centermost point
      takeMeasurement(machineX, machineY, 0.5);
      float l_1 = corners[0].beltLength;
      float l_2 = corners[1].beltLength;
      float l_3 = corners[2].beltLength;
      //float l4 = corners[3].beltLength;
      
      float step = (l_3-l_1) *0.05; 
      belts_set_target(l_1+step , l_1+step);
      //state = 3;
      if(abs (l_3-l_2) < 2 /*&& abs(l3-l4) < 2*/ ){
          state = 3;
          println("arrived at centermost point ,recodign values");
          
          l0 = corners[0].beltLength; //top left corner again
          m2Y = machineY;
          calculate_rectangular_dimentions();
      }
    }
    break;
    
    case 3:
      
    break;
    
  }

  move();
}
boolean start = false;
float m1Y,m2Y;
void calculate_rectangular_dimentions(){
  // per formulas
  println("measured lengths: l0 =  " + l0 + ", l1 = " + l1 + ", l2 = " + l2 ); 
  float a,b, delta;
  delta = sqrt ( (sq(l1) + sq(l2) )/2 - sq(l0) );
  println("calculated delta = " + delta ); 
  println("real delta = " + abs(m1Y-m2Y) ); 
  //delta = abs(m1Y-m2Y);
  a =  ( sq(l1) - sq(l0) - sq(delta) ) / (2*delta) ; 
  b = sqrt( sq(l0) - sq(a) );
  println("calculated dimentions: " + a + " x " +b ); 
  corners[0].calcX = 0; //top left corner
  corners[0].calcY = 0;
  
  corners[1].calcX = 2*b; //top right corner
  corners[1].calcY = 0;
  
  corners[2].calcX = 0; //bottom left corner
  corners[2].calcY = 2*a;
  
  corners[3].calcX = 2*b; //bottom right corner
  corners[3].calcY = 2*a;
  
}

//calibration variables
float l0,l1,l2;

float targetX, targetY;
boolean moving = false;

void move() {
  float easing = 0.15;
  float dx = targetX - machineX;
  float dy = targetY - machineY;
  if (abs(dx) > 0.2 || abs(dy) > 0.2)
  {
    moving = true;
    //print(".");
    machineX += dx*easing;
    machineY += dy*easing;
  } else {
    moving = false;
  }
}


void belts_set_target(float l1, float l2) {
  println(l1 +"  "+ l2);
  //move in little increments towards the place
  takeMeasurement(machineX, machineY, 0.5);
  float d = corners[1].realX - corners[0].realX;
  float x =  ( sq(l1)-sq(l2)+ sq(d) ) / (2*d);
  float y = sqrt( sq(l1) - sq(x) );
  //println(x +"  "+ y);
  moveTo( int(x), int(y) );
}

void moveTo(int x, int y) {
  targetX = x;
  targetY = y;
  moving = true;
}

void render() {
  background(10);
  translate(100, 100);

  //draw real corners and frame
  noStroke();
  fill(20);
  rect(0,0,corners[3].realX, corners[3].realY);
  
  stroke(20, 150, 20);
  strokeWeight(6);
  for (int i = 0; i < 4; i++) {
    point( corners[i].realX, corners[i].realY);
    fill(20, 150, 20);
    text(corners[i].realX + ","+ corners[i].realY, corners[i].realX+10, corners[i].realY+10);
  }
  
  //draw calculated frame
  
  stroke(150, 20, 20);
  
  for (int i = 0; i < 4; i++) {
    strokeWeight(6);
    point( corners[i].calcX, corners[i].calcY);
    
    fill(150, 20, 20);
    text(corners[i].calcX + ","+ corners[i].calcY, corners[i].calcX-10, corners[i].calcY-10);
  }
  strokeWeight(2);
  line(corners[0].calcX, corners[0].calcY, corners[1].calcX, corners[1].calcY);
  line(corners[1].calcX, corners[1].calcY, corners[3].calcX, corners[3].calcY);
  line(corners[3].calcX, corners[3].calcY, corners[2].calcX, corners[2].calcY);
  line(corners[2].calcX, corners[2].calcY, corners[0].calcX, corners[0].calcY);

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
  
  
}


void keyPressed() {
  if (key == ENTER) {
    println("state 1, moving to center point");
    state = 1;
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
