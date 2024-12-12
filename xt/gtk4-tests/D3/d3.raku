use Graph::TriangularGrid;
use JavaScript::D3;
 
my $g = Graph::TriangularGrid.new(4, 4);
my @highlight = ($g.vertex-list Z=> $g.vertex-degree).classify(*.value).map({ $_.value».key });
 
 
js-d3-graph-plot( $g.edges(:dataset),
    :@highlight,
    background => 'none', 
    edge-thickness => 3,
    vertex-size => 10,
    vertex-label-color => 'none',
    width => 1000,
    height => 300, 
    margins => 5,
    edge-color => 'SteelBlue',
    force => {charge => {strength => -300}, y => {strength => 0.2}, link => {minDistance => 4}}
)
