#% javascript
require.config({
     paths: {
     d3: 'https://d3js.org/d3.v7.min'
}});
 
require(['d3'], function(d3) {
     console.log(d3);
});
