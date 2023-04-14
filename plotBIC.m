figure('Name','Number of phonation types');
plot(spec_num_clusters, BIC(1,:), 'Color','b', 'LineWidth', 2);
hold on
plot(spec_num_clusters, BIC(2,:), 'Color','r', 'LineWidth', 2);
hold on
plot(spec_num_clusters, BIC(3,:), 'Color','k', 'LineWidth', 2);
h = zeros(3,1);
%     h(1) = plot(num_clusters, BIC(spec_num_clusters==num_clusters), '*', 'MarkerSize', 10, 'MarkerEdgeColor', 'k', 'LineWidth', 2);
h(1) = plot(4, BIC(1,4), 'o', 'MarkerSize', 10, 'MarkerEdgeColor', 'b', 'LineWidth', 2);
h(2) = plot(3, BIC(2,3), '*', 'MarkerSize', 10, 'MarkerEdgeColor', 'r', 'LineWidth', 2);
h(3) = plot(2, BIC(3,2), 's', 'MarkerSize', 10, 'MarkerEdgeColor', 'k', 'LineWidth', 2);
xticks(spec_num_clusters)
xlabel('Number of phonation types')
ylabel('BIC')
ylim([160000, 210000]);
legend(h,'Estimated number for Male','Estimated number for Female','Estimated number for Children', 'Location','northeast')
set(gca, 'FontSize', 13)
hold off