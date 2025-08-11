var data=[["lupinus","Achillea",1],
["microstictus","Arnica",1],
["robustior","Aster",1],
["metenuus","Calochortus",2],
["lupinus","Centaurea",1],
["microstictus","Centaurea",1],
["lupinus","Chrysothamnus",1],
["rivalis","Cirsium",1],
["lupinus","Clarkia",1],
["robustior","Coreopsis",3],
["metenuus","Dipsacus",2],
["lupinus","Epilobium",4],
["metenuus","Epilobium",1],
["microstictus","Epilobium",1],
["bimatris","Ericameria",11],
["lupinus","Ericameria",1],
["microstictus","Ericameria",1],
["robustior","Ericameria",1],
["semilupinus","Ericameria",1],
["microstictus","Erigeron",1],
["lupinus","Gaillardia",1],
["lupinus","Grindelia",5],
["robustior","Hebe",1],
["lupinus","Helenium",1],
["microstictus","Helenium",1],
["robustior","Helenium",1],
["lupinus","Helianthus",9],
["robustior","Helianthus",4],
["robustior","Heliopsis",4],
["lupinus","Hypochaeris",1],
["lupinus","Melilotus",1],
["microstictus","Monardella",1],
["lupinus","Quercus",4],
["lupinus","Rudbeckia",2],
["robustior","Rudbeckia",2],
["lupinus","Sidalcea",1],
["lupinus","Solidago",1],
["microstictus","Solidago",4],
["microstictus","Spiraea",1]]



 function sort(sortOrder){
                    return function(a,b){ return d3.ascending(sortOrder.indexOf(a),sortOrder.indexOf(b)) }
                  }
var color = {'Unlinked ':'#3366CC','lupinus':'#7FC97F','microstictus':'#BEAED4','robustior':'#FDC086','metenuus':'#FFFF99','rivalis':'#386CB0','bimatris':'#F0027F','semilupinus':'#BF5B17'};




var g1 = svg.append("g").attr("transform","translate(231,50)");
                         var bp1=viz.bP()
                         .data(data)
                         .value(d=>d[2])
                         .min(10)
                         .pad(1)
                         .height(400)
                         .width(200)
                         .barSize(35)
                         .fill(d=>color[d.primary])
.orient("vertical");

g1.call(bp1);g1.append("text")
                        .attr("x",-50).attr("y",-8)
                        .style("text-anchor","middle")
                        .text("Melissodes Species");
                        g1.append("text")
                        .attr("x", 250)
                        .attr("y",-8).style("text-anchor","middle")
                        .text("Aster Plants");
                        g1.append("text")
                        .attr("x",100).attr("y",-25)
                        .style("text-anchor","middle")
                        .attr("class","header")
                        .text("freq");

 g1.selectAll(".mainBars")
                        .on("mouseover",mouseover)
                        .on("mouseout",mouseout);

 g1.selectAll(".mainBars").append("text").attr("class","label")
                        .attr("x",d=>(d.part=="primary"? -34.4:35.6))
                        .attr("y",d=>+6)
                        .text(d=>d.key)
                        .attr("text-anchor",d=>(d.part=="primary"? "end": "start"));

 g1.selectAll(".mainBars").append("text").attr("class","perc")
                        .attr("x",d=>(d.part=="primary"? -177:198))
                        .attr("y",d=>+6)
                        .text(function(d){ return d3.format("0.0%")(d.percent)})
                        .attr("text-anchor",d=>(d.part=="primary"? "end": "start")); 

function mouseover(d){
bp1.mouseover(d);
                            g1.selectAll(".mainBars")
                            .select(".perc")
                            .text(function(d){ return d3.format("0.0%")(d.percent)});
}

                     function mouseout(d){
bp1.mouseout(d);
                            g1.selectAll(".mainBars")
                            .select(".perc")
                            .text(function(d){ return d3.format("0.0%")(d.percent)});
}


