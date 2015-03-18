$(function($){
  var rubyBenchmark = new Benchmark('.SectionBenchmark-chart-ruby-svg-container');

  rubyBenchmark.default = {
                            yAxis: { orient: 'left',
                                     domain: [0, 200] },
                            xAxis: { orient: 'bottom',
                                     domain: [0, 1000] },
                            margin: {
                                      top: 40.5,
                                      right: 40.5,
                                      bottom: 50.5,
                                      left: 60.5 },
                            height: 0,
                            width: 0,
                          };

  rubyBenchmark.setSize(300, 400);
  rubyBenchmark.createSvg();
  rubyBenchmark.createTitle('Ruby');
  rubyBenchmark.createAxisX();
  rubyBenchmark.createAxisY();


  $.get("/data/ruby.json",function(){}).done(function(data) {
    var dataAngus = [];
    var dataRails = [];
    var dataGrape = [];
    var dataSinatra = [];

    for (var i = 0; i < data['angus'].length; i++) {
      console.log(i);
      dataAngus.push([data['angus'][i], i])
    };
    for (var i = 0; i < data['grape'].length; i++) {
      dataGrape.push([data['grape'][i], i])
    };

    for (var i = 0; i < data['sinatra'].length; i++) {
      dataSinatra.push([data['sinatra'][i], i])
    };
    for (var i = 0; i < data['rails'].length; i++) {
      dataRails.push([data['rails'][i], i])
    };

    rubyBenchmark.createLine(dataGrape, 'grape');
    rubyBenchmark.createLine(dataAngus, 'angus');
    rubyBenchmark.createLine(dataRails, 'rails');
    rubyBenchmark.createLine(dataSinatra, 'sinatra');
  })


  var jrubyBenchmark = new Benchmark('.SectionBenchmark-chart-jruby-svg-container');

  jrubyBenchmark.default = {
                            yAxis: { orient: 'left',
                                     domain: [0, 1600] },
                            xAxis: { orient: 'bottom',
                                     domain: [0, 1000] },
                            margin: {
                                      top: 40.5,
                                      right: 40.5,
                                      bottom: 50.5,
                                      left: 60.5 },
                            height: 0,
                            width: 0
                          };

  jrubyBenchmark.setSize(300, 400);
  jrubyBenchmark.createSvg();
  jrubyBenchmark.createTitle('JRuby');
  jrubyBenchmark.createAxisX();
  jrubyBenchmark.createAxisY();


  $.get("/data/jruby.json",function(){}).done(function(data) {
    var dataAngus = [];
    var dataRails = [];
    var dataGrape = [];
    var dataSinatra = [];

    for (var i = 0; i < data['angus'].length; i++) {
      console.log(i);
      dataAngus.push([data['angus'][i], i])
    };
    for (var i = 0; i < data['grape'].length; i++) {
      dataGrape.push([data['grape'][i], i])
    };

    for (var i = 0; i < data['sinatra'].length; i++) {
      dataSinatra.push([data['sinatra'][i], i])
    };
    for (var i = 0; i < data['rails'].length; i++) {
      dataRails.push([data['rails'][i], i])
    };

    jrubyBenchmark.createLine(dataGrape, 'grape');
    jrubyBenchmark.createLine(dataAngus, 'angus');
    jrubyBenchmark.createLine(dataRails, 'rails');
    jrubyBenchmark.createLine(dataSinatra, 'sinatra');
  })

});



var Benchmark = function(selector) {

  var self = {};
  var svg;

  self.default = {
                    yAxis: { orient: 'left',
                             domain: [0, 3000] },
                    xAxis: { orient: 'bottom',
                             domain: [0, 1000] },
                    margin: {
                              top: 40.5,
                              right: 40.5,
                              bottom: 50.5,
                              left: 60.5 },
                    height: 0,
                    width: 0
                  };

  self.setSize = function(height, width) {
    console.log(height, width);
    self.default.height = height;
    self.default.width  = width;
  }

  self.calcHeight = function(){
    var calc =  {}
    calc.max = self.default.height + self.default.margin.top + self.default.margin.bottom,
    calc.min = self.default.height - self.default.margin.top - self.default.margin.bottom

    return calc;
  }

  self.calcWidth = function(){
    var calc =  {}
    calc.max = self.default.width + self.default.margin.left + self.default.margin.right,
    calc.min = self.default.width - self.default.margin.left - self.default.margin.right

    return calc;
  }


  self.getX = function() {
    var x = d3.scale.linear()
              .domain(self.default.xAxis.domain)
              .range([0, self.calcWidth().min]);
    return x
  }

  self.getY = function() {
    var y = d3.scale.linear()
              .domain(self.default.yAxis.domain)
              .range([self.calcHeight().min, 0]);
    return y;
  }

  self.getAxisX = function(){
    var xAxis = d3.svg.axis()
                  .scale(self.getX())
                  .orient(self.default.xAxis.orient);

    return xAxis;
  }

  self.getAxisY = function(){
    var yAxis = d3.svg.axis()
                  .scale(self.getY())
                  .orient(self.default.yAxis.orient);

    return yAxis;
  }

  self.createSvg = function(){
    var translate = "translate(" + self.default.margin.left +
                             "," + self.default.margin.top + ")";

    svg = d3.select(selector).append("svg")
            .attr("width", self.calcWidth().max)
            .attr("height", self.calcHeight().max)
            .append("g")
            .attr("class", "g-container")
            .attr("transform",  translate);
  }

  self.createTitle = function(title){
    svg.append("text")
       .attr("transform", "translate(110, 0)")
       .attr("class", "benchmark-title")
       .attr("x", 6)
       .attr("dx", ".71em")
       .text(title);
  }

  self.createAxisX = function(){
    var xAxis = self.getAxisX();
    svg.append("g")
         .attr("class", "axis axis--x")
         .attr("transform", "translate(0," + (self.calcHeight().min + 10) + ")")
         .call(xAxis)
       .append("text")
         .attr("transform", "translate(250, -10)")
         .attr("class", "title")
         .attr("x", 6)
         .attr("dx", ".71em")
         .text("Request")
  }

  self.createAxisY = function(){
    var yAxis = self.getAxisY();
    svg.append("g")
       .attr("class", "axis axis--y")
       .attr("transform", "translate(-10, 0)")
       .call(yAxis)
       .append("text")
        .attr("class", "title")
        .attr("transform", "translate(10, 90) rotate(-90)")
        .attr("y", 2)
        .attr("dy", ".51em")
        .text("Response time (ms)");
  }

  self.createLine = function(dataArry, styleClass){
    var styleClass = "line " + styleClass;

    var x = self.getX();
    var y = self.getY();

    var line = d3.svg.line()
                 .x(function(d) { return x(d[1]); })
                 .y(function(d) { return y(d[0]); })
                 .interpolate("basis");

    svg.append("path")
       .datum(dataArry)
       .attr("class", styleClass)
       .attr("d", line);
  }

  return self;
}
