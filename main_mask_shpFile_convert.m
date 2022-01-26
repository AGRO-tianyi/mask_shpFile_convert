
%   WRITTEN BY:  Tianyi Jia (email: ttianyi12@126.com)
%   RELEASED ON: 10 October, 2021

clc, clear, close all
%% parameters setting
prm.defaultDir = '.';  

prm.rpatchSize = 220;     % splitSize
prm.cpatchSize = 200;    

prm.maskSuffix = '_mask';

%% mainFunc
imgSplit(prm)
% imgMerge(prm)