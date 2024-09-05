const crypto = require('crypto');

function findNonce(input, prefix){
  let nonce = 0;
  while(true){
    // Concatenate input with the nonce
    let inputStr = input + nonce.toString();
    let hash = crypto.createHash('sha256').update(inputStr).digest('hex');

    if(hash.startsWith(prefix)){
      return {nonce: nonce, hash: hash};
    }
    nonce++;
  }
}

const input = "Dev => Karan | Rs 100 Karan => Darsh | Rs 10";
const result = findNonce(input, '00000'); // Adjust the prefix as needed (e.g., '00000' for 5 leading zeros)
console.log(`Nonce: ${result.nonce}`);
console.log(`Hash: ${result.hash}`);
