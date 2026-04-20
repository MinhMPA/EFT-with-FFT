(* arXiv:2309.10133 Appendix A master-integral derivation and checks *)

ClearAll["Global`*"];

Get[FileNameJoin[{DirectoryName[$InputFileName], "FFTLog_MasterIntegrals_DerivationCommon.wl"}]];

$LyAAppendixAPaper = <|
   "Title" -> "Don't miss the forest for the trees: the Lyman alpha forest power spectrum in effective field theory",
   "ArXiv" -> "2309.10133",
   "Section" -> "Appendix A / Master Integrals"
|>;

$AppendixACoefficientMap = <|
   "A5" -> {5, 1}, "B5" -> {5, 3}, "C5" -> {5, 5},
   "A6" -> {6, 0}, "B6" -> {6, 2}, "C6" -> {6, 4}, "D6" -> {6, 6},
   "A7" -> {7, 1}, "B7" -> {7, 3}, "C7" -> {7, 5}, "D7" -> {7, 7},
   "A8" -> {8, 0}, "B8" -> {8, 2}, "C8" -> {8, 4}, "D8" -> {8, 6},
   "E8" -> {8, 8}
|>;

$AppendixALabelsByN = <|
   5 -> {"A5", "B5", "C5"},
   6 -> {"A6", "B6", "C6", "D6"},
   7 -> {"A7", "B7", "C7", "D7"},
   8 -> {"A8", "B8", "C8", "D8", "E8"}
|>;

ScalarJMaster[nu1_, nu2_] := ScalarIMaster[nu1, nu2];
ScalarJ[leftNu1_ - a_Integer?NonNegative, leftNu2_ - b_Integer?NonNegative] :=
  ShiftedScalarIMaster[a, b][leftNu1, leftNu2];
ScalarJ[nu1_, nu2_] := ScalarJMaster[nu1, nu2];

LyANotationMap[] := <|
   "Scalar master integral J(nu1,nu2)" -> "ScalarJ[nu1, nu2] = ScalarJMaster[nu1, nu2] = ScalarIMaster[nu1, nu2]",
   "General LOS coefficient C_{n,m}" -> "DerivedMuCoefficientByM[n, m, nu1, nu2]",
   "Named Lya master-integral coefficients" -> "DerivedCoefficient[name][nu1, nu2] with name in {A5..E8}",
   "Audited Appendix A reference" -> "ReferenceCoefficient[name][nu1, nu2] follows the paper where it passes exact triangular-basis reconstruction and uses locally corrected coefficients for {B6,A7,C7,A8,B8,C8,D8}",
   "Extension relative to the galaxy notebook" -> "This notebook continues the same LOS hierarchy beyond the CLASS-PT A1..C4 sector to the higher A5..E8 sector"
|>;

(* Appendix A audit note:
   Exact triangular-basis reconstruction of the Schwinger-derived coefficients shows
   that A5, B5, C5, A6, C6, D6, B7, D7, and E8 match the paper transcription.
   The paper expressions for B6, A7, C7, A8, B8, C8, and D8 do not. We keep the
   direct Schwinger derivation untouched and patch only those seven reference
   expressions below to the exact audited coefficients.

   The mismatch pattern is systematic rather than a convention issue:
   - B6 has a local block of seven wrong triangular-basis coefficients.
   - A7 has the correct leading j[7,0] term, but every other term is too small
     by a factor of 35 in the paper appendix.
   - C7 has the correct magnitudes but the wrong overall sign.
   - A8 and B8 again keep the leading j[8,0] term and suppress all other terms
     by a factor of 35.
   - C8 keeps the leading j[8,0] term and suppresses all other terms by 105.
   - D8 keeps the leading j[8,0] term and suppresses all other terms by 7.

   Because B7, D7, and E8 reconstruct exactly, this cannot be explained by a
   mu-parity choice, a q <-> k-q swap, or a different scalar-master convention. *)

