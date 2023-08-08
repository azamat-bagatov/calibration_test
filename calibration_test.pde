
// frame  coordinates, mm
float[][] realCoordinates = {
  {0, 1000, }, {1800, 1000, },
  {0, 0, }, {1800, 0, }
};

float Xtl = realCoordinates[0][0];
float Ytl = realCoordinates[0][1];

float Xtr = realCoordinates[1][0];
float Ytr = realCoordinates[1][1];

float Xbl = realCoordinates[2][0];
float Ybl = realCoordinates[2][1];

float Xbr = realCoordinates[3][0];
float Ybr = realCoordinates[3][1];

//mass in kg
float mass = 5.0;

float G_CONSTANT =  9.80665;

//frame angle in radians
float alpha = 0.1;

//fixed tension of bottom belts, in N
float tensionBottom = 100.0;

//tension forces
float BL, TL, BR, TR;

void calculate_tesions(float x, float y) {
  BR = tensionBottom;
  BL = tensionBottom;
  float A, C, sinD, cosD, sinE, cosE; // respective quarters cotangents, and sin and cos
  float Fx, Fy;  // known forces vector sum

  A = (Xtl - x) / (Ytl - y);
  C = (Xtr - x) / (Ytr - y);
  sinD =  x / sqrt( sq(x) + sq(y) );
  cosD =  y / sqrt( sq(x) + sq(y) );
  sinE = (Xbr - x) / sqrt( sq(Xbr-x) + sq(y) );
  cosE = y / sqrt( sq(Xbr-x) + sq(y) );

  Fx = BR*sinD - BL*sinE;
  Fy = BR*cosD + BR*cosE + mass * G_CONSTANT * cos(alpha);

  float TLy = ( Fx + C*Fy) / ( A + C );
  float TRy =  Fy - TLy ;
  float TRx = C * ( Fy - TLy);
  float TLx = A * TLy;

  TL = sqrt( sq(TLx) + sq(TLy) );
  TR = sqrt( sq(TRx) + sq(TRy) );
}


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


//add error in MM
float realCoordinatesError = 0;

int state = 0;


void setup() {
  size(1920, 1080);
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
    machineX = mouseX-OFFSET;
    machineY = -mouseY-OFFSET+height;
  }
  calculate_tesions(machineX, machineY);
  //move();
}

boolean start = false;


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
int OFFSET = 50;
void render() {
  background(10);
  scale(1, -1);
  translate(OFFSET, OFFSET - height);

  //draw real corners and frame
  noStroke();
  fill(20);
  rect(0, 0, corners[3].realX, corners[3].realY);

  stroke(20, 150, 20);
  strokeWeight(6);
  for (int i = 0; i < 4; i++) {
    point( corners[i].realX, corners[i].realY);
    fill(20, 150, 20);
    pushMatrix();
    translate(corners[i].realX+10, corners[i].realY+10);
    scale(1, -1);
    text(corners[i].realX + ","+ corners[i].realY, 0, 0 );
    popMatrix();
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

  //draw tensions
  strokeWeight(4);
  stroke(200, 30, 50);
  fill(200, 30, 50);
  
  float scale = 0.5;
  pushMatrix();
  translate(machineX, machineY);


  float f = TL*scale;
  float a = atan( (machineY - Ytl) / (machineX - Xtl) );
  arrow(0, 0, -f*cos(a), -f*sin(a));



  f = TR*scale;
  a = atan( abs(machineY - Ytr) / abs(machineX - Xtr) );
  arrow(0, 0, f*cos(a), f*sin(a));



  f = BR*scale;
  a = atan( (machineY - Ybr) / (machineX - Xbr) );
  arrow(0, 0, f*cos(a), f*sin(a));



  f = BL*scale;
  a = atan( (machineY - Ybl) / (machineX - Xbl) );
  arrow(0, 0, -f*cos(a), -f*sin(a));


  popMatrix();
  textSize(20);
  int OFFS = 40;
  fill(250);
  translate(machineX, machineY);
  pushMatrix();
  translate(-OFFS*2, OFFS);
  scale(1, -1);
  text(nf(TL,0,1),0 , 0);
  popMatrix();
  
  pushMatrix();
  translate(OFFS, OFFS);
  scale(1, -1);
  text(TR,0 , 0);
  popMatrix();
  
  pushMatrix();
  translate(OFFS, -OFFS);
  scale(1, -1);
  text(BR,0 , 0);
  popMatrix();
  
  pushMatrix();
  translate(-OFFS*2, -OFFS);
  scale(1, -1);
  text(BL,0 , 0);
  popMatrix();

  
  //measuring belt lengths at the start
  takeMeasurement(machineX, machineY, 0.5);
  int textoffs = 40;
  fill(245);
  //text(corners[0].beltLength, machineX - textoffs, machineY - textoffs );
  //text(corners[1].beltLength, machineX + textoffs, machineY - textoffs );
  //text(corners[2].beltLength, machineX - textoffs, machineY + textoffs );
  //text(corners[3].beltLength, machineX + textoffs, machineY + textoffs );
}

void arrow(float x1, float y1, float x2, float y2) {
  float a = 6;// dist(x1, y1, x2, y2) / 50;
  pushMatrix();
  translate(x2, y2);
  rotate(atan2(y2 - y1, x2 - x1));
  triangle(- a * 2, - a, 0, 0, - a * 2, a);
  popMatrix();
  line(x1, y1, x2, y2);
}

void keyPressed() {
  if (key == ENTER) {
    println("state 1, moving to center point");
    state = 1;
  }
}

boolean dragged = false;

void mousePressed() {
  println((mouseX-OFFSET) + " " + (-OFFSET + height -mouseY) );
  if ( dist (mouseX-OFFSET, -mouseY-OFFSET+height, machineX, machineY) < 40) {
    dragged = true;
    //println("drag on");
  }
  //println( dist (mouseX,mouseY,machineX, machineY) );
}

void mouseReleased() {
  dragged = false;
  //println("drag off");
}
