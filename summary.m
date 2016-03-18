% generates a summary of all the fields
% handle class
classdef summary < handle
	properties
		colnames
		cvals
		pvals
		value
	end

	methods
		% initialize
		function m = summary(ntimes)

			m.colnames = {'nx','ny','nt','nit','gtm'...
				'Price','Change','Ratio',...
				'Delta_x','Change','Ratio',...
				'Delta_y','Change','Ratio',...
				'Gamma_x','Change','Ratio',...
				'Gamma_y','Change','Ratio',...
				'FBnd','Change','Ratio',...
				'Cond','Ratio',...
				'NormInv','Ratio'};

			% if additional tab needed
			m.cvals = { '','','','','',...
				'\t','\t','',...
				'\t','\t','',...
				'\t','\t','',...
				'\t','\t','',...
				'\t','\t','',...
				'\t','\t','',...
				'','','',''};

			m.pvals = { '%i','%i','%i','%i','%i',...
				'%6.6f','%6.6f','%2.2f',... % price
				'%6.6f','%6.6f','%2.2f',... % delta_x
				'%6.6f','%6.6f','%2.2f',... % delta_y
				'%6.6f','%6.6f','%2.2f',... % gamma_x
				'%6.6f','%6.6f','%2.2f',... % gamma_y
				'%6.6f','%6.6f','%2.2f',... % fb
				'%6.0f','%2.2f','%6.0f','%2.2f',... % cond,norm
				};
			m.value = zeros(ntimes,length(m.colnames));
		end

		% updates after each grid
		function update(m,uj1,Am,Nm,Gm,Aim)
			% monotonic time steps
			gtm = gtmf(Gm.gt);

			% determine value
			uv = intp(uj1,Gm);

			Adx = kron(Am.A1x,Am.Iy) + Am.Ab;
			dxv = intp(Adx*uj1,Gm);

			Ady = kron(Am.Ix,Am.A1y) + Am.Ab;
			dyv = intp(Ady*uj1,Gm);

			Agx = kron(Am.A2x,Am.Iy) + Am.Ab;
			gxv = intp(Agx*uj1,Gm);

			Agy = kron(Am.Ix,Am.A2y) + Am.Ab;
			gyv = intp(Agy*uj1,Gm);

			% fbv = 0;
			f = DirechletBC(Gm.gx,Gm.gy,0);
			fbv = fbc(uj1,f,Gm);

			if (Nm.ni<=3)
				condA = cond(full(Aim),Inf);
				normA = norm(full(Aim)^-1,Inf);
			else
				condA = 0;
				normA = 0;
			end

			% change/ratios calculated at the end
			m.value(Nm.ni,:) = [Nm.nx,Nm.ny,Nm.nt,Nm.nit,gtm,...
				uv,0,0,dxv,0,0,dyv,0,0,gxv,0,0,gyv,0,0,...
				fbv,0,0,condA,0,normA,0];

			% print values at points of interest
			intp_v(m,uj1,Gm);
		end

		function print_cols(m,cols)
			% print column names
			for j = cols
				fprintf(['%s',cell2mat(m.cvals(j)),'\t'], ...
					cell2mat(m.colnames(j)));
			end
			fprintf('\n');

			% print values
			for i = 1:size(m.value,1)
				for j = cols
					fprintf([cell2mat(m.pvals(j)),'\t'], ...
						m.value(i,j));
				end
				fprintf('\n');
			end

			fprintf('\n');

		end

		% prints results
		function print(m,Display)
			global PDEname Uname RbName PenaltyName Unift;
			global xp yp T Gdno Unift;
			disp([PDEname,', u = ',Uname, ', ',...
				 RbName,', ',PenaltyName]);
			disp(['Gdno: ',int2str(Gdno),...
				', Unift: ',int2str(Unift), ', xp: ', ...
				num2str(xp), ', yp: ', num2str(yp)]);

			% get change/ratio
			% omit first 4 and last 4 columns
			for j0 = 1:(length(m.colnames) - 8)/3
				j = (j0-1)*3 + 6;
				m.value(:,j+1:j+2) = chg( m.value(:,j), j0);
			end
			% get ratio of matrix cond and norm
			for j = length(m.colnames)-2:2:length(m.colnames)
				m.value(:,j) = ratio(m.value(:,j-1));
			end

			print_cols(m,1:8); % grid and price
			if Display
				print_cols(m,9:14); % deltas
				print_cols(m,15:20); % gammas
				print_cols(m,21:27); % fb,cond,norm
			end
		end

		% plot the final surface
		function plot(m,uj1,Gm,xmax,ymax)
			figure;
			mx = length(Gm.gx); my = length(Gm.gy);
			um = reshape(uj1,my,mx);

			switch nargin
			case {5}
				indx = Gm.gx<xmax; indy = Gm.gy<ymax;
			otherwise
				indx = 1:mx; indy = 1:my;
			end
			mesh(Gm.gx(indx),Gm.gy(indy),um(indy,indx));
			xlabel('Asset Price'); ylabel('Volatility');
			zlabel('Option Price');
		end

		% plot the interior surface
		function plot_int(m,uj1,Gm,xmax,ymax)
			nx = length(Gm.gx);
			ny = length(Gm.gy);
			v = reshape(uj1,length(Gm.gy),length(Gm.gx));
			gx = Gm.gx(2:nx-1); gy = Gm.gy(2:ny-1);
			v = v(2:ny-1,2:nx-1);

			switch nargin
			case {5}
				indx = gx<=xmax; indy = gy<=ymax;
			otherwise
				indx = 1:nx-2; indy = 1:ny-2;
			end
			figure;
			mesh(gx(indx),gy(indy),v(indy,indx));
			xlabel('Asset Price'); ylabel('Volatility');
		end

		% plot the surface of greeks
		% only plot the interior points
		function plot_greeks(m,uj1,Gm,Am,xm,ym)
			global Smax ymax;
			switch nargin
			case {6}
				% nothing
			otherwise
				xm = Smax; ym = ymax;
			end

			% Adx = kron(Am.A1x,Am.Iy) + Am.Ab;
			% plot_int(m,Adx*uj1,Gm,xm,ym);
			% zlabel('Ux');

			% Ady = kron(Am.Ix,Am.A1y) + Am.Ab;
			% plot_int(m,Ady*uj1,Gm,xm,ym);
			% zlabel('Uy');

			Agx = kron(Am.A2x,Am.Iy) + Am.Ab;
			plot_int(m,Agx*uj1,Gm,xm,ym);
			zlabel('Uxx');

			Agy = kron(Am.Ix,Am.A2y) + Am.Ab;
			plot_int(m,Agy*uj1,Gm,xm,ym);
			zlabel('Uyy');
		end

		% plot the interior cross section in the x-dir
		% no-interpolation, use closest point of y
		function plot_csx(m,uj1,Gm,yv)
			nx = length(Gm.gx); ny = length(Gm.gy);
			ujm = reshape(uj1,ny,nx);

			figure; hold on;

			Legend=cell(length(yv),1);
			
			for i = 1:length(yv)
				yp = yv(i);
				[~,yind] = min(abs(Gm.gy-yp));
				y = Gm.gy(yind);

				plot(Gm.gx(2:nx-1),ujm(2:nx-1,yind));
				Legend{i} = num2str(y);
			end
			legend(Legend);
			hold off;
		end

		function plot_greeks_csx(m,uj1,Gm,Am,yv)
			% Adx = kron(Am.A1x,Am.Iy) + Am.Ab;
			% plot_csx(m,Adx*uj1,Gm,yp);

			% Ady = kron(Am.Ix,Am.A1y) + Am.Ab;
			% plot_csx(m,Ady*uj1,Gm,yp);

			Agx = kron(Am.A2x,Am.Iy) + Am.Ab;
			plot_csx(m,Agx*uj1,Gm,yv);

			Agy = kron(Am.Ix,Am.A2y) + Am.Ab;
			plot_csx(m,Agy*uj1,Gm,yv);
		end

		function plot_fb(m,uj1,Gm,xmax,ymax)
			global tol;
			f = DirechletBC(Gm.gx,Gm.gy,0);
			mx = length(Gm.gx); my = length(Gm.gy);
			t = reshape(uj1-f-tol>0,my,mx);
			ind = zeros(mx,1);

			% optional inputs
			switch nargin
			case {5}
				indx = Gm.gx<xmax; indy = Gm.gy<ymax;
			otherwise
				indx = 1:mx; indy = 1:my;
			end

			for i = 1:my
				ind(i) = find(t(i,:),1);
			end
			figure;
			% plot(Gm.gx(ind),Gm.gy);
			hold on;
			um = reshape(uj1,length(Gm.gy),length(Gm.gx));
			mesh(Gm.gx(indx),Gm.gy(indy),um(indy,indx));

			indu = (ind'-1)*my+(1:mx);
			plot3(Gm.gx(ind(indy)),Gm.gy(indy),...
				uj1(indu(indy)),'LineWidth',5);
			hold off;
			xlabel('Asset Price'); ylabel('Volatility');
			zlabel('Option Price');
		end

		% surface of free boundary
		function mesh_fb(m,ucomp,Gm)
			global tol K;

			f = DirechletBC(Gm.gx,Gm.gy,0);
			mx = length(Gm.gx); my = length(Gm.gy);
			mt = length(Gm.gt);
			K_ind = find(Gm.gx>K,1);

			ind = zeros(my,1);
			fb = zeros(my,mt);

			for j = 1:mt
				u = ucomp(:,j);
				t = reshape(u-f-tol>0,my,mx);

				for i = 1:my
					ftmp = find(t(i,:),1);
					if isempty(ftmp); ftmp = K_ind; end;
					ind(i) = ftmp;
				end
				fb(:,j) = Gm.gx(ind);
			end
			figure;
			mesh(Gm.gt,Gm.gy,fb);
			xlabel('Time tau'); ylabel('Volatility');
			zlabel('Free Boundary');
		end

		function intp_v(m,uj1,Gm)
			xv = Gm.xv; yv = Gm.yv;
			lx = length(xv); ly = length(yv);
			uv = zeros(lx,ly);
			mx = length(Gm.gx);
			my = length(Gm.gy);
			mt = length(Gm.gt);

			fprintf('Grid nx=%i,ny=%i,nt=%i \n',mx,my,mt);
			for j = 1:ly
				for i = 1:lx
					Gm.x = xv(i); Gm.y = yv(j);
					uv(i,j) = intp(uj1,Gm);
					fprintf('%6.6f \t',uv(i,j));
				end
				fprintf('\n');
			end
		end

	end % end methods
end % end class

% interpolation at points given grid
function [up] = intp(uj1,Gm)
	gx = Gm.gx;
	gy = Gm.gy;
	x = Gm.x;
	y = Gm.y;

	mx = length(gx); my = length(gy);
	uj1m = reshape(uj1,my,mx);
	ix = find(gx>x,1); iy = find(gy>y,1);

	um = uj1m(iy-1:iy,ix-1:ix);
	hx = gx(ix)-gx(ix-1); hy = gy(iy)-gy(iy-1);
	dx = 1-abs(gx(ix-1:ix)-x)/hx; dy = 1-abs(gy(iy-1:iy)-y)/hy;
	up = dy * um * dx';
end

% interpolation of a vector of u(x)
function [uv] = intp_x(uj1,Gm)
	gx = Gm.gx;
	gy = Gm.gy;
	y = Gm.y;

	mx = length(gx); my = length(gy);
	uj1m = reshape(uj1,my,mx);
	iy = find(gy>y,1);

	um = uj1m(iy-1:iy,:);
	hy = gy(iy)-gy(iy-1);
	dy = 1-abs(gy(iy-1:iy)-y)/hy;
	uv = dy * um;
end

% find the free boundary
function fb = fbc(uj1,f,Gm)
	global tol;
	uv = intp_x(uj1,Gm);
	fv = intp_x(f,Gm);
	ind = find(uv-fv-tol>0,1);
	fb = Gm.gx(ind);
end

% return change and ratio as 2 columns
% vec is a column vector
function [vec3] = chg(vec,j0)
	global xp yp T OptionType;

	n = length(vec);

	% only return trueval for price for now
	if (j0==1) & (OptionType==0)
		vec1 = abs(vec - EuroRb(xp,yp,T));
	else
		vec1 = [0;vec(2:n) - vec(1:n-1)];
	end

	vec2 = vec1(1:n-1) ./ vec1(2:n);
	vec2(isnan(vec2) | isinf(vec2)) = 0;
	vec3 = [vec1 , [0;vec2]];
end

% return the ratio as one vector
function [vec1] = ratio(vec)
	n = length(vec);
	vec1 = [0; vec(2:n) ./ vec(1:n-1)];
end

function [gtm] = gtmf(gridt)
	mt = length(gridt);
	ht = gridt(2:mt) - gridt(1:mt-1);
	gtm = min(ht(2:mt-2) >= ht(1:mt-3));
end