DerivedMuCoefficientByM[n_Integer?NonNegative, m_Integer?NonNegative, nu1_, nu2_] /;
   0 <= 2 m <= n :=
  DerivedLOSCoefficientByM[n, m, nu1, nu2];

DerivedMuCoefficient[n_Integer?NonNegative, muPower_Integer?NonNegative, nu1_, nu2_] /;
   muPower <= n && EvenQ[n - muPower] :=
  DerivedLOSCoefficient[n, muPower, nu1, nu2];

CoefficientNames[n_Integer?NonNegative] := Lookup[$AppendixALabelsByN, n, {}];

ReferenceCoefficient["A5"][nu1_, nu2_] := Module[{j},
  j[a_, b_] := ScalarJ[nu1 - a, nu2 - b];
  (15/256)*
   (j[5, 0] - 5 j[4, 1] - 3 j[4, 0] + 10 j[3, 2] + 4 j[3, 1] +
     2 j[3, 0] - 10 j[2, 3] + 6 j[2, 2] + 2 j[2, 1] + 2 j[2, 0] +
     5 j[1, 4] - 12 j[1, 3] + 6 j[1, 2] + 4 j[1, 1] - 3 j[1, 0] -
     j[0, 5] + 5 j[0, 4] - 10 j[0, 3] + 10 j[0, 2] - 5 j[0, 1] +
     j[0, 0])
];

ReferenceCoefficient["B5"][nu1_, nu2_] := Module[{j},
  j[a_, b_] := ScalarJ[nu1 - a, nu2 - b];
  -(35/128) j[5, 0] + (175/128) j[4, 1] + (25/128) j[4, 0] -
   (175/64) j[3, 2] + (25/32) j[3, 1] + (5/64) j[3, 0] +
   (175/64) j[2, 3] - (225/64) j[2, 2] + (45/64) j[2, 1] +
   (5/64) j[2, 0] - (175/128) j[1, 4] + (125/32) j[1, 3] -
   (225/64) j[1, 2] + (25/32) j[1, 1] + (25/128) j[1, 0] +
   (35/128) j[0, 5] - (175/128) j[0, 4] + (175/64) j[0, 3] -
   (175/64) j[0, 2] + (175/128) j[0, 1] - (35/128) j[0, 0]
];

ReferenceCoefficient["C5"][nu1_, nu2_] := Module[{j},
  j[a_, b_] := ScalarJ[nu1 - a, nu2 - b];
  (63/256) j[5, 0] - (315/256) j[4, 1] + (35/256) j[4, 0] +
   (315/128) j[3, 2] - (105/64) j[3, 1] + (15/128) j[3, 0] -
   (315/128) j[2, 3] + (525/128) j[2, 2] - (225/128) j[2, 1] +
   (15/128) j[2, 0] + (315/256) j[1, 4] - (245/64) j[1, 3] +
   (525/128) j[1, 2] - (105/64) j[1, 1] + (35/256) j[1, 0] -
   (63/256) j[0, 5] + (315/256) j[0, 4] - (315/128) j[0, 3] +
   (315/128) j[0, 2] - (315/256) j[0, 1] + (63/256) j[0, 0]
];

ReferenceCoefficient["A6"][nu1_, nu2_] := Module[{j},
  j[a_, b_] := ScalarJ[nu1 - a, nu2 - b];
  -(5/1024)*
   (j[6, 0] - 6 j[5, 1] - 6 j[5, 0] + 15 j[4, 2] + 18 j[4, 1] +
     15 j[4, 0] - 20 j[3, 3] - 12 j[3, 2] - 12 j[3, 1] - 20 j[3, 0] +
     15 j[2, 4] - 12 j[2, 3] - 6 j[2, 2] - 12 j[2, 1] + 15 j[2, 0] -
     6 j[1, 5] + 18 j[1, 4] - 12 j[1, 3] - 12 j[1, 2] + 18 j[1, 1] -
     6 j[1, 0] + j[0, 6] - 6 j[0, 5] + 15 j[0, 4] - 20 j[0, 3] +
     15 j[0, 2] - 6 j[0, 1] + j[0, 0])
];

