close all;
clearvars -except plateNet;
[filename,pathname] = uigetfile('*.jpg;*.png;*.bmp;*.jpeg','choose a image');

img = imread([pathname filesep filename]);
figure(1);imshow(img);

dw = colorLocate(img);
figure(2);imshow(dw);
PIN=stringsplit(dw);
plotPIN(4,PIN);
% 如果 颜色定位失败，则去使用边缘检测定位
if(hasEmpty(PIN))
    dw = location(img);
    figure(3);imshow(dw);
    PIN=stringsplit(dw);    
end


% 如果边缘检测失败，则通知定位失败
if(hasEmpty(PIN))
    disp('车牌定位失败');
    return;
end

plotPIN(5,PIN);

plate = classifyPlateText(plateNet,PIN);
disp(plate);



function empty=hasEmpty(PIN)
empty = false;
pSize = 7;

if(size(PIN,2) ~= pSize)
    empty = true;
    return;
end
for i =1:pSize
    if(isempty(PIN{i}))
        empty = true;
        break;
    end
end

end


function plate = classifyPlateText(plateNet,PIN)
pSize = 7;
plate = '';
for i=1:pSize
    p = PIN{i};
    
    if(size(p,3) ~= 3)
        p = repmat(p,[1 1 3]);
    end
    
    p = imresize(p,[227 227]);
    figure(4);subplot(1,pSize,i);imshow(p);
    pred = classify(plateNet,p);
    plate = strcat(plate ,{' '}, char(pred));
end
end

function plotPIN(fi,PIN)
pSize = 7;
for i=1:pSize
    p = PIN{i};
    
    if(isempty(p))
        continue;
    end
    
    if(size(p,3) ~= 3)
        p = repmat(p,[1 1 3]);
    end
    
    p = imresize(p,[227 227]);
    figure(fi);subplot(1,pSize,i);imshow(p);
end
end