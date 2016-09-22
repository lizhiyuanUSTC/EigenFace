clear all
s = dir('train');
s(1:2) = [];
d = 128 * 128;    % 每张图片像素总数
n = length(s);    % 训练集内照片总数
img = zeros(d, n);
for k = 1:n
    path = strcat('train/', s(k).name);
    f = imread(path);
    if(numel(size(f)) == 3)
       f = rgb2gray(f); 
    end
    f = imresize(f, [128, 128]);
    f = reshape(f, [d, 1]);
    f = im2double(f);
    img(:, k) = f;
end

mean_img = mean(img, 2);
for k = 1:n
   img(:, k) = img(:, k) - mean_img; 
end
[w, a, explained] = pcacov(img' * img);
w = img * w;
face_num = 0;   % face_num用于存储需要特征脸的数目,协方差>=95% 
per = 0;
while(per<95)
    face_num = face_num + 1;
    per = per + explained(face_num);
end

w = w(:, 1:face_num);
for k = 1:face_num
   w(:, k) = w(:, k)/norm(w(:, k)); 
end

eigenface = zeros(face_num, n);   % eigenface用于储存在人脸图像在特征空间的表达
for k = 1:n
    eigenface(:, k) = w' * img(:, k);
end

[file, path] = uigetfile({'*.*', 'All Files'}, '选择您要识别的图片：');
path = strcat(path,file);
f = imread(path);
subplot(1, 2, 1);
imshow(f);
title('要识别的图片');
if(numel(size(f)) == 3)
    f = rgb2gray(f); 
end
f = imresize(f, [128, 128]);
f = reshape(f, [d, 1]);
f = im2double(f);
f = f - mean_img;
f = w' * f;  % 将要识别的图片投影到特征空间上

% 在数据库中找寻与识别图片最相近的图片
distance = Inf;
best_k = 0;
for k = 1:n
    d = norm(f - eigenface(:, k));
    if(distance > d)
        best_k = k;
        distance = d;
    end
end

path = strcat('train/', s(best_k).name);
subplot(1, 2, 2);
imshow(path);
title('数据库中最接近的图片');


