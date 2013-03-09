type
  TDigit = record
    rect: array[0..4] of D3DRECT;
    rectangleCount: integer;
  end;

const // (x1:; y1:; x2:; y2:)
  CDigitArray: array[0..14] of TDigit = (
  // 0 {{{0,0,15,5},   {0,0,5,25}, {10,0,15,25}, {0,20,15,25}, {0,0,0,0}}, 4},
    ( rect: (( x1:  0; y1:  0; x2: 15; y2:  5), (x1:  0; y1:  0; x2:  5; y2: 25), (x1: 10; y1:  0; x2: 15; y2: 25), (x1:  0; y1: 20; x2: 15; y2: 25), (x1:  0; y1:  0; x2:  0; y2:  0)); rectangleCount: 4 ),
  // 1 {{{10,0,15,25}, {0,0,0,0}, {0,0,0,0}, {0,0,0,0}, {0,0,0,0}}, 1},
    ( rect: (( x1: 10; y1:  0; x2: 15; y2: 25), (x1:  0; y1:  0; x2:  0; y2:  0), (x1:  0; y1:  0; x2:  0; y2:  0), (x1:  0; y1:  0; x2:  0; y2:  0), (x1:  0; y1:  0; x2:  0; y2:  0)); rectangleCount: 1 ),
  // 2 {{{0,10,5,25},  {0,0,15,5},   {0,10,15,15}, {10,0,15,15}, {0,20,15,25}}, 5},
    ( rect: (( x1:  0; y1: 10; x2:  5; y2: 25), (x1:  0; y1:  0; x2: 15; y2:  5), (x1:  0; y1: 10; x2: 15; y2: 15), (x1: 10; y1:  0; x2: 15; y2: 15), (x1:  0; y1: 20; x2: 15; y2: 25)); rectangleCount: 5 ),
  // 3 {{{0,0,15,5},   {0,10,15,15}, {10,0,15,25}, {0,20,15,25}, {0,0,0,0}}, 4},
    ( rect: (( x1:  0; y1:  0; x2: 15; y2:  5), (x1:  0; y1: 10; x2: 15; y2: 15), (x1: 10; y1:  0; x2: 15; y2: 25), (x1:  0; y1: 20; x2: 15; y2: 25), (x1:  0; y1:  0; x2:  0; y2:  0)); rectangleCount: 4 ),
  // 4 {{{0,0,5,15},   {0,10,15,15}, {10,0,15,25}, {0,0,0,0}, {0,0,0,0}}, 3},
    ( rect: (( x1:  0; y1:  0; x2:  5; y2: 15), (x1:  0; y1: 10; x2: 15; y2: 15), (x1: 10; y1:  0; x2: 15; y2: 25), (x1:  0; y1:  0; x2:  0; y2:  0), (x1:  0; y1:  0; x2:  0; y2:  0)); rectangleCount: 3 ),
  // 5 {{{0,0,15,5},   {0,0,5,15}, {0,10,15,15}, {10,10,15,25}, {0,20,15,25}}, 5},
    ( rect: (( x1:  0; y1:  0; x2: 15; y2:  5), (x1:  0; y1:  0; x2:  5; y2: 15), (x1:  0; y1: 10; x2: 15; y2: 15), (x1: 10; y1: 10; x2: 15; y2: 25), (x1:  0; y1: 20; x2: 15; y2: 25)); rectangleCount: 5 ),
  // 6 {{{0,0,5,25},   {0,10,15,15}, {10,10,15,25}, {0,20,15,25}, {0,0,0,0}}, 4},
    ( rect: (( x1:  0; y1:  0; x2:  5; y2: 25), (x1:  0; y1: 10; x2: 15; y2: 15), (x1: 10; y1: 10; x2: 15; y2: 25), (x1:  0; y1: 20; x2: 15; y2: 25), (x1:  0; y1:  0; x2:  0; y2:  0)); rectangleCount: 4 ),
  // 7 {{{0,0,15,5},   {10,0,15,25}, {0,0,0,0}, {0,0,0,0}, {0,0,0,0}}, 2},
    ( rect: (( x1:  0; y1:  0; x2: 15; y2:  5), (x1: 10; y1:  0; x2: 15; y2: 25), (x1:  0; y1:  0; x2:  0; y2:  0), (x1:  0; y1:  0; x2:  0; y2:  0), (x1:  0; y1:  0; x2:  0; y2:  0)); rectangleCount: 2 ),
  // 8 {{{0,0,15,5},   {0,0,5,25}, {10,0,15,25}, {0,10,15,15}, {0,20,15,25}}, 5},
    ( rect: (( x1:  0; y1:  0; x2: 15; y2:  5), (x1:  0; y1:  0; x2:  5; y2: 25), (x1: 10; y1:  0; x2: 15; y2: 25), (x1:  0; y1: 10; x2: 15; y2: 15), (x1:  0; y1: 20; x2: 15; y2: 25)); rectangleCount: 5 ),
  // 9 {{{0,0,15,5},   {0,0,5,15}, {0,10,15,15}, {10,0,15,25}, {0,0,0,0}}, 4},
    ( rect: (( x1:  0; y1:  0; x2: 15; y2:  5), (x1:  0; y1:  0; x2:  5; y2: 15), (x1:  0; y1: 10; x2: 15; y2: 15), (x1: 10; y1:  0; x2: 15; y2: 25), (x1:  0; y1:  0; x2:  0; y2:  0)); rectangleCount: 4 ),
  // ' '  {{{0,0,0,0}, {0,0,0,0}, {0,0,0,0}, {0,0,0,0}, {0,0,0,0}}, 0},
    ( rect: (( x1:  0; y1:  0; x2:  0; y2:  0), (x1:  0; y1:  0; x2:  0; y2:  0), (x1:  0; y1:  0; x2:  0; y2:  0), (x1:  0; y1:  0; x2:  0; y2:  0), (x1:  0; y1:  0; x2:  0; y2:  0)); rectangleCount: 0 ),
  // : {{{5,5,10,10}, {5,15,10,20}, {0,0,0,0}, {0,0,0,0}, {0,0,0,0}}, 2},
    ( rect: (( x1:  5; y1:  5; x2: 10; y2: 10), (x1:  5; y1: 15; x2: 10; y2: 20), (x1:  0; y1:  0; x2:  0; y2:  0), (x1:  0; y1:  0; x2:  0; y2:  0), (x1:  0; y1:  0; x2:  0; y2:  0)); rectangleCount: 2 ),


  // F {{{0,0,15,5},   {0,0,5,25}, {0,0,5,25}, {0,10,10,15}, {0,0,0,0}}, 3},
    ( rect: (( x1:  0; y1:  0; x2: 15; y2:  5), (x1:  0; y1:  0; x2:  5; y2: 25), (x1: 0; y1:  10; x2: 10; y2: 15), (x1:  0; y1:  0; x2:  0; y2:  0), (x1:  0; y1:  0; x2:  0; y2:  0)); rectangleCount: 3 ),
  // P {{{0,0,15,5},   {0,0,5,25}, {0,0,5,25}, {0,10,15,15}, {0,0,0,0}}, 4},
    ( rect: (( x1:  0; y1:  0; x2: 15; y2:  5), (x1:  0; y1:  0; x2:  5; y2: 25), (x1: 0; y1:  10; x2: 15; y2: 15), (x1: 10; y1:  0; x2: 15; y2: 15), (x1:  0; y1:  0; x2:  0; y2:  0)); rectangleCount: 4 ),
  // S {{{10,10,15,25},{0,0,15,5}, {0,10,15,15}, {0,0,5,15}, {0,20,15,25}}, 5},
    ( rect: (( x1: 10; y1: 10; x2: 15; y2: 25), (x1:  0; y1:  0; x2: 15; y2:  5), (x1:  0; y1: 10; x2: 15; y2: 15), (x1:  0; y1:  0; x2:  5; y2: 15), (x1:  0; y1: 20; x2: 15; y2: 25)); rectangleCount: 5 )


);
