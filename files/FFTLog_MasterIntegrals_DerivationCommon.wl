BeginPackage["FFTLogMasterIntegralsDerivation`"];

ResolveDerivationPath::usage =
  "ResolveDerivationPath[parts...] builds a path relative to this derivation-first notebook suite.";
ScalarIMaster::usage =
  "ScalarIMaster[nu1, nu2] is the scalar FFTLog master integral I(nu1,nu2).";
ShiftedScalarIMaster::usage =
  "ShiftedScalarIMaster[a,b][nu1,nu2] returns ScalarIMaster[nu1-a,nu2-b].";
DerivedLOSCoefficientByM::usage =
  "DerivedLOSCoefficientByM[n,m,nu1,nu2] is the Schwinger-derived coefficient of mu^(n-2 m).";
DerivedLOSCoefficient::usage =
  "DerivedLOSCoefficient[n,muPower,nu1,nu2] returns the LOS coefficient at the requested mu power.";
KernelReferenceText::usage =
  "KernelReferenceText[path] imports and trims one reference expression text file.";
KernelReferenceExpression::usage =
  "KernelReferenceExpression[path] parses one Mathematica expression from a reference text file.";
DefaultValidationPoint::usage =
  "DefaultValidationPoint[] returns a deterministic rational test point.";
ExactValidationSummary::usage =
  "ExactValidationSummary[keys,residualFn,seconds] applies FullSimplify[residual==0] to each key.";
NumericResidualSummary::usage =
  "NumericResidualSummary[keys,residualFn,point,precision] evaluates deterministic residuals.";

Begin["`Private`"];

$FFTLogDerivationRoot = Replace[DirectoryName[$InputFileName], {
    _String?(StringLength[#] > 0 &) :> DirectoryName[$InputFileName],
    _ :> Directory[]
}];

ResolveDerivationPath[parts__String] :=
  FileNameJoin[{$FFTLogDerivationRoot, parts}];

parseMathematicaExpression[text_String] :=
  Replace[
   ToExpression[text, InputForm, HoldComplete],
   HoldComplete[expr_] :> expr
  ];

KernelReferenceText[path_String] :=
  KernelReferenceText[path] = StringTrim[Import[path, "Text"]];

KernelReferenceExpression[path_String] :=
  KernelReferenceExpression[path] =
   parseMathematicaExpression[KernelReferenceText[path]];

ScalarIMaster[nu1_, nu2_] :=
  (1/(8 Pi^(3/2)))*
   Gamma[3/2 - nu1]*
   Gamma[3/2 - nu2]*
   Gamma[nu1 + nu2 - 3/2]/
   (Gamma[nu1] Gamma[nu2] Gamma[3 - nu1 - nu2]);

ShiftedScalarIMaster[a_Integer?NonNegative, b_Integer?NonNegative][nu1_, nu2_] :=
  ScalarIMaster[nu1 - a, nu2 - b];

DerivedLOSCoefficientByM[n_Integer?NonNegative, m_Integer?NonNegative, nu1_, nu2_] /;
   0 <= 2 m <= n :=
  (Factorial[n]/(Factorial[m] Factorial[n - 2 m] 4^m))*
   (1/(8 Pi^(3/2)))*
   Gamma[nu1 + nu2 - 3/2 - m]*
   Gamma[3/2 - nu2 + m]*
   Gamma[n - m + 3/2 - nu1]/
   (Gamma[nu1] Gamma[nu2] Gamma[n + 3 - nu1 - nu2]);

DerivedLOSCoefficient[n_Integer?NonNegative, muPower_Integer?NonNegative, nu1_, nu2_] /;
   muPower <= n && EvenQ[n - muPower] :=
  Module[{m = (n - muPower)/2},
   DerivedLOSCoefficientByM[n, m, nu1, nu2]
  ];

DefaultValidationPoint[] := <|
   "nu1" -> 2/5,
   "nu2" -> 3/7,
   "mu" -> 5/11,
   "k" -> 7/5
|>;

ExactValidationSummary[keys_List, residualFn_, seconds_: 30] :=
  AssociationMap[
   Function[key,
    TimeConstrained[
     Quiet@Check[TrueQ[FullSimplify[residualFn[key] == 0]], $Failed],
     seconds,
     $Aborted
    ]
   ],
   keys
  ];

NumericResidualSummary[
   keys_List,
   residualFn_,
   point_Association : DefaultValidationPoint[],
   precision_: 40
] :=
  AssociationMap[
   Function[key,
    N[
     residualFn[key] /. {
        nu1 -> Lookup[point, "nu1"],
        nu2 -> Lookup[point, "nu2"],
        mu -> Lookup[point, "mu"],
        k -> Lookup[point, "k"]
       },
     precision
    ]
   ],
   keys
  ];

End[];
EndPackage[];