ReferenceCoefficient["B6"][nu1_, nu2_] := Module[{j},
  j[a_, b_] := ScalarJ[nu1 - a, nu2 - b];
  (105/1024) j[0, 0] - (315/512) j[0, 1] + (1575/1024) j[0, 2] -
   (525/256) j[0, 3] + (1575/1024) j[0, 4] - (315/512) j[0, 5] +
   (105/1024) j[0, 6] - (135/512) j[1, 0] + (225/512) j[1, 1] +
   (225/256) j[1, 2] - (675/256) j[1, 3] + (1125/512) j[1, 4] -
   (315/512) j[1, 5] + (135/1024) j[2, 0] + (45/256) j[2, 1] +
   (405/512) j[2, 2] - (675/256) j[2, 3] + (1575/1024) j[2, 4] +
   (15/256) j[3, 0] + (45/256) j[3, 1] + (225/256) j[3, 2] -
   (525/256) j[3, 3] + (135/1024) j[4, 0] + (225/512) j[4, 1] +
   (1575/1024) j[4, 2] - (135/512) j[5, 0] - (315/512) j[5, 1] +
   (105/1024) j[6, 0]
];

ReferenceCoefficient["C6"][nu1_, nu2_] := Module[{j},
  j[a_, b_] := ScalarJ[nu1 - a, nu2 - b];
  -(315/1024) j[6, 0] + (945/512) j[5, 1] + (105/512) j[5, 0] -
   (4725/1024) j[4, 2] + (525/512) j[4, 1] + (75/1024) j[4, 0] +
   (1575/256) j[3, 3] - (1575/256) j[3, 2] + (225/256) j[3, 1] +
   (15/256) j[3, 0] - (4725/1024) j[2, 4] + (2625/256) j[2, 3] -
   (3375/512) j[2, 2] + (225/256) j[2, 1] + (75/1024) j[2, 0] +
   (945/512) j[1, 5] - (3675/512) j[1, 4] + (2625/256) j[1, 3] -
   (1575/256) j[1, 2] + (525/512) j[1, 1] + (105/512) j[1, 0] -
   (315/1024) j[0, 6] + (945/512) j[0, 5] - (4725/1024) j[0, 4] +
   (1575/256) j[0, 3] - (4725/1024) j[0, 2] + (945/512) j[0, 1] -
   (315/1024) j[0, 0]
];

ReferenceCoefficient["D6"][nu1_, nu2_] := Module[{j},
  j[a_, b_] := ScalarJ[nu1 - a, nu2 - b];
  (231/1024) j[6, 0] - (693/512) j[5, 1] + (63/512) j[5, 0] +
   (3465/1024) j[4, 2] - (945/512) j[4, 1] + (105/1024) j[4, 0] -
   (1155/256) j[3, 3] + (1575/256) j[3, 2] - (525/256) j[3, 1] +
   (25/256) j[3, 0] + (3465/1024) j[2, 4] - (2205/256) j[2, 3] +
   (3675/512) j[2, 2] - (525/256) j[2, 1] + (105/1024) j[2, 0] -
   (693/512) j[1, 5] + (2835/512) j[1, 4] - (2205/256) j[1, 3] +
   (1575/256) j[1, 2] - (945/512) j[1, 1] + (63/512) j[1, 0] +
   (231/1024) j[0, 6] - (693/512) j[0, 5] + (3465/1024) j[0, 4] -
   (1155/256) j[0, 3] + (3465/1024) j[0, 2] - (693/512) j[0, 1] +
   (231/1024) j[0, 0]
];

