[p,v,c,m]=mgstat('ex15.cmd');
subplot(1,2,2);imagesc(v{1});axis image;title('Variance')
subplot(1,2,1);imagesc(p{1});axis image;title('Prediction')
