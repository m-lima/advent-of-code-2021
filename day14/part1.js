const fs = require('fs');

class Polymer {
  polymer;

  constructor(polymer) {
    this.polymer = polymer;
  }

  mapPairs(fn) {
    let buffer = ''
    for (let i = 0; i < this.polymer.length - 1; i++) {
      buffer += fn(i, this.polymer[i], this.polymer[i+1]);
    }
    return new Polymer(buffer);
  }
}

const load = () => {
  let lines = fs.readFileSync('input.txt', 'utf8')
    .split('\n')
    .filter(l => l.length > 0)
    .reverse();
  let polymer = new Polymer(lines.pop());
  let insertions = new Map(lines.map(l => l.split(' -> ')));

  return [polymer, insertions];
};

const charCount = (string) => {
  return string.split('').reduce((a, c) => {
    a.set(c, (a.has(c) ? a.get(c) : 0) + 1);
    return a;
  }, new Map());
}

const minMax = (counts) => {
  let min = Number.MAX_VALUE;
  let max = Number.MIN_VALUE;

  for (let iter = counts.entries(), next = iter.next(); !next.done; next = iter.next()) {
    if (next.value[1] < min) {
      min = next.value[1];
    }
    if (next.value[1] > max) {
      max = next.value[1];
    }
  }

  return max - min;
}

let [polymer, insertions] = load();

for (let i = 0; i < 10; i++) {
  polymer = polymer.mapPairs((i, left, right) => {
    let middle = insertions.get(left + right);
    if (middle) {
      return i > 0 ? middle + right : left + middle + right;
    } else {
      return i > 0 ? right : left + right;
    }
  })
}

console.log(minMax(charCount(polymer.polymer)));
