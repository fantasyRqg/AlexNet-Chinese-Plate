%程序功能：实现车牌自动定位
%作者：重庆大学 田建国 QQ:363966533
%编写时间:2007.04.10
%修改时间:2007.07.06;修改内容:增加合并区域操作，第88行开始
clear;clc;close all
[filename,pathname] = uigetfile('*.jpg;*.png;*.bmp;*.jpeg','choose a image');
I=imread([pathname filesep filename]);%调用自编函数读取图像，并转化为灰度图象；
I = rgb2gray(I);
tic   %计时开始
[height,width]=size(I);
%预处理
I_edge=zeros(height,width);% 创建height*width的矩阵
for i=1:width-1            % 对每一列开始遍历
    I_edge(:,i)=abs(I(:,i+1)-I(:,i));% 每列的值赋为原图像中左右两列相减的绝对值(即梯度)
end
% 归一化处理(0～255)
I_edge=(255/(max(max(I_edge))-min(min(I_edge))))*(I_edge-min(min(I_edge)));
figure
imshow(I_edge);title('归一化处理')
[I_edge,y1]=select(I_edge,height,width);   %%%%%%调用select函数
figure
imshow(I_edge);title('选择')
BW2 = I_edge;%
%%%%%%%%%%%%%%%%一些形态学处理
SE=strel('rectangle',[10,10]);
IM2=imerode(BW2,SE);%腐蚀
figure
imshow(IM2);title('腐蚀');
IM2=bwareaopen(IM2,20);%开运算，消除细小物体
figure
imshow(IM2);title('开运算');
IM3=imdilate(IM2,SE);%膨胀
figure
imshow(IM2);title('膨胀');
%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%投影以粗略估计车牌位置
p_h=projection(double(IM3),'h');                %调用projection函数
if(p_h(1)>0)
    p_h=[0,p_h];
end
p_v=projection(double(IM3),'v');                %调用projection函数
if(p_v(1)>0)
    p_v=[0,p_v];
end
%%%%%%
p_h=double((p_h>5));
p_h=find(((p_h(1:end-1)-p_h(2:end))~=0));
len_h=length(p_h)/2;
%%%%%
p_v=double((p_v>5));
p_v=find(((p_v(1:end-1)-p_v(2:end))~=0));
len_v=length(p_v)/2;
%%%%%%%%%%%

%%%%%%%%%%%%%%%%%粗略计算车牌候选区
k=1;
for i=1:len_h
    for j=1:len_v
        s=IM3(p_h(2*i-1):p_h(2*i),p_v(2*j-1):p_v(2*j));
        if(mean(mean(s))>0.1)
            p{k}=[p_h(2*i-1),p_h(2*i)+1,p_v(2*j-1),p_v(2*j)+1];
            k=k+1;
        end
    end
end
k=k-1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%进一步缩小车牌候选区
for i=1:k
   edge_IM3=double(edge(double(IM3(p{i}(1):p{i}(2),p{i}(3):p{i}(4))),'canny'));
   [x,y]=find(edge_IM3==1);
   p{i}=[p{i}(1)+min(x),p{i}(2)-(p{i}(2)-p{i}(1)+1-max(x)),...
         p{i}(3)+min(y),p{i}(4)-(p{i}(4)-p{i}(3)+1-max(y))];
   p_center{i}=[fix((p{i}(1)+p{i}(2))/2),fix((p{i}(3)+p{i}(4))/2)];
   p_ratio(i)=(p{i}(4)-p{i}(3))/(p{i}(2)-p{i}(1));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%对上面参数和变量的说明：p为一胞元，用于存放每个图像块的左上和右下两个点的坐标；
%存放格式为：p{k}=[x1,x2,y1,y2]；x1,x2分别为行坐标，y1,y2为列坐标
%p_center为一胞元,用于存放每个图像块的中心坐标,p_center{k}=[x,y];x,y分别为行,列坐标
%p_ratio为一矩阵，用来存放图像块的长宽比例
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%合并临近区域%%%%%%%
%如果有多个区域则执行合并
if k>1
    n=0;
    ncount=zeros(1,k);
    for i=1:k-1
        %%%需要调整if条件中的比例
        %%%需要调整
        %检查是否满足合并条件
        if(abs(p{i}(1)+p{i}(2)-p{i+1}(1)-p{i+1}(2))<=height/30&&abs(p{i+1}(3)-p{i}(4))<=width/15)
            p{i+1}(1)=min(p{i}(1),p{i+1}(1));
            p{i+1}(2)=max(p{i}(2),p{i+1}(2));
            p{i+1}(3)=min(p{i}(3),p{i+1}(3));
            p{i+1}(4)=max(p{i}(4),p{i+1}(4));  %向后合并
            n=n+1;
            ncount(n)=i+1;
        end
    end
    %如果有合并，求出合并后最终区域
    if(n>0)
        d_ncount=ncount(2:n+1)-ncount(1:n);%避免重复记录临近的多个区域。
        index=find(d_ncount~=1);
        m=length(index);
        for i=1:m
            pp{i}=p{ncount(index(i))};
            
            %pp_center{i}=p_center{ncount(i)};
            
            %重新记录合并区域的比例
            pp_ratio(i)=(pp{i}(4)-pp{i}(3))/(pp{i}(2)-pp{i}(1));     
        end
        p=pp;%更新区域记录
        p_ratio=pp_ratio; %更新区域比例记录
        clear pp;clear pp_ratio; %清除部分变量
    end
end
k=length(p); %更新区域个数
%%%%%%%%%%%%%%合并结束%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%根据区域比例判断是否为车牌区域%%%%%%%%%%%%
m=1;T=0.6*max(p_ratio);%0.8参数需要调整
for i=1:k
    if(p_ratio(i)>=T&p_ratio(i)<20)
        p1{m}=p{i};
        m=m+1;
    end
end
p=p1;clear p1;
k=m-1;   %更新区域数
%%%%%%%%%%%判定结束%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%d=zeros(k+1,k+1);
%for i=1:k+1
%   for j=i+1:k+1
        %d(i,j)=sqrt((p_center{i}(1)-p_center{j}(1))^2+(p_center{i}(2)-p_center{j}(2))^2);
  %  end
%end
%说明:d用于存放第i,j个图像块中心点的距离;
%T=sqrt(height^2+width^2)/10;%阈值
%[x,y]=find(d>0&d<T); 
%for i=1:length(x)
%    p{x(i)}(1)=min(p{x(i)}(1),p{y(i)}(1));
%    p{x(i)}(2)=max(p{x(i)}(2),p{y(i)}(2));
%    p{x(i)}(3)=min(p{x(i)}(3),p{y(i)}(3));
%    p{x(i)}(4)=max(p{x(i)}(4),p{y(i)}(4));
%end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
toc                                  %计时结束
clear edge_IM3;clear x; clear y;     % 清空部分变量
%%%%%%%%%%%%%%%%显示
figure;
subplot(221);imshow(I);
subplot(222);imshow(BW2);
subplot(223);imshow(IM2);
subplot(224);imshow(IM3);
%%%%%%%%%%%%%%%%%显示
figure;
for i=1:k
    subplot(1,k,i);
    index=p{i};
    imshow(I(index(1)-2:index(2),index(3):index(4)));
end
if(k==1)
%     imwrite(I(index(1)-2:index(2),index(3):index(4)),'cp.jpg');
end
%存储车牌图像           
%%%%%%%%%%%%%%%%
figure;
I1=I.*uint8(IM3);imshow(I1)