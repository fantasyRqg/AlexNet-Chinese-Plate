clear;close all;

i1 = imread('timg.jpeg');
i2 = imread('timg1.jpeg');
i3 = imread('timg3.jpeg');
i4 = imread('carPlates/京A89106.jpg');
% 
% showMser(1,i1);
% showMser(2,i2);
% 
% 
% function showMser(figureId,img)
% grayImg = rgb2gray(img);
% regs = detectMSERFeatures(grayImg);
% figure(figureId);imshow(img); hold on;
% plot(regs);
% end
% 
% 
dw = location(i2);
figure(2);imshow(dw);
PIN=stringsplit(dw);
pSize = size(PIN,1);
for i =1:pSize
    figure(1);subplot(1,pSize,i);
    imshow(PIN{i});
end