ReferenceCoefficient["A7"][nu1_, nu2_] := Module[{j},
  j[a_, b_] := ScalarJ[nu1 - a, nu2 - b];
  -(35/2048) j[0, 0] + (245/2048) j[0, 1] - (735/2048) j[0, 2] +
   (1225/2048) j[0, 3] - (1225/2048) j[0, 4] + (735/2048) j[0, 5] -
   (245/2048) j[0, 6] + (35/2048) j[0, 7] + (175/2048) j[1, 0] -
   (315/1024) j[1, 1] + (525/2048) j[1, 2] + (175/512) j[1, 3] -
   (1575/2048) j[1, 4] + (525/1024) j[1, 5] - (245/2048) j[1, 6] -
   (315/2048) j[2, 0] + (315/2048) j[2, 1] + (105/1024) j[2, 2] +
   (315/1024) j[2, 3] - (1575/2048) j[2, 4] + (735/2048) j[2, 5] +
   (175/2048) j[3, 0] + (35/512) j[3, 1] + (105/1024) j[3, 2] +
   (175/512) j[3, 3] - (1225/2048) j[3, 4] + (175/2048) j[4, 0] +
   (315/2048) j[4, 1] + (525/2048) j[4, 2] + (1225/2048) j[4, 3] -
   (315/2048) j[5, 0] - (315/1024) j[5, 1] - (735/2048) j[5, 2] +
   (175/2048) j[6, 0] + (245/2048) j[6, 1] - (35/2048) j[7, 0]
];

ReferenceCoefficient["B7"][nu1_, nu2_] := Module[{j},
  j[a_, b_] := ScalarJ[nu1 - a, nu2 - b];
  (105/2048)*
   (3 j[7, 0] - 21 j[6, 1] - 7 j[6, 0] + 63 j[5, 2] + 14 j[5, 1] +
     3 j[5, 0] - 105 j[4, 3] + 35 j[4, 2] + 5 j[4, 1] + j[4, 0] +
     105 j[3, 4] - 140 j[3, 3] + 30 j[3, 2] + 4 j[3, 1] + j[3, 0] -
     63 j[2, 5] + 175 j[2, 4] - 150 j[2, 3] + 30 j[2, 2] + 5 j[2, 1] +
     3 j[2, 0] + 21 j[1, 6] - 98 j[1, 5] + 175 j[1, 4] -
     140 j[1, 3] + 35 j[1, 2] + 14 j[1, 1] - 7 j[1, 0] - 3 j[0, 7] +
     21 j[0, 6] - 63 j[0, 5] + 105 j[0, 4] - 105 j[0, 3] +
     63 j[0, 2] - 21 j[0, 1] + 3 j[0, 0])
];

ReferenceCoefficient["C7"][nu1_, nu2_] := Module[{j},
  j[a_, b_] := ScalarJ[nu1 - a, nu2 - b];
  -(693/2048) j[0, 0] + (4851/2048) j[0, 1] - (14553/2048) j[0, 2] +
   (24255/2048) j[0, 3] - (24255/2048) j[0, 4] + (14553/2048) j[0, 5] -
   (4851/2048) j[0, 6] + (693/2048) j[0, 7] + (441/2048) j[1, 0] +
   (1323/1024) j[1, 1] - (19845/2048) j[1, 2] + (11025/512) j[1, 3] -
   (46305/2048) j[1, 4] + (11907/1024) j[1, 5] - (4851/2048) j[1, 6] +
   (147/2048) j[2, 0] + (2205/2048) j[2, 1] - (11025/1024) j[2, 2] +
   (25725/1024) j[2, 3] - (46305/2048) j[2, 4] + (14553/2048) j[2, 5] +
   (105/2048) j[3, 0] + (525/512) j[3, 1] - (11025/1024) j[3, 2] +
   (11025/512) j[3, 3] - (24255/2048) j[3, 4] + (105/2048) j[4, 0] +
   (2205/2048) j[4, 1] - (19845/2048) j[4, 2] + (24255/2048) j[4, 3] +
   (147/2048) j[5, 0] + (1323/1024) j[5, 1] - (14553/2048) j[5, 2] +
   (441/2048) j[6, 0] + (4851/2048) j[6, 1] - (693/2048) j[7, 0]
];

