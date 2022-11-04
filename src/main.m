clc; clear; close all;

%% Load Parameters and Image
[calibration_var, calibration_data] = ...
readvars('../KITTI-Dataset/2011_09_26_drive_0048/calib_cam_to_cam.txt');

K_00 = strsplit(string(calibration_data(3)),' ');
K_00 = str2double(reshape(K_00,3,3)');
D_00 = strsplit(string(calibration_data(4)),' ');
D_00 = str2double(D_00);

K_01 = strsplit(string(calibration_data(11)),' ');
K_01 = str2double(reshape(K_01,3,3)');
D_01 = strsplit(string(calibration_data(12)),' ');
D_01 = str2double(D_01);

K_02 = strsplit(string(calibration_data(19)),' ');
K_02 = str2double(reshape(K_02,3,3)');
D_02 = strsplit(string(calibration_data(20)),' ');
D_02 = str2double(D_02);

K_03 = strsplit(string(calibration_data(27)),' ');
K_03 = str2double(reshape(K_03,3,3)');
D_03 = strsplit(string(calibration_data(28)),' ');
D_03 = str2double(D_03);

cam2_folder = '../KITTI-Dataset/2011_09_26_drive_0048/unsync_unrect/image_02/data/'; 
cam3_folder = '../KITTI-Dataset/2011_09_26_drive_0048/unsync_unrect/image_03/data/'; 

list = dir(cam2_folder);
img_name = [];
for i = 3:30
    img_name = [img_name; list(i).name]; 
end

Image1 = imread([cam2_folder, img_name(1, :)]);
Image2 = imread([cam3_folder, img_name(1, :)]);

undistortImage1 = undistort_image(Image1, K_02, D_02, 1);
undistortImage2 = undistort_image(Image2, K_03, D_03, 1);

[m1_concat, m2_concat] = get_correspondence_points(undistortImage1, undistortImage2);

for i = 2:28
    Image1 = imread([cam2_folder, img_name(i, :)]);
    Image2 = imread([cam3_folder, img_name(i, :)]);

    undistortImage1 = undistort_image(Image1, K_00, D_00, 1);
    undistortImage2 = undistort_image(Image2, K_01, D_01, 1);

    [m1, m2] = get_correspondence_points(undistortImage1,undistortImage2);
 
    m1_concat = vertcat(m1_concat, m1);
    m2_concat = vertcat(m2_concat, m2);
end



% Image1 = imread('../KITTI-Dataset/2011_09_26_drive_0048/calibration/image_02/data/0000000000.png');
% Image2 = imread('../KITTI-Dataset/2011_09_26_drive_0048/calibration/image_03/data/0000000000.png');

%% Undistortion
% undistortImage1 = undistort_image(Image1, K_00, D_00, 1);
% undistortImage2 = undistort_image(Image2, K_01, D_01, 1);

%% Get Correspondence Points
% [H,num_inliers,residual] = get_correspondence_points(Image1,Image2);
% [m1, m2] = get_correspondence_points(undistortImage1,undistortImage2);

%% Get F and E matrix
[F, E] = get_F_and_E_matrix(undistortImage1, undistortImage2, m1_concat, m2_concat, K_02, K_03);

[R,t] = decomp_E_matrix(E);

R_rect = estimate_Rrect(t);
% estimateStereoRectification
% estimateUncalibratedRectification


[t1, t2]=estimateStereoRectification(F,m1_concat,m2_concat,[size(undistortImage1,1),size(undistortImage1,2)]);
tform1 = projtform2d(t1);
tform2 = projtform2d(t2);
[I1Rect, I2Rect] = rectifyStereoImages(undistortImage1,undistortImage2,tform1,tform2);
% showMatchedFeatures(undistortImage1, undistortImage2,m1_concat,m2_concat,'montage');


% [J1,J2] = rectifyStereoImages(undistortImage1,undistortImage2,R_rect,R_rect)
% tform1 = projtform2d(K_02*inv(R)*inv(K_02));
% tform2 = projtform2d(K_03*inv(R*R_rect)*inv(K_03));
% [I1Rect, I2Rect] = rectifyStereoImages(undistortImage1,undistortImage2,tform1,tform2);
% rectImage1 = rectify_image(undistortImage1, K_02, R_rect);
% rectImage2 = rectify_image(undistortImage2, K_03, R*R_rect);
% figure; imshow([I1Rect, I2Rect]);
% figure; imshow([undistortImage1, undistortImage2]);
%% Get Disparity Map
disparityImage1 = get_disparity_map(I1Rect, I2Rect);
disparityImage2 = disparitymap(I1Rect, I2Rect);
% feature_width = 16;
% [x1, y1, confidence1, scale1] = get_interest_points_scaling(Iu_0, feature_width);
% [x2, y2, confidence2, scaimshow(I_disp);le2] = get_interest_points_scaling(Iu_1, feature_width);
% 
% 
% 
% [image1_features] = get_features(Iu_0, x1, y1, feature_width);
% [image2_features] = get_features(Iu_1, x2, y2, feature_width);
% 
% [matches, confidences] = match_features(image1_features, image2_features);
% 
% %% Visualization
% num_pts_to_visualize = size(matches,1);
% 
% show_correspondence(Iu_0, Iu_1, x1(matches(1:num_pts_to_visualize,1)), ...
%                                     y1(matches(1:num_pts_to_visualize,1)), ...
%                                     x2(matches(1:num_pts_to_visualize,2)), ...
%                                     y2(matches(1:num_pts_to_visualize,2)));