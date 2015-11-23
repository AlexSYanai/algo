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

  if (genes !== undefined) { this.genes = genes }
}

Chromosome.prototype = {
  constructor: Chromosome,
  setGenes: function() {
    for (var i = 0; i < this.enviro.getNumBits(); i++) {
      this.genes += Math.floor(Math.random() + 0.5).toString();
    }
  },

  mutate: function() {
    var tempGene = "";

    for ( var i = 0; i < this.genes.length; i++) {
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
  }
};

function Nucleus(natEnviro, genome1, genome2) {
  this.enviro  = natEnviro;
  this.genome1 = genome1 || "";
  this.genome2 = genome2 || "";
  this.child1  = "";
  this.child2  = "";
}

Nucleus.prototype = {
  constructor: Nucleus,
  setXoverRegions: function() {
    var locus = Math.ceil(Math.random() * (this.genome1.count()));
    
    var half1 = this.genome1.genes.substring(0,locus);
    var half2 = this.genome2.genes.substring(locus,this.genome2.count());

    return (half1 + half2);
  },

  recombine: function() {
    var xover1  = this.setXoverRegions();
    var xover2  = this.setXoverRegions();

    this.child1 = new Chromosome(this.enviro, xover1);
    this.child2 = new Chromosome(this.enviro, xover2);

    return [this.child1, this.child2];
  }
};

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

    for (var i = 0; i < natEnviro.getPop(); i++) {
      tempXsome = new Chromosome(natEnviro);
      tempXsome.setGenes();
      xsomes1.push(tempXsome);
    }

    this.xsomes = xsomes1;
  },

  getGenes: function(natEnviro) {
    var genes = [];

    for (var i = 0; i < this.xsomes.length; i++) {
      genes.push(this.xsomes[i].genes);
    }

    this.genes = genes;
  },

  fitnessVals: function(natEnviro) {
    var tempTotal  = 0;
    var tempMax    = 0;

    for (var i = 0; i < this.xsomes.length; i++) {
      tempTotal += this.xsomes[i].w();
      if (this.xsomes[i].w() > tempMax) {
        tempMax = this.xsomes[i].w();
      }
    }

    this.wTotal = tempTotal;
    this.wMax   = tempMax;
    this.wAvrg  = tempTotal/this.xsomes.length;
  },

  selectBest: function() {
    var wTotal     = 0;
    var randSelect = Math.ceil(Math.random() * (this.wTotal));

    for (var i = 0; i < this.xsomes.length; i++) {
      wTotal += this.xsomes[i].w();
      if (wTotal > randSelect || i == this.xsomes.length - 1) {
        this.xsomes = this.xsomes[i];
        return;
      }
    }
  },

  count:     function() { return this.xsomes.length; },
  getXsomes: function() { return this.xsomes },
  setXsomes: function(newXsomes) { 
    this.xsomes = newXsomes; 
  }
}

var selection = function() {
  function analyze_crossover(fn1,fn2,natEnviro) {
    if (Math.random() <= natEnviro.getXoverRate()) {
      var nucleus  = new Nucleus(natEnviro,fn1,fn2);
      var children = nucleus.recombine;
      
      return children;
    } else {
      return [fn1, fn2];
    }
  }

  function addOffspring(offspring,children,natEnviro) {
    if (natEnviro.getPop() % 2 === 0) {
      offspring.setXsomes(children);
    } else {
      offspring.setXsomes(children.genes[Math.floor(Math.random() * children.genes.length)]);
    }
  }

  function logFinal(firstGen,prevGen,environment) {
    console.log("\n");

    for (var i = 0; i < prevGen.count(); i++) {
      if (i < 9) {
        console.log("N" + (i + 1) + ":  " + prevGen.genes[i]);
      } else {
        console.log("N" + (i + 1) + ": "  + prevGen.genes[i]);
      }
    }

    console.log(
                "********************* "           + "\n" +
                "Generation:  " + 1                + "\n" +
                "Avg Fitness: " + firstGen.wAvrg   + "\n" +
                "Max Fitness: " + firstGen.wMax    + "\n" +
                "********************* "           + "\n" +
                "Generation:  " + environment.gens + "\n" +
                "Avg Fitness: " + prevGen.wAvrg    + "\n" +
                "Max Fitness: " + prevGen.wMax     + "\n" +
                "********************* ");
  }

  function runGenerations(natEnviro, prevGen) {
    var firstGen = prevGen;
    var prevGen  = prevGen;
    prevGen.setGen(natEnviro);
    
    for (var i = 0; i < natEnviro.getGens(); i++) {
      var offspring = new Population;
      offspring.setGen(natEnviro);

      while (offspring.count() < prevGen.count()) {
        var parent1  = prevGen.selectBest();
        var parent2  = prevGen.selectBest();
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

    logFinal(firstGen,prevGen,environment);
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