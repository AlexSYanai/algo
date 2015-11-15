var World = (function() {
  function nature() {
    this.setConditions = function(initConditions) {
      this.popN       = initConditions.n;
      this.numBits    = initConditions.l;
      this.gens       = initConditions.gen;
      this.xoverRate  = initConditions.pc;
      this.mutRate    = initConditions.u;
    }

    this.getPop       = function() { return this.popN      },
    this.getNumBits   = function() { return this.numBits   },
    this.getGens      = function() { return this.gens      },
    this.getXoverRate = function() { return this.xoverRate },
    this.getMutRate   = function() { return this.mutRate   }
  }

  return {
    setAll: function() { return new nature }
  }
}());

function Chromosome(natEnviro, genes) {
  this.enviro = natEnviro;
  this.count  = 0;
  this.genes  = "";

  if(genes != undefined) { this.genes = genes }
}

Chromosome.prototype = {
  constructor: Chromosome,
  setGenes: function() {
    for(var l = 0; l < this.enviro.getNumBits(); l++) {
      this.genes += Math.floor(Math.random() + 0.5).toString();
    }
  },

  mutate: function() {
    var tempGene = ""
    for(i = 0; i < this.genes.length; i++) {
      if (this.genes[i] === "0") {
        tempGene += "0";
      } else {
        if (Math.random() <= this.enviro.getMutRate()) {
          tempGene += "0";
        } else {
          tempGene += "1";
        }
      }
    }
    this.genes = tempGene;
  },

  w: function() {
    return this.genes.match((/1/g) || []).length;
  },
}

function Nucleus(natEnviro, genome1, genome2) {
  this.enviro  = natEnviro;
  this.genome1 = genome1 || "";
  this.genome2 = genome2 || "";
  this.child1  = "";
  this.child2  = "";
}

Nucleus.prototype = {
  constructor: Nucleus,
  setXoverRegions: function(locus) {
    var locus = Math.ceil(Math.random() * (this.genome1.genes.length))
    
    var half1 = this.genome1.genes.substring(0,locus);
    var half2 = this.genome2.genes.substring(locus,this.genome2.genes.length);

    return (half1 + half2);
  },

  recombine: function() {
    xover1 = this.setXoverRegions();
    xover2 = this.setXoverRegions();
    this.child1 = new Chromosome(this.enviro, xover1);
    this.child2 = new Chromosome(this.enviro, xover2);

    return [this.child1, this.child2];
  }
}

function Population() {
  this.xsomes = [];
  this.genes  = [];
  this.wTotal = 0;
  this.wMax   = 0;
  this.wAvrg  = 0;
}

Population.prototype = {
  constructor: Population,

  setGen: function(natEnviro) {
    this.populate(natEnviro);
    this.getGenes(natEnviro);
    this.fitnessVals(natEnviro);
  },

  populate: function(natEnviro) {
    var xsomes1 = [];
    var k = 0;
    for(k = 0; k < natEnviro.getPop(); k++) {
      tempXsome = new Chromosome(natEnviro);
      tempXsome.setGenes();
      xsomes1.push(tempXsome);
    }

    this.xsomes = xsomes1;
  },

  getGenes: function(natEnviro) {
    var genes = [];

    for(i = 0; i < this.xsomes.length; i++) {
      genes.push(this.xsomes[i].genes);
    }

    this.genes = genes;
  },

  fitnessVals: function(natEnviro) {
    var tempTotal  = 0;
    var tempMax    = 0;

    for(var j = 0; j < this.xsomes.length; j++) {
      tempTotal += this.xsomes[j].w();
      if (this.xsomes[j].w() > tempMax) {
        tempMax = this.xsomes[j].w();
      }
    }

    this.wTotal = tempTotal;
    this.wMax   = tempMax;
    this.wAvrg  = tempTotal/this.xsomes.length;
  },

  getXsomes: function() { return this.xsomes },
  setXsomes: function(newXsomes) { 
    this.xsomes = newXsomes; 
  },

  count: function() {
    return this.xsomes.length;
  },
  
  selecti: function() {
    var total      = 0;
    var randSelect = Math.ceil(Math.random() * (this.wTotal));
    for(i = 0; i < this.xsomes.length; i++) {
      total += this.xsomes[i].w();
      if(total > randSelect || i == this.xsomes.length - 1) {
        this.xsomes = this.xsomes[i];
        return;
      }
    }
  }
}


var selection = function() {
  function analyze_crossover(fn1,fn2,natEnviro) {
    if (Math.random() <= natEnviro.getXoverRate()) {
      var nuc = new Nucleus(natEnviro,fn1,fn2);
      var children = nuc.recombine;
      return children;
    } else {
      return [fn1, fn2];
    }
  }

  function addOffspring(offspring,children,natEnviro) {
    if(natEnviro.getPop() % 2 === 0) {
      offspring.setXsomes(children);
    } else {
      offspring.setXsomes(children.genes[Math.floor(Math.random() * children.genes.length)]);
    }
  }

  function logFinal(prevGen,environment) {
    console.log("\n");
    for (var g = 0; g < prevGen.genes.length; g++) {
      if (g < 9) {
        console.log("N" + (g + 1) + ":  " + prevGen.genes[g]);
      } else {
        console.log("N" + (g + 1) + ": "  + prevGen.genes[g]);
      }
    }

    console.log(  "Generation:  " + environment.gens + " \n" 
                + "Avg Fitness: " + prevGen.wAvrg    + " \n" 
                + "Max Fitness: " + prevGen.wMax);
  }

  function runGenerations(natEnviro, prevGen) {
    var prevGen = prevGen;
    prevGen.setGen(natEnviro);
    
    for(var i = 0; i < natEnviro.getGens(); i++) {
      var offspring = new Population;
      offspring.setGen(natEnviro);

      while(offspring.getXsomes().length < prevGen.getXsomes().length) {
        var parent1 = prevGen.selecti();
        var parent2 = prevGen.selecti();
        var children = analyze_crossover(parent1, parent2, natEnviro);
        var child1   = children[0];
        var child2   = children[1];

        child1.mutate();
        child2.mutate();

        addOffspring(child1, child2, natEnviro);
      }

      console.log("Gen: " + i + " | " + "Avg: " + prevGen.wAvrg.toPrecision(4) + " | " + "Max: " + prevGen.wMax);
      prevGen = offspring;
    }

    logFinal(prevGen,environment);
  }

  return {
    init: function(initConditions) {
      environment = World.setAll();
      environment.setConditions(initConditions);
      previousGen = new Population;

      runGenerations(environment, previousGen);
    }
  }
}();

var initConditions = { n: 32, l: 64, gen: 1000, pc: 0.8, u: 0.04 };
selection.init(initConditions);