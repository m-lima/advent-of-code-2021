const fs = require('fs');

// Integer indexing speeds up ~25%
const hash = (left, right) => (left << 7) | right
const depthHash = (depth, left, right) => ((depth - 8) << 14) | hash(left, right)

const load = () => {
  let lines = fs.readFileSync('input.txt', 'utf8')
    .split('\n')
    .filter(l => l.length > 0)
    .reverse();
  let polymer = lines.pop();
  // CharCode operations speeds up ~25%
  let insertions =
    new Map(lines
      .map(l => l.split(' -> '))
      .map(([l, r]) => [hash(l.charCodeAt(0), l.charCodeAt(1)), r.charCodeAt(0)]));

  return [polymer, insertions];
};

// Using a global speeds up by ~5%
const [polymer, insertions] = load();

// Using cache simply obliterates any other optimization
const cache = new Map();

const toPairs = (string) => {
  let pairs = []
  for (let i = 0; i < string.length - 1; i++) {
    pairs.push([string[i], string[i + 1]])
  }
  return pairs;
}

// Passing a mutable map sppeds up ~60%
const combine = (left, right, depth, map) => {
  if (depth > 8) {
    const cached = cache.get(depthHash(depth, left, right));
    if (cached) {
      map = merge(map, cached);
      return;
    }
  }

  if (depth > 0) {
    let middle = insertions.get(hash(left, right));
    if (middle) {
      if (depth > 8) {
        let newMap = new Map();
        combine(left, middle, depth - 1, newMap);
        combine(middle, right, depth - 1, newMap);
        newMap.set(middle, newMap.get(middle) - 1);
        cache.set(depthHash(depth, left, right), newMap);
        map = merge(map, newMap);
      } else {
        combine(left, middle, depth - 1, map);
        combine(middle, right, depth - 1, map);
        map.set(middle, map.get(middle) - 1);
      }
      return;
    }
  }

  let mol = map.get(left);
  if (mol) {
    map.set(left, mol + 1);
  } else {
    map.set(left, 1);
  }
  mol = map.get(right);
  if (mol) {
    map.set(right, mol + 1);
  } else {
    map.set(right, 1);
  }
}

const merge = (acc, curr) => {
  for (let iter = curr.entries(), next = iter.next(); !next.done; next = iter.next()) {
    if (acc.has(next.value[0])) {
      acc.set(next.value[0], acc.get(next.value[0]) + next.value[1]);
    } else {
      acc.set(next.value[0], next.value[1]);
    }
  }
  return acc;
}

const initialCount = (string) => {
  return string
    .substr(1, string.length - 2)
    .split('')
    .map(l => new Map([[l.charCodeAt(0), -1]]))
    .reduce(merge, new Map());
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

const countChars = (pair) => {
  let map = new Map();
  combine(pair[0].charCodeAt(0), pair[1].charCodeAt(0), 40, map);
  return map;
}

console.log(minMax(toPairs(polymer).map(countChars).reduce(merge, initialCount(polymer))));
