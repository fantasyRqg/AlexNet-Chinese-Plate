function [PIN]=stringsplit(dw)
%字符分割方法，利用垂直投影法
if ndims(dw) == 3%如果为rgb图像则转换为灰度图像
    I1=rgb2gray(dw);
else
    I1=dw;
end
g_max=double(max(max(I1)));
g_min=double(min(min(I1)));
t=round(g_max-(g_max-g_min)/3);%阈值
[m,n]=size(I1);
I2=imbinarize(I1,t/256);%二值化
% % 腐蚀噪声
% I2= imresize(I2,6);
% 
% % se = strel('square',4);
% % 
% % II2 = imclose(II2,se);
% 
% se = strel('square',2);
% I2 = imerode(I2,se);
% 
% 
% I2 = imresize(I2,1/6);

% figure(6),imshow(I2);title('gray img');

[y1,x1,z1]=size(I2);
I3=I2;
XX1=zeros(1,x1);%统计每一列像素值为1的个数
for jj=1:x1
    for ii=1:y1
        if(I3(ii,jj,1)==1)
            XX1(1,jj)=XX1(1,jj)+1;
        end
    end
end
% 填充低谷
colMax = max(XX1);
colMin = min(XX1);
minWhitePixl = colMin + (colMax - colMin) * 0.1;
minWhitePixl = round(minWhitePixl);


flateWidth = 1;

for jj=flateWidth + 1:size(XX1,2)-flateWidth - 1
    if(XX1(1,jj) < minWhitePixl)
        flateSum = 0;
        for ll=jj - flateWidth:jj+flateWidth
            if(XX1(1,ll) >= minWhitePixl)
                flateSum = minWhitePixl + round(XX1(1,ll)*0.05) + flateSum;
            end
        end
        
        XX1(1,jj) = XX1(1,jj) + round(flateSum / (flateWidth * 2));
    end
end

% figure(7),plot(1:x1,XX1);
Px0=1;
Px1=1;


minWidth = n/20;

PIN = cell(1,7);
i = 1;
while(Px0 < n && Px1 < n && i <=7)%分割字符
    l_Px0 = Px0;
    while((Px0<x1)&&(XX1(1,Px0)<minWhitePixl) )%求字符的左边界
        Px0=Px0+1;
    end
    Px1=Px0;
    while(((Px1<x1)&&(XX1(1,Px1)>=minWhitePixl))||((Px1-Px0)< minWidth ) )%求字符右边界
        Px1=Px1+1;
    end
    
    if Px1 - (l_Px0 - Px0) / 2 > minWidth
        Px0 = clamp(Px0,1,n);
        Px1 = clamp(Px1,Px0,n);
        Z=I1(:,Px0:Px1,:);
        PIN{i} = Z;
        
        %         figure(3);
        %         subplot(1,7,i);
        %         imshow(Z);
        
        i = i + 1;
    end
    Px0=Px1;
end