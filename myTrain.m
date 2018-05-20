clear; close all;

net = alexnet;
opts = trainingOptions('sgdm','InitialLearnRate',0.001,...
    'Plots','training-progress');
layers = net.Layers;

layers(end - 2) = fullyConnectedLayer(65);
layers(end) = classificationLayer;

letDs = imageDatastore('ann','IncludeSubfolders',true,'LabelSource','foldernames','ReadFcn',@readImg);

[trainDs,testDs] = splitEachLabel(letDs,0.9,'randomized');
[plateNet,info] = trainNetwork(trainDs,layers,opts);

save PlateAlexNet.mat plateNet;

function img = readImg(file)
img = imread(file);
if(size(img,3) == 1)
    img = repmat(img,[1 1 3]);
end

left = 1;
right = size(img,1);

% find left
for ix=1:size(img,2)
    plc=0;
    for iy = 1:size(img,1)
        if(img(iy,ix,1)+img(iy,ix,2)+img(iy,ix,3) >30)
            plc=plc +1;
        end
    end
    
    if(plc >2)
        left = ix;
        break;
    end
end

% find right
for ix=size(img,2):-1:1
    prc=0;
    for iy = size(img,1):-1:1
        if(img(iy,ix,1)+img(iy,ix,2)+img(iy,ix,3) >30)
            prc = prc +1;
        end
    end
    
    if(prc >2)
        right = ix;
        break;
    end
end

w = right - left;
h = size(img,2);
img = imcrop(img,[left 1 w h]);

img = imresize(img,[227 227]);
end