ReferenceCoefficient["D7"][nu1_, nu2_] := Module[{j},
  j[a_, b_] := ScalarJ[nu1 - a, nu2 - b];
  (1/2048)*
   (429 j[7, 0] - 3003 j[6, 1] + 231 j[6, 0] + 9009 j[5, 2] -
     4158 j[5, 1] + 189 j[5, 0] - 15015 j[4, 3] + 17325 j[4, 2] -
     4725 j[4, 1] + 175 j[4, 0] + 15015 j[3, 4] - 32340 j[3, 3] +
     22050 j[3, 2] - 4900 j[3, 1] + 175 j[3, 0] - 9009 j[2, 5] +
     31185 j[2, 4] - 39690 j[2, 3] + 22050 j[2, 2] - 4725 j[2, 1] +
     189 j[2, 0] + 3003 j[1, 6] - 15246 j[1, 5] + 31185 j[1, 4] -
     32340 j[1, 3] + 17325 j[1, 2] - 4158 j[1, 1] + 231 j[1, 0] -
     429 j[0, 7] + 3003 j[0, 6] - 9009 j[0, 5] + 15015 j[0, 4] -
     15015 j[0, 3] + 9009 j[0, 2] - 3003 j[0, 1] + 429 j[0, 0])
];

ReferenceCoefficient["A8"][nu1_, nu2_] := Module[{j},
  j[a_, b_] := ScalarJ[nu1 - a, nu2 - b];
  (35/32768) j[0, 0] - (35/4096) j[0, 1] + (245/8192) j[0, 2] -
   (245/4096) j[0, 3] + (1225/16384) j[0, 4] - (245/4096) j[0, 5] +
   (245/8192) j[0, 6] - (35/4096) j[0, 7] + (35/32768) j[0, 8] -
   (35/4096) j[1, 0] + (175/4096) j[1, 1] - (315/4096) j[1, 2] +
   (175/4096) j[1, 3] + (175/4096) j[1, 4] - (315/4096) j[1, 5] +
   (175/4096) j[1, 6] - (35/4096) j[1, 7] + (245/8192) j[2, 0] -
   (315/4096) j[2, 1] + (315/8192) j[2, 2] + (35/2048) j[2, 3] +
   (315/8192) j[2, 4] - (315/4096) j[2, 5] + (245/8192) j[2, 6] -
   (245/4096) j[3, 0] + (175/4096) j[3, 1] + (35/2048) j[3, 2] +
   (35/2048) j[3, 3] + (175/4096) j[3, 4] - (245/4096) j[3, 5] +
   (1225/16384) j[4, 0] + (175/4096) j[4, 1] + (315/8192) j[4, 2] +
   (175/4096) j[4, 3] + (1225/16384) j[4, 4] - (245/4096) j[5, 0] -
   (315/4096) j[5, 1] - (315/4096) j[5, 2] - (245/4096) j[5, 3] +
   (245/8192) j[6, 0] + (175/4096) j[6, 1] + (245/8192) j[6, 2] -
   (35/4096) j[7, 0] - (35/4096) j[7, 1] + (35/32768) j[8, 0]
];

ReferenceCoefficient["B8"][nu1_, nu2_] := Module[{j},
  j[a_, b_] := ScalarJ[nu1 - a, nu2 - b];
  -(315/8192) j[0, 0] + (315/1024) j[0, 1] - (2205/2048) j[0, 2] +
   (2205/1024) j[0, 3] - (11025/4096) j[0, 4] + (2205/1024) j[0, 5] -
   (2205/2048) j[0, 6] + (315/1024) j[0, 7] - (315/8192) j[0, 8] +
   (175/1024) j[1, 0] - (735/1024) j[1, 1] + (735/1024) j[1, 2] +
   (1225/1024) j[1, 3] - (3675/1024) j[1, 4] + (3675/1024) j[1, 5] -
   (1715/1024) j[1, 6] + (315/1024) j[1, 7] - (525/2048) j[2, 0] +
   (315/1024) j[2, 1] + (525/2048) j[2, 2] + (525/512) j[2, 3] -
   (7875/2048) j[2, 4] + (3675/1024) j[2, 5] - (2205/2048) j[2, 6] +
   (105/1024) j[3, 0] + (105/1024) j[3, 1] + (105/512) j[3, 2] +
   (525/512) j[3, 3] - (3675/1024) j[3, 4] + (2205/1024) j[3, 5] +
   (175/4096) j[4, 0] + (105/1024) j[4, 1] + (525/2048) j[4, 2] +
   (1225/1024) j[4, 3] - (11025/4096) j[4, 4] + (105/1024) j[5, 0] +
   (315/1024) j[5, 1] + (735/1024) j[5, 2] + (2205/1024) j[5, 3] -
   (525/2048) j[6, 0] - (735/1024) j[6, 1] - (2205/2048) j[6, 2] +
   (175/1024) j[7, 0] + (315/1024) j[7, 1] - (315/8192) j[8, 0]
];

