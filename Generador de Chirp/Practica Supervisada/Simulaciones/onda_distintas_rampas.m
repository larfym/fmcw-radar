%PS Andrés Agustín Cesana 
clc;
close all;
clear;
fs = 1000;
t = 0:2*pi/fs:2*pi;
M = length(t);
y = zeros(1,M);
n = zeros(1,M);
for i = 1 : M/2
    y(i) = cos(i*t(i));
    n(i) = i;
end
hold on
plot(t,y)
plot(t,n)
hold off