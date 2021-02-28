import gifAnimation.*;

GifMaker gifFile;

PShape solid;
ArrayList<PVector> pointList;
boolean drawSolid = false;
boolean initialScreen = true;

void setup(){
  size(600, 600, P3D);
  
  gifFile = new GifMaker(this, "img/animacion.gif");
  
  pointList = new ArrayList();
}

void draw(){
  background(0);
  
  if(initialScreen){
    text("Uso", width/2 - 10, height/2 - 100);
    text("Click en la pantalla para definir los puntos",  width/2 - 120, height/2 - 80);
    text("Presiona <ENTER> para formar el sólido de revolución", width/2 - 160, height/2 - 60);
    text("Presiona <r> para limpiar la pantalla", width/2 - 110, height/2 - 40);
    text("Presiona <s> para empezar", width/2 - 90, height/2);
  }
  else{
    if(!drawSolid){
      stroke(255, 0, 0);
      line(width/2, 0, width/2, height);
    
      for(int i = 0; i < pointList.size() - 1; i++){
        PVector v1 = pointList.get(i);
        PVector v2 = pointList.get(i + 1);
        line(v1.x, v1.y, v2.x, v2.y);
      }    
    }else{
      translate(width/2, height/4);
      shape(solid);
    }
  }
  
  gifFile.addFrame();
}

//método encargado de formar la malla con los puntos iniciales y lo puntos de rotación
//angle: ángulo de rotación
//se devuelve una lista con todos los puntos que forman la malla
ArrayList<PVector> formMesh(int angle){
  int count = 0;
  int inc = 0;
  ArrayList<PVector> meshPoints = new ArrayList();
  
  //se van añadiendo puntos hasta que se termina de formar la malla y en cada iteración se va incrementando
  //el ángulo de rotación hasta llegar a 360
  while(count < 360/angle){
    for(int i = 0; i< pointList.size(); i++){
      PVector v = pointList.get(i);
      //rotación en el eje y
      meshPoints.add(new PVector(
                     v.x*cos(radians(inc)) - v.z*sin(radians(inc)),
                     v.y,
                     v.x*sin(radians(inc)) + v.z*cos(radians(inc))
                     ));
    }
    count++;
    inc += angle;
  }
  return meshPoints;
}

//método encargado de generar el PShape del sólido de revolución
//vertexList: malla de puntos
void formShape(ArrayList<PVector> vertexList){
  solid.beginShape(TRIANGLE_STRIP);
  solid.stroke(0);
  
  //por cada dos vértices (i, i + 1) y estos mismos vértices en el siguiente meridiano
  //(i + n, (i + 1) + n) (donde 'n' es el número de puntos pointList.size()) se forma un 'cuadrado' y a partir
  // de este se forman dos triángulos
  for(int i = 0; i < (vertexList.size() - pointList.size()); i++){
    if((i + 1) % pointList.size() == 0) { //si nos encontramos en el último vértice pasamos al siguiente meridiano
      continue;
    }else{
      PVector v1 = vertexList.get(i);
      PVector v2 = vertexList.get(i + 1);
      PVector v3 = vertexList.get(i + pointList.size());
      PVector v4 = vertexList.get((i + 1) + pointList.size());
    
      solid.vertex(v1.x, v1.y, v1.z);
      solid.vertex(v3.x, v3.y, v3.z);
      solid.vertex(v4.x, v4.y, v4.z);
    
      solid.vertex(v1.x, v1.y, v1.z);
      solid.vertex(v2.x, v2.y, v2.z);
      solid.vertex(v4.x, v4.y, v4.z);
    }
  }

  //Este bucle se encarga de determinar la conexión del último meridiano con el primero para completar la figura
  for(int i = (vertexList.size() - pointList.size()); i < vertexList.size() - 1; i++){
    PVector v1 = vertexList.get(i);
    PVector v2 = vertexList.get(i + 1);
    PVector v3 = vertexList.get((i + 1) % pointList.size());//elemento i del primer meridiano (se usa i + 1 para aprovechar la operación de módulo)
    PVector v4 = vertexList.get((i + 2) % pointList.size());//elemento i + 1 del primer meridiano (se usa i + 2 para aprovechar la operación del módulo)
    
    //el orden en el que se crean los triángulos es distinsto ya que vamos desde el final al principio
    solid.vertex(v3.x, v3.y, v3.z);
    solid.vertex(v1.x, v1.y, v1.z);
    solid.vertex(v2.x, v2.y, v2.z);
    
    solid.vertex(v3.x, v3.y, v3.z);
    solid.vertex(v4.x, v4.y, v4.z);
    solid.vertex(v2.x, v2.y, v2.z); 
  }
  
  solid.endShape(CLOSE);
}

void mousePressed(){
  pointList.add(new PVector(mouseX, mouseY, 0));
}

void keyPressed(){
  if(keyCode == ENTER && !drawSolid){
    drawSolid = true;
    
    solid = createShape();
    solid.scale(0.5);
    
    formShape(formMesh(5));
  }
  
  if(key == 'r'){
    drawSolid = false;
    pointList.clear();
  }
  
  if(key == 's'){
    initialScreen = false;
  }
  
  if(key == 'f'){
    gifFile.finish();
  }
}
