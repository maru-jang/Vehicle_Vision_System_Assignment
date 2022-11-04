function R_rect=estimate_Rrect(t)

e1 = t/norm(t);
e2 = cross(e1,[0 0 -1]');
e3 = cross(e1, e2);
R_rect = [e1'; e2'; e3'];
R_rect_02 = [9.998817e-01 1.511453e-02 -2.841595e-03; -1.511724e-02 9.998853e-01 -9.338510e-04; 2.827154e-03 9.766976e-04 9.999955e-01];
R_rect_03 = [9.998321e-01 -7.193136e-03 1.685599e-02; 7.232804e-03 9.999712e-01 -2.293585e-03; -1.683901e-02 2.415116e-03 9.998553e-01];

end