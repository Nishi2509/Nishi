//What if I ask you the following question — Give me an input string that outputs a SHA-256 hash that starts with 00000 . How will you do it?

const crypto = require('crypto');

function findHashWithPrefix(prefix){
  let input =0;
  while(true){
    let inputStr = input.toString();
    let hash = crypto.createHash('sha256').update(inputStr).digest('hex');

    if(hash.startsWith(prefix)){
      return {input:input, hash:hash};
    }
    input++;
  }
}

const result = findHashWithPrefix('00000');
console.log(`Input: ${result.input}`);
console.log(`Hash: ${result.hash}`);
