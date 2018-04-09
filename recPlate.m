
% recognizePlate(plateNet)

% function plate = recognizePlate(plateNet)
    [filename,pathname] = uigetfile('*.jpg;*.png;*.bmp;*.jpeg','choose a image');
    
    img = imread([pathname filesep filename]);
    dw = location(img);
%     figure(2);imshow(dw);
    PIN=stringsplit(dw);
    pSize = size(PIN,1);
    plate = '';
    for i =1:pSize
        p = PIN{i};
        
        if(size(p,3) ~= 3)
            p = repmat(p,[1 1 3]);
        end
        
        p = imresize(p,[227 227]);
        figure(1);subplot(1,pSize,i);imshow(p);
        pred = classify(plateNet,p);
        plate = strcat(plate ,{' '}, char(pred));
    end
    plate
% end