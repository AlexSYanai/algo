var WordMutation = function() { 
  function stringGen(target,allChars) {
    var temp = "";
    
    for(var i = 0; i < target.length; i++) {
      temp += allChars[Math.ceil(Math.random() * (allChars.length - 1))];
    }

    return temp;
  }

  function w(target,candidate) {
    var sum = 0;

    for (var i = 0; i < target.length; i++) {
      sum += Math.abs(target.charCodeAt(i) - candidate.charCodeAt(i));
    }

    return (Math.exp(sum / -10) * 100);
  }

  function mutationRate(target,candidate) {
    return (1.0 - Math.exp( -(100.0 - w(target,candidate)) / 400)).toPrecision(2);
  }

  function last(rates) {
    return rates[rates.length - 1];
  }

  function mutate(firstGen,popSize,rate,allChars) {
    var nextPop = [firstGen];

    for (var i = 0; i < popSize; i++) {
      var temp = "";

      for (var j = 0; j < firstGen.length; j++) {
        if (Math.random() <= rate) {
          temp += allChars[Math.floor(Math.random() * (allChars.length))];
        } else {
          temp += firstGen[j];
        }
      }

      nextPop.push(temp);
    }

    return nextPop;
  }

  function selectFittest(firstGen,target,nextPop) {
    var mostFit  = firstGen;
    var bestW    = 0;
    var currentW = w(target,firstGen);


    for (var k = 0; k < nextPop.length; k++) {
      if (w(target,nextPop[k]) > currentW) {
        var mostFit = nextPop[k];
      }
    }

    return mostFit;
  }

  function compareGens(firstGen,target,genCount,rates) {
    if (firstGen !== target) {
      console.log(genCount + " " + last(rates) + " " + w(target,firstGen) + " " + firstGen);  
    } else {
      var sumRates = 0;

      for (var n = 0; n < rates.length; n++) {
        sumRates += parseFloat(rates[n]);
      }

      console.log("\nNumber of Generations: " 
                  + genCount + "\n" 
                  + "Average mutation rate: " + (sumRates/rates.length) + "\n" 
                  + "Final Fitness: " + w(target,firstGen) + "\n" 
                  + "Final Generation: " + firstGen);  
    }
  }

  return {
    init: function(target) {
      var popSize  = 100; // Can change this for larger generation size => fewer iterations
      var rates    = [];
      var firstGen = "";
      var prevGen  = "";
      var nextPop  = [];
      var genCount = 1;
      var allChars = ["A", "B", "C", "D", "E", "F", "G", 
                      "H", "I", "J", "K", "L", "M", "N", 
                      "O", "P", "Q", "R", "S", "T", "U", 
                      "V", "W", "X", "Y", "Z", "a", "b", 
                      "c", "d", "e", "f", "g", "h", "i", 
                      "j", "k", "l", "m", "n", "o", "p", 
                      "q", "r", "s", "t", "u", "v", "w", 
                      "x", "y", "z", " "];

      firstGen = stringGen(target,allChars);

      while (firstGen !== target) {
        rates.push(mutationRate(target,firstGen));

        while (firstGen != prevGen) {
          console.log(genCount + " " + last(rates) + " " + w(target,firstGen) + " " + firstGen);  
          prevGen = firstGen;    
        }

        nextPop  = mutate(firstGen,popSize,last(rates),allChars);
        firstGen = selectFittest(firstGen,target,nextPop); 

        genCount++;
      }

      compareGens(firstGen,target,genCount,rates);
    }
  }
}();

WordMutation.init("This is a test phrase");