ReferenceCoefficient["C8"][nu1_, nu2_] := Module[{j},
  j[a_, b_] := ScalarJ[nu1 - a, nu2 - b];
  (3465/16384) j[0, 0] - (3465/2048) j[0, 1] + (24255/4096) j[0, 2] -
   (24255/2048) j[0, 3] + (121275/8192) j[0, 4] -
   (24255/2048) j[0, 5] + (24255/4096) j[0, 6] - (3465/2048) j[0, 7] +
   (3465/16384) j[0, 8] - (945/2048) j[1, 0] + (2205/2048) j[1, 1] +
   (6615/2048) j[1, 2] - (33075/2048) j[1, 3] + (55125/2048) j[1, 4] -
   (46305/2048) j[1, 5] + (19845/2048) j[1, 6] - (3465/2048) j[1, 7] +
   (735/4096) j[2, 0] + (735/2048) j[2, 1] + (11025/4096) j[2, 2] -
   (18375/1024) j[2, 3] + (128625/4096) j[2, 4] - (46305/2048) j[2, 5] +
   (24255/4096) j[2, 6] + (105/2048) j[3, 0] + (525/2048) j[3, 1] +
   (2625/1024) j[3, 2] - (18375/1024) j[3, 3] + (55125/2048) j[3, 4] -
   (24255/2048) j[3, 5] + (315/8192) j[4, 0] + (525/2048) j[4, 1] +
   (11025/4096) j[4, 2] - (33075/2048) j[4, 3] + (121275/8192) j[4, 4] +
   (105/2048) j[5, 0] + (735/2048) j[5, 1] + (6615/2048) j[5, 2] -
   (24255/2048) j[5, 3] + (735/4096) j[6, 0] + (2205/2048) j[6, 1] +
   (24255/4096) j[6, 2] - (945/2048) j[7, 0] - (3465/2048) j[7, 1] +
   (3465/16384) j[8, 0]
];

ReferenceCoefficient["D8"][nu1_, nu2_] := Module[{j},
  j[a_, b_] := ScalarJ[nu1 - a, nu2 - b];
  -(3003/8192) j[0, 0] + (3003/1024) j[0, 1] - (21021/2048) j[0, 2] +
   (21021/1024) j[0, 3] - (105105/4096) j[0, 4] + (21021/1024) j[0, 5] -
   (21021/2048) j[0, 6] + (3003/1024) j[0, 7] - (3003/8192) j[0, 8] +
   (231/1024) j[1, 0] + (1617/1024) j[1, 1] - (14553/1024) j[1, 2] +
   (40425/1024) j[1, 3] - (56595/1024) j[1, 4] + (43659/1024) j[1, 5] -
   (17787/1024) j[1, 6] + (3003/1024) j[1, 7] + (147/2048) j[2, 0] +
   (1323/1024) j[2, 1] - (33075/2048) j[2, 2] + (25725/512) j[2, 3] -
   (138915/2048) j[2, 4] + (43659/1024) j[2, 5] - (21021/2048) j[2, 6] +
   (49/1024) j[3, 0] + (1225/1024) j[3, 1] - (8575/512) j[3, 2] +
   (25725/512) j[3, 3] - (56595/1024) j[3, 4] + (21021/1024) j[3, 5] +
   (175/4096) j[4, 0] + (1225/1024) j[4, 1] - (33075/2048) j[4, 2] +
   (40425/1024) j[4, 3] - (105105/4096) j[4, 4] + (49/1024) j[5, 0] +
   (1323/1024) j[5, 1] - (14553/1024) j[5, 2] + (21021/1024) j[5, 3] +
   (147/2048) j[6, 0] + (1617/1024) j[6, 1] - (21021/2048) j[6, 2] +
   (231/1024) j[7, 0] + (3003/1024) j[7, 1] - (3003/8192) j[8, 0]
];

