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
% figure,imshow(I2);

[y1,x1,z1]=size(I2);
I3=double(I2);
XX1=zeros(1,x1);%统计每一列像素值为1的个数
for jj=1:x1
    for ii=1:y1
        if(I3(ii,jj,1)==1)
            XX1(1,jj)=XX1(1,jj)+1;
        end
    end
end
% figure(1),plot(1:x1,XX1);
Px0=1;
Px1=1;

minWidth = n / 14;

PIN = cell(7);
i = 1;
while(Px0 < n && Px1 < n && i <=7)%分割字符
    while((XX1(1,Px0)<3)&&(Px0<x1))%求字符的左边界
        Px0=Px0+1;
    end
    Px1=Px0;
    while(((XX1(1,Px1)>=3)&&(Px1<x1))||((Px1-Px0)<10))%求字符右边界
        Px1=Px1+1;
    end
    
    if Px1 - Px0 > minWidth
        Z=dw(:,Px0:Px1,:);
        PIN{i} = Z;
        
%         figure(3);
%         subplot(1,7,i);
%         imshow(Z);

        i = i + 1;
    end
    
%     switch strcat('Z',num2str(i))
%     case 'Z1'
%     PIN0=Z;
%     case 'Z2'
%     PIN1=Z;
%     case 'Z3'
%     PIN2=Z;
%     case 'Z4'
%     PIN3=Z;
%     case 'Z5'
%     PIN4=Z;
%     case 'Z6'
%     PIN5=Z;
%     otherwise
%     PIN6=Z;
%     end
%     figure(3);
%     subplot(1,7,i);
%     imshow(Z);
    Px0=Px1;
end