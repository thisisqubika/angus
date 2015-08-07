var fs = require('fs');
var csv = require('fast-csv');

var data = { angus:[], grape:[], rails:[], sinatra:[] }
csv.fromPath("./angus.csv")
   .on("data", function(csvAngus){
      data.angus.push(csvAngus[3]);
   })
   .on("end", function(){
       console.log("Done Angus");
       console.log(data.angus.length)
       csv.fromPath("./grape.csv")
           .on("data", function(csvGrape){
              data.grape.push(csvGrape[3]);
           })
           .on("end", function(){
               console.log("Done Grape");
               csv.fromPath("./rails-api.csv")
                   .on("data", function(csvRails){
                      data.rails.push(csvRails[3]);
                   })
                   .on("end", function(){
                       console.log("Done Rails");
                       csv.fromPath("./sinatra.csv")
                           .on("data", function(csvSinatra){
                              data.sinatra.push(csvSinatra[3]);
                           })
                           .on("end", function(){
                              console.log("Done Sinatra");
                              fs.writeFile("../../public/data/jruby.json", JSON.stringify(data), function(err) {
                                  if(err) {
                                      console.log(err);
                                  } else {
                                      console.log("The file was saved!");
                                  }
                              });
                           });
                   });
           });
   });

