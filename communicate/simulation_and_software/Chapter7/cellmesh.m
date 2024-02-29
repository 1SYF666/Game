% Program 7-4
%
% cellmesh.m
%
% This function sets meshs in a cell.	
%
% Programmed by F. Kojima
% Checked by H.Harada
%

function [meshnum, meshposition] =  cellmesh()

Fineness = 50; % parameter for mesh fineness
k = 1;
j = 0;
ds = sqrt(3.0) / Fineness;
xmesh = -0.5 * sqrt(3.0);
while xmesh < 0.5 * sqrt(3.0)
   xmesh = (k - 1) * ds - 0.5 * sqrt(3.0); 
   if xmesh < 0.0
      ymin = -xmesh/sqrt(3.0) - ds - 1.0; % lower line of a cell
      ymax = xmesh/sqrt(3.0) + 1.0; % upper line of a cell
   elseif xmesh == 0.0
      ymin = -1.0;
      ymax = 1.0;
   else
      ymin = xmesh/sqrt(3.0) - ds -1.0; % lower line of a cell
      ymax = -xmesh/sqrt(3.0) + 1.0; % upper line of a cell     
   end
   k= k + 1;
   ymesh = ymin;
   while ymesh < ymax
      ymesh = ymesh + ds;
      if ymesh > ymax
         break
      end
      j = j + 1;
      posi(j,1) = xmesh;
      posi(j,2) = ymesh; 
   end
end
meshnum = j;
meshposition = posi;

%******* end of file *********
