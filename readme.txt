%//
%//
%// mask_shpFile_convert
%//
%// This tool is used to convert the binary image to .shp file (vector file). 
%// The converted .shp file can be used for label marking. It also supports 
%// splitting the binary image into patches and converts the corresponding 
%// binary image patch to .shp patch file at the same time. (see the imgSplit Func)
%//
%// The tool also supports restoring the modified .shp file to a binary image
%// (raster image). It also can automatically generate the entire binary image 
%// using the .shp patch file split by the imgSplit Func. (see the imgMerge Func)
%//
%// WRITTEN BY:  Tianyi Jia (email: ttianyi12@126.com)
%// RELEASED ON: 10 October, 2021