int SET_BIT = 0;
int INPUT_BIT = 1;
int RESET = 2;

//int delayMillisecStep = 1;
int delayMillisecTest = 3000;

int instruction_a[11] =     {1,1,0,1,1,1,1,1,1,1,1};
int instruction_b[11] =     {1,1,1,1,1,1,1,1,1,1,1};
int instruction_c[11] =     {1,1,0,0,0,0,0,0,0,0,0};
int instruction_d[11] =     {1,1,1,0,0,0,0,0,0,0,0};

int instruction[11] =     {1,1,1,0,1,1,1,1,1,1,1};

int instruction_blank[11] = {0,0,0,0,0,0,0,0,0,0,0};

void setup()
{
  // setup
  pinMode(SET_BIT, OUTPUT);
  pinMode(INPUT_BIT, OUTPUT);
  pinMode(RESET, OUTPUT);
  
  SendReset();
  
  // activation delay
  delay(delayMillisecTest);

  // runs once
  RunInstruction(instruction_a); delay(delayMillisecTest);
  //RunInstruction(instruction_b); delay(delayMillisecTest);
  
  //RunInstruction(instruction); delay(delayMillisecTest);
  
  RunInstruction(instruction_c); delay(delayMillisecTest);
  //RunInstruction(instruction_d); delay(delayMillisecTest);

  // launcher test
  int instruction_r[11] = {0,1,0,0,1,0,0,0,0,0,0};
  int instruction_e[11] = {0,1,1,1,1,0,0,0,0,0,0};
  int instruction_g[11] = {1,1,0,0,0,0,0,0,0,0,0};
  
  //RunInstruction(instruction_r); delay(delayMillisecTest);
  //RunInstruction(instruction_e); delay(delayMillisecTest);
  
  //RunInstruction(instruction_g); delay(delayMillisecTest);
  
  
  RunInstruction(instruction_blank);
}

void loop() {}

void RunInstruction(int instruction[11])
{
  // activate
  digitalWrite(SET_BIT, HIGH);
  //delay(delayMillisecStep);
  digitalWrite(SET_BIT, LOW);
  //delay(delayMillisecStep);

  // Send bit
  for (int I = 0; I < 11; I++)
  {
    SetNextBit(instruction[I]);
  }

  // deactivate
  digitalWrite(SET_BIT, HIGH);
  //delay(delayMillisecStep);
  digitalWrite(SET_BIT, LOW);
}

void SetNextBit(int input)
{
  if (input == 1) {digitalWrite(INPUT_BIT, HIGH);}
  digitalWrite(SET_BIT, HIGH);
  //delay(delayMillisecStep);
  digitalWrite(SET_BIT, LOW);
  digitalWrite(INPUT_BIT, LOW);
  //delay(delayMillisecStep);
}

void SendReset()
{
  digitalWrite(RESET, HIGH);
  digitalWrite(SET_BIT, HIGH);
  //delay(delayMillisecStep);
  digitalWrite(SET_BIT, LOW);
  digitalWrite(RESET, LOW);
}

