Group {

  Diel1 = Region[7];
  Ground = Region[10];
  Electrode1 = Region[8];
  Electrode2 = Region[9];

  Vol_Ele = Region[ {Diel1 } ];
  Sur_Neu_Ele = Region[ {} ];
}
Function {

  eps0 = 8.854187818e-12;
  epsilon[Diel1] = 1* eps0;
}
Constraint {

  { Name Dirichlet_Ele; Type Assign;
    Case {
      { Region Ground; Value 0.; }
      { Region Electrode1; Value 1; }
      { Region Electrode2; Value 0.; }
    }
  }
}
Group{

  Dom_Hgrad_v_Ele =  Region[ {Vol_Ele, Sur_Neu_Ele} ];
}
FunctionSpace {
  { Name Hgrad_v_Ele; Type Form0;
    BasisFunction {
      { Name sn; NameOfCoef vn; Function BF_Node;
        Support Dom_Hgrad_v_Ele; Entity NodesOf[ All, Not Electrode1 ]; }
      { Name sf; NameOfCoef vf; Function BF_GroupOfNodes;
        Support Dom_Hgrad_v_Ele; Entity GroupsOfNodesOf[ Electrode1 ]; }
    }
    GlobalQuantity {
      { Name GlobalPotential; Type AliasOf; NameOfCoef vf; }
      { Name ArmatureCharge; Type AssociatedWith; NameOfCoef vf; }
    }
    Constraint {
      { NameOfCoef vn; EntityType NodesOf; NameOfConstraint Dirichlet_Ele; }
      { NameOfCoef GlobalPotential; EntityType GroupsOfNodesOf; NameOfConstraint Dirichlet_Ele; }
    }
  }
}

Jacobian {

  { Name Vol ;
    Case {
      { Region All ; Jacobian Vol ; }
    }
  }
  { Name Sur ;
    Case {
      { Region All ; Jacobian Sur ; }
    }
  }
}
Integration {
  /* A Gauss quadrature rule with 4 points is used for all integrations below. */

  { Name Int ;
    Case { { Type Gauss ;
             Case { { GeoElement Line        ; NumberOfPoints  4 ; }
                    { GeoElement Triangle    ; NumberOfPoints  4 ; }
                    { GeoElement Quadrangle  ; NumberOfPoints  4 ; } }
      }
    }
  }
}

Formulation {
  { Name Electrostatics_v; Type FemEquation;
    Quantity {
      { Name v; Type Local; NameOfSpace Hgrad_v_Ele; }
      { Name U; Type Global; NameOfSpace Hgrad_v_Ele [GlobalPotential]; }
      { Name Q; Type Global; NameOfSpace Hgrad_v_Ele [ArmatureCharge]; }
    }
    Equation {
      Integral { [ epsilon[] * Dof{d v} , {d v} ];
      In Vol_Ele; Jacobian Vol; Integration Int; }
      GlobalTerm { [ -Dof{Q} , {U} ]; In Electrode1; }
    }
  }
}
Resolution {
  { Name EleSta_v;
    System {
      { Name Sys_Ele; NameOfFormulation Electrostatics_v; }
    }
    Operation {
      Generate[Sys_Ele]; Solve[Sys_Ele]; SaveSolution[Sys_Ele];
    }
  }
}
PostProcessing {
  { Name EleSta_v; NameOfFormulation Electrostatics_v;
    Quantity {
      { Name v; Value {
          Term { [ {v} ]; In Dom_Hgrad_v_Ele; Jacobian Vol; }
        }
      }
      { Name e; Value {
          Term { [ -{d v} ]; In Dom_Hgrad_v_Ele; Jacobian Vol; }
        }
      }
      { Name d; Value {
          Term { [ -epsilon[] * {d v} ]; In Dom_Hgrad_v_Ele; Jacobian Vol; }
        }
      }
      { Name Q; Value {
          Term { [ {Q} ]; In Electrode1; }
        }
      }
      { Name U; Value {
          Term { [ {U} ]; In Electrode1; }
        }
      }
      { Name C; Value {
          Term { [ Fabs[{Q}/{U}] ]; In Electrode1; }
        }
      }
    }
  }
}

PostOperation {
  { Name Map; NameOfPostProcessing EleSta_v;
     Operation {
       Print[ v, OnElementsOf Dom_Hgrad_v_Ele, File "v.pos" ];
       Print[ e, OnElementsOf Dom_Hgrad_v_Ele, File "e.pos" ];
       Print[ d, OnElementsOf Dom_Hgrad_v_Ele, File "d.pos" ];

       Echo[ "Electrode1 charge [C]:", Format Table, File > "output.txt"] ;
       Print[ Q, OnRegion Electrode1, File > "output.txt", Format Table ];
       Echo[ "Electrode1 potential [V]:", Format Table, File > "output.txt"] ;
       Print[ U, OnRegion Electrode1, File > "output.txt", Format Table ];
       Echo[ "Coaxial cable capacitance [F]:", Format Table, File > "output.txt"] ;
       Print[ C, OnRegion Electrode1, File > "output.txt", Format Table ];
     }
  }
}
