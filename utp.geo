// Gmsh project created on Wed Aug 28 16:49:13 2024
SetFactory("OpenCASCADE");
//+
Circle(1) = {3, 0, 0, 2, 0, 2*Pi};
//+
Circle(2) = {-3, 0, 0, 2, 0, 2*Pi};
//+
Point(3) = {-100, -50, 0, 1.0};
//+
Point(4) = {100, -50, 0, 1.0};
//+
Point(5) = {100, 100, 0, 1.0};
//+
Point(6) = {-100, 100, 0, 1.0};
//+
Line(3) = {3, 4};
//+
Line(4) = {5, 6};
//+
Line(5) = {3, 6};
//+
Line(6) = {5, 4};
//+
Curve Loop(1) = {2};
//+
Plane Surface(1) = {1};
//+
Curve Loop(2) = {1};
//+
Plane Surface(2) = {2};
//+
Curve Loop(3) = {3, -6, 4, -5};
//+
Curve Loop(4) = {2};
//+
Curve Loop(5) = {1};
//+
Plane Surface(3) = {3, 4, 5};
//+
Physical Surface("air", 7) = {3};
//+
Physical Surface("elec1", 8) = {1};
//+
Physical Surface("elec2", 9) = {2};
//+
Physical Curve("boun", 10) = {3, 6, 4, 5};
//+
Transfinite Curve {2, 1} = 50 Using Progression 1;
//+
Transfinite Surface {3};
//+
Transfinite Curve {5, 4, 6, 3} = 10 Using Progression 1;
