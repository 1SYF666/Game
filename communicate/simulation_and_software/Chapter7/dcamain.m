% Program 7-1
%
% dcamain.m
%
% Simulation program to realize DCA algorithm
%
% Programmed by F. Kojima
%

%%%%%%%%%%%%%%%% preparation part %%%%%%%%%%%%%%%%%%%%%%%%%%%%

cnedge = 20.0; % CNR on cell edge (dB)
cnirth = 15.0; % CNIR threshold (dB)
lambda = 6.0; % average call arrival rate (times/hour)
ht = 120.0; % average call holding time (second)
timestep = 10; % time step of condition check (second)
timeend = 5000; % time length of simulation (second)
chnum = 5; % number of channels per each base station

alpha = 3.5;          % pass loss factor
sigma = 6.5;          % standard deviation of shadowing

usernum = [5,10,15,20,25]; % number of users per cell

output = zeros(4,5); % output matrix

check = zeros(5,floor(timeend/timestep)); % matrix for transient statu

for parameter = 1:5
   
   rand('state',5);
   randn('state',1);
   
   user = usernum(parameter); %number of users per cell
   
   baseinfo = zeros(19, 2);
   %baseinfo(cell #, informations)
   %%%%%baseinfo(:, 1): x coordinates
   %%%%%baseinfo(:, 2): y coordinates
   
   userinfo = zeros(19, user, 15);
   %userinfo(cell #, user #, informations)
   %%%%%userinfo(:, :, 1): x axis
   %%%%%userinfo(:, :, 2): y axis
   %%%%%userinfo(:, :, 3): attenuation
   %%%%%userinfo(:, :, 4): usage 0->non-connected 1->connected
   %%%%%userinfo(:, :, 5): call termination time
   %%%%%userinfo(:, :, 6): allocated channel # 
   
   [baseinfo] = basest;
   [wrapinfo] = wrap;
   
   [meshnum, meshposition] = cellmesh;
   
   timenow = 0;
   blocknum = 0;
   forcenum = 0;
   callnum = 0;
   users = 0; % number of connected users
   
   %%%%%%%%%%%%%%%% main loop part %%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   while timenow < timeend
      
      callnumold = callnum;
      blocknumold = blocknum;
      forcenumold = forcenum;
      
      %finished calls
      for numcell = 1:19
         for numuser = 1:user
            if userinfo(numcell, numuser, 4) == 1 & userinfo(numcell, numuser, 5) < timenow
               userinfo(numcell, numuser, 4) = 0;
               users = users -1;
            end
         end
      end
      
      %reallocation check
      for numcell = 1:19
         for numuser = 1:user
            if userinfo(numcell, numuser,4) == 1
               reallo = 0; % flag
               cnirdb1 = 0.0;
               dwave = userinfo(numcell, numuser, 3);
               cn = power(10.0, cnedge/10.0) * dwave;
               uwave = 0.0;
               ch = userinfo(numcell, numuser, 6);
               for around = 2:7
                  othercell = wrapinfo(numcell, around);
                  for other = 1:user
                     if userinfo(othercell, other, 4) == 1 & userinfo(othercell, other, 6) == ch
                        userposi(1,1:2) = userinfo(othercell, other, 1:2);
                        here = baseinfo(numcell, :);
                        there = userposi - baseinfo(othercell, :) + baseinfo(around, :) + baseinfo(numcell, :);
                        uwave = uwave + dist(here, there, alpha)*shadow(sigma);
                     end
                  end
               end % around loop
               if uwave == 0
                  cnirdb = 10.0*log10(cn);
               else
                  cnirdb = 10.0*log10(1/(uwave/dwave+1/cn));
               end
               if cnirdb < cnirth
                  reallo = 1;
               end
               
               if reallo == 1 
                  userinfo(numcell, numuser, 4) = 0;
                  users = users -1;
                  succeed = 0;
                  cnirdb = 0.0;
                  for ch = 1:chnum
                     available = 1;
                     for other = 1:user
                        if userinfo(numcell, other, 4) == 1 & userinfo(numcell, other, 6) == ch
                           available = 0;
                        end
                     end
                     if available == 1
                        uwave = 0.0;
                        for around = 2:7
                           othercell = wrapinfo(numcell, around);
                           for other = 1:user
                              if userinfo(othercell, other, 4) == 1 & userinfo(othercell, other, 6) == ch
                                 userposi(1,1:2) = userinfo(othercell, other, 1:2);
                                 here = baseinfo(numcell, :);
                                 there = userposi - baseinfo(othercell, :) + baseinfo(around, :) + baseinfo(numcell, :);
                                 uwave = uwave + dist(here, there, alpha)*shadow(sigma);
                              end
                           end
                        end % around loop
                        if uwave == 0
                           cnirdb = 10.0*log10(cn);
                        else
                           cnirdb = 10.0*log10(1/(uwave/dwave+1/cn));
                        end
                     else
                        cnirdb = 0.0;
                     end
                     if cnirdb >= cnirth
                        succeed = 1;
                        users = users + 1;
                        userinfo(numcell, numuser, 4) = 1;
                        userinfo(numcell, numuser, 6) = ch;
                        break
                     end
                  end % ch loop
                  if succeed == 0
                     forcenum = forcenum + 1;
                  end
               end % reallo == 1
            end % connected (need to be checked)
         end % user loop
      end % cell loop
      
      %new call arrival
      for numcell = 1:19
         for numuser = 1:user
            if userinfo(numcell, numuser, 4) == 0 & rand <= lambda*timestep/3600
               callnum = callnum + 1;
               mesh = floor(meshnum.*rand) +1;
               while mesh > meshnum
                  mesh = floor(meshnum.*rand) +1;
               end
               userinfo(numcell, numuser, 1:2) = baseinfo(numcell, :) + meshposition(mesh, :);
               succeed = 0; % flag
               cnirdb = 0.0;
               userposi(1,1:2) = userinfo(numcell, numuser, 1:2);
               here = baseinfo(numcell,:);
               there = userposi;
               dwave = dist(here, there, alpha) * shadow(sigma);
               cn = power(10.0, cnedge/10.0) * dwave;
               for ch = 1:chnum
                  available = 1;
                  for other = 1:user
                     if userinfo(numcell, other, 4) == 1 & userinfo(numcell, other, 6) == ch
                        available = 0;
                     end
                  end
                  if available == 1
                     
                     uwave = 0.0;
                     for around = 2:7
                        othercell = wrapinfo(numcell, around);
                        for other = 1:user
                           if userinfo(othercell, other, 4) == 1 & userinfo(othercell, other, 6) == ch
                              userposi(1,1:2) = userinfo(othercell, other, 1:2);
                              here = baseinfo(numcell, :);
                              there = userposi - baseinfo(othercell, :) + baseinfo(around, :) + baseinfo(numcell, :);
                              uwave = uwave + dist(here, there, alpha)*shadow(sigma);
                           end
                        end
                     end % around loop
                     if uwave == 0
                        cnirdb = 10.0*log10(cn);
                     else
                        cnirdb = 10.0*log10(1/(uwave/dwave+1/cn));
                     end
                  else
                     cnirdb = 0.0;
                  end
                  if cnirdb >= cnirth
                     succeed = 1;
                     users = users + 1;
                     userinfo(numcell, numuser, 3) = dwave;
                     userinfo(numcell, numuser, 4) = 1;
                     userinfo(numcell, numuser, 5) = timenow + holdtime(ht);
                     userinfo(numcell, numuser, 6) = ch;
                     break
                  end
               end % ch loop
               if succeed == 0
                  blocknum = blocknum + 1;
               end
            end % new call
         end % user loop
      end % cell loop
      
      fprintf('%d\t%d\t%d\t%d\t%e\n',parameter,timenow,callnum-callnumold,blocknum-blocknumold,blocknum/callnum);
      check(parameter,timenow/timestep+1) = blocknum/callnum;
      check2(parameter,timenow/timestep+1) = forcenum/(callnum-blocknum);
      
      timenow = timenow + timestep;
   end %while loop
   
   %%%%%%%%%%%%%%%% output part %%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   output(1,parameter) = callnum;
   output(2,parameter) = blocknum;
   output(3,parameter) = blocknum/callnum;
   output(4,parameter) = forcenum/(callnum-blocknum);
end %parameter loop

fid = fopen('data.txt','w');
fprintf(fid,'UserNumber\t');
fprintf(fid,'%g\t%g\t%g\n', usernum(1,:));
fprintf(fid,'CallNumber\t');
fprintf(fid,'%g\t%g\t%g\n', output(1,:));
fprintf(fid,'BlockNumber\t');
fprintf(fid,'%g\t%g\t%g\n', output(2,:));
fprintf(fid,'BlockingProb. \t');
fprintf(fid,'%g\t%g\t%g\n', output(3,:));
fprintf(fid,'ForcedTerminationProb. \t');
fprintf(fid,'%g\t%g\t%g\n', output(4,:));
fclose(fid);

%******* end of file *********