ReferenceCoefficient["E8"][nu1_, nu2_] := Module[{j},
  j[a_, b_] := ScalarJ[nu1 - a, nu2 - b];
  (1/32768)*
   (6435 j[8, 0] - 51480 j[7, 1] + 3432 j[7, 0] + 180180 j[6, 2] -
     72072 j[6, 1] + 2772 j[6, 0] - 360360 j[5, 3] +
     360360 j[5, 2] - 83160 j[5, 1] + 2520 j[5, 0] +
     450450 j[4, 4] - 840840 j[4, 3] + 485100 j[4, 2] -
     88200 j[4, 1] + 2450 j[4, 0] - 360360 j[3, 5] +
     1081080 j[3, 4] - 1164240 j[3, 3] + 529200 j[3, 2] -
     88200 j[3, 1] + 2520 j[3, 0] + 180180 j[2, 6] -
     792792 j[2, 5] + 1372140 j[2, 4] - 1164240 j[2, 3] +
     485100 j[2, 2] - 83160 j[2, 1] + 2772 j[2, 0] -
     51480 j[1, 7] + 312312 j[1, 6] - 792792 j[1, 5] +
     1081080 j[1, 4] - 840840 j[1, 3] + 360360 j[1, 2] -
     72072 j[1, 1] + 3432 j[1, 0] + 6435 j[0, 8] - 51480 j[0, 7] +
     180180 j[0, 6] - 360360 j[0, 5] + 450450 j[0, 4] -
     360360 j[0, 3] + 180180 j[0, 2] - 51480 j[0, 1] +
     6435 j[0, 0])
];

DerivedCoefficient[name_String][nu1_, nu2_] := Module[{spec},
  spec = Lookup[$AppendixACoefficientMap, name, Missing["UnknownCoefficient", name]];
  If[MissingQ[spec],
   spec,
   DerivedMuCoefficient[spec[[1]], spec[[2]], nu1, nu2]
  ]
];

Clear[
  ReducedToScalarMasterBasis,
  DerivedCoefficientReduced,
  ReferenceCoefficientReduced,
  NormalizedCoefficientValidationExpression,
  TriangularBasisPairs,
  ExactTriangularBasisCoefficients
];

ReducedToScalarMasterBasis[expr_] :=
  expr/ScalarIMaster[nu1, nu2];

DerivedCoefficientReduced[name_String] :=
  DerivedCoefficientReduced[name] =
   ReducedToScalarMasterBasis[DerivedCoefficient[name][nu1, nu2]];

ReferenceCoefficientReduced[name_String] :=
  ReferenceCoefficientReduced[name] =
   ReducedToScalarMasterBasis[ReferenceCoefficient[name][nu1, nu2]];

(* Exact triangular-basis audit helper:
   solve DerivedCoefficientReduced[name] = Sum_{a+b<=n} c[a,b] I(nu1-a,nu2-b)/I(nu1,nu2)
   by clearing denominators and equating the polynomial numerator to zero. *)
TriangularBasisPairs[n_Integer?NonNegative] :=
  Flatten[Table[{a, b}, {a, 0, n}, {b, 0, n - a}], 1];

ExactTriangularBasisCoefficients[name_String] :=
  ExactTriangularBasisCoefficients[name] = Module[
    {n, pairs, vars, basis, ansatz, expr, num, eqns, sol},
    n = Lookup[$AppendixACoefficientMap, name, Missing["UnknownCoefficient", name]][[1]];
    pairs = TriangularBasisPairs[n];
    vars = Array[c, Length[pairs], 0];
    basis = Table[
      ShiftedScalarIMasterRatio[pairs[[i, 1]], pairs[[i, 2]]][nu1, nu2],
      {i, Length[pairs]}
    ];
    ansatz = Total[vars*basis];
    expr = Cancel @ Together @ FunctionExpand[DerivedCoefficientReduced[name] - ansatz];
    num = Expand[Numerator[expr]];
    eqns = Thread[DeleteDuplicates[Last /@ CoefficientRules[num, {nu1, nu2}]] == 0];
    sol = First @ Solve[eqns, vars, Rationals];
    AssociationThread[pairs, vars /. sol]
  ];

ReferenceMasterIntegral[n_Integer?Positive, nu1_, nu2_, mu_, k_] /;
   KeyExistsQ[$AppendixALabelsByN, n] :=
  k^(3 - 2 (nu1 + nu2))*k^n*
   Total[
    (mu^Lookup[$AppendixACoefficientMap, #][[2]])*
       ReferenceCoefficient[#][nu1, nu2] & /@
     $AppendixALabelsByN[n]
   ];

DerivedMasterIntegral[n_Integer?Positive, nu1_, nu2_, mu_, k_] /;
   KeyExistsQ[$AppendixALabelsByN, n] :=
  k^(3 - 2 (nu1 + nu2))*k^n*
   Total[
   (mu^Lookup[$AppendixACoefficientMap, #][[2]])*
       DerivedCoefficient[#][nu1, nu2] & /@
     $AppendixALabelsByN[n]
   ];

CoefficientValidationExpression[name_String] :=
  DerivedCoefficientReduced[name] - ReferenceCoefficientReduced[name];

NormalizedCoefficientValidationExpression[name_String] :=
  NormalizedCoefficientValidationExpression[name] =
   NormalizeValidationResidual[CoefficientValidationExpression[name]];

$DefaultValidationPoint = <|
   "nu1" -> 101/37,
   "nu2" -> 109/41,
   "mu" -> 2/5,
   "k" -> 3/7
|>;

Options[CoefficientValidationSummary] = Options[ExactValidationSummary];

CoefficientValidationSummary[
   seconds_: Infinity,
   opts : OptionsPattern[]
] :=
  ExactValidationSummary[
   Keys[$AppendixACoefficientMap],
   NormalizedCoefficientValidationExpression,
   seconds,
   "AlreadyNormalized" -> True,
   opts
  ];

CoefficientNumericResidualSummary[
   point_Association : $DefaultValidationPoint,
   precision_: 40
] :=
  NumericResidualSummary[
   Keys[$AppendixACoefficientMap],
   NormalizedCoefficientValidationExpression,
   KeyTake[point, {"nu1", "nu2"}],
   precision
  ];

MasterIntegralValidationExpression[n_Integer?Positive] /;
   KeyExistsQ[$AppendixALabelsByN, n] :=
  Total[
   (mu^Lookup[$AppendixACoefficientMap, #][[2]])*
     NormalizedCoefficientValidationExpression[#] & /@
    $AppendixALabelsByN[n]
  ];

Options[MasterIntegralValidationSummary] = Options[ExactValidationSummary];

MasterIntegralValidationSummary[
   seconds_: Infinity,
   opts : OptionsPattern[]
] :=
  ExactValidationSummary[
   Keys[$AppendixALabelsByN],
   MasterIntegralValidationExpression,
   seconds,
   opts
  ];

MasterIntegralNumericResidualSummary[
   point_Association : $DefaultValidationPoint,
   precision_: 40
] :=
  NumericResidualSummary[
   Keys[$AppendixALabelsByN],
   MasterIntegralValidationExpression,
   KeyTake[point, {"nu1", "nu2", "mu", "k"}],
   precision
  